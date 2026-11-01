# What is different from DeskLib64 and DeskLib32

## The sources

`src/` is the `src/` of [DeskLib64](https://github.com/robheaton/riscos-desklib64) (commit `aa93ab1`) **byte for byte**, except that
`include/dl64.h` is not here (it is what the C veneers of DeskLib64 need; the 32 bit library has DeskLib's own ARM assembler
veneers instead). DeskLib64 is [Andrew Youll's DeskLib32](https://github.com/adyoull/desklib32) (commit `957863a`, upstream DeskLib
master `f7469f4` with a few fixes) with 71 files changed and one added: every one of those changes, with the problem, the
evidence and the reasoning, is in [docs/MODIFICATIONS64.md](docs/MODIFICATIONS64.md), and the exact edits are in
[patches/desklib64-vs-desklib32.diff](patches/desklib64-vs-desklib32.diff). **Nothing was changed in the sources for the 32 bit
GCC build** (the `Mem` library is replaced in the build, see below). The structure sizes that the Window Manager needs (`window_block` is 88 bytes, `wimp_colourflags` 8) are checked
at compile time by `Libraries/Template/Clone.c`, and the build passes them.

## The build (new, not DeskLib)

| | |
|---|---|
| `build.sh` | compiles the C files with `arm-riscos-gnueabihf-gcc -std=gnu17 -O2 -fsigned-char` (the tool chain's defaults: ARMv7-A, VFPv3, hard float) and assembles the 259 `.s` files with GCCSDK's `asasm` |
| `tools/asasm-fix.sh` | asasm writes EABI version 0 into the ELF header, which GCC 16's linker refuses next to its own version 5, and names the sections after the AREA (`D$$code`); this sets the version and renames the sections to `.text`, `.data`, `.bss` and `.rodata` |
| `gcc/Mem.c` | DeskLib's `Mem` library builds its own heap with a hook of the SharedCLibrary (`_kernel_register_slotextend`) and its `Mem_Initialise` returns FALSE with UnixLib, the C library of this tool chain (found by the `clear` test on the first run on a machine). `gcc/Mem.c`, DeskLib64's replacement on `malloc` (the blocks never move, `Mem_Compact` has nothing to do), is built instead of `src/Libraries/Mem/`; the interface is the same |
| not built | `BackTrace` (Norcroft stack frames), `PCI`, `USB` (hardware), `Compat` (the Norcroft `snprintf`), `Mem` (see above) |
| `-w` | warnings are off for the library, as in DeskLib64's build; the sources are DeskLib's, and the diff above is the record of what was changed |

## The tests

`tests/` is the `tests/` of DeskLib64 with `DeskLib64` and `RISC OS 64` in the text changed to the 32 bit names, the file type of the
programs `&E1F` (ELF) instead of `&FF8`, three checks of "no stale top half" written as `(uint64_t) (uintptr_t) p >> 32`
(a shift by 32 of a 32 bit value is undefined), and a new `tests/build.sh`.
