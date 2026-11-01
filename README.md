# DeskLib32 for GCC - DeskLib for 32 bit RISC OS, built with GCC 16

**DeskLib**, the FreeWare C library for RISC OS, built for **32 bit RISC OS (ARM EABI, hard float)** with the
[GCC 16 tool chain](https://github.com/robheaton/riscos-gcc16) (`arm-riscos-gnueabihf-gcc`), as a static library
`libDeskLib32.a` that GCC links. Programs are ELF files (`!RunImage,e1f`), which the RISC OS 5 ELF loader runs.

It is the same source as [DeskLib64](https://github.com/robheaton/riscos-desklib64), which is
[Andrew Youll's DeskLib32](https://github.com/adyoull/desklib32) (upstream DeskLib master `f7469f4` with a few fixes)
with the pointer fields of the Window Manager's structures written as `dl_ptr`, a 32 bit word (`uint32_t`) that holds an
address. A pointer is a 32 bit word on 32 bit RISC OS too, so there the conversions cost nothing, **and one program source
builds for RISC OS 32 and for RISC OS 64** (`DL_PTR (p)` makes a `dl_ptr` from a pointer, `DL_P (v)` gives the pointer back).
The price is that a program written for the old DeskLib, which assigns pointers to those fields (`icon.buffer = text`),
needs `DL_PTR (...)` there: GCC 14 and later refuse the conversion between a pointer and an integer. The places are few and
[docs/PORTING.md](docs/PORTING.md) lists them.

Why another DeskLib32? The prebuilt DeskLib32 of Andrew Youll is built with Norcroft (AOF/ALF), which GCC cannot link,
and the older GCC-built DeskLib is for the old APCS-32 ABI (GCC 4.7). This one is built with the current tool chain
(EABI, VFP hard float, the UnixLib of that tool chain).

**Status: first version.** The whole library builds (515 objects, none failed) and the 24 demonstration and test applications
in `tests/` build. Four of the command line tests have passed on a Compute Module 4 (231 checks); others are not run yet or
failed: see [docs/STATUS.md](docs/STATUS.md). Please report problems as issues.

## Build

You need the 32 bit tool chain (`TC32` below: the folder that has `bin/arm-riscos-gnueabihf-gcc`, for example the unpacked
`riscos-gcc16` cross tool chain), `bash`, `python3` (for the template files of the tests) and GCCSDK's `asasm` (the
assembler for DeskLib's 259 ARM assembler veneers, which are kept as they are in ObjAsm syntax).

```
./build.sh TC32                  # -> dist/lib/libDeskLib32.a and dist/include/ (the headers as DeskLib:Wimp.h ...)
tests/build.sh TC32              # -> dist/apps/: the demonstration and test applications
```

`ASASM=/path/to/asasm` if `asasm` is not on the PATH (it is looked for in `~/gccsdk/cross/bin`).
`tools/asasm-fix.sh` makes the objects of asasm linkable with GCC 16's (it sets the EABI version in the ELF header and
names the sections `.text`, `.data`, `.bss` and `.rodata`).

## Use

```
TC32/bin/arm-riscos-gnueabihf-gcc -static -O2 -fsigned-char -I dist/include myapp.c dist/lib/libDeskLib32.a -o RunImage.elf
TC32/bin/arm-riscos-gnueabihf-strip -o '!MyApp/!RunImage,e1f' RunImage.elf
```

* `-fsigned-char` because DeskLib (as the Norcroft compiler) has `char` signed.
* `-static` makes a program that needs no other module; without it the program needs the SharedLibs and ARMEABISupport modules.
* The headers are included as `#include "DeskLib:Wimp.h"`, as always; `dist/include` has them under those names.
* The code is for the defaults of the tool chain (ARMv7-A, VFPv3, hard float): every 32 bit machine with RISC OS 5 and a VFP runs it.
* Pointers in the structures that the OS reads or writes are `dl_ptr` (in `window_block`, `icon_block`, `font_string`, the sprite
  structures ...): write `DL_PTR (pointer)` to store one and `DL_P (value)` to read it. See
  [docs/MODIFICATIONS64.md](docs/MODIFICATIONS64.md) for the list.
* Not built: `BackTrace` (it needs Norcroft's stack frames), `PCI` and `USB` (hardware) and `Compat` (the `snprintf` that Norcroft
  programs need; GCC's C library has it). `Mem` is `gcc/Mem.c`, a version on `malloc` (DeskLib's own cannot work with UnixLib).

## Layout

```
src/            DeskLib: include/ (headers), oldinclude/ (compatibility headers), Libraries/ (C and ARM assembler)
build.sh        builds the library
gcc/            Mem.c: the Mem library on malloc, built instead of src/Libraries/Mem
tools/          asasm-fix.sh
tests/          demonstration and test applications (the DeskLib64 ones, built for 32 bits) and their build.sh
docs/           STATUS.md, MODIFICATIONS64.md (what DeskLib64 changed in DeskLib32), PORTING.md
patches/        the changes of DeskLib64 to DeskLib32 as a unified diff
LICENCE         DeskLib's licence, credits and contact, verbatim
NOTICE.md       what the licence means for this repository
MODIFICATIONS.md  what is different from DeskLib64 and DeskLib32
```

## Licence

DeskLib is under its own licence ([LICENCE](LICENCE)): it may be copied and distributed with its copyright messages and
conditions, as original copies, without profit; software built with it must say in its distribution that DeskLib was used.
See [NOTICE.md](NOTICE.md).
