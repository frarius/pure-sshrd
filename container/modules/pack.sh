#!/bin/bash


_psshrd_getinfo_target()
{
		local IFS x; IFS=$'\n'

	if [ -n "${1}" ]; then
		x="${1}"
		rdpath="${1%/*}"
	else
			echo "Please select directory to produce from:"
		select x in $(find "${psshrd_root}/ipsw/" -type f -name "info.json" | sed "s|${psshrd_root}/ipsw/||g") "Exit this utility"; do
			if [ "${x}" = "Exit this utility" ]; then
				return 0
			elif [ -s "${psshrd_root}/ipsw/${x}" ]; then
				x="${psshrd_root}/ipsw/${x}"; rdpath="${x%/*}"; break
			elif [ ! -s "${psshrd_root}/ipsw/${x}" ]; then
				echo "_psshrd_getinfo_target: error cannot read ${psshrd_root}/ipsw/${x}"
				return 1
			else
				continue
			fi
		done
	fi

	if [ ! -s "${x}" ]; then
		echo "_psshrd_getinfo_target: error cannot read file: ${x}"
		return 2
	fi

	echo "_psshrd_getinfo_target: getting the idenitifers from: ${x}"
	id=($(cat "${rdpath}/info.json" | jq -r .info[]))
	echo "_psshrd_getinfo_target: found idenitifers: ${id[@]}"
	IFS=$'.'; ios=(${id[3]}); cpid="${id[2]}"; ticket="${psshrd_root}/tmp/${cpid}.bin"

	if [[ "${cpid}" =~ (0x8030|0x8027|0x8020|0x8006) ]]; then
			arch="arm64e"
	elif [[ "${cpid}" =~ (0x8960|0x8965|0x8015|0x8012|0x8011|0x8010|0x8003|0x8001|0x8000|0x7001|0x7000) ]]; then
			arch="arm64"
	elif [[ "${cpid}" =~ (0x8955|0x8950|0x8945|0x8942|0x8940|0x8930|0x8004|0x8002|0x7002) ]]; then
			arch="arm32"
	else
		echo "_psshrd_getinfo_target: error unknown CPID: ${cpid}"
		return 2
	fi

	echo "_psshrd_getinfo_target: target arch: ${arch}"
	output="${psshrd_root}/sshrd/sshrd_${id[1]}_${id[4]}(${id[3]})"
	echo "_psshrd_getinfo_target: creating output dir: ${output}"
	mkdir -p "${output}"
	return 0
}


_psshrd_validate_deps()
{
	local target stamp

		psshrd_root="${psshrd_root:-./container}"
	if [ "${arch}" = "arm64e" ]; then
		binpack="${psshrd_root}/tmp/binpack-arm64.tar"
	elif [ "${arch}" = "arm64" ]; then
		binpack="${psshrd_root}/tmp/binpack-arm64.tar"
	elif [ "${arch}" = "arm32" ]; then
		binpack="${psshrd_root}/tmp/binpack-armv7.tar"
	fi
		_psshrd_download_file "${binpack}.gz" && gzip -fdkq "${binpack}.gz" || return ${?}

	if [ "${arch}" = "arm64e" ] || [ "${arch}" = "arm64" ]; then
		tickets="${psshrd_root}/tmp/tickets.tar.gz"
		_psshrd_download_file "${tickets}" && tar -xvf "${tickets}" -C "${psshrd_root}/tmp/" || return ${?}
	fi
		return 0
}


_psshrd_download_file()
{
		local repo file out
		repo="https://github.com/frarius/frarius-store/releases/download/v1.0-deps"
		file="${1##*/}"; out="${1%/*}"

	if [ ! -s "${1}" ]; then
		echo "_psshrd_download_file: downloading: ${file}"
		mkdir -p "${out}"; curl -LOA "Pure-SSHRD/1.0 (Pure SSH-Ramdisk Maker)" "${repo}/${file}" --output-dir "${out}" || return 1
	fi
	return 0
}


