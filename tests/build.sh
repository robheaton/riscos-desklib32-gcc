#!/bin/bash
# tests/build.sh [TC32]: builds the demonstration and test applications into dist/apps/ (run ../build.sh first).  Copy an application folder to RISC OS and double-click it.
# The programs are static ELF files (filetype &E1F), which the RISC OS 5 ELF loader runs without any other module.  python3 makes the template files.
set -e
HERE=$(cd "$(dirname "$0")" && pwd); R=$HERE/..
TC32=${1:-${TC32:?give the 32 bit tool chain folder as the first argument or in TC32}}
CC=$TC32/bin/arm-riscos-gnueabihf-gcc; STRIP=$TC32/bin/arm-riscos-gnueabihf-strip
LIB=$R/dist/lib/libDeskLib32.a
A=$R/dist/apps; rm -rf "$A"; mkdir -p "$A"
FLAGS="-static -O2 -fsigned-char -I $R/dist/include"
# exe SOURCE OUTPUT: compiles, links and strips one program
exe() { $CC $FLAGS "$HERE/$1" "$LIB" -o "$A/.tmp.elf" && $STRIP -o "$2" "$A/.tmp.elf" && rm -f "$A/.tmp.elf"; }
# app DIR NAME [SOURCE]: the application !NAME from tests/DIR (its !Run and !Boot, its program, its template file if there is a mktemplate.py)
app() {
  d=$1; n=$2; s=${3:-$1/$1.c}
  mkdir -p "$A/!$n"; cp "$HERE/$d/!Run,feb" "$HERE/$d/!Boot,feb" "$A/!$n/"
  exe "$s" "$A/!$n/!RunImage,e1f"
  [ ! -f "$HERE/$d/mktemplate.py" ] || python3 "$HERE/$d/mktemplate.py" "$A/!$n/Templates,fec"
}
app hello DLHello
app demo2 DLDemo2
for t in dialogs:DLDialogs save:DLSave sprite:DLSprite pane:DLPane font:DLFont font3:DLFont3 drag:DLDrag menu2:DLMenu2 controls:DLControls gaps:DLGaps gaps2:DLGaps2; do app "${t%%:*}" "${t##*:}"; done
app clip DLClip; cp "$HERE/clip/Paster,feb" "$A/!DLClip/"
app taskwindow DLTaskWindow; exe taskwindow/twecho.c "$A/!DLTaskWindow/twecho,e1f"
app gaps3 DLGaps3; cp "$HERE/gaps3/Msgs" "$A/!DLGaps3/"
# the command line programs
exe sprite/spritetest.c "$A/spritetest,e1f"; exe sprite/sprite2test.c "$A/sprite2test,e1f"; exe filing/filetest.c "$A/filetest,e1f"; exe colour/colourtest.c "$A/colourtest,e1f"
exe clear/cleartest.c "$A/cleartest,e1f"; exe env/envtest.c "$A/envtest,e1f"; exe misc/misctest.c "$A/misctest,e1f"
mkdir -p "$A/msgtest"; exe msgs/msgtest.c "$A/msgtest/msgtest,e1f"; cp "$HERE/msgs/Messages" "$A/msgtest/Messages,fff"; cp "$HERE/msgs/Msgs" "$A/msgtest/Msgs,fff"
echo "built $(ls "$A" | wc -l) items in $A"
