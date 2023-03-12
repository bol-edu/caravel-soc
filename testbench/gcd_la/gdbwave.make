# GDBWave
GDBWAVE = ~/gdbwave/src/gdbwave

all: ./gcd_la_tb $(SW_FILES)
	vvp ./gcd_la_tb $(VVP_ARGS)

./gcd_la_tb: $(VERILOG_FILES) 
	iverilog -D SIMULATION=1 -f./include.rtl.list -o gcd_la_tb gcd_la_tb.v

gdbwave: 
	$(GDBWAVE) -w waves.fst -c ./gdbwave.config


clean:
	\rm -fr *.vcd ./tb *.fst *.fst.hier

