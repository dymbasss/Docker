Install GitLab using Docker[](#install-gitlab-using-docker "Permalink")
=======================================================================

**Tier:** Free, Premium, Ultimate **Offering:** Self-managed

The GitLab Docker images are monolithic images of GitLab running all the necessary services in a single container.

Find the GitLab official Docker image at:

*   [GitLab Docker image in Docker Hub](https://hub.docker.com/r/gitlab/gitlab-ee/)

The Docker images don’t include a mail transport agent (MTA). The recommended solution is to add an MTA (such as Postfix or Sendmail) running in a separate container. As another option, you can install an MTA directly in the GitLab container, but this adds maintenance overhead as you’ll likely need to reinstall the MTA after every upgrade or restart.

You should not deploy the GitLab Docker image in Kubernetes as it creates a single point of failure. If you want to deploy GitLab in Kubernetes, the [GitLab Helm Chart](https://docs.gitlab.com/charts/) or [GitLab Operator](https://docs.gitlab.com/operator/) should be used instead.

caution

Docker for Windows is not officially supported. There are known issues with volume permissions, and potentially other unknown issues. If you are trying to run on Docker for Windows, see the [getting help page](https://about.gitlab.com/get-help/) for links to community resources (such as IRC or forums) to seek help from other users.

Prerequisites[](#prerequisites "Permalink")
-------------------------------------------

To use the GitLab Docker images:

*   You must [install Docker](https://docs.docker.com/engine/install/#server).
*   You must use a valid externally-accessible hostname. Do not use `localhost`.

Configure the SSH port[](#configure-the-ssh-port "Permalink")
-------------------------------------------------------------

GitLab uses SSH to interact with Git over SSH. By default, GitLab uses port `22`.

To use a different port when using the GitLab Docker image, you can either:

*   Change the server’s SSH port (recommended).
*   Change the GitLab Shell SSH port.

### Change the server’s SSH port[](#change-the-servers-ssh-port "Permalink")

You can change the server’s SSH port without making another SSH configuration change in GitLab. In that case, the SSH clone URLs looks like `ssh://git@gitlab.example.com/user/project.git`.

To change the server’s SSH port:

1.  Open `/etc/ssh/sshd_config` with your editor, and change the SSH port:
    
        Port = 2424
        
    
2.  Save the file and restart the SSH service:
    
        sudo systemctl restart ssh
        
    
3.  Open a new terminal session and verify that you can connect using SSH to the server using the new port.
    

### Change the GitLab Shell SSH port[](#change-the-gitlab-shell-ssh-port "Permalink")

If you don’t want to change the server’s default SSH port, you can configure a different SSH port that GitLab uses for Git over SSH pushes. In that case, the SSH clone URLs looks like `ssh://git@gitlab.example.com:<portNumber>/user/project.git`.

For more information, see how to [change the GitLab Shell SSH port](#expose-gitlab-on-different-ports).

Set up the volumes location[](#set-up-the-volumes-location "Permalink")
-----------------------------------------------------------------------

Before setting everything else, create a directory where the configuration, logs, and data files will reside. It can be under your user’s home directory (for example `~/gitlab-docker`), or in a directory like `/srv/gitlab`. To create that directory:

    sudo mkdir -p /srv/gitlab
    

If you’re running Docker with a user other than `root`, ensure appropriate permissions have been granted to that directory.

Configure a new environment variable `$GITLAB_HOME` that sets the path to the directory you created:

    export GITLAB_HOME=/srv/gitlab
    

You can also append the `GITLAB_HOME` environment variable to your shell’s profile so it is applied on all future terminal sessions:

*   Bash: `~/.bash_profile`
*   ZSH: `~/.zshrc`

The GitLab container uses host mounted volumes to store persistent data:

Local location

Container location

Usage

`$GITLAB_HOME/data`

`/var/opt/gitlab`

For storing application data.

`$GITLAB_HOME/logs`

`/var/log/gitlab`

For storing logs.

`$GITLAB_HOME/config`

`/etc/gitlab`

For storing the GitLab configuration files.

Find the GitLab version and edition to use[](#find-the-gitlab-version-and-edition-to-use "Permalink")
-----------------------------------------------------------------------------------------------------

In a production environment, you should pin your deployment to a specific GitLab version. Find the version to use in the Docker tags page:

*   [GitLab Enterprise Edition tags](https://hub.docker.com/r/gitlab/gitlab-ee/tags/)
*   [GitLab Community Edition tags](https://hub.docker.com/r/gitlab/gitlab-ce/tags/)

The tag name consists of the following:

    gitlab/gitlab-ee:<version>-ee.0
    

Where `<version>` is the GitLab version, for example `16.5.3`. It always includes `<major>.<minor>.<patch>` in its name.

For testing purposes, you can use the `latest` tag, such as `gitlab/gitlab-ee:latest`, which points to the latest stable release.

In the following examples, we use a stable Enterprise Edition version, but if you want to use the Release Candidate (RC) or nightly image, use `gitlab/gitlab-ee:rc` or `gitlab/gitlab-ee:nightly` instead.

To install the Community Edition, replace `ee` with `ce`.

Installation[](#installation "Permalink")
-----------------------------------------

The GitLab Docker images can be run in multiple ways:

*   [Using Docker Engine](#install-gitlab-using-docker-engine)
*   [Using Docker Compose](#install-gitlab-using-docker-compose)
*   [Using Docker swarm mode](#install-gitlab-using-docker-swarm-mode)

### Install GitLab using Docker Engine[](#install-gitlab-using-docker-engine "Permalink")

You can fine tune these directories to meet your requirements. Once you’ve set up the `GITLAB_HOME` variable, you can run the image:

    sudo docker run --detach \
      --hostname gitlab.example.com \
      --env GITLAB_OMNIBUS_CONFIG="external_url 'http://gitlab.example.com'" \
      --publish 443:443 --publish 80:80 --publish 22:22 \
      --name gitlab \
      --restart always \
      --volume $GITLAB_HOME/config:/etc/gitlab \
      --volume $GITLAB_HOME/logs:/var/log/gitlab \
      --volume $GITLAB_HOME/data:/var/opt/gitlab \
      --shm-size 256m \
      gitlab/gitlab-ee:<version>-ee.0
    

This command downloads and starts a GitLab container, and [publishes ports](https://docs.docker.com/network/#published-ports) needed to access SSH, HTTP and HTTPS. All GitLab data are stored as subdirectories of `$GITLAB_HOME`. The container automatically restarts after a system reboot.

If you are on SELinux, then run this instead:

    sudo docker run --detach \
      --hostname gitlab.example.com \
      --env GITLAB_OMNIBUS_CONFIG="external_url 'http://gitlab.example.com'" \
      --publish 443:443 --publish 80:80 --publish 22:22 \
      --name gitlab \
      --restart always \
      --volume $GITLAB_HOME/config:/etc/gitlab:Z \
      --volume $GITLAB_HOME/logs:/var/log/gitlab:Z \
      --volume $GITLAB_HOME/data:/var/opt/gitlab:Z \
      --shm-size 256m \
      gitlab/gitlab-ee:<version>-ee.0
    

This command ensures that the Docker process has enough permissions to create the configuration files in the mounted volumes.

If you’re using the [Kerberos integration](../integration/kerberos.html), you must also publish your Kerberos port (for example, `--publish 8443:8443`). Failing to do so prevents Git operations with Kerberos.

The initialization process may take a long time. You can track this process with:

    sudo docker logs -f gitlab
    

After starting the container, you can visit `gitlab.example.com`. It might take a while before the Docker container starts to respond to queries.

Visit the GitLab URL, and sign in with the username `root` and the password from the following command:

    sudo docker exec -it gitlab grep 'Password:' /etc/gitlab/initial_root_password
    

note

The password file is automatically deleted in the first container restart after 24 hours.

### Install GitLab using Docker Compose[](#install-gitlab-using-docker-compose "Permalink")

With [Docker Compose](https://docs.docker.com/compose/) you can easily configure, install, and upgrade your Docker-based GitLab installation:

1.  [Install Docker Compose](https://docs.docker.com/compose/install/linux/).
2.  Create a `docker-compose.yml` file:
    
        version: '3.6'
        services:
          gitlab:
            image: gitlab/gitlab-ee:<version>-ee.0
            container_name: gitlab
            restart: always
            hostname: 'gitlab.example.com'
            environment:
              GITLAB_OMNIBUS_CONFIG: |
                # Add any other gitlab.rb configuration here, each on its own line
                external_url 'https://gitlab.example.com'
            ports:
              - '80:80'
              - '443:443'
              - '22:22'
            volumes:
              - '$GITLAB_HOME/config:/etc/gitlab'
              - '$GITLAB_HOME/logs:/var/log/gitlab'
              - '$GITLAB_HOME/data:/var/opt/gitlab'
            shm_size: '256m'
        
    
3.  Make sure you are in the same directory as `docker-compose.yml` and start GitLab:
    
        docker compose up -d
        
    

note

Read the [Pre-configure Docker container](#pre-configure-docker-container) section to see how the `GITLAB_OMNIBUS_CONFIG` variable works.

Below is another `docker-compose.yml` example with GitLab running on a custom HTTP and SSH port. Notice how the `GITLAB_OMNIBUS_CONFIG` variables match the `ports` section:

    version: '3.6'
    services:
      gitlab:
        image: gitlab/gitlab-ee:<version>-ee.0
        container_name: gitlab
        restart: always
        hostname: 'gitlab.example.com'
        environment:
          GITLAB_OMNIBUS_CONFIG: |
            external_url 'http://gitlab.example.com:8929'
            gitlab_rails['gitlab_shell_ssh_port'] = 2424
        ports:
          - '8929:8929'
          - '443:443'
          - '2424:2424'
        volumes:
          - '$GITLAB_HOME/config:/etc/gitlab'
          - '$GITLAB_HOME/logs:/var/log/gitlab'
          - '$GITLAB_HOME/data:/var/opt/gitlab'
        shm_size: '256m'
    

This configuration is the same as using `--publish 8929:8929 --publish 2424:2424`.

### Install GitLab using Docker swarm mode[](#install-gitlab-using-docker-swarm-mode "Permalink")

With [Docker swarm mode](https://docs.docker.com/engine/swarm/), you can easily configure and deploy your Docker-based GitLab installation in a swarm cluster.

In swarm mode you can leverage [Docker secrets](https://docs.docker.com/engine/swarm/secrets/) and [Docker configurations](https://docs.docker.com/engine/swarm/configs/) to efficiently and securely deploy your GitLab instance. Secrets can be used to securely pass your initial root password without exposing it as an environment variable. Configurations can help you to keep your GitLab image as generic as possible.

Here’s an example that deploys GitLab with four runners as a [stack](https://docs.docker.com/get-started/swarm-deploy/#describe-apps-using-stack-files), using secrets and configurations:

1.  [Set up a Docker swarm](https://docs.docker.com/engine/swarm/swarm-tutorial/).
2.  Create a `docker-compose.yml` file:
    
        version: "3.6"
        services:
          gitlab:
            image: gitlab/gitlab-ee:<version>-ee.0
            container_name: gitlab
            restart: always
            hostname: 'gitlab.example.com'
            ports:
              - "22:22"
              - "80:80"
              - "443:443"
            volumes:
              - $GITLAB_HOME/data:/var/opt/gitlab
              - $GITLAB_HOME/logs:/var/log/gitlab
              - $GITLAB_HOME/config:/etc/gitlab
            shm_size: '256m'
            environment:
              GITLAB_OMNIBUS_CONFIG: "from_file('/omnibus_config.rb')"
            configs:
              - source: gitlab
                target: /omnibus_config.rb
            secrets:
              - gitlab_root_password
          gitlab-runner:
            image: gitlab/gitlab-runner:alpine
            deploy:
              mode: replicated
              replicas: 4
        configs:
          gitlab:
            file: ./gitlab.rb
        secrets:
          gitlab_root_password:
            file: ./root_password.txt
        
    
    For simplicity reasons, the `network` configuration was omitted. More information can be found in the official [Compose file reference](https://docs.docker.com/compose/compose-file/).
    
3.  Create a `gitlab.rb` file:
    
        external_url 'https://my.domain.com/'
        gitlab_rails['initial_root_password'] = File.read('/run/secrets/gitlab_root_password').gsub("\n", "")
        
    
4.  Create a file called `root_password.txt` containing the password:
    
        MySuperSecretAndSecurePassw0rd!
        
    
5.  Make sure you are in the same directory as `docker-compose.yml` and run:
    
        docker stack deploy --compose-file docker-compose.yml mystack
        
    

Configuration[](#configuration "Permalink")
-------------------------------------------

This container uses the official Linux package, so all configuration is done in the unique configuration file `/etc/gitlab/gitlab.rb`.

To access the GitLab configuration file, you can start a shell session in the context of a running container. This will allow you to browse all directories and use your favorite text editor:

    sudo docker exec -it gitlab /bin/bash
    

You can also just edit `/etc/gitlab/gitlab.rb`:

    sudo docker exec -it gitlab editor /etc/gitlab/gitlab.rb
    

Once you open `/etc/gitlab/gitlab.rb` make sure to set the `external_url` to point to a valid URL.

To receive emails from GitLab you have to configure the [SMTP settings](https://docs.gitlab.com/omnibus/settings/smtp.html) because the GitLab Docker image doesn’t have an SMTP server installed. You may also be interested in [enabling HTTPS](https://docs.gitlab.com/omnibus/settings/ssl/index.html).

After you make all the changes you want, you will need to restart the container to reconfigure GitLab:

    sudo docker restart gitlab
    

GitLab will reconfigure itself whenever the container starts. For more options about configuring GitLab, check the [configuration documentation](https://docs.gitlab.com/omnibus/settings/configuration.html).

### Pre-configure Docker container[](#pre-configure-docker-container "Permalink")

You can pre-configure the GitLab Docker image by adding the environment variable `GITLAB_OMNIBUS_CONFIG` to Docker run command. This variable can contain any `gitlab.rb` setting and is evaluated before the loading of the container’s `gitlab.rb` file. This behavior allows you to configure the external GitLab URL, and make database configuration or any other option from the [Linux package template](https://gitlab.com/gitlab-org/omnibus-gitlab/blob/master/files/gitlab-config-template/gitlab.rb.template). The settings contained in `GITLAB_OMNIBUS_CONFIG` aren’t written to the `gitlab.rb` configuration file, and are evaluated on load. To provide multiple settings, separate them with a colon (`;`).

Here’s an example that sets the external URL and enables LFS while starting the container:

    sudo docker run --detach \
      --hostname gitlab.example.com \
      --env GITLAB_OMNIBUS_CONFIG="external_url 'http://gitlab.example.com'; gitlab_rails['lfs_enabled'] = true;" \
      --publish 443:443 --publish 80:80 --publish 22:22 \
      --name gitlab \
      --restart always \
      --volume $GITLAB_HOME/config:/etc/gitlab \
      --volume $GITLAB_HOME/logs:/var/log/gitlab \
      --volume $GITLAB_HOME/data:/var/opt/gitlab \
      --shm-size 256m \
      gitlab/gitlab-ee:<version>-ee.0
    

Every time you execute a `docker run` command, you need to provide the `GITLAB_OMNIBUS_CONFIG` option. The content of `GITLAB_OMNIBUS_CONFIG` is _not_ preserved between subsequent runs.

### Run GitLab on a public IP address[](#run-gitlab-on-a-public-ip-address "Permalink")

You can make Docker to use your IP address and forward all traffic to the GitLab container by modifying the `--publish` flag.

To expose GitLab on IP `198.51.100.1`:

    sudo docker run --detach \
      --hostname gitlab.example.com \
      --env GITLAB_OMNIBUS_CONFIG="external_url 'http://gitlab.example.com'" \
      --publish 198.51.100.1:443:443 \
      --publish 198.51.100.1:80:80 \
      --publish 198.51.100.1:22:22 \
      --name gitlab \
      --restart always \
      --volume $GITLAB_HOME/config:/etc/gitlab \
      --volume $GITLAB_HOME/logs:/var/log/gitlab \
      --volume $GITLAB_HOME/data:/var/opt/gitlab \
      --shm-size 256m \
      gitlab/gitlab-ee:<version>-ee.0
    

You can then access your GitLab instance at `http://198.51.100.1/` and `https://198.51.100.1/`.

### Expose GitLab on different ports[](#expose-gitlab-on-different-ports "Permalink")

GitLab will occupy [some ports](../administration/package_information/defaults.html) inside the container.

If you want to use a different host port than `80` (HTTP), `443` (HTTPS), or `22` (SSH), you need to add a separate `--publish` directive to the `docker run` command.

For example, to expose the web interface on the host’s port `8929`, and the SSH service on port `2424`:

1.  Use the following `docker run` command:
    
        sudo docker run --detach \
          --hostname gitlab.example.com \
          --env GITLAB_OMNIBUS_CONFIG="external_url 'http://gitlab.example.com:8929'; gitlab_rails['gitlab_shell_ssh_port'] = 2424" \
          --publish 8929:8929 --publish 2424:2424 \
          --name gitlab \
          --restart always \
          --volume $GITLAB_HOME/config:/etc/gitlab \
          --volume $GITLAB_HOME/logs:/var/log/gitlab \
          --volume $GITLAB_HOME/data:/var/opt/gitlab \
          --shm-size 256m \
          gitlab/gitlab-ee:<version>-ee.0
        
    
    note
    
    The format for publishing ports is `hostPort:containerPort`. Read more in the Docker documentation about [exposing incoming ports](https://docs.docker.com/network/#published-ports).
    
2.  Enter the running container:
    
        sudo docker exec -it gitlab /bin/bash
        
    
3.  Open `/etc/gitlab/gitlab.rb` with your editor and set `external_url`:
    
        # For HTTP
        external_url "http://gitlab.example.com:8929"
        
        or
        
        # For HTTPS (notice the https)
        external_url "https://gitlab.example.com:8929"
        
    
    The port specified in this URL must match the port published to the host by Docker. Additionally, if the NGINX listen port is not explicitly set in `nginx['listen_port']`, it will be pulled from the `external_url`. For more information see the [NGINX documentation](https://docs.gitlab.com/omnibus/settings/nginx.html).
    
4.  Set the SSH port:
    
        gitlab_rails['gitlab_shell_ssh_port'] = 2424
        
    
5.  Finally, reconfigure GitLab:
    
        gitlab-ctl reconfigure
        
    

Following the above example, you will be able to reach GitLab from your web browser under `<hostIP>:8929` and push using SSH under the port `2289`.

A `docker-compose.yml` example that uses different ports can be found in the [Docker compose](#install-gitlab-using-docker-compose) section.

### Configure multiple database connections[](#configure-multiple-database-connections "Permalink")

In [GitLab 16.0](https://gitlab.com/gitlab-org/omnibus-gitlab/-/merge_requests/6850), GitLab defaults to using two database connections that point to the same PostgreSQL database.

If, for any reason, you wish to switch back to single database connection:

1.  Edit `/etc/gitlab/gitlab.rb` inside the container:
    
        sudo docker exec -it gitlab editor /etc/gitlab/gitlab.rb
        
    
2.  Add the following line:
    
        gitlab_rails['databases']['ci']['enable'] = false
        
    
3.  Restart the container:
    

    sudo docker restart gitlab
    

Recommended next steps[](#recommended-next-steps "Permalink")
-------------------------------------------------------------

After completing your installation, consider taking the [recommended next steps](next_steps.html), including authentication options and sign-up restrictions.

Upgrade[](#upgrade "Permalink")
-------------------------------

In most cases, upgrading GitLab is as easy as downloading the newest Docker image tag.

### Upgrade GitLab using Docker Engine[](#upgrade-gitlab-using-docker-engine "Permalink")

To upgrade GitLab that was [installed using Docker Engine](#install-gitlab-using-docker-engine):

1.  Take a [backup](#back-up-gitlab). As a minimum, back up [the database](#create-a-database-backup) and the GitLab secrets file.
    
2.  Stop the running container:
    
        sudo docker stop gitlab
        
    
3.  Remove the existing container:
    
        sudo docker rm gitlab
        
    
4.  Pull the new image:
    
        sudo docker pull gitlab/gitlab-ee:<version>-ee.0
        
    
5.  Ensure that the `GITLAB_HOME` environment variable is [defined](#set-up-the-volumes-location):
    
        echo $GITLAB_HOME
        
    
6.  Create the container once again with the [previously specified](#install-gitlab-using-docker-engine) options:
    
        sudo docker run --detach \
        --hostname gitlab.example.com \
        --publish 443:443 --publish 80:80 --publish 22:22 \
        --name gitlab \
        --restart always \
        --volume $GITLAB_HOME/config:/etc/gitlab \
        --volume $GITLAB_HOME/logs:/var/log/gitlab \
        --volume $GITLAB_HOME/data:/var/opt/gitlab \
        --shm-size 256m \
        gitlab/gitlab-ee:<version>-ee.0
        
    

On the first run, GitLab will reconfigure and upgrade itself.

Refer to the GitLab [Upgrade recommendations](../policy/maintenance.html#upgrade-recommendations) when upgrading between versions.

### Upgrade GitLab using Docker compose[](#upgrade-gitlab-using-docker-compose "Permalink")

To upgrade GitLab that was [installed using Docker Compose](#install-gitlab-using-docker-compose):

1.  Take a [backup](#back-up-gitlab). As a minimum, back up [the database](#create-a-database-backup) and the GitLab secrets file.
2.  Edit `docker-compose.yml` and change the version to pull.
3.  Download the newest release and upgrade your GitLab instance:
    
        docker compose pull
        docker compose up -d
        
    

### Convert Community Edition to Enterprise Edition[](#convert-community-edition-to-enterprise-edition "Permalink")

You can convert an existing Docker-based GitLab Community Edition (CE) container to a GitLab [Enterprise Edition](https://about.gitlab.com/pricing/) (EE) container using the same approach as [upgrading the version](#upgrade).

We recommend you convert from the same version of CE to EE (for example, CE 14.1 to EE 14.1). This is not explicitly necessary, and any standard upgrade (for example, CE 14.0 to EE 14.1) should work. The following steps assume that you are upgrading the same version.

1.  Take a [backup](#back-up-gitlab). As a minimum, back up [the database](#create-a-database-backup) and the GitLab secrets file.
    
2.  Stop the current CE container, and remove or rename it.
    
3.  To create a new container with GitLab EE, replace `ce` with `ee` in your `docker run` command or `docker-compose.yml` file. However, reuse the CE container name, port and file mappings, and version.
    

### Downgrade GitLab[](#downgrade-gitlab "Permalink")

To downgrade GitLab after an upgrade:

1.  Follow the upgrade procedure, by [specifying the version](#find-the-gitlab-version-and-edition-to-use) to downgrade to.
    
2.  Restore the [database backup you made](#create-a-database-backup) as part of the upgrade.
    
    *   Restoring is required to back out database data and schema changes (migrations) made as part of the upgrade.
    *   GitLab backups must be restored to the exact same version and edition.
    *   [Follow the restore steps for Docker images](../administration/backup_restore/restore_gitlab.html#restore-for-docker-image-and-gitlab-helm-chart-installations), including stopping Puma and Sidekiq. Only the database must be restored, so add `SKIP=artifacts,repositories,registry,uploads,builds,pages,lfs,packages,terraform_state` to the `gitlab-backup restore` command line arguments.

Back up GitLab[](#back-up-gitlab "Permalink")
---------------------------------------------

You can create a GitLab backup with:

    docker exec -t <container name> gitlab-backup create
    

Read more on how to [back up and restore GitLab](../administration/backup_restore/index.html).

note

If configuration is provided entirely via the `GITLAB_OMNIBUS_CONFIG` environment variable (per the [“Pre-configure Docker Container”](#pre-configure-docker-container) steps), meaning no configuration is set directly in the `gitlab.rb` file, then there is no need to back up the `gitlab.rb` file.

caution

[Backing up the GitLab secrets file](../administration/backup_restore/backup_gitlab.html#storing-configuration-files) is required to avoid [complicated steps](../administration/backup_restore/troubleshooting_backup_gitlab.html#when-the-secrets-file-is-lost) when recovering GitLab from backup. The secrets file is stored at `/etc/gitlab/gitlab-secrets.json` inside the container, or `$GITLAB_HOME/config/gitlab-secrets.json` [on the container host](#set-up-the-volumes-location).

### Create a database backup[](#create-a-database-backup "Permalink")

A database backup is required to roll back GitLab upgrade if you encounter issues.

    docker exec -t <container name> gitlab-backup create SKIP=artifacts,repositories,registry,uploads,builds,pages,lfs,packages,terraform_state
    

The backup is written to `/var/opt/gitlab/backups` which should be on a [volume mounted by Docker](#set-up-the-volumes-location).

Troubleshooting[](#troubleshooting "Permalink")
-----------------------------------------------

The following information will help if you encounter problems with an installation that used the Linux package and Docker.

### Diagnose potential problems[](#diagnose-potential-problems "Permalink")

Read container logs:

    sudo docker logs gitlab
    

Enter running container:

    sudo docker exec -it gitlab /bin/bash
    

From within the container you can administer the GitLab container as you would usually administer a [Linux package installation](https://gitlab.com/gitlab-org/omnibus-gitlab/blob/master/README.md).

### 500 Internal Error[](#500-internal-error "Permalink")

When updating the Docker image you may encounter an issue where all paths display a `500` page. If this occurs, restart the container to try to rectify the issue:

    sudo docker restart gitlab
    

### Permission problems[](#permission-problems "Permalink")

When updating from older GitLab Docker images you might encounter permission problems. This happens when users in previous images were not preserved correctly. There’s script that fixes permissions for all files.

To fix your container, execute `update-permissions` and restart the container afterwards:

    sudo docker exec gitlab update-permissions
    sudo docker restart gitlab
    

### Windows/Mac: `Error executing action run on resource ruby_block[directory resource: /data/GitLab]`[](#windowsmac-error-executing-action-run-on-resource-ruby_blockdirectory-resource-datagitlab "Permalink")

This error occurs when using Docker Toolbox with VirtualBox on Windows or Mac, and making use of Docker volumes. The `/c/Users` volume is mounted as a VirtualBox Shared Folder, and does not support the all POSIX file system features. The directory ownership and permissions cannot be changed without remounting, and GitLab fails.

Our recommendation is to switch to using the native Docker install for your platform, instead of using Docker Toolbox.

If you cannot use the native Docker install (Windows 10 Home Edition, or Windows 7/8), then an alternative solution is to setup NFS mounts instead of VirtualBox shares for Docker Toolbox’s boot2docker.

### Linux ACL issues[](#linux-acl-issues "Permalink")

If you are using file ACLs on the Docker host, the `docker` group requires full access to the volumes in order for GitLab to work:

    getfacl $GITLAB_HOME
    
    # file: $GITLAB_HOME
    # owner: XXXX
    # group: XXXX
    user::rwx
    group::rwx
    group:docker:rwx
    mask::rwx
    default:user::rwx
    default:group::rwx
    default:group:docker:rwx
    default:mask::rwx
    default:other::r-x
    

If these are not correct, set them with:

    sudo setfacl -mR default:group:docker:rwx $GITLAB_HOME
    

The default group is `docker`. If you changed the group, be sure to update your commands.

### `/dev/shm` mount not having enough space in Docker container[](#devshm-mount-not-having-enough-space-in-docker-container "Permalink")

GitLab comes with a Prometheus metrics endpoint at `/-/metrics` to expose a variety of statistics on the health and performance of GitLab. The files required for this gets written to a temporary file system (like `/run` or `/dev/shm`).

By default, Docker allocates 64 MB to the shared memory directory (mounted at `/dev/shm`). This is insufficient to hold all the Prometheus metrics related files generated, and will generate error logs like the following:

    writing value to /dev/shm/gitlab/sidekiq/gauge_all_sidekiq_0-1.db failed with unmapped file
    writing value to /dev/shm/gitlab/sidekiq/gauge_all_sidekiq_0-1.db failed with unmapped file
    writing value to /dev/shm/gitlab/sidekiq/gauge_all_sidekiq_0-1.db failed with unmapped file
    writing value to /dev/shm/gitlab/sidekiq/histogram_sidekiq_0-0.db failed with unmapped file
    writing value to /dev/shm/gitlab/sidekiq/histogram_sidekiq_0-0.db failed with unmapped file
    writing value to /dev/shm/gitlab/sidekiq/histogram_sidekiq_0-0.db failed with unmapped file
    writing value to /dev/shm/gitlab/sidekiq/histogram_sidekiq_0-0.db failed with unmapped file
    

Other than disabling the Prometheus Metrics from the Admin Area, the recommended solution to fix this problem is to increase the size of shared memory to at least 256 MB. If using `docker run`, this can be done by passing the flag `--shm-size 256m`. If using a `docker-compose.yml` file, the `shm_size` key can be used for this purpose.

### Docker containers exhausts space due to the `json-file`[](#docker-containers-exhausts-space-due-to-the-json-file "Permalink")

Docker uses the [`json-file` default logging driver](https://docs.docker.com/config/containers/logging/configure/#configure-the-default-logging-driver), which performs no log rotation by default. As a result of this lack of rotation, log files stored by the `json-file` driver can consume a significant amount of disk space for containers that generate a lot of output. This can lead to disk space exhaustion. To address this, use [`journald`](https://docs.docker.com/config/containers/logging/journald/) as the logging driver when available, or [another supported driver](https://docs.docker.com/config/containers/logging/configure/#supported-logging-drivers) with native rotation support.

### Buffer overflow error when starting Docker[](#buffer-overflow-error-when-starting-docker "Permalink")

If you receive this buffer overflow error, you should purge old log files in `/var/log/gitlab`:

    buffer overflow detected : terminated
    xargs: tail: terminated by signal 6
    

Removing old log files helps fix the error, and ensures a clean startup of the instance.

### ThreadError can’t create Thread Operation not permitted[](#threaderror-cant-create-thread-operation-not-permitted "Permalink")

    can't create Thread: Operation not permitted
    

This error occurs when running a container built with newer `glibc` versions on a [host that doesn’t have support for the new clone3 function](https://github.com/moby/moby/issues/42680). In GitLab 16.0 and later, the container image includes the Ubuntu 22.04 Linux package which is built with this newer `glibc`.

This problem is fixed with newer container runtime tools like [Docker 20.10.10](https://github.com/moby/moby/pull/42836).

To resolve this issue, update Docker to version 20.10.10 or later.

[

Help & feedback
---------------

](#help-feedback-content)

### Docs

[Edit this page](https://gitlab.com/gitlab-org/gitlab/-/blob/master/doc/install/docker.md) to fix an error or add an improvement in a merge request.  
[Create an issue](https://gitlab.com/gitlab-org/gitlab/-/issues/new?issue[description]=Link%20the%20doc%20and%20describe%20what%20is%20wrong%20with%20it.%0A%0A%3C!--%20Don%27t%20edit%20below%20this%20line%20--%3E%0A%0A%2Flabel%20~documentation%20~%22docs%5C-comments%22%20&issue[title]=Docs%20feedback:%20Write%20your%20title) to suggest an improvement to this page.  

### Product

[Create an issue](https://gitlab.com/gitlab-org/gitlab/-/issues/new?issue[description]=Describe%20what%20you%20would%20like%20to%20see%20improved.%0A%0A%3C!--%20Don%27t%20edit%20below%20this%20line%20--%3E%0A%0A%2Flabel%20~%22docs%5C-comments%22%20&issue[title]=Docs%20-%20product%20feedback:%20Write%20your%20title) if there's something you don't like about this feature.  
[Propose functionality](https://gitlab.com/gitlab-org/gitlab/-/issues/new?issuable_template=Feature%20proposal%20-%20detailed&issue[title]=Docs%20feedback%20-%20feature%20proposal:%20Write%20your%20title) by submitting a feature request.  
[Join First Look](https://about.gitlab.com/community/gitlab-first-look/) to help shape new features.

### Feature availability and product trials

[View pricing](https://about.gitlab.com/pricing/) to see all GitLab tiers and features, or to upgrade.  
[Try GitLab for free](https://about.gitlab.com/free-trial/) with access to all features for 30 days.  

### Get Help

If you didn't find what you were looking for, [search the docs](/search/).  

If you want help with something specific and could use community support, [post on the GitLab forum](https://forum.gitlab.com/new-topic?title=topic%20title&body=topic%20body&tags=docs-feedback).  

For problems setting up or using this feature (depending on your GitLab subscription).  

[Request support](https://about.gitlab.com/support/)

[![Sign in to GitLab.com](/assets/images/gitlab-logo.svg)Sign in to GitLab.com](https://gitlab.com/dashboard)

*   [Twitter](https://twitter.com/gitlab)
*   [Facebook](https://www.facebook.com/gitlab)
*   [YouTube](https://www.youtube.com/channel/UCnMGQ8QHMAnVIsI3xJrihhg)
*   [LinkedIn](https://www.linkedin.com/company/gitlab-com)

*   [Docs Repo](https://gitlab.com/gitlab-org/gitlab-docs)
*   [About GitLab](https://about.gitlab.com/company/)
*   [Terms](https://about.gitlab.com/terms/)
*   [Privacy Statement](https://about.gitlab.com/privacy/)
*   Cookie Settings
*   [Contact](https://about.gitlab.com/company/contact/)

View [page source](https://gitlab.com/gitlab-org/gitlab/-/blob/master/doc/install/docker.md) - Edit in [Web IDE](https://gitlab.com/-/ide/project/gitlab-org/gitlab/edit/master/-/doc/install/docker.md) [![Creative Commons License](/assets/images/by-sa.svg)](https://creativecommons.org/licenses/by-sa/4.0/)

*   [Twitter](https://twitter.com/gitlab)
*   [Facebook](https://www.facebook.com/gitlab)
*   [YouTube](https://www.youtube.com/channel/UCnMGQ8QHMAnVIsI3xJrihhg)
*   [LinkedIn](https://www.linkedin.com/company/gitlab-com)

![](https://dc.ads.linkedin.com/collect/?pid=30694&fmt=gif)