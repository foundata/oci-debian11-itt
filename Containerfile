FROM debian:bullseye
LABEL description="Debian 11 (Bullseye), Integration Test Target (ITT) with systemd"
LABEL maintainer="foundata GmbH (https://foundata.com)"

# Inform systemd it's running in a container and specify the container manager
# type (this may affect the behavior, see src/basic/virt.c).
# Docker users can overwrite this with "--env container=docker".
ENV container=podman

# Ensure Python output goes directly to the terminal without buffering,
# preventing loss of partial output if an application crashes.
ENV PYTHONUNBUFFERED=1

# Set non-interactive mode for apt to prevent prompts during builds
ARG DEBIAN_FRONTEND=noninteractive

# Install required packages and clean-up package manager caches afterwards.
# Packages are included for these purposes:
#
# - Overall compatibility and network functionality:
#   build-essential iproute2 libffi-dev libssl-dev procps systemd
#
# - Easier debugging within the container (good feature-to-size ratio):
#   iputils-ping, iputils-tracepath, less, vim-tiny
#
# - Accessing a container via Ansible:
#   python3, python3-apt, sudo
RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        iproute2 \
        libffi-dev \
        libssl-dev \
        procps \
        systemd \
        iputils-ping \
        iputils-tracepath \
        less \
        vim-tiny \
        python3 \
        python3-apt \
        sudo \
    && rm -rf "/var/lib/apt/lists/"* \
    && apt-get clean \
    # Clean up unnecessary installed files that aren't needed in this image.
    # --no-install-recommends does not prevent installation of docs for all
    # packages, and --path-exclude is only available for dpkg, not for apt-get.
    && rm -rf "/usr/share/doc" \
    && rm -rf "/usr/share/man"

# Configure systemd, mask or remove inconvenient systemd units and services.
# Helpful resources to determine problematic units to be removed:
#   systemctl list-dependencies
#   systemctl list-units --state=waiting
#   systemctl list-units --state=failed
#   systemctl mask (if not available: cd path && ln -s -f "/dev/null")
#   https://www.freedesktop.org/software/systemd/man/latest/bootup.html
RUN systemctl mask \
        # Prevent login prompts, agetty on agetty on tty[1-6] etc.
        console-getty.service \
        getty.target \
        systemd-logind.service \
        systemd-ask-password-console.service \
        systemd-ask-password-plymouth.service \
        systemd-ask-password-wall.service \
        # Filesystem related
        dev-hugepages.mount \
        sys-fs-fuse-connections.mount \
        systemd-remount-fs.service \
        # Miscellaneous
        systemd-initctl.service \
        systemd-machine-id-commit.service \
        systemd-random-seed.service \
        systemd-udevd.service \
        systemd-udev-trigger.service \
    && systemctl disable \
        # Debian specific
        apt-daily-upgrade.timer \
        apt-daily.timer \
        dpkg-db-backup.timer \
        e2scrub_all.timer \
        motd-news.timer

# Ensure non-interactive sudo commands work in containerized environments where
# TTY allocation is often unavailable or undesired (if needed, it is usually
# allowed on this platform).
RUN sed -i -e 's/\(^Defaults\s*\)\(requiretty\)/\1!\2/' "/etc/sudoers"

# Define volumes for systemd (Podman will do this automatically, but let's add
# this for best-effort Docker compatibility)
VOLUME ["/run", "/run/lock", "/tmp", "/sys/fs/cgroup/systemd", "/var/lib/journal" ]

# Start systemd init
CMD ["/lib/systemd/systemd"]
