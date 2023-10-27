{config, lib, pkgs, ...}:

let
  container_name = "llng-handler";
  container_description = "Enables authentication handling container";
  container_image_registry = "docker.io";
  container_image_name = "tiredofit/lemonldap";
  container_image_tag = "latest";
  cfg = config.host.container.${container_name};
  hostname = config.host.network.hostname;
  activationScript = "system.activationScripts.docker_${container_name}";
in
  with lib;
{
  options = {
    host.container.${container_name} = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = container_description;
      };
      image = {
        name = mkOption {
          default = container_image_name;
          type = with types; str;
          description = "Image name";
        };
        tag = mkOption {
          default = container_image_tag;
          type = with types; str;
          description = "Image tag";
        };
        registry = {
          host = mkOption {
            default = container_image_registry;
            type = with types; str;
            description = "Image Registry";
          };
        };
      };
      logship = mkOption {
        default = "false";
        type = with types; str;
        description = "Enable monitoring for this container";
      };
      monitor = mkOption {
        default = "false";
        type = with types; str;
        description = "Enable monitoring for this container";
      };
    };
  };

  config = mkIf cfg.enable {
    system.activationScripts."docker_${container_name}" = ''
      if [ ! -d /var/local/data/_system/${container_name}/logs ]; then
          mkdir -p /var/local/data/_system/${container_name}/logs
          ${pkgs.e2fsprogs}/bin/chattr +C /var/local/data/_system/${container_name}/logs
      fi
    '';

    systemd.services."docker-${container_name}" = {
      serviceConfig = {
        StandardOutput = "null";
        StandardError = "null";
      };
    };

    virtualisation.oci-containers.containers."${container_name}" = {
      image = "${cfg.image.name}:${cfg.image.tag}";
      labels = {
        "traefik.enable" = "true";
        "traefik.http.routers.${hostname}-${container_name}.rule" = "Host(`${hostname}.handler.auth.${config.host.network.domainname}`)";
        "traefik.http.services.${hostname}-${container_name}.loadbalancer.server.port" = "80";
      };
      volumes = [
        "/var/local/data/_system/${container_name}/logs:/www/logs"
      ];
      environment = {
      "TIMEZONE" = "America/Vancouver";
      "CONTAINER_NAME" = "${hostname}-${container_name}";
      "CONTAINER_ENABLE_MONITORING" = cfg.monitor;
      "CONTAINER_ENABLE_LOGSHIPPING" = cfg.logship;

      "DOMAIN_NAME" = config.host.network.domainname;
      "HANDLER_HOSTNAME" = "${hostname}.handler.auth.${config.host.network.domainname}";
      "HANDLER_ALLOWED_IPS"= "common_env";

      "CONFIG_TYPE=REST";
      "REST_HOST" = "common_env";
      "REST_USER" = "host_env";
      "REST_PASS" = "host_env";
      };
      environmentFiles = [

      ];
      extraOptions = [
        "--memory=512M"
        "--network=proxy"
        "--network=services"
        "--network-alias=${hostname}-${container_name}"
      ];

      autoStart = mkDefault true;
      log-driver = mkDefault "local";
      login = {
        registry = cfg.image.registry.host;
      };
    };
  };
}