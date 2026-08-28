#!/bin/bash

# a solid script for solving all booting issues
# all rights are reserved to frarius

_boot_usage()
{
cat <<EOF
usage: boot.sh no-arguments
variable:    description:
 pwntool,     pwn tool binary path + argument
 irecovery,   irecovery binary path
 rdpath,      ssh-ramdisk path

EOF
return 0
}


_boot_prepare()
{

		[ -n "${1}" ] && { _boot_usage; return 1; }
		[ -z "${rdpath}" ] && rdpath="."
	select x in $(find "${rdpath}" -type f \( -iname "ramdisk.img3" -or -iname "ramdisk.img4" \)) "Exit this utility"; do
		[ "${x}" = "Exit this utility" ] && return 1
		rdpath="${x}"
		break
	done


	[ -z "${x}" ] && { _boot_usage; return 1; }


	image="${rdpath: -4}"; rdpath=$(cd "${rdpath%/*}" && pwd)
	ramdisk="${rdpath}/ramdisk.${image}"
	kcache="${rdpath}/kernelcache.${image}"
	dtree="${rdpath}/devicetree.${image}"
	trust="${rdpath}/trustcache.${image}"
	logo="${rdpath}/logo.${image}"
	ibss="${rdpath}/iBSS.${image}"
	ibec="${rdpath}/iBEC.${image}"
	ibot="${rdpath}/iBoot.${image}"

	for f in ${ibss} ${ibec} ${ramdisk} ${dtree} ${kcache}; do
		if [ ! -s "${f}" ]; then
			echo "_boot_prepare: error cannot find: ${f}"
			echo "rdpath: ${rdpath}"
			echo "image: ${image}"
			return 1
		fi
	done

		[ -z "${irecovery}" ] && irecovery="irecovery"
	if ! command -v irecovery >/dev/null && ! command -v ${irecovery} >/dev/null; then
		echo "_boot_prepare: error cannot find irecovery"
		return 2
	fi

	if [ -z "${pwntool}" ]; then
		if command -v "iPwnder32" >/dev/null; then
			ipwnder32="iPwnder32"
		elif command -v "ipwnder32" >/dev/null; then
			ipwnder32="ipwnder32"
		elif command -v "ipwnder_lite" >/dev/null; then
			ipwnder32="ipwnder_lite"
		else
			echo "_boot_prepare: warning cannot find: iPwnder32"
		fi

		if command -v "gaster" >/dev/null; then
			gaster="gaster"
		else
			echo "_boot_prepare: warning cannot find: gaster"
		fi
	fi
	return 0
}


_boot_getinfo()
{
		cpid=$(${irecovery} -vq | grep "CPID" | sed "s/CPID: //")
		pwned=$(${irecovery} -vq | grep "PWND" | sed "s/PWND: //")
	if [ -z "${cpid}" ]; then
		echo "_boot_getinfo: error could not read device info."
		return 1
	elif [[ "${cpid}" =~ (0x8960|0x8965|0x8015|0x8012|0x8011|0x8010|0x8003|0x8001|0x8000|0x7001|0x7000) ]]; then
		mode="arm64"
		return 0
	elif [[ "${cpid}" =~ (0x8955|0x8950|0x8945|0x8942|0x8940|0x8930|0x8004|0x8002|0x7002) ]]; then
		mode="32bit"
		return 0
	else
		echo "_boot_getinfo: unexpected cpid: ${cpid}"
		return 1
	fi
}


_boot_pwndevice()
{
	if [ -n "${pwned}" ]; then
		return 0
	elif [ -n "${pwntool}" ]; then
		${pwntool} || return ${?}
		return 0
	elif [ "${mode}" = "arm64" ]; then
		${gaster} pwn || return ${?}
		${gaster} reset
		return 0
	elif [ "${mode}" = "arm32" ]; then
		${ipwnder32} -p || return ${?}
		return 0
	fi
}


_boot_safeflash()
{
	if [ "${1}" = "-f" ]; then
		if echo -n>~/tmp; then
			${irecovery} -f "${2}" | tee "./tmp"
			grep -F "100.0%" "./tmp" >/dev/null && return 0 || echo "_boot_safeflash: failed attempt 1"
			${irecovery} -f "${2}" | tee "./tmp"
			grep -F "100.0%" "./tmp" >/dev/null && return 0 || { echo "_boot_safeflash: failed attempt 2"; exit 2; }
		else
			[ -z "${warn_safeflash}" ] && { warn_safeflash="1"; echo "_boot_safeflash: warning can not write into: ~/tmp"; }
			result=$(${irecovery} -f "${2}")
			[[ "${result}" =~ "100.0%" ]] && return 0 || echo "_boot_safeflash: failed attempt 1"
			result=$(${irecovery} -f "${2}")
			[[ "${result}" =~ "100.0%" ]] && return 0 || { echo "_boot_safeflash: failed attempt 2"; exit 2; }
		fi
	elif [ "${1}" = "-c" ]; then
		${irecovery} -c "${2}" || return ${?}
		return 0
	fi


}


	# prepare for war
	_boot_prepare "$@" || exit ${?}
	_boot_getinfo || exit ${?}
	_boot_pwndevice || exit ${?}

	echo "Flashing: iBSS"
	_boot_safeflash -f "${ibss}"; sleep 3
	echo "Flashing: iBEC"
	_boot_safeflash -f "${ibec}"; sleep 10
	if [[ "$cpid" =~ (0x8015|0x8012|0x8011|0x8010) ]]; then
		_boot_safeflash -c "go"
		sleep 3
	fi

	if [ -s "${logo}" ]; then
		echo "Flashing: logo"
		_boot_safeflash -f "${logo}"
		_boot_safeflash -c "setpicture 0x1"
	fi

	echo "Flashing: ramdisk"
	_boot_safeflash -f "${ramdisk}"
	_boot_safeflash -c "ramdisk"

	echo "Flashing: devicetree"
	_boot_safeflash -f "${dtree}"
	_boot_safeflash -c "devicetree"

	if [ -s "${trust}" ]; then
		echo "Flashing: trustcache"
		_boot_safeflash -f "${trust}"
		_boot_safeflash -c "firmware"
	fi

	echo "Flashing: kernelcache"
	_boot_safeflash -f "${kcache}"
	_boot_safeflash -c "bootx"
