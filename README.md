# VexRiscv SoC
VexRiscv SoC is a platform for developing RISC-V CPU based hardware and software which was simpified from [Efabless Caravel “harness” SoC](https://caravel-harness.readthedocs.io/en/latest/#efabless-caravel-harness-soc). You can develop and integrate custom design into this platform, then vefify their functionality with open source toolchain.

<img src="https://user-images.githubusercontent.com/11850122/220771595-250f3dfd-8eb9-4216-9a63-91d4c40e28de.png" width=0%>

More detail can be found in [Caravel's system specification](https://github.com/efabless/caravel/tree/main/docs/pdf).

## Toolchain Prerequisites
* [Ubuntu 20.04.5](https://releases.ubuntu.com/focal/)
* [RISC-V GCC Toolchains rv32i-4.0.0](https://github.com/stnolting/riscv-gcc-prebuilt)
* [Icarus Verilog v10.3](http://iverilog.icarus.com/)
* [Icarus Verilog v12 + GTKWave Windows](https://bleyer.org/icarus/) (option)
* [GTKWave v3.3.103](https://gtkwave.sourceforge.net/)
* [vtags-3.11](https://www.vim.org/scripts/script.php?script_id=5494)

## Setup and Config

    sudo apt install iverilog gtkwave vim python gcc -y
    sudo wget -O /tmp/riscv32-unknown-elf.gcc-12.1.0.tar.gz https://github.com/stnolting/riscv-gcc-prebuilt/releases/download/rv32i-4.0.0/riscv32-unknown-elf.gcc-12.1.0.tar.gz
    sudo mkdir /opt/riscv
    sudo tar -xzf /tmp/riscv32-unknown-elf.gcc-12.1.0.tar.gz -C /opt/riscv
    sudo wget -O /tmp/vtags-3.11.tar.gz https://www.vim.org/scripts/download_script.php?src_id=28365
    sudo tar -xzf /tmp/vtags-3.11.tar.gz -C /opt
    python /opt/vtags-3.11/vim_glb_config.py
    git clone https://github.com/bol-edu/vexriscv_soc
    cd vexriscv_soc/
    python /opt/vtags-3.11/vtags.py
    rm -rf vtags.db/
    chmod +x ./testbench/counter_la/run_sim ./testbench/counter_wb/run_sim ./testbench/gcd_la/run_sim
    echo 'export PATH=$PATH:/opt/riscv/bin' >> ~/.bashrc
    echo 'alias vtags="python /opt/vtags-3.11/vtags.py"' >> ~/.bashrc
    echo 'source /opt/vtags-3.11/vtags_vim_api.vim' >> ~/.vimrc
    source ~/.bashrc

validate your [setup & config](https://github.com/kevinjantw/vexriscv_soc/blob/main/setup_config.log)

## Testbenches for custom designs
In each testbench subdirectory contains (1) firmware driver (.c), (2) RTL testbench (.v), (3) included RTL files (.list), (4) run simulation script calls riscv32 command to compile c source to hex target and invokes iverilog && vvp to run RTL simulation, (5) GTKWave save file (.gtkw) saves selected signals from vexriscv_soc modules and corresponded testbench module.

* Counter with (LA) logic analyzer interface 
  * 32-bit LA input  
  * 32-bit LA output
  * 16-bit mrpj_io as output  
  ##################################################  
  vexriscv_soc/testbench/counter_la/counter_la.c  
  vexriscv_soc/testbench/counter_la/counter_la_tb.v  
  vexriscv_soc/testbench/counter_la/include.rtl.list  
  vexriscv_soc/testbench/counter_la/run_sim  
  vexriscv_soc/testbench/counter_la/waveform.gtkw  
  ##################################################  
  /vexriscv_soc/testbench/counter_la$ ./run_sim  
  Reading counter_la.hex  
  counter_la.hex loaded into memory  
  Memory 5 bytes = 0x6f 0x00 0x00 0x0b 0x13  
  VCD info: dumpfile counter_la.vcd opened for output.  
  LA Test 1 started  
  output:  
  LA Test 2 passed  
  /vexriscv_soc/testbench/counter_la$ gtkwave waveform.gtkw  

![counter_la_waveform](https://user-images.githubusercontent.com/11850122/220594971-0dc2047d-6883-445e-944e-4cc736c0ab7e.png)
  
* Counter with wishbone interface
  * 32-bit wishbone input  
  * 32-bit wishbone output
  * 16-bit mrpj_io as output  
  ##################################################  
  vexriscv_soc/testbench/counter_la/counter_wb.c  
  vexriscv_soc/testbench/counter_la/counter_wb_tb.v  
  vexriscv_soc/testbench/counter_la/include.rtl.list  
  vexriscv_soc/testbench/counter_la/run_sim  
  vexriscv_soc/testbench/counter_la/waveform.gtkw  
  ##################################################  
  vexriscv_soc/testbench/counter_wb$ ./run_sim  
  Reading counter_wb.hex  
  counter_wb.hex loaded into memory  
  Memory 5 bytes = 0x6f 0x00 0x00 0x0b 0x13  
  VCD info: dumpfile counter_wb.vcd opened for output.  
  Monitor: MPRJ-Logic WB Started  
  Monitor: Mega-Project WB (RTL) Passed  
  vexriscv_soc/testbench/counter_wb$ gtkwave waveform.gtkw  

![counter_wb_waveform](https://user-images.githubusercontent.com/11850122/220597221-3a266f07-1525-4c64-92a8-216b5fe82e25.png)
   
* GCD with (LA) logic analyzer interface
  * 32-bit x 2 LA input  
  * 32-bit LA output
  * 16-bit mrpj_io as output  
  ##################################################  
  vexriscv_soc/testbench/gcd_la/gcd_la.c  
  vexriscv_soc/testbench/gcd_la/gcd_la_tb.v  
  vexriscv_soc/testbench/gcd_la/include.rtl.list  
  vexriscv_soc/testbench/gcd_la/run_sim  
  vexriscv_soc/testbench/gcd_la/waveform.gtkw  
  ##################################################   
  vexriscv_soc/testbench/gcd_la$ ./run_sim  
  Reading gcd_la.hex  
  gcd_la.hex loaded into memory  
  Memory 5 bytes = 0x6f 0x00 0x00 0x0b 0x13  
  VCD info: dumpfile gcd_la.vcd opened for output.  
  LA Test seq_gcd(10312050, 29460792)=138 started  
  LA Test seq_gcd(10312050, 29460792)=138 passed  
  LA Test seq_gcd(1993627629, 1177417612)=7 started  
  LA Test seq_gcd(1993627629, 1177417612)=7 passed  
  LA Test seq_gcd(2097015289, 3812041926)=1 started  
  LA Test seq_gcd(2097015289, 3812041926)=1 passed  
  LA Test seq_gcd(1924134885, 3151131255)=135 started  
  LA Test seq_gcd(1924134885, 3151131255)=135 passed  
  LA Test seq_gcd(992211318, 512609597)=1 started  
  LA Test seq_gcd(992211318, 512609597)=1 passed  
  vexriscv_soc/testbench/gcd_la$ gtkwave waveform.gtkw  
 
![gcd_la_waveform](https://user-images.githubusercontent.com/11850122/220589367-339a7e00-ca5c-4070-a38a-cce3eefb4441.png)

## Trace verilog code with vim + vtags
We use vim + vtags to help signal trace source. First case, a signal *mprj_io* at gcd_la_tb module (gcd_la_tb.v) can be traced back to caravel module (cavavel.v) and chip_io module (chip_io.v).

vexriscv_soc$ vtags  
vexriscv_soc$ vim vtags.db/  
----------------Top Module List-------------  
0   : counter_la_tb  
1   : counter_wb_tb  
2   : debug_regs  
3   : gcd_la_tb  
4   : sky130_sram_2kbyte_1rw1r_32x512_8  
5   : wb_rw_test  
Choise Top Module To Open (0-5):  
3  
"~/vexriscv_soc/testbench/gcd_la/gcd_la_tb.v" 275L, 12459C  
Press ENTER or type command to continue  
ENTER

＜Space＞＜Left＞ *mprj_io* at gcd_la_tb.v:29
![mprj_io_trace_01](https://user-images.githubusercontent.com/11850122/220661210-ea1533cf-edd6-4d1a-b342-4d2cd154956f.png)

vtags shows *mprj_io* connected to caravel module at gcd_la_tb.v:250
![mprj_io_trace_02](https://user-images.githubusercontent.com/11850122/220661770-9ceca160-e09f-4a56-921b-e93ff7cc44b6.png)

vim goto gcd_la_tb.v:250
![mprj_io_trace_03](https://user-images.githubusercontent.com/11850122/220662335-1a5faf8a-a511-40b0-9724-03cbefa32b24.png)

＜Space＞＜Left＞ *mprj_io* at gcd_la_tb.v:250
![mprj_io_trace_04](https://user-images.githubusercontent.com/11850122/220664219-67a6ddb2-c2dd-45f8-a5b3-279a3ccb44d4.png)

found *mprj_io* at caravel.v:84
![mprj_io_trace_05](https://user-images.githubusercontent.com/11850122/220663031-1b8e578e-bd11-4bbc-bf7f-928facfe2b88.png)

vim searches *mprj_io* connected to chip_io module at cavavel.v:345 then ＜Space＞＜Left＞ at *mprj_io*
![mprj_io_trace_06](https://user-images.githubusercontent.com/11850122/220777168-f17e9a53-3d57-4640-a4ba-fc0d2aa28f3b.png)

*mprj_io* at chip_io.v:92
![mprj_io_trace_06](https://user-images.githubusercontent.com/11850122/220777908-6675112e-7877-47c0-b10b-3e8943b070e8.png)

Another case, we demonstrate to find a signal *clock* drive target from gcd_la_tb module (gcd_la_tb.v) to caravel module (cavavel.v) and chip_io module (chip_io.v)

＜Space＞＜Right＞ at gcd_la_tb.v:21
![clock_drive_01](https://user-images.githubusercontent.com/11850122/220786310-33e5244d-0d6c-4e63-887d-e220745ee2fa.png)

vtags shows *clock* connected to caravel module at gcd_la_tb.v:248
![clock_drive_02](https://user-images.githubusercontent.com/11850122/220786946-a8c01e98-a525-4b30-adb8-d5dd9f487688.png)

vim goto gcd_la_tb.v:248 then ＜Space＞＜Right＞ at *clock*
![clock_drive_03](https://user-images.githubusercontent.com/11850122/220788223-73e071a3-3b7e-4f34-b844-4731ef7cb53b.png)

found *clock* at caravel.v:85 then ＜Space＞＜Right＞ at *clock*
![clock_drive_04](https://user-images.githubusercontent.com/11850122/220788441-42210697-0ccd-47b4-9b5d-7b914dae627d.png)

found *clock* connected to chip_io module at caravel.v:346 then ＜Space＞＜Right＞ at *clock*
![clock_drive_05](https://user-images.githubusercontent.com/11850122/220788689-af6fbec1-81af-474b-b74c-3a1e8aa6e79d.png)

found *clock* at chip_io.v:61 then ＜Space＞＜Right＞ at *clock*
![clock_drive_06](https://user-images.githubusercontent.com/11850122/220789214-4cb756c8-a514-43c5-a68e-eddbdcb68207.png)

found *clock* connected to *clock_core* at chip_io.v:140 then ＜Space＞＜Right＞ at *clock_core*
![clock_drive_07](https://user-images.githubusercontent.com/11850122/220789814-faf69080-ac2c-4f4f-adb4-2ab21b786775.png)

found *clock_core* declaration at chip_io.v:72
![clock_drive_08](https://user-images.githubusercontent.com/11850122/220790186-f25933ac-8860-477c-97ba-9f61cdae311d.png)

## Toolchain Reference Manual
* [Documentation for Icarus Verilog](https://steveicarus.github.io/iverilog/)
* [GTKWave 3.3 Wave Analyzer User's Guide](https://gtkwave.sourceforge.net/gtkwave.pdf)
* [vtags : verdi like, verilog code signal trace and show topo script](https://www.vim.org/scripts/script.php?script_id=5494)