_psshrd_validate_utilperm()
{
	if command -v "${1##*/}" >/dev/null; then
		return 0
	else
		echo "_psshrd_validate_utilperm: adding execute permission: ${1}"
		chmod +x "${1}" && return 0 || return ${?}
	fi
}


_psshrd_getkey_image()
{
		local x
	if [ -z "${1}" ]; then
		echo "_psshrd_getkey_image: error no arugment is passed."
		return 1
	elif [ ! -s "${rdpath}/keys.json" ]; then
		# not encrypted
		return 2
	fi

		x="${id[5]}_${id[4]}_(${id[0]})#2304#"; x="${x}#${1}"
	if [[ ! "$(cat "${rdpath}/keys.json" | jq 'keys')" =~ "${x}" ]]; then
		echo "_psshrd_getkey_image: error no keys is found for image: ${1}"
		return 3
	else
		echo "_psshrd_getkey_image: getting decryption key from: ${x}"
		key="$(cat "${rdpath}/keys.json" | jq -r '."'${x}'" | .iv,.key | .[]' | tr -d '\n')"
		echo "_psshrd_getkey_image: found iv+key: ${key}"
		return 0
	fi
}


_psshrd_process_iboot()
{
	local x y z enc
	y="${ios[0]}"; x="-v debug=0x2014e rd=md0 amfi=0xff wdt=-1 cs_enforcement_disable=1"
	[ "${y}" -lt "17" ] && x+=" amfi_allow_any_signature=1"
	[ "${y}" -lt "10" ] && x+=" amfi_unrestrict_task_for_pid=1 amfi_get_out_of_my_way=1"
	echo "_psshrd_process_iboot: generated bootargs: ${x}"

		echo "_psshrd_process_iboot: processing iboot: iboot"
	if [ "${arch}" = "arm32" ]; then
		_psshrd_getkey_image "ibss" && \
			oldimgtool "${rdpath}/"iBSS.*.dfu "${output}/iBSS.raw" -k "${key}" || \
			oldimgtool "${rdpath}/"iBSS.*.dfu "${output}/iBSS.raw"
		_psshrd_getkey_image "ibec" && \
			oldimgtool "${rdpath}/"iBEC.*.dfu "${output}/iBEC.raw" -k "${key}" || \
			oldimgtool "${rdpath}/"iBEC.*.dfu "${output}/iBEC.raw"
		_psshrd_getkey_image "iboot" && \
			oldimgtool "${rdpath}/"iBoot.*.img3 "${output}/iBoot.raw" -k "${key}" || \
			oldimgtool "${rdpath}/"iBoot.*.img3 "${output}/iBoot.raw"

		if [ "${iboot_patcher,,}" = "ibootpatcher" ]; then
			iBootPatcher --32bit "${output}/iBSS.raw" "${output}/iBSS.tmp" || return ${?}
			iBootPatcher --32bit "${output}/iBEC.raw" "${output}/iBEC.tmp" -b "${x}" || return ${?}
			iBootPatcher --32bit "${output}/iBoot.raw" "${output}/iBoot.tmp" || return ${?}
		else
			iBoot32Patcher "${output}/iBSS.raw" "${output}/iBSS.tmp" || return ${?}
			iBoot32Patcher "${output}/iBEC.raw" "${output}/iBEC.tmp" -b "${x}" || return ${?}
			iBoot32Patcher "${output}/iBoot.raw" "${output}/iBoot.tmp" || return ${?}
		fi

		oldimgtool -m IMG3 -T ibss "${output}/iBSS.tmp" "${output}/iBSS.img3" || return ${?}
		oldimgtool -m IMG3 -T ibec "${output}/iBEC.tmp" "${output}/iBEC.img3" || return ${?}
		oldimgtool -m IMG3 -T ibot "${output}/iBoot.tmp" "${output}/iBoot.img3" || return ${?}
		return 0
	elif [ "${arch}" = "arm64e" ] || [ "${arch}" = "arm64" ]; then
		z=$(xxd -l40 "${rdpath}/"iBSS.*.im4p)
		[[ "${z}" =~ "mBoot" ]] && enc=0 || { [[ "${z}" =~ "iBoot" ]] && enc=1 || enc=2; }

		if [ ${enc} -eq 0 ]; then
			img4 -i "${rdpath}/"iBSS.*.im4p -o "${output}/iBSS.raw"
			img4 -i "${rdpath}/"iBEC.*.im4p -o "${output}/iBEC.raw"
			img4 -i "${rdpath}/"iBoot.*.im4p -o "${output}/iBoot.raw"
		elif [ ${enc} -ge 1 ]; then
			_psshrd_getkey_image "ibss" && img4 -i "${rdpath}/"iBSS.*.im4p -o "${output}/iBSS.raw" -k "${key}"
			_psshrd_getkey_image "ibec" && img4 -i "${rdpath}/"iBEC.*.im4p -o "${output}/iBEC.raw" -k "${key}"
			_psshrd_getkey_image "iboot" && img4 -i "${rdpath}/"iBoot.*.im4p -o "${output}/iBoot.raw" -k "${key}"
		else
			echo "_psshrd_process_iboot: error unexpected header:"
			xxd -l40 "${rdpath}/"iBSS.*.im4p
			return 1
		fi

		if [ "${iboot_patcher,,}" = "iboot64patcher" ]; then
			iBoot64Patcher "${output}/iBSS.raw" "${output}/iBSS.tmp" || return ${?}
			iBoot64Patcher "${output}/iBEC.raw" "${output}/iBEC.tmp" -b "${x}" || return ${?}
			iBoot64Patcher "${output}/iBoot.raw" "${output}/iBoot.tmp" || return ${?}
		else
			iBootPatcher "${output}/iBSS.raw" "${output}/iBSS.tmp" || return ${?}
			iBootPatcher "${output}/iBEC.raw" "${output}/iBEC.tmp" -b "${x}" || return ${?}
			iBootPatcher "${output}/iBoot.raw" "${output}/iBoot.tmp" || return ${?}
		fi

		img4 -i "${output}/iBSS.tmp" -o "${output}/iBSS.img4" -M "${ticket}" -A -T "ibss" || return ${?}
		img4 -i "${output}/iBEC.tmp" -o "${output}/iBEC.img4" -M "${ticket}" -A -T "ibec" || return ${?}
		img4 -i "${output}/iBoot.tmp" -o "${output}/iBoot.img4" -M "${ticket}" -A -T "ibot" || return ${?}
		return 0
	fi
}


