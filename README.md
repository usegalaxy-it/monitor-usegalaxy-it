# monitor-usegalaxy-it

This project contains an Ansible playbook, nginx configuration files, and a Dockerfile to deploy containers that host test job reports generated by SABER.

## Docker

### Saber
The provided Dockerfile creates a Docker image optimized for Python applications that runs the latest version of SABER. To work correctly alongside the SWAG Docker container, you need to set specific key/values through Docker CLI or Docker Compose:

```
saber:
  build:
    context: /etc/saber
    dockerfile: Dockerfile
  image: <image-name>
  container_name: <name>
  volumes:
    - /dev/log:/dev/log # Mandatory, all saber logs will also be written in the syslog
    - /etc/saber/configs:/configs # Mandatory, folder containing the configuration files for saber.
    # Make sure the path in settings.yaml matches the path inside the container (/configs/settings.yaml and /configs/workflow.ga)
    - /etc/saber/logs:/logs
    - /etc/swag/configs/:/shared_data # It should match the SWAG volume to have the correct File Rotation of HTML outputs
  environment:
    SABER_PASSWORD: "${SABER_PASSWORD}"
    TZ: "Europe/Rome" # Optional, Defaults to UTC
```

#### Saber Docker Entrypoint
The container running SABER has an entrypoint that can be used to run SABER outside the cronjobs with the command:

```
docker exec <container-name> /usr/local/bin/entrypoint.sh run-once
```

For other bash commands use:
```
docker exec <container-name> /usr/local/bin/entrypoint.sh <other-bash-commands>
```

Additionally, the entrypoint script handles file rotation. The most recent `report.html` file is placed inside `/config/www` (`/shared_data/www` inside the SABER docker), while another copy is placed in `/config/www/index` with date and time appended to its name. These files are rotated every 7 days.

### SWAG
The SWAG container is deployed alongside the SABER container, with nginx hosting the HTML reports on monitor.usegalaxy.it. The hosting takes advantage of the Autoreload feature to update webpages when the SABER container overwrites old reports and adds new entries to the index. Make sure to match the mounted volume with the SABER container and to enable SWAG_AUTORELOAD:

```
swag:
  image: lscr.io/linuxserver/swag:latest
  container_name: example
  environment:
    SWAG_AUTORELOAD: "true"
    SWAG_AUTORELOAD_WATCHLIST: "/config/www"
  volumes:
    - /etc/saber/swag:/config # Note how this folder is the same used by saber
```

## Playbook
The playbook deploys the two Docker containers on the chosen host. It uses the compose.yaml file for the variables, although not all of them. The file is included for ease in case of manual test runs. To use it, make sure that this repository is the current working directory and run:

```
ansible-playbook -i <FQDN>, swag-playbook.yaml -u <user> -b --private-key <path-to-private-key> -e password="<SABER_PASSWORD>"
```

The cronjob schedule can be edited inside the playbook.