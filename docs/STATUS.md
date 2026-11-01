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
| `sprite2test` | 80 of 80 pass (the first run found that `Sprite_AppendP` of DeskLib's assembler passes the name of the second sprite where the OS wants its address, the bug that DeskLib64 documents as C16: the OS then reads the name as a sprite header and corrupts memory, and the program aborted at its end. `gcc/SpriteAppendP.c` replaces the veneer) |
| `cleartest` | 20 of 20 pass (the first run found that DeskLib's own `Mem_Initialise` returns FALSE under UnixLib; `gcc/Mem.c` replaces `Mem`) |
| `msgtest` | 32 of 32 pass |
| `colourtest` and the desktop applications (`!DLHello`, `!DLDemo2`, `!DLDialogs`, `!DLGaps` ...) | **not run yet** |

363 checks of the seven command line programs pass.

A large Wimp program built with the library, the Witter chat client (windows and dialogues made in code, menus, icons, the event loop, sprites, fonts, a scroll wheel, drag and drop of files), starts, saves its settings and works on the same Compute Module 4. That exercises the `Event`, `EventMsg`, `Window`, `Icon`, `Menu`, `Pane2`, `Sprite` and `Font` parts in daily use, but it is not a test of each function: the desktop test applications above are still to be run.

## Known risks
* The `Mem` library (`Libraries/Mem`) is DeskLib's own heap, which DeskLib64 replaced by one on `malloc`; the 32 bit build uses DeskLib's, and `cleartest` is the first thing that runs it.
* The veneers keep the old APCS register rules (r4-r9 saved, `ip` = the argument pointer); GCC's EABI keeps the same for these registers. Only `Menu/FontMenu3.s` calls C (`malloc` and `free`), possibly with a stack that is not 8-byte aligned, which the C library of the tool chain has to tolerate; the font menu test (`font`) is the one that runs it.
