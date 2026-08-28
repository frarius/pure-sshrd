# List of known iOS boot-args
* This table includes list of known boot-args with their description and usage.

## boot-args
* The list may contain inaccurate information you have been warned.

boot-arg | Values | Description | Notes
----------------|----------|----------------|------------
amfi_unrestrict_task_for_pid | `0`, `1` | Disable AMFI entitlement restriction | * Allows to run binary without requiring AMFI's entitlements<br>* It still requires binary to be signed</br>* No longer applicable on iOS 10.x
amfi_allow_any_signature | `0`, `1` | Disable AMFI signtrue requirement | * Allows to run binary with any signtrue<br>* It still requires binary to be signed</br>* No longer applicable on iOS 16.1.x
amfi_get_out_of_my_way  | `0`, `1` | Disable AMFI | * Allows to completely disable AMFI<br>* Allows to run almost all binaries without code signing or entitlement</br>* No longer applicable on iOS 10.x
cs_enforcement_disable   | `0`, `1` | Disable Code signing enforcement | * Allows to run binary without code signtrue<br>* Apple remove it from iOS 10.x then restore it back on iOS 11.x</br>* Applicable starting from iOS 6.x
nand-enable-reformat        | `0`, `1` | Allows to format Nand storage | * Used to fix downgrade issue<br>* Applicable only to Nand storage based devices (older devices)</br>
pio-error                               | `0`, `1` | ? | * No longer applicable on iOS 11.x
-restore                                 |             | ?  | * Applicable starting from iOS 10.x
amfi                                       | `0xff` | ?  | * Applicable starting from iOS 6.x
wdt                                        | `0`, `-1` | Set WatchDogTimer  | * Allows to prevent WatchDogTimer from killing binary after timeout ends<br>* Setting value to `0` will completely [disable](https://www.instructables.com/IOS-Kernel-Debugging/) WatchDogTimer but this may require aditional patches</br>* Applicable starting from iOS 6.x
-v                                            |             | Verbose boot | * Allows to display detailed information while booting


### Useful links

* List of all available boot-args: https://github.com/pod2g/ios_stuff/blob/20cefc99edf78657e2a4bee7913f5bde1eddc440/idc-ios-boot-args/README
