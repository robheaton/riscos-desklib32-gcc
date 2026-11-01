# Status

## Built
All of DeskLib's C (about 270 files) and the 259 ARM assembler veneers: 515 objects in `libDeskLib32.a`, no failures. The 24 demonstration and test applications of `tests/` build and link without a warning. Not built: `BackTrace`, `PCI`, `USB`, `Compat`.

## Run (1 November 2026, a Raspberry Pi Compute Module 4 with RISC OS 5.30)
The test applications are the ones of DeskLib64 (see its `docs/STATUS.md` for what each one checks), built here as static ELF programs.

| Program | Result |
|---|---|
| `envtest` | 51 of 51 checks pass |
| `misctest` | 61 of 61 pass |
| `filetest` | 81 of 81 pass |
| `spritetest` | 38 of 38 pass |
| `cleartest` | failed on the first run: DeskLib's own `Mem_Initialise` returns FALSE under UnixLib. Fixed by `gcc/Mem.c`; **not run again yet** |
| `sprite2test` | **hung** the machine's test agent; not understood yet (library or test) |
| `msgtest`, `colourtest` and the desktop applications (`!DLHello`, `!DLDemo2`, `!DLDialogs` ...) | **not run yet** |

## Known risks
* The `Mem` library (`Libraries/Mem`) is DeskLib's own heap, which DeskLib64 replaced by one on `malloc`; the 32 bit build uses DeskLib's, and `cleartest` is the first thing that runs it.
* The veneers keep the old APCS register rules (r4-r9 saved, `ip` = the argument pointer); GCC's EABI keeps the same for these registers. Only `Menu/FontMenu3.s` calls C (`malloc` and `free`), possibly with a stack that is not 8-byte aligned, which the C library of the tool chain has to tolerate; the font menu test (`font`) is the one that runs it.
