#!/data/data/com.termux/files/usr/bin/bash

if [[ $# != 1 ]]
    then
        echo please pass me the path to the directory i am inside
        exit
fi

if [[ ! -e $1 ]]
    then
        echo $1 does not exist
        exit
fi
if [[ ! -d $1 ]]
    then
        echo $1 is not a directory
        exit
fi

case `dpkg --print-architecture` in
    aarch64)
        linarch="arm64"
        ;;
    *)
        echo "unsupported architecture, we only support aarch64 for now"
        exit 1
        ;;
esac

folder="ubuntu-$linarch--rootfs"
uv=22.04
tarball="ubuntu.tar.gz"

if [[ ! -d "$folder" ]]
    then
        echo "$folder" is not a directory
        exit
fi

echo "downloading ubuntu-image to create minimal chroot from"
apt install wget || exit
wget "https://cdimage.ubuntu.com/ubuntu-base/releases/${uv}/release/ubuntu-base-${uv}-base-${linarch}.tar.gz" -O "$tarball"
cur="$(pwd)"
if [[ -d "$folder" ]]
    then
        echo ; echo
        echo removing existing chroot...
        echo ; echo
        time rm -rf "$folder" || exit
fi
mkdir -p "$folder"
cd "$folder"
echo "decompressing ubuntu image"
apt install proot || exit
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
## unset LD_PRELOAD in case termux-exec is installed
unset LD_PRELOAD
command="/data/data/com.termux/files/usr/bin/proot"
command+=" --link2symlink"
command+=" -0"
command+=" -r $folder"
command+=" -b /dev"
command+=" -b /proc"
command+=" -b /sys"
#command+=" -b /data/data/com.termux/files/home:/termux"
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
termux-fix-shebang $bin
echo "making $bin executable"
chmod +x $bin
echo symlinking ubuntu sh to bash
./$bin "rm /bin/sh; ln -s /bin/bash /bin/sh"
echo "updating package list"
./$bin "apt update"

echo constructing minified chroot
cp $1/make.sh "$folder/root/make.sh"

./$bin "~/make.sh"

echo replacing ubuntu image with minified chroot
mv "$folder/root/ubuntu22.04" "$folder-tmp"
rm -rf "$folder"
mv "$folder-tmp" "$folder"
echo done

echo "fixing symlinks for proot"
find "$folder" -type l -exec $1/fixlinks.sh "{}" "/data/data/com.termux/files/home/$folder" "/data/data/com.termux/files/home/$folder" "root/ubuntu22.04" \;
echo done

echo ; echo
echo updating apt sources, this will take up some space
echo ; echo

./$bin apt update

du -sh ./$folder | sort -h

echo ; echo
echo installing nano, su, and sudo
echo ; echo

./$bin apt install -y nano
./$bin apt install -y util-linux
./$bin apt install -y sudo

du -sh ./$folder | sort -h

echo "installing wgetpaste"
apt install -y wgetpaste
cp ~/../usr/bin/wgetpaste $folder/bin
sed -i "s/\/data\/data\/com\.termux\/files//g" "$(realpath "$folder/bin/wgetpaste")"
sed -i "s/\/usr\/tmp/\/tmp/g" "$(realpath "$folder/bin/wgetpaste")"

du -sh ./$folder | sort -h

echo "You can now launch Ubuntu $linarch with the ./${bin} script"
