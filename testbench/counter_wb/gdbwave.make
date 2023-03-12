# GDBWave
GDBWAVE = ~/gdbwave/src/gdbwave

all: ./counter_wb_tb $(SW_FILES)
	vvp ./counter_wb_tb $(VVP_ARGS)

./counter_wb_tb: $(VERILOG_FILES) 
	iverilog -D SIMULATION=1 -f./include.rtl.list -o counter_wb_tb counter_wb_tb.v

gdbwave: 
	$(GDBWAVE) -w waves.fst -c ./gdbwave.config


clean:
	\rm -fr *.vcd ./tb *.fst *.fst.hier

