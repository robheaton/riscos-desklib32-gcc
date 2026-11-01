# Status

## Built
All of DeskLib's C (about 270 files) and the 259 ARM assembler veneers: 515 objects in `libDeskLib32.a`, no failures. The 24 demonstration and test applications of `tests/` build and link without a warning. Not built: `BackTrace`, `PCI`, `USB`, `Compat`.

## Run
Nothing has been run on a machine yet (1 November 2026, the day of the first version). The test applications are the ones of DeskLib64, which ran on a Raspberry Pi 5 with RISC OS 64 (see its `docs/STATUS.md` for what each one checks); they are to be run on 32 bit RISC OS 5 (a Compute Module 4 and a Raspberry Pi 3 or 4) and this file updated with the results.

## Known risks
* The `Mem` library (`Libraries/Mem`) is DeskLib's own heap, which DeskLib64 replaced by one on `malloc`; the 32 bit build uses DeskLib's, and `cleartest` is the first thing that runs it.
* The veneers keep the old APCS register rules (r4-r9 saved, `ip` = the argument pointer); GCC's EABI keeps the same for these registers. Only `Menu/FontMenu3.s` calls C (`malloc` and `free`), possibly with a stack that is not 8-byte aligned, which the C library of the tool chain has to tolerate; the font menu test (`font`) is the one that runs it.
