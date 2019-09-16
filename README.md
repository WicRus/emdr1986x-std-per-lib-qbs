

# emdr1986x-std-per-lib-qbs
QtCreator template for Milandr microcpu

This is **unofficial** template for **unofficial** fork of **unofficial** library that compatible with GCC compiler. 

**MCU's supported status:**
- MDR1901VC1T (compiled, not tested, CMSIS deprecated)
- MDR1986VE1T (compiled, tested)
- MDR1986VE3 (compiled, not tested)
- MDR1986BE4 (compiled, not tested, CMSIS deprecated)
- MDR1986VE8T (compiled, not tested)
- MDR1986VE9x (compiled, not tested, CMSIS deprecated)

All test are made on Ubuntu 18.04.

[**Unofficial** fork of **unofficial** library](https://github.com/WicRus/emdr1986x-std-per-lib)

[**Unofficial** library](https://github.com/eldarkg/emdr1986x-std-per-lib)

[The GNU Embedded Toolchain for Arm](https://developer.arm.com/tools-and-software/open-source-software/developer-tools/gnu-toolchain/gnu-rm/downloads)

[Openocd for write and debug firmware](http://openocd.org)

**How to's**

*From command line*

    git clone https://github.com/WicRus/emdr1986x-std-per-lib-qbs.git --recursive

*From QtCreator*

File -> Create file or Project -> Clone from git 
Reository https://github.com/WicRus/emdr1986x-std-per-lib-qbs.git

**☑** Recursive



**Issuse** 

Openocd target config have only for MDR1986VE1T and MDR1986VE9x. Others config are use placeholders.
