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
tardir="/var/tmp/pia-linux";
mkdir -p $tardir;
wget $(curl -sL https://api.github.com/repos/pia-foss/desktop/releases/latest | \
  jq -r ".body" | \
  grep -E -o 'https://.*pia-linux.*.run' | \
  grep -v -e arm64 -e armhf) -P $tardir;

piapath="$(readlink -f "$tardir"/pia-linux*.run)"
chmod +x $piapath

# Should now have the latest .run file in /tmp/pia-linux/

# sh $(sed -n 's|/dev/tty|/dev/null|g' $piapath)
sh $piapath --tar -xf -C $tardir
chmod +x "$tardir"/install.sh
sh "$tardir"/install.sh

rm -rf $tardir

#### Example for enabling a System Unit File

systemctl enable podman.socket
