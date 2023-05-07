#!/data/data/com.termux/files/usr/bin/bash
case `dpkg --print-architecture` in
    aarch64)
        linarch="arm64"
        ;;
    arm)
        linarch="armhf"
        ;;
    *)
        echo "unsupported architecture, we only support aarch64 for now"
        exit 1
        ;;
esac

folder="ubuntu-$linarch--rootfs"
uv=22.04
tarball="ubuntu.tar.gz"

echo "downloading ubuntu-image"
wget "https://cdimage.ubuntu.com/ubuntu-base/releases/${uv}/release/ubuntu-base-${uv}-base-${linarch}.tar.gz" -O "$tarball"
cur=`pwd`
echo removing any existing "$folder"
rm -rf "$folder"
mkdir -p "$folder"
cd "$folder"
echo "decompressing ubuntu image"
apt install proot
proot --link2symlink tar -xf "${cur}/${tarball}" --exclude='dev'
echo "removing ubuntu image tarball"
rm "${cur}/${tarball}"
echo "fixing nameserver, otherwise it can't connect to the internet"
echo "nameserver 1.1.1.1" > etc/resolv.conf
echo "127.0.0.1 localhost" > etc/hosts
cd "$cur"
bin=enter_ubuntu.sh
echo "writing launch script"
cat > $bin <<- EOM
#!/bin/bash
cd "$cur"
echo "the distribution may be minimized"
echo "please execute the following command to unminimize it"
echo "  unminimize"
## unset LD_PRELOAD in case termux-exec is installed
unset LD_PRELOAD
command="/data/data/com.termux/files/usr/bin/proot"
command+=" --link2symlink"
command+=" -0"
command+=" -r $folder"
command+=" -b /dev"
command+=" -b /proc"
command+=" -b /sys"
command+=" -b /data/data/com.termux/files/home:/termux"
command+=" -w /root"
command+=" /usr/bin/env -i"
command+=" HOME=/root"
command+=" PATH=/usr/local/sbin:/usr/local/bin:/bin:/usr/bin:/sbin:/usr/sbin:/usr/games:/usr/local/games"
command+=" TERM=\$TERM"
command+=" LANG=C.UTF-8"
command+=" /bin/bash --login"
com="\$@"
if [ -z "\$1" ];then
exec \$command
else
\$command -c "\$com"
fi
EOM

echo "fixing shebang of $bin"
termux-fix-shebang $bin &&
echo "making $bin executable" &&
chmod +x $bin &&
echo symlinking ubuntu sh to bash &&
./$bin "rm /bin/sh; ln -s /bin/bash /bin/sh" &&
echo "updating package list" &&
./$bin "apt update" &&
echo "installing core packages for apt" &&
./$bin "apt install -y apt-utils" &&
./$bin "apt install -y dialog" &&
./$bin "apt install -y sudo" &&
./$bin "apt install -y wget curl tzdata" &&
echo "You can now launch Ubuntu $uv $linarch with the ./${bin} script"
