#!/bin/bash

set -ouex pipefail

RELEASE="$(rpm -E %fedora)"


### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/39/x86_64/repoview/index.html&protocol=https&redirect=1

# this installs a package from fedora repos
rpm-ostree install screen

# this would install a package from rpmfusion
# rpm-ostree install vlc

# This should (hopefully) install the latest Private Internet Access
wget $(curl -sL https://api.github.com/repos/pia-foss/desktop/releases/latest | \
  jq -r ".body" | \
  grep -E -o 'https://.*pia-linux.*.run' | \
  grep -v -e arm64 -e armhf) -P /tmp/pia-linux && \
sh /tmp/pia-linux/pia-linux* --noexec --target /tmp/pia-linux && \
chmod +x /tmp/pia-linux/install.sh && \
sh /tmp/pia-linx/install.sh && \
rm -rf /tmp/pia-linux*

#### Example for enabling a System Unit File

systemctl enable podman.socket