_psshrd_process_kernel()
{
	local h y v; y="${ios[0]}${ios[1]}${ios[2]}"

		echo "_psshrd_process_kernel: processing kernel: ${1}"
	if [ "${arch}" = "arm32" ]; then
		_psshrd_getkey_image "kernelcache" && \
			oldimgtool "${1}" "${output}/kcache.raw" -k "${key}" || \
			oldimgtool "${1}" "${output}/kcache.raw" 

		echo "_psshrd_process_kernel: warning cannot patch arm32 kernal"
		kernelPatcher "${output}/kcache.raw" "${output}/kcache.tmp" && \
			oldimgtool -m IMG3 -T krnl --comp "${output}/kcache.tmp" "${output}/kernelcache.img3" || \
			oldimgtool -m IMG3 -T krnl --comp "${output}/kcache.raw" "${output}/kernelcache.img3"
	elif [ "${arch}" = "arm64e" ] || [ "${arch}" = "arm64" ]; then
			img4 -i "${1}" -o "${output}/kcache.raw"
			h=$(od -An -tx1 -N9 "${output}/kcache.raw" | tr -d " "); h="${h,,}"; v="${h: -2}"; h="${h:0:8}"
		if [ "${h}" = "cafebabe" ]; then
			KPlooshFinder "${output}/kcache.raw" "${output}/kcache.tmp"
			kerneldiff "${output}/kcache.raw" "${output}/kcache.tmp" "${output}/kcache.cmp"
			img4 -i "${1}" -o "${output}/kernelcache.img4" -M "${ticket}" -T "rkrn" -P "${output}/kcache.cmp" -J || return ${?}
		elif [ "${h}${v}" = "cffaedfe00" ]; then
			KPlooshFinder "${output}/kcache.raw" "${output}/kcache.tmp"
			kerneldiff "${output}/kcache.raw" "${output}/kcache.tmp" "${output}/kcache.cmp"
			img4 -i "${1}" -o "${output}/kernelcache.img4" -M "${ticket}" -T "rkrn" -P "${output}/kcache.cmp" || return ${?}
		elif [ "${h}${v}" = "cffaedfe02" ]; then
			echo "_psshrd_process_kernel: warning cannot patch arm64e kernal"
			img4 -i "${1}" -o "${output}/kernelcache.img4" -M "${ticket}" -T "rkrn" || return ${?}
		else
			echo "_psshrd_process_kernel: unexpected kernel header: ${h}-${v}"
			return 1
		fi
	fi
}


