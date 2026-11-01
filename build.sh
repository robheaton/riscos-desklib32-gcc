#!/bin/bash
# build.sh: builds DeskLib for 32 bit RISC OS with GCC (ARM EABI, hard float) into dist/lib/libDeskLib32.a and dist/include/ (the headers under their RISC OS names, DeskLib:Wimp.h ...).
#   TC32   the 32 bit tool chain folder (the one with bin/arm-riscos-gnueabihf-gcc)    default: from the first argument, or $TC32
#   ASASM  GCCSDK's asasm, the assembler for ObjAsm syntax                              default: asasm on the PATH, or ~/gccsdk/cross/bin/asasm
#   JOBS   how many files to build at once                                              default: 8
# DeskLib's 259 ARM assembler veneers (the .s files of src/Libraries, unchanged) are assembled by asasm and tools/asasm-fix.sh makes the objects linkable with GCC 16's.
# Not built: BackTrace (it needs Norcroft's stack frames), PCI and USB (hardware), Compat (the snprintf that Norcroft programs need), Mem (gcc/Mem.c, a version on malloc, is built instead).
set -e
HERE=$(cd "$(dirname "$0")" && pwd)
TC32=${1:-${TC32:?give the 32 bit tool chain folder as the first argument or in TC32}}
ASASM=${ASASM:-$(command -v asasm || echo "$HOME/gccsdk/cross/bin/asasm")}
JOBS=${JOBS:-8}
CC=$TC32/bin/arm-riscos-gnueabihf-gcc; AR=$TC32/bin/arm-riscos-gnueabihf-ar
FIX=$HERE/tools/asasm-fix.sh
for x in "$CC" "$ASASM"; do [ -x "$x" ] || { echo "build.sh: $x is missing"; exit 1; }; done
export PATH=$TC32/bin:$PATH
SRC=$HERE/src; W=$HERE/work; D=$HERE/dist
rm -rf "$W" "$D"; mkdir -p "$W/shim" "$W/obj" "$D/lib" "$D/include"
# DeskLib's sources include "DeskLib:Wimp.h" (a RISC OS path): one copy of each header under each spelling
for h in "$SRC"/include/*.h "$SRC"/oldinclude/*.h; do
  b=$(basename "$h")
  for p in DeskLib Desklib desklib; do [ -e "$W/shim/$p:$b" ] || cp "$h" "$W/shim/$p:$b"; done
done
# the defaults of the tool chain (ARMv7-A, VFPv3, hard float) run on every 32 bit machine with RISC OS 5 and a VFP
FLAGS="-std=gnu17 -O2 -fsigned-char -w -I $W/shim -I $SRC/include -I $SRC/oldinclude -I $SRC/Libraries"
SKIP='/BackTrace/|/PCI/|/USB/|/Compat/|/Mem/'
: > "$W/log"
one() {
  f=$1; r=${f#$SRC/Libraries/}; r=${r#$HERE/}; n=$(echo "$r" | sed 's|/|_|g; s|\.[cs]$||')
  case $f in
    *.c) $CC $FLAGS -I "$(dirname "$f")" -c "$f" -o "$W/obj/$n.o" 2>>"$W/log" ;;
    *.s) ( cd "$(dirname "$f")" && $ASASM -I "$SRC/Libraries" -I "$(dirname "$f")" -o "$W/obj/$n.o" "$f" ) 2>>"$W/log" && $FIX "$W/obj/$n.o" 2>>"$W/log" ;;
  esac || echo "FAILED $f" >> "$W/log"
}
export -f one; export CC FLAGS W SRC ASASM FIX HERE
{ find "$SRC/Libraries" \( -name '*.c' -o -name '*.s' \) | grep -v -E "$SKIP"; echo "$HERE/gcc/Mem.c"; } | sort | xargs -P "$JOBS" -I{} bash -c 'one {}'
bad=$(grep -c '^FAILED' "$W/log" || true)
$AR rcs "$D/lib/libDeskLib32.a" "$W"/obj/*.o
cp "$W"/shim/DeskLib:*.h "$D/include/"
echo "DeskLib32: $(ls "$W/obj" | wc -l) objects, $bad failed (see work/log): dist/lib/libDeskLib32.a, dist/include/"
[ "$bad" = 0 ]
