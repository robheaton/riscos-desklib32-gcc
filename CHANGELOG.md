# Changelog

## 0.1 - 1 November 2026
* First version: DeskLib (the sources of DeskLib64 `aa93ab1`, unchanged) built for 32 bit RISC OS with GCC 16.2 (ARM EABI, hard float): 520 objects in `libDeskLib32.a`, the C files with `arm-riscos-gnueabihf-gcc`, the 259 ARM assembler veneers with `asasm` and `tools/asasm-fix.sh`.
* The 24 demonstration and test applications of DeskLib64 build for 32 bits (`tests/build.sh`) as static ELF programs.