_psshrd_process_ramdisk()
{
	local u h s; u="$(uname)"

		echo "_psshrd_process_ramdisk: processing ramdisk: ${1}"
	if [ "${arch}" = "arm32" ]; then
		_psshrd_getkey_image "updateramdisk" && \
			oldimgtool "${1}" "${output}/ramdisk.dmg" -k "${key}" || \
			oldimgtool "${1}" "${output}/ramdisk.dmg"

		s=$(du "${output}/ramdisk.dmg" | awk '{print $1}'); s=$((${s}*1024*1024/512))
		hfsplus "${output}/ramdisk.dmg" grow "${s}" || return ${?}

		if [ "${u}" = "Darwin" ]; then
			hfsplus "${output}/ramdisk.dmg" untar "${binpack}" >/dev/null || return ${?}
		else
			# for some unknown reason ssh won't connect on linux
			# trying to restart usbmuxd + usb unplug can cause kernel crash
			hfsplus "${output}/ramdisk.dmg" mv "/usr/local/bin/restored_update" "/usr/local/bin/restored_update_bak" || return ${?}
			hfsplus "${output}/ramdisk.dmg" untar "${binpack}" >/dev/null || return ${?}
			echo "/usr/local/bin/dropbear -p44; exec /usr/local/bin/restored_update_bak" >"${output}/restored_update.tmp" || return ${?}
			hfsplus "${output}/ramdisk.dmg" add "${output}/restored_update.tmp" "/usr/local/bin/restored_update" || return ${?}
			hfsplus "${output}/ramdisk.dmg" chmod 700 "/usr/local/bin/restored_update" || return ${?}
			# quick fix to prevent auto reboot
			hfsplus "${output}/ramdisk.dmg" mv "/sbin/reboot" "/sbin/reboot_bak" || return ${?}
			hfsplus "${output}/ramdisk.dmg" mv "/sbin/halt" "/sbin/halt_bak" || return ${?}
		fi

		hfsplus "${output}/ramdisk.dmg" chown 0:0 "/usr/local/bin/restored_update" || return ${?}
		hfsplus "${output}/ramdisk.dmg" chown 0:0 "/usr/local/bin/dropbear" || return ${?}
		oldimgtool -m "IMG3" -T "rdsk" "${output}/ramdisk.dmg" "${output}/ramdisk.img3" || return ${?}

		_psshrd_getkey_image "devicetree" && \
			oldimgtool "${rdpath}/"DeviceTree* "${output}/devicetree.raw" -k "${key}" || \
			oldimgtool "${rdpath}/"DeviceTree* "${output}/devicetree.raw"
			oldimgtool -m "IMG3" -T "dtre" "${output}/devicetree.raw" "${output}/devicetree.img3"

		_psshrd_getkey_image "applelogo" && \
			oldimgtool "${rdpath}/"applelogo* "${output}/logo.raw" -k "${key}" || \
			oldimgtool "${rdpath}/"applelogo* "${output}/logo.raw"
			oldimgtool -m "IMG3" -T "logo" "${output}/logo.raw" "${output}/logo.img3"

		return 0
	elif [ "${arch}" = "arm64e" ] || [ "${arch}" = "arm64" ]; then
			img4 -i "${1}" -o "${output}/ramdisk.dmg"
		if [ "$(od -An -tx1 -j32 -N4 "${output}/ramdisk.dmg" | tr -d " ")" = "4e585342" ]; then
			h="apfs"
		elif [ "$(od -An -tx1 -j1024 -N4 "${output}/ramdisk.dmg" | tr -d " ")" = "48580005" ]; then
			h="hfs"
		else
			echo "_psshrd_process_ramdisk: unexpectd ramdisk header: ${h}"
			xxd -l10 "${output}/ramdisk.dmg"
			return 1
		fi

		if [ "${u}" = "Linux" ] && [ "${h}" = "apfs" ]; then
			echo "_psshrd_process_ramdisk: warnning: cannot manipulate ramdisk image: ${h}"
		elif [ "${u}" = "Linux" ] && [ "${h}" = "hfs" ]; then
			s=$(du "${output}/ramdisk.dmg" | awk '{print $1}'); s=$((${s}*1024*1024/512))
			hfsplus "${output}/ramdisk.dmg" grow "${s}" || return ${?}
			hfsplus "${output}/ramdisk.dmg" untar "${binpack}" >/dev/null || return ${?}
		elif [ "${u}" = "Darwin" ] && [ "${h}" = "apfs" ]; then
			hdiutil attach -mountpoint '/tmp/sshrd' "${output}/ramdisk.dmg"
			hdiutil create -size 210m -imagekey diskimage-class=CRawDiskImage -format UDZO -fs HFS+ -layout NONE -srcfolder '/tmp/sshrd' -copyuid root "${output}/reassigned_ramdisk.dmg"
      	  hdiutil detach -force '/tmp/sshrd'
			hdiutil attach -mountpoint '/tmp/sshrd' "${output}/reassigned_ramdisk.dmg"
			gtar -x --no-overwrite-dir -f "${binpack}" -C '/tmp/sshrd/' 2>&1 >/dev/null
			hdiutil detach -force '/tmp/sshrd'
			hdiutil resize -sectors min "${output}/reassigned_ramdisk.dmg"					
		elif [ "${u}" = 'Darwin' ] && [ "${h}" = "hfs" ]; then
			hdiutil resize -size 210MB "${output}/ramdisk.dmg"
			hdiutil attach -mountpoint '/tmp/sshrd' "${output}/ramdisk.dmg"
			gtar -x --no-overwrite-dir -f "${binpack}" -C '/tmp/sshrd/' 2>&1 >/dev/null
			hdiutil detach -force '/tmp/sshrd'
			hdiutil resize -sectors min "${output}/ramdisk.dmg"
		fi
			img4 -i "${1}" -o "${output}/ramdisk.img4" -R "${output}/ramdisk.dmg" -M "${ticket}" -T rdsk
			[ -s "${rdpath}/"*.trustcache ] && img4 -i "${rdpath}/"*.trustcache -o "${output}/trustcache.img4" -M "${ticket}" -T "rtsc"
			[ -s "${rdpath}/"DeviceTree* ] && img4 -i "${rdpath}/"DeviceTree* -o "${output}/devicetree.img4" -M "${ticket}" -T "rdtr"
			[ -s "${rdpath}/"applelogo* ] && img4 -i "${rdpath}/"applelogo*.im4p -o "${output}/logo.img4" -M "${ticket}" -T "rlgo"
			return 0
	fi
}


_psshrd_runner()
{
	if [ "${FUNCNAME[@]: -1}" = "source" ]; then
		return 0
	else
		_psshrd_getinfo_target "${1}" || return ${?}
		_psshrd_validate_deps || return ${?}
		_psshrd_process_iboot || return ${?}
		_psshrd_process_kernel "${rdpath}/"kernel* || return ${?}
		_psshrd_process_ramdisk "${rdpath}/"*.dmg || return ${?}
		rm -f "${output}/"*.dmg "${output}/"*.raw "${output}/"*.tmp "${output}/"*.cmp "${output}/"*.bin
	fi
}


_psshrd_runner "${@}"

