# OCI Image: Debian 11 (Bullseye), Integration Test Target (ITT)

[Debian 11 (Bullseye)](https://www.debian.org/releases/bullseye/index.en.html) (Linux) for integration testing.

Main features of the [OCI](https://opencontainers.org/) image:

* Fully functional [`systemd`](https://systemd.io/) (not a shim)
* Unprivileged execution support

The image aims to replicate a "VM-like" operating system environment while maintaining container portability, making it ideal for:

* DevOps validation (like testing Ansible collections, roles, and playbooks)
* CI pipeline testing for quick smoke tests (e.g. before running full VM integration test)
* Development environments requiring systemd
* Testing system services and daemons



## Table of contents<a id="toc"></a>

- [Tags](#tags)
- [How to build](#build)
- [How to use](#usage)
- [Notes](#notes)
- [Licensing, copyright](#licensing-copyright)
  - [Container configuration, repository](#licensing-copyright-project)
  - [Container image](#licensing-copyright-image)
- [Author information](#author-information)



## Tags<a id="tags"></a>

- `latest`: Latest release of this image.



## How to build<a id="build"></a>

To build the image locally, do the following:

1. [Install Podman](https://podman.io/docs/installation).
2. Clone or pull the latest changes from the [`foundata/oci-debian11-itt` git repository](https://github.com/foundata/oci-debian11-itt).
3. Change into the directory and execute the [build command](https://docs.podman.io/en/latest/markdown/podman-build.1.html):
   ```bash
   podman build -t debian11-itt .
   ```



## How to use<a id="usage"></a>

1. [Install Podman](https://podman.io/docs/installation).
2. Use the image you built earlier or pull the image from a registry:
   - [Quay](https://quay.io/repository/foundata/debian11-itt):
     ```bash
     podman pull quay.io/foundata/debian11-itt:latest
     ```
   - [Docker Hub](https://hub.docker.com/r/foundata/debian11-itt):
     ```bash
     podman pull docker.io/foundata/debian11-itt:latest
     ```
3. Run a container from the image:
   ```bash
   podman run --detach --systemd=always debian11-itt:latest "/lib/systemd/systemd"
   ```
   Note: **On SELinux-enabled systems**, systemd attempts to write to the cgroup filesystem, which is typically denied by default security policies. To allow this operation, you must **enable the `container_manage_cgroup` boolean** on the host system: `sudo setsebool -P container_manage_cgroup 1`
4. You can now work with the container, e.g. open a Bash terminal:
   ```bash
   podman ps
   podman exec -it "<container-id-or-name>" "/bin/bash"
   ```
   Look around and check if `systemd` is really working:
   ```bash
   cat /etc/os-release
   systemctl status
   ```



## Notes<a id="notes"></a>

This image is built and tested with [Podman](https://podman.io/) only.

We currently do *not* support [Docker](https://www.docker.com/) (but it might work with `sudo` and `--privileged --volume=/sys/fs/cgroup/systemd:/sys/fs/cgroup/systemd:rw --cgroupns=host --env container=docker` instead of `--systemd=always`).

> **Important**: This image is not hardened or optimized for production use. It prioritizes compatibility and functionality over security and performance and is for usage in isolated environments only.



## Licensing, copyright<a id="licensing-copyright"></a>

### Container configuration, repository<a id="licensing-copyright-project"></a>

<!--REUSE-IgnoreStart-->
Copyright (c) 2025 foundata GmbH (https://foundata.com)

This project is licensed under the GNU General Public License v3.0 or later (SPDX-License-Identifier: `GPL-3.0-or-later`), see [`LICENSES/GPL-3.0-or-later.txt`](LICENSES/GPL-3.0-or-later.txt) for the full text.

The [`REUSE.toml`](REUSE.toml) file provides detailed licensing and copyright information in a human- and machine-readable format. This includes parts that may be subject to different licensing or usage terms, such as third-party components. The repository conforms to the [REUSE specification](https://reuse.software/spec/). You can use [`reuse spdx`](https://reuse.readthedocs.io/en/latest/readme.html#cli) to create a [SPDX software bill of materials (SBOM)](https://en.wikipedia.org/wiki/Software_Package_Data_Exchange).
<!--REUSE-IgnoreEnd-->

[![REUSE status](https://api.reuse.software/badge/github.com/foundata/oci-debian11-itt)](https://api.reuse.software/info/github.com/foundata/oci-debian11-itt)



### Container image<a id="licensing-copyright-image"></a>

The pre-built image itself bundles various software components along with direct and indirect dependencies, which are subject to their respective licenses. When using the pre-built image, **you are responsible for ensuring that your usage complies with all relevant licenses** for the software contained within the image.

For further licensing information about the software contained in this image, please refer to the following resources:

* https://www.debian.org/legal/licenses/



## Author information<a id="author-information"></a>

This project was created and is maintained by foundata GmbH (https://foundata.com).
