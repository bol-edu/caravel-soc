MARCH           = rv32i
TOOLS_PREFIX    = /opt/riscv/bin
TARGET          = $(TOOLS_PREFIX)/riscv32-unknown-elf
AS              = $(TARGET)-as
ASFLAGS         = -march=$(MARCH) -mabi=ilp32
LD              = $(TARGET)-gcc
LDFLAGS         = -march=$(MARCH) -g -ggdb -I../../../firmware -mabi=ilp32 -Wl,-T,../../../firmware/sections.lds,-Map,progmem.map -ffreestanding -nostdlib -nostartfiles -Wl,--no-relax -Wl,--start-group,--end-group
OBJCOPY         = $(TARGET)-objcopy
OBJDUMP         = $(TARGET)-objdump
READELF         = $(TARGET)-readelf
GDBGUI          = gdbgui

.PHONY: all clean 

all: progmem.dis progmem.bin

progmem.dis: progmem_dis.elf
	$(OBJDUMP) -s -D $< > $@

progmem.bin: progmem.elf
	$(OBJCOPY) -O binary $< progmem.bin

progmem.elf: 
	$(LD) $(LDFLAGS) -o progmem.elf ../../../firmware/crt0_vex.S ../../../firmware/isr.c counter_la.c -lm 

progmem_dis.elf:
	$(LD) $(LDFLAGS) -o progmem_dis.elf ../../../firmware/crt0_vex.S ../../../firmware/isr.c counter_la.c -lm

gdb:
	$(TARGET)-gdb -q \
		progmem.elf \
		-ex "target extended-remote localhost:3333"

gdbgui:
	$(GDBGUI) -g '$(TARGET)-gdb -q progmem.elf -ex "target extended-remote localhost:3333"'

clean:
	\rm -fr *.o *.hex *.elf *.dis *.bin *.coe *.map *.mif *.mem *.funcs *.globs *.hexe
