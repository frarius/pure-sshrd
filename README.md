# Pure-SSHRD
*The new generation of SSH-Ramdisk maker.*


## Description
***Pure-SSHRD** is a project provides an automated scripts for generating/making the `SSH-Ramdisk` for Apple devices under any iOS/iPadOS version. It's focuses on efficiency, simplicity and most importantly the portability. **It's does not matters wither you use `SSH-Ramdisk` for Research or Jailbreak what matters is Pure-SSHRD generates it for you.***


### Supported devices
**Summary:** *Apple devices has an special low level mode for restoring the device firmware when needed, this mode is called the `DFU mode` in this mode only signed or authorized images are allowed to be flashed into device. Besides that there's also many other security checks inside `DFU mode` which prevents or resistance tampering or altering the firmware images. So in order to boot `SSH-Ramdisk` a BootROM vulnerability is first required then we can bypass/remove these limitations and verifications inside BootROM. `DFU mode` consistence of serval parts the most crucial part is the `BootROM` which is the first thing runs when device is booting/starting. The `BootROM` is stored in special area in a component inside the motherboard this component are only writeable-once meaning once vulnerability is found patching it will be impossible for Apple at least not without hardware revising. Apple knows this very well so they made accessing `BootROM` extremely very hard by restricting it and adding other verification mechanism as we stated earlier hence they made dumping, debugging or exploiting the `BootROM` near impossible.*

*Comparing to the kernel exploits BootROM exploits are rare and barely researchers can find one there is only a few BootROM exploits available and the latest available exploits is only `usbliter8` (released by foo on May 2026) and `checkm8` (originaly found by @axi0mX and released on 2020) and as you can see there is 6 years gap between these two exploits which indicates how long it's can take to find BootROM vulnerability. Pure-SSHRD support range is limited to availablity of BootROM exploit support range as long as there a newer BootROM exploit Pure-SSHRD team will add support for these newer devices (when available).*


**`usbliter8` support range:**
* **iPhone:** SE (2nd gen.), 11ProMax, 11Pro, 11, XR, XSMAX and XS.
* **iPad**: Pro 12.9-inch (4th gen.), Pro 12.9-inch (3rd gen.), Pro 11-inch (2nd gen.), Pro 11-inch (1st gen.), iPad 8th (gen.), iPad Air 3rd (gen.) and iPad mini 5th (gen.). 

**`checkm8` support range:**
* **iPhone:** X, 8/8Plus, 7/7Plus, 6Plus/6/6s/6sPlus and 5s.
* **iPad**: iPad 2 until iPad (7th gen.), iPad mini until iPad mini 4, 
iPad Air, iPad Air 2, iPad Pro and iPad Pro (2nd gen.)




### Installation / Getting started

> [!NOTE]
> **Pure-SSHRD** is on it's first release and any errors can possibly be happen.


```Bash
git clone https://github.com/frarius/pure-sshrd
cd pure-sshrd
./pure-sshrd.sh
```


### Manual / Notes

[sshrd-notes.md](/docs/sshrd-notes.md)
[boot-args.md](/docs/boot-args.md)
