#!/bin/bash

set -ouex pipefail

RELEASE="$(rpm -E %fedora)"


### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/39/x86_64/repoview/index.html&protocol=https&redirect=1

# this installs a package from fedora repos
rpm-ostree install java-latest-openjdk
rpm-ostree install bootc
rpm-ostree install vlc

# wget https://repository.mullvad.net/rpm/stable/mullvad.repo -P /etc/yum.repos.d
# rpm-ostree install mullvad-vpn

### This function triggers the robots.txt. Can this file be downloaded from github or something?
# wget -r --no-parent -A 'NetExtender.Linux-.*.x86.64.rpm' https://software.sonicwall.com/NetExtender/ -P /tmp
# netextender="$(readlink -f /tmp/NetExtender.Linux-.*.x86.64.rpm)"
# rpm-ostree install "$netextender"
# rm "$netextender"

# rpm-ostree override remove waydroid

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

# Should now have the latest .run file in /var/tmp/pia-linux/

# sh $(sed -n 's|/dev/tty|/dev/null|g' $piapath)
sh $piapath --tar -xpf -C $tardir
sed -i 's|/opt/${brandCode}vpn|/var/opt/${brandCode}vpn|g' "$tardir"/install.sh
chmod +x "$tardir"/install.sh

useradd -s /bin/bash bazzite
touch /etc/sudoers.d/pia
echo "bazzite ALL=(ALL) NOPASSWD:ALL" | EDITOR='tee -a' visudo --file=/etc/sudoers.d/pia
# ls -l /opt
# This returns lrwxrwxrwx 2 root root 7 Jan  1  1970 /opt -> var/opt

# root=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# sudo /bin/cp -rf "$root/piafiles/"* $installDir/
## /bin/cp: cannot stat '/var/tmp/pia-linux/piafiles/*': No such file or directory
# ls "$tardir"/piafiles
# ls "$tardir"/installfiles
runuser -u bazzite -- sh "$tardir"/install.sh --force-architecture

# Cleanup PIA install steps
rm -f /etc/sudoers.d/pia
killall -u bazzite
userdel -f bazzite
rm -rf $tardir

#### Example for enabling a System Unit File

systemctl enable podman.socket
