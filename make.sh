if [[ -d ubuntu22.04 ]]
    then
        du -sh ./* | sort -h
        echo ; echo
        echo removing existing chroot...
        echo ; echo
        time rm -rf ubuntu22.04 || exit
fi

echo ; echo
echo creating real chroot directory structure
echo ; echo

mkdir -p ubuntu22.04
mkdir -p ubuntu22.04/var/lib/dpkg
mkdir -p ubuntu22.04/usr/bin
mkdir -p ubuntu22.04/dev
mkdir -p ubuntu22.04/proc
mkdir -p ubuntu22.04/tmp

if [[ -d debs ]]
    then
        echo ; echo
        echo removing existing debs...
        echo ; echo
        time rm -rf debs || exit
fi

mkdir debs

cd debs

echo ; echo
echo downloading shell chroot packages
echo ; echo

apt download libc6 bash libtinfo6 sed libselinux1 libpcre2-8-0 coreutils libgcc-s1 gcc-12-base debianutils libacl1 libcrypt1

ls -l ../ubuntu22.04
ln -s usr/bin ../ubuntu22.04/bin
ln -s usr/lib ../ubuntu22.04/lib
ls -l ../ubuntu22.04

if [[ -d ../ubuntu22.04-tmp ]]
    then
        echo ; echo
        echo removing existing shell chroot...
        echo ; echo
        time rm -rf ../ubuntu22.04-tmp || exit
fi

echo ; echo
echo creating shell chroot
echo ; echo

dpkg --extract libc6*.deb ../ubuntu22.04-tmp
dpkg --extract bash*.deb ../ubuntu22.04-tmp
dpkg --extract libtinfo*.deb ../ubuntu22.04-tmp
dpkg --extract sed*.deb ../ubuntu22.04-tmp
dpkg --extract libselinux1*.deb ../ubuntu22.04-tmp
dpkg --extract libpcre2-8*.deb ../ubuntu22.04-tmp
dpkg --extract coreutils*.deb ../ubuntu22.04-tmp
dpkg --extract libcrypt1*.deb ../ubuntu22.04-tmp
dpkg --extract libacl1*.deb ../ubuntu22.04-tmp
dpkg --extract libgcc-s1*.deb ../ubuntu22.04-tmp
dpkg --extract gcc-12-base*.deb ../ubuntu22.04-tmp
dpkg --extract debianutils*.deb ../ubuntu22.04-tmp

echo ; echo
echo copying shell chroot to real chroot...
echo ; echo

cp -r ../ubuntu22.04-tmp/* ../ubuntu22.04/
cp -r ../ubuntu22.04-tmp/bin/* ../ubuntu22.04/bin/
cp -r ../ubuntu22.04-tmp/lib/* ../ubuntu22.04/lib/

ln -s bash ../ubuntu22.04/usr/bin/sh
ln -s which.debianutils ../ubuntu22.04/usr/bin/which

echo ; echo
echo removing shell chroot...
echo ; echo

time rm -rf ../ubuntu22.04-tmp || exit

du -sh ../* | sort -h

echo ; echo
echo installing libc6
echo ; echo

dpkg --root=../ubuntu22.04 --install gcc-12-base*.deb
dpkg --root=../ubuntu22.04 --install libgcc-s1*.deb libacl1*.deb libcrypt1*.deb libc6*.deb

du -sh ../* | sort -h

echo ; echo
echo installing terminfo
echo ; echo

apt download ncurses-base terminfo
dpkg --root=../ubuntu22.04 --install ncurses-base*.deb terminfo*.deb

echo ; echo
echo installing libc-bin
echo ; echo

apt download libattr1
dpkg --root=../ubuntu22.04 --install libattr1*.deb

apt download libc-bin
dpkg --root=../ubuntu22.04 --install libc-bin*.deb

du -sh ../* | sort -h

echo ; echo
echo installing mawk
echo ; echo

apt download mawk

echo ; echo
echo spoofing update-alternatives from package dpkg
echo ; echo

touch ../ubuntu22.04/bin/update-alternatives
chmod +x ../ubuntu22.04/bin/update-alternatives
dpkg --root=../ubuntu22.04 --install mawk*.deb
rm ../ubuntu22.04/bin/update-alternatives

echo ; echo
echo installing base-passwd
echo ; echo

apt download base-passwd libdebconfclient0
dpkg --root=../ubuntu22.04 --install base-passwd*.deb libdebconfclient0*.deb

echo ; echo
echo installing dialog
echo ; echo

apt download dialog libncursesw6

echo ; echo
echo spoofing update-alternatives from package dpkg
echo ; echo

touch ../ubuntu22.04/bin/update-alternatives
chmod +x ../ubuntu22.04/bin/update-alternatives
dpkg --root=../ubuntu22.04 --install debianutils*.deb
rm ../ubuntu22.04/bin/update-alternatives

dpkg --root=../ubuntu22.04 --install dialog*.deb libncursesw6*.deb libtinfo6*.deb libselinux1*.deb libpcre2-8*.deb

du -sh ../* | sort -h

echo ; echo
echo installing dpkg
echo ; echo

apt download libgmp10 libcap-ng0

dpkg --root=../ubuntu22.04 --install sed*.deb libgmp10*.deb libcap-ng0*.deb


dpkg --root=../ubuntu22.04 --install coreutils*.deb

apt download libbz2-1.0 liblzma5 libzstd1 zlib1g
dpkg --root=../ubuntu22.04 --install libbz2-1.0*.deb liblzma5*.deb libzstd1*.deb zlib1g*.deb libselinux1*.deb libpcre2-8*.deb
apt download tar

echo ; echo
echo spoofing update-alternatives from package dpkg
echo ; echo

touch ../ubuntu22.04/bin/update-alternatives
chmod +x ../ubuntu22.04/bin/update-alternatives
dpkg --root=../ubuntu22.04 --install tar*.deb
rm ../ubuntu22.04/bin/update-alternatives

apt download dpkg

echo ; echo
echo spoofing deb-systemd-helper from package init-system-helpers
echo ; echo

touch ../ubuntu22.04/bin/deb-systemd-helper
chmod +x ../ubuntu22.04/bin/deb-systemd-helper
dpkg --root=../ubuntu22.04 --install dpkg*.deb
rm ../ubuntu22.04/bin/deb-systemd-helper


apt download init-system-helpers perl-base debconf
dpkg --root=../ubuntu22.04 --install perl-base*.deb

dpkg --root=../ubuntu22.04 --install debconf*.deb init-system-helpers*.deb

echo ; echo
echo reinstalling dpkg with correct deb-systemd-helper from package init-system-helpers
echo ; echo

dpkg --root=../ubuntu22.04 --install dpkg*.deb

echo ; echo
echo reinstalling tar with correct update-alternatives from package dpkg
echo ; echo

dpkg --root=../ubuntu22.04 --install tar*.deb

echo ; echo
echo reinstalling tar with correct dpkg
echo ; echo

dpkg --root=../ubuntu22.04 --install tar*.deb

echo ; echo
echo reinstalling dpkg with correct tar
echo ; echo

dpkg --root=../ubuntu22.04 --install dpkg*.deb

du -sh ../* | sort -h

echo ; echo
echo installing mawk to provide awk
echo ; echo

dpkg --root=../ubuntu22.04 --install mawk*.deb

echo ; echo
echo installing base-files
echo ; echo

apt download diffutils
dpkg --root=../ubuntu22.04 --install diffutils*.deb

apt download base-files
dpkg --root=../ubuntu22.04 --install base-files*.deb

du -sh ../* | sort -h

echo ; echo
echo installing passwd
echo ; echo

apt download libaudit1 libpam0g libaudit-common sysvinit-utils lsb-base
dpkg --root=../ubuntu22.04 --install libaudit-common*.deb libaudit1*.deb libpam0g*.deb sysvinit-utils*.deb lsb-base*.deb

apt download libsemanage2 libsemanage-common libsepol2 libdb5.3 libnsl2 libtirpc3 libtirpc-common libgssapi-krb5-2 libcom-err2 libk5crypto3 libkrb5-3 libkrb5support0 libkeyutils1 libssl3
dpkg --root=../ubuntu22.04 --install libsemanage-common*.deb libsemanage2*.deb libsepol2*.deb libdb5.3*deb libnsl2*.deb libtirpc3*.deb libtirpc-common*.deb  libgssapi-krb5-2*.deb libcom-err2*.deb libk5crypto3*.deb libkrb5-3*.deb libkrb5support0*.deb libkeyutils1*.deb libssl3*.deb

apt download libpam-modules libpam-modules-bin grep libpcre3
dpkg --root=../ubuntu22.04 --install libpcre3*.deb
dpkg --root=../ubuntu22.04 --install libpam-modules-bin*.deb grep*.deb
dpkg --root=../ubuntu22.04 --install libpam-modules_*.deb

apt download passwd
dpkg --root=../ubuntu22.04 --install passwd*.deb

du -sh ../* | sort -h

echo ; echo
echo installing man
echo ; echo

apt download bsdextrautils groff-base libgdbm6 libpipeline1 libseccomp2 libsmartcols1 libstdc++6 libuchardet0
dpkg --root=../ubuntu22.04 --install bsdextrautils*.deb groff*.deb libgdbm6*.deb libpipeline1*.deb libseccomp2*.deb libsmartcols1*.deb libstdc++6*.deb libuchardet0*.deb

apt download less
dpkg --root=../ubuntu22.04 --install less*.deb

apt download man-db
dpkg --root=../ubuntu22.04 --install man-db*.deb

du -sh ../* | sort -h

echo ; echo
echo installing bash
echo ; echo

dpkg --root=../ubuntu22.04 --install bash*.deb

apt download bash-completion
dpkg --root=../ubuntu22.04 --install bash-completion*.deb

echo ; echo
echo installing apt
echo ; echo

apt download libcap2 libgcrypt20 libgpg-error0 liblz4-1 libudev1
dpkg --root=../ubuntu22.04 --install libcap2*.deb libgcrypt20*.deb libgpg-error0*.deb liblz4-1*.deb libudev1*.deb

apt download libsystemd0
dpkg --root=../ubuntu22.04 --install libsystemd0*.deb

apt download libffi8
dpkg --root=../ubuntu22.04 --install libffi8*.deb

apt download libp11-kit0
dpkg --root=../ubuntu22.04 --install libp11-kit0*.deb

apt download adduser gpgv libapt-pkg6.0 ubuntu-keyring libgnutls30 libxxhash0 libhogweed6 libidn2-0 libnettle8 libtasn1-6 libunistring2 libpam-runtime
dpkg --root=../ubuntu22.04 --install adduser*.deb gpgv*.deb libapt-pkg6.0*.deb ubuntu-keyring*.deb libgnutls30*.deb libxxhash0*.deb libhogweed6*.deb libidn2-0*.deb libnettle8*.deb libtasn1-6*.deb libunistring2*.deb libpam-runtime*.deb

apt download login
dpkg --root=../ubuntu22.04 --install login*.deb

apt download apt apt-utils
dpkg --root=../ubuntu22.04 --install apt*.deb

du -sh ../* | sort -h

apt download findutils
dpkg --root=../ubuntu22.04 --install findutils*.deb

echo ; echo
echo importing apt sources
echo ; echo

cp /etc/apt/sources.list ../ubuntu22.04/etc/apt/sources.list
#cp -r /etc/apt/trusted.gpg.d/* ../ubuntu22.04/etc/apt/trusted.gpg.d/

du -sh ../* | sort -h

echo ; echo
echo "fixing nameserver, otherwise we can't connect to the internet"
echo ; echo
echo "nameserver 1.1.1.1" > ../ubuntu22.04/etc/resolv.conf
echo "127.0.0.1 localhost" > ../ubuntu22.04/etc/hosts

du -sh ../* | sort -h
