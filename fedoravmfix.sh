#!/bin/bash



# Download Patches
cd /var/tmp
curl -O http://pkgbuild.com/git/aur-mirror.git/plain/vmware-patch/vmblock-9.0.2-5.0.2-3.10.patch
curl -O http://pkgbuild.com/git/aur-mirror.git/plain/vmware-patch/vmnet-9.0.2-5.0.2-3.10.patch

# Extract Code To Apply Patches
cd /usr/lib/vmware/modules/source
tar -xvf vmblock.tar
tar -xvf vmnet.tar

# Lets Apply Patches
patch -p0 -i /var/tmp/vmblock-9.0.2-5.0.2-3.10.patch
patch -p0 -i /var/tmp/vmnet-9.0.2-5.0.2-3.10.patch

# Include Patch In Archieves
tar -cf vmblock.tar vmblock-only
tar -cf vmnet.tar vmnet-only

# Remove Unwanted Directory
rm -rf vmblock-only vmnet-only

# Lets Configure VMWare
vmware-modconfig --console --install-all
