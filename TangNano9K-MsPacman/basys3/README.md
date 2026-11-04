# Ms. Pac-Man - Digilent Basys 3

Ms. Pac-Man (© 1981 Midway, General Computer Corporation), FPGA core by MikeJ
(www.fpgaarcade.com), Tang Nano 9K port by pinballwiz.org
(<https://github.com/pinballwizz/TangNano9K-MsPacman>), built here for the Digilent
Basys 3 (Artix-7 `xc7a35tcpg236-1`).

## Hardware

- Digilent Basys 3.
- VGA monitor (31 kHz), or a 15 kHz TV/CRT (sw13, not tested).
- USB keyboard on the Basys 3 USB-HID host port.
- Optional: Atari-style joystick on Pmod JA, Digilent PmodAMP2 on Pmod JXADC.

## Build

Requirements:

- Vivado 2020.2, gcc, make, unzip, openFPGALoader.
- Romsets `mspacmab.zip` (bootleg, unencrypted program boot1-6) and its MAME parent
  `mspacman.zip` (graphics, PROMs), supplied by the user. Roms are not part of this
  repository.

```
make roms        # compile make_vhdl_prom, unzip romsets from ~/roms, write PROM VHDL
make bitstream   # Vivado batch build of basys3/mspacman_basys3.xpr
make load        # program the Basys 3 (SRAM), building first if the bitstream is outdated
make clean       # remove roms, PROM VHDL and Vivado outputs
```

- `ROMDIR=<dir>` or `ROMZIP=<zip>[,<zip>...]` selects the romsets.
- `VIVADO=<path>` selects the Vivado binary.

## IO

| Input           | Function                                      |
|-----------------|-----------------------------------------------|
| Arrow keys      | move                                          |
| 1 / 2           | start 1 player / 2 players                    |
| 5               | coin                                          |
| btnU, btnD      | coin                                          |
| btnL / btnR     | start 1 player / 2 players                    |
| btnC            | reset                                         |
| JA 1/2/3/4      | joystick right/left/down/up (active low)      |
| sw0-sw7         | DIP switches (down = default, see below)      |
| sw13 down       | 31 kHz VGA                                    |
| sw13 up         | 15 kHz TV, composite sync on HS (not tested)  |
| sw14 up         | scanlines, alternate lines at 50 %, 31 kHz    |
| sw15 up         | audio off (PmodAMP2 shutdown)                 |

DIP switches (switch up inverts the default bit):

| Bits | Setting     | Default         |
|------|-------------|-----------------|
| 1:0  | coinage     | 1 coin 1 credit |
| 3:2  | lives       | 3               |
| 5:4  | bonus       | 10000           |
| 6    | difficulty  | normal          |
| 7    | unused      |                 |

## Resource use

From a Vivado 2020.2 build:

| Resource  | Used       | Util.                          |
|-----------|------------|--------------------------------|
| LUTs      | 1559       | 7.50%                          |
| Registers | 601        | 1.44%                          |
| Block RAM | 10.5 tiles | 21.00%                         |
| DSPs      | 0          | 0.00%                          |
| Clock     | 24.576 MHz | WNS +25.238 ns, WHS +0.024 ns  |

The core runs on the one 24.576 MHz clock (6.144 MHz pixel rate as the original board)
with clock enables.

## Core changes for the Basys 3 port

Changes to the core files in `src/` (shared with the Tang Nano 9K project):

- DIP switch input, native video outputs and scanlines input of `pacman` for the Basys 3
  top (`pacman.vhd`). Unconnected in the Tang Nano 9K top, defaults keep its settings.
- Vivado elaboration error: palette PROM address connected in full
  (`pacman_video.vhd`).
- Vivado synthesis error: scan doubler `scanlines` input through a signal
  (`pacman.vhd`).
- Sprite errors (sprites one pixel early, errors where sprites overlap): sprite line
  buffer read on the pixel enable, as the original design (`dpram.vhd`,
  `pacman_video.vhd`).

## Third-party additions

PROM tool, unmodified, from <https://github.com/pinballwizz/DE2-Xevious> (commit
`a5d9eed`):

| File                                        | Function                   | Author  |
|---------------------------------------------|----------------------------|---------|
| `tools/tools_prom_src/src/make_vhdl_prom.c` | PROM-to-VHDL converter     | darfpga |

## License

- The additions and changes made for the Basys 3 port are MIT licensed.
- Core files (`src/pacman*.vhd`): (c) MikeJ, terms as stated in their headers. Other
  code keeps the terms stated in its files. `make_vhdl_prom.c` states no license.
- Roms and anything generated from them (PROM VHDL, bitstreams) are not distributed.
