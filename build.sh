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
mkdir -p /tmp/pia-linux;
wget $(curl -sL https://api.github.com/repos/pia-foss/desktop/releases/latest | \
  jq -r ".body" | \
  grep -E -o 'https://.*pia-linux.*.run' | \
  grep -v -e arm64 -e armhf) -P /tmp/pia-linux;

piapath="$(readlink -f /tmp/pia-linux/pia-linux*.run)"

# Should now have the latest .run file in /tmp/pia-linux/

MS_dd()
{
    blocks="$(expr "$3" / 1024)"
    bytes="$(expr "$3" % 1024)"
    dd if="$1" ibs="$2" skip=1 obs=1024 conv=sync 2> /dev/null | \
    { test "$blocks" -gt 0 && dd ibs=1024 obs=1024 count="$blocks" ; \
      test "$bytes"  -gt 0 && dd ibs=1 obs=1024 count="$bytes" ; } 2> /dev/null
}

# Get the filesizes variable
# Keep the above function for readability, and keep the filesizes check, just in case of future updates.
filesizes="$(sed -nr 's/^.*filesizes="([0-9]+)".*$/\1/p' "$piapath")"
offset=$(head -n 624 "$piapath" | wc -c | tr -d " ")
for s in "$filesizes";
    do
        MS_dd "$piapath" "$offset" "$s" | gzip -cd | tar -C /tmp/pia-linux --no-overwrite-dir -xvf;
        offset="$(xpr "$offset" + "$s")";
done

# Should have the original file untarred at this point.
chmod +x /tmp/pia-linux/install.sh && \
sh /tmp/pia-linx/install.sh && \
rm -rf /tmp/pia-linux

#### Example for enabling a System Unit File

systemctl enable podman.socket
