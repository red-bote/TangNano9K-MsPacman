#!/bin/bash
# Generate the PROM VHDL from the Ms. Pac-Man romset into ../proms/ (port of
# make_mspacmanb_proms.bat):
#   1. compile make_vhdl_prom into tools_prom_src/bin/
#   2. unzip ROMZIP (comma-separated) or ${ROMDIR:-~/roms}/mspacmab.zip (bootleg program
#      boot1-6) and its MAME parent mspacman.zip (graphics and PROMs) into unzip/
#   3. write the PROM VHDL into ../proms/
#   4. create ../proms/.done, a marker file the Makefile checks before a bitstream build
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
PROM_DIR="$HERE/../proms"
UNZIP="$HERE/unzip"
TOOL="$HERE/tools_prom_src/bin/make_vhdl_prom"

if [ -n "${ROMZIP:-}" ]; then
    IFS=, read -r -a romzips <<< "$ROMZIP"
else
    romzips=("${ROMDIR:-$HOME/roms}/mspacmab.zip" "${ROMDIR:-$HOME/roms}/mspacman.zip")
fi
for z in "${romzips[@]}"; do
    if [ ! -f "$z" ]; then
        echo "error: romset not found: $z (set ROMDIR or ROMZIP)" >&2
        exit 1
    fi
done

mkdir -p "$(dirname "$TOOL")" "$UNZIP" "$PROM_DIR"
gcc -w "$HERE/tools_prom_src/src/make_vhdl_prom.c" -lm -o "$TOOL"

for z in "${romzips[@]}"; do
    unzip -q -o "$z" -d "$UNZIP"
done
cd "$UNZIP"

prom() {
    "$TOOL" "$1" "$2"
    mv -f "$2" "$PROM_DIR/$2"
}

cat 5e 5f > gfx1.bin
prom gfx1.bin GFX1.vhd

cat boot1 boot2 boot3 boot4 > main.bin
prom main.bin ROM_PGM_0.vhd

cat boot5 boot6 > wiz.bin
prom wiz.bin ROM_PGM_1.vhd

prom 82s126.1m PROM1_DST.vhd
prom 82s126.4a PROM4_DST.vhd
prom 82s123.7f PROM7_DST.vhd

touch "$PROM_DIR/.done"
echo "PROM VHDL in $PROM_DIR:"
ls -1 "$PROM_DIR"
