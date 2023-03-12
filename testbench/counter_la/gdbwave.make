# GDBWave
GDBWAVE = ~/gdbwave/src/gdbwave

all: ./counter_la_tb $(SW_FILES)
	vvp ./counter_la_tb $(VVP_ARGS)

./counter_la_tb: $(VERILOG_FILES) 
	iverilog -D SIMULATION=1 -f./include.rtl.list -o counter_la_tb counter_la_tb.v

gdbwave: 
	$(GDBWAVE) -w waves.fst -c ./gdbwave.config


clean:
	\rm -fr *.vcd ./tb *.fst *.fst.hier

