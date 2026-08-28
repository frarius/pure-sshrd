#!/bin/bash



_config()
{

	psshrd_root="${psshrd_root:-./container}"
	_getDeviceModel
	_getFirmwareLink "${model[1]}"
	_getRamdiskFiles "${model[2]}"
	exit 0

}


_getDeviceModel()
{


		_menuloop()
					{
						local x IFS models; IFS=$'\n'
						models="\
							iPhone 11 (Series)
							iPhone X (Series)
							iPhone 8 (Series)
							iPhone 7 (Series)
							iPhone 6 (Series)
							iPhone 5 (Series)
							iPhone 4 (Series)
							iPhone SE (Series)
							iPad Pro (Series)
							iPad Air (Series)
							iPad mini (Series)
							iPad (Series)"

							echo -e "Please select your device series:\n--------------------------------------------------"
						select x in ${models//$'\t'/} "Exit this utility"; do
							if [ "$x" = "Exit this utility" ]; then
								exit 0
							elif [ "$x" = "iPhone 11 (Series)" ]; then
								models="\
									iPhone 11 Pro Max (Global) | iPhone12,5 | D431AP
									iPhone 11 Pro (Global)     | iPhone12,3 | D421AP
									iPhone 11 (Global)         | iPhone12,1 | N104AP"
								break
							elif [ "$x" = "iPhone X (Series)" ]; then
								models="\
									iPhone X (GSM)    | iPhone10,6 | D221AP
									iPhone X (Global) | iPhone10,3 | D221AP"
								break
							elif [ "$x" = "iPhone 8 (Series)" ]; then
								models="\
									iPhone 8 Plus (GSM)    | iPhone10,5 | D211AP
									iPhone 8 (GSM)         | iPhone10,4 | D201AP
									iPhone 8 Plus (Global) | iPhone10,2 | D21AP
									iPhone 8 (Global)      | iPhone10,1 | D20AP"
								break
							elif [ "$x" = "iPhone 7 (Series)" ]; then
								models="\
									iPhone 7 Plus (GSM)    | iPhone9,4 | D111AP
									iPhone 7 (GSM)         | iPhone9,3 | D101AP
									iPhone 7 Plus (Global) | iPhone9,2 | D11AP
									iPhone 7 (Global)      | iPhone9,1 | D10AP"
								break
							elif [ "$x" = "iPhone 6 (Series)" ]; then
								models="\
									iPhone 6s Plus (Global) | iPhone8,2 | N66mAP
									iPhone 6s Plus (GSM)    | iPhone8,2 | N66AP
									iPhone 6s (Global)      | iPhone8,1 | N71mAP
									iPhone 6s (GSM)         | iPhone8,1 | N71AP
									iPhone 6 (Global)       | iPhone7,2 | N61mAP
									iPhone 6 (GSM)          | iPhone7,2 | N61AP
									iPhone 6 Plus (Global)  | iPhone7,1 | N56mAP
									iPhone 6 Plus (GSM)     | iPhone7,1 | N56AP"
								break
							elif [ "$x" = "iPhone 5 (Series)" ]; then
								models="\
									iPhone 5s (Global) | iPhone6,2 | N53AP
									iPhone 5s (GSM)    | iPhone6,1 | N51AP
									iPhone 5c (Global) | iPhone5,4 | N49AP
									iPhone 5c (GSM)    | iPhone5,3 | N48AP
									iPhone 5 (Global)  | iPhone5,2 | N42AP
									iPhone 5 (GSM)     | iPhone5,1 | N41AP"
								break
							elif [ "$x" = "iPhone 4 (Series)" ]; then
								models="\
									iPhone 4s       | iPhone4,1 | N94AP
									iPhone 4 (CDMA) | iPhone3,3 | N92AP
									iPhone 4 (GSM)  | iPhone3,2 | N90bAP
									iPhone 4 (GSM)  | iPhone3,1 | N90AP"
								break
							elif [ "$x" = "iPhone SE (Series)" ]; then
								models="\
									iPhone SE (1st gen.) | iPhone8,4 | N69AP"
								break
							elif [ "$x" = "iPad Pro (Series)" ]; then
								models="\
									iPad Pro (2nd gen.) (GSM)   | iPad7,2 | J121AP
									iPad Pro (2nd gen.) (Wi-Fi) | iPad7,1 | J120AP
									iPad Pro (GSM)              | iPad6,8 | J99aAP
									iPad Pro (Wi-Fi)            | iPad6,7 | J98aAP
									iPad Pro (GSM)              | iPad6,4 | J128AP
									iPad Pro (Wi-Fi)            | iPad6,3 | J127AP"
								break
							elif [ "$x" = "iPad Air (Series)" ]; then
								models="\
									iPad Air 2 (GSM)   | iPad5,4 | J82AP
									iPad Air 2 (Wi-Fi) | iPad5,3 | J81AP
									iPad Air (Global)  | iPad4,3 | J73AP
									iPad Air (GSM)     | iPad4,2 | J72AP
									iPad Air (Wi-Fi)   | iPad4,1 | J71AP"
								break
							elif [ "$x" = "iPad mini (Series)" ]; then
								models="\
									iPad mini 4 (GSM)    | iPad5,2 | J97AP
									iPad mini 4 (Wi-Fi)  | iPad5,1 | J96AP
									iPad mini 3 (Global) | iPad4,9 | J87mAP
									iPad mini 3 (GSM)    | iPad4,8 | J86mAP
									iPad mini 3 (Wi-Fi)  | iPad4,7 | J85mAP
									iPad mini 2 (Global) | iPad4,6 | J87AP
									iPad mini 2 (GSM)    | iPad4,5 | J86AP
									iPad mini 2 (Wi-Fi)  | iPad4,4 | J85AP
									iPad mini (Global)   | iPad2,7 | P107AP
									iPad mini (GSM)      | iPad2,6 | P106AP
									iPad mini (Wi-Fi)    | iPad2,5 | P105AP"
								break
							elif [ "$x" = "iPad (Series)" ]; then
								models="\
									iPad (7th gen.) (GSM)    | iPad7,12 | J172AP
									iPad (7th gen.) (Wi-Fi)  | iPad7,11 | J171AP
									iPad (6th gen.) (GSM)    | iPad7,6 | J72bAP
									iPad (6th gen.) (Wi-Fi)  | iPad7,5 | J71bAP
									iPad (5th gen.) (GSM)    | iPad6,12 | J72sAP
									iPad (5th gen.) (Wi-Fi)  | iPad6,11 | J71sAP
									iPad (4th gen.) (Global) | iPad3,6 | P103AP
									iPad (4th gen.) (GSM)    | iPad3,5 | P102AP
									iPad (4th gen.) (Wi-Fi)  | iPad3,4 | P101AP
									iPad (3rd gen.) (GSM)    | iPad3,3 | J2aAP
									iPad (3rd gen.) (CDMA)   | iPad3,2 | J2AP
									iPad (3rd gen.) (Wi-Fi)  | iPad3,1 | J1AP
									iPad 2 (Wi-FI)           | iPad2,4 | K93aAP
									iPad 2 (CDMA)            | iPad2,3 | K95AP
									iPad 2 (GSM)             | iPad2,2 | K94AP
									iPad 2 (Wi-Fi)           | iPad2,1 | K93AP"
								break
							fi
						done

							echo -e "Please select your device variant:\n--------------------------------------------------"
						select x in ${models//[$'\t']/} "Return main menu" "Exit this utility"; do
							if [ "$x" = "Exit this utility" ]; then
								exit 0
							elif [ "$x" = "Return main menu" ]; then
								return 1
							elif [ -n "$x" ]; then
								IFS=$'|'; x=($x); model[0]="${x[0]}"
								x[1]="${x[1]// /}"; model[1]="${x[1]}"
								x[2]="${x[2]// /}"; model[2]="${x[2],,}"
								break
							fi
						done
					}

	while true; do
		if [ -n "${model[0]}" ] && [ -n "${model[1]}" ] && [ -n "${model[2]}" ]; then
			return 0
		else
			_menuloop
		fi
	done

}


_getFirmwareLink()
{


			_downloadManifest()
					{
					
						if [[ ! -s "${psshrd_root}/tmp/firmwares.json" || "$update_manifest" = "yes" ]]; then
								x="https://api.ipsw.me/v2.1/firmwares.json/condensed"
								echo "creating main dir: ${psshrd_root}"; mkdir -p "${psshrd_root}"
								echo "feching firmware manifest: $x" 
							if curl "$x" -o "${psshrd_root}/tmp/firmwares.tmp"; then
								echo "fecteched firmware manifest succssfully!"
								mv "${psshrd_root}/tmp/firmwares.tmp" "${psshrd_root}/tmp/firmwares.json"
							else
								echo "An error occurred while trying to download: $x"
								exit 1
							fi
						fi

					}
			_downloadManifest

			local IFS=$'\n'
		list="$(cat "${psshrd_root}/tmp/firmwares.json" | jq -r '.devices."'$1'".firmwares[].version' | awk -F '.' '{print "iOS " $1 ".x"}' | uniq)"
		echo -e "Please select target iOS version:\n--------------------------------------------------"
	select x in ${list} "Exit this utility"; do
		if [ "$x" = "Exit this utility" ]; then
			exit 0
		elif [ "${x:0:3}" = "iOS" ]; then
		 	x="${x/iOS /}"; x="${x/.x/}"; x="${x}"
			echo "target version: $x"; break
		fi
	done

		list="$(cat "${psshrd_root}/tmp/firmwares.json" | jq -r '.devices."'$1'".firmwares[] | select(.version | startswith("'$x'")) | "\(.version) (\(.buildid))"')" 
		echo -e "Please select your device iOS version:\n--------------------------------------------------"
	select x in ${list} "Exit this utility"; do
			IFS=$' '; x="${x/(/}"; x="${x/)/}"; ver=($x)
		if [ "$x" = "Exit this utility" ]; then
			exit 0
		elif [ -n "${ver[0]}" ] && [ -n "${ver[1]}" ]; then
			echo "selected version: ${ver[@]}"; break
		fi
	done

	echo "getting firmware link for version: ${ver[1]}"
	ipsw="$(cat "${psshrd_root}/tmp/firmwares.json" | jq -r '.devices."'$1'".firmwares[] | select(.buildid | startswith("'${ver[1]}'")) .url')"
	echo "found firmware link: $ipsw"

}


_getRamdiskFiles()
{

		_getManifest()
			{
					local x
					x="${psshrd_root}/ipsw/${model[2]}_${ver[1]}(${ver[0]})"
				if [ ! -s "$x/BuildManifest.plist" ]; then
						echo "creating new output dir: $x"; mkdir -p "$x"
						echo "fetecthing build manifest from: $ipsw"
					if $(cd "$x"; pzb -g "BuildManifest.plist" "$ipsw" -o "./BuildManifest.plist" >/dev/null 2>&1); then
						echo "feteched build manifest successfully: $x"
					else
						echo "An error occurred while trying to download the build manifest."
						exit 1
					fi
				fi
					rdpath="$x"
			}

		_convertManifest()
			{
					echo "convertting the build manifest: $rdpath/BuildManifest.plist"
				if [ -s "$rdpath/BuildManifest.json" ]; then
					echo "skipping already converted: $rdpath/BuildManifest.json"
				elif plist2json "$rdpath/BuildManifest.plist" >"$rdpath/BuildManifest.json"; then
					echo "convertting succedd: $rdpath/BuildManifest.json"
				else
					echo "An error occurred while trying to convert the build manifest."
					exit 1
				fi
			}

		_getUpdateDict()
			{
						local i x; i="0"
					echo "getting update dict for: $1"
				while read x; do
					if [ "$x" = "$1" ]; then
							x="$(cat "$2" | jq -r '.BuildIdentities['$i'].Info.RestoreBehavior')"
						if [ "$x" = "Update" ]; then
							echo "found update dict: $i"
							break
						else
							echo "ignoring erase dict: $i"
						fi
					else
						echo "ignoring dict: $i"
					fi
						i=$((i+1))
				done< <(cat "$2" | jq -r '.BuildIdentities[].Info.DeviceClass')
					dict="$i"
			}

		_getDictFiles()
			{
				local i; i="0"
				echo "getting ramdisk files for: $1"
				rdlist="$(cat "$2" | jq -r '
					.BuildIdentities['$dict'].Manifest |
						.iBEC.Info.Path,
						.iBSS.Info.Path,
						.iBoot.Info.Path,
						.AppleLogo.Info.Path,
						.RestoreRamDisk.Info.Path,
						.DeviceTree.Info.Path,
						.RestoreTrustCache.Info.Path,
						.KernelCache.Info.Path
					')"
			}

 		_downloadRamdisk()
			{
					local f x
				for x in $rdlist; do
						f="$(basename "$x")"
					if [ -s "$rdpath/$f" ]; then
						echo "skipping already downloaded: $rdpath/$f"
						continue
					else
							echo "downloading: $x"
						if [ "$x" = "null" ]; then
							echo "skipping null string (probably trustcache)"
						elif $(cd "$rdpath"; pzb -g "$x" "$ipsw" >/dev/null 2>&1); then
							echo "downloading succedd: $x"
						else
							echo "An error occurred while trying to download: $x"
							exit 1
						fi
					fi
				done
			}

		_getfirmKeys()
			{
				local x c
					echo "getting the firmware keys for: $1 $2"
				if [ -f "$rdpath/keys.json" ]; then
					echo "skipping keys already exist: $rdpath/keys.json" 
					return 0
				else
						echo "getting build-train identifier for: $1 $2"
						ver[2]="$(cat "$3" | jq -r '.BuildIdentities['$dict'].Info.BuildTrain')"
						echo "found build-train identifier: ${ver[2]}"
						x="https://theapplewiki.com/wiki/Special:Ask/-5B-5B-2DHas-20subobject::Keys:${ver[2]}-20${2}-20(${1})-5D-5D/-3FHas-20filename%3Dfilename/-3FHas-20firmware-20device%3Ddevice/-3FHas-20key%3Dkey/-3FKey-20DevKBAG%3Ddevkbag/-3FHas-20key-20IV%3Div/-3FKey-20KBAG%3Dkbag/mainlabel%3Dfilename/limit%3D100/offset%3D0/format%3Djson/searchlabel%3DKeys/type%3Dsimple"
						echo "target firmware keys link: $x"
						echo "downloading the firmware keys for: $1 $2"
						c="$(curl -sA "AdvancedSSHRD/1.0 (Advance SSH Ramdisk Maker)" "$x" -o "$rdpath/keys.json" -w "%{size_download}")"
					if jq . "$rdpath/keys.json" && [ $c -ge 100 ]; then
						echo "downloading succedd"
					elif jq . "$rdpath/keys.json" && [ $c -eq 0 ]; then
						echo "target version has no encrypted images"
					else
						echo "An error occurred while downloading the firmware keys."
						exit 1
					fi
				fi
			}

		_genDeviceInfo()
			{
					local x y IFS
					IFS=$'\n'
					x=($(cat "$5" | jq -r '.BuildIdentities['$dict'] | .ApChipID, .Info.BuildTrain'))
					x="${x[0]}"; y="${x[1]}"
					echo "generated device info: $1 $2 $x $3 $4 $y"
					echo "saving device info into: $rdpath/info.json"
					echo '{"info":["'$1'", "'$2'", "'$x'", "'$3'", "'$4'", "'$y'"]}' | jq . >"$rdpath/info.json"
			}

	_getManifest
	_convertManifest
	_getUpdateDict "${model[2]}" "$rdpath/BuildManifest.json"
	_getDictFiles "${model[2]}" "$rdpath/BuildManifest.json"
	_downloadRamdisk "$rd_list"
	_getfirmKeys "${model[1]}" "${ver[1]}" "$rdpath/BuildManifest.json"
	_genDeviceInfo "${model[1]}" "${model[2]}" "${ver[0]}" "${ver[1]}" "$rdpath/BuildManifest.json"

}

_config "$@"
