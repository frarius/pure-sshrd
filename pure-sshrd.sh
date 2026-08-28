#!/bin/bash


_pure_sshrd_menu()
{
cat <<EOF

 Welcome to Pure-SSHRD v1.0.0
----------------------------------------
 d) index-module (prepares ssh-ramdisk)
 p) pack-module (makes ssh-ramdisk)
 b) boot-module (boots ssh-ramdisk)
 e) Exit this script
----------------------------------------
EOF
	while true; do
		read -p "Enter the letter of your option:" x; x="${x,,}"
		[ "${x}" = "e" ] && exit 0 || break
	done
	_pure_sshrd_select "${x}"
}


_pure_sshrd_select()
{
	if [ "${1}" = "d" ]; then
		_pure_sshrd_deps "curl jq pzb plistutil plist2json" || return ${?}
		echo "now you are on index-module"
		./container/modules/index.sh
	elif [ "${1}" = "p" ]; then
		_pure_sshrd_deps || return ${?}
		echo "now you are on pack-module"
		./container/modules/pack.sh
	elif [ "${1}" = "b" ]; then
		_pure_sshrd_deps "irecovery" || return ${?}
		echo "now you are on boot-module"
		./container/modules/boot.sh
	else
		echo "unrecognized option ${1} exiting now.."
		return 1
	fi
}


_pure_sshrd_deps()
{
		target="$(uname | sed s/Darwin/macosx/)-$(uname -o | sed "s/\/Linux//")-$(uname -m)"; target="${target,,}"
		export psshrd_root="$(cd "./container" && pwd)"
		mkdir -p "${psshrd_root}/tmp/sshrd-utils/libs"
		export LD_LIBRARY_PATH+=":$(cd "${psshrd_root}/tmp/sshrd-utils/libs" && pwd)"
		export PATH+=":$(cd "${psshrd_root}/tmp/sshrd-utils" && pwd)"
	if [ "${target}" = "linux-gnu-x86_64" ]; then
		stamp="1787786136"
	else
		echo "warning you are running on untested system: ${target}"
	fi
	if [ -n "${stamp}" ]; then
		if [ -e "${psshrd_root}/tmp/sshrd-utils/${stamp}.tag" ]; then
			return 0
		else
			curl -LOA "Pure-SSHRD/1.0 (Pure SSH-Ramdisk Maker)" --output-dir "${psshrd_root}/tmp/" "https://github.com/frarius/frarius-store/releases/download/v1.0-utils/sshrd-utils-${target}-${stamp}.tar.gz" && \
			{
				tar -xvf "${psshrd_root}/tmp/sshrd-utils-${target}-${stamp}.tar.gz" -C "${psshrd_root}/tmp/sshrd-utils/" && \
				echo -n>"${psshrd_root}/tmp/sshrd-utils/${stamp}.tag"
			} || return ${?}
		fi
	fi
	return 0
}


	p="${1}"; p="${p,,}"
if [ -n "${p}" ]; then
	_pure_sshrd_select "${p:0:1}"
else
	_pure_sshrd_menu
fi
