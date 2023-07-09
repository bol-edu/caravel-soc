# 全端IC設計工程師養成計劃 (FullStack IC Designer Development)
The FullStack IC Designer Development will base on the [Caravel SoC](https://github.com/bol-edu/caravel-soc) backbone. We target two ASIC tapeouts: Google Efabless SKY130 with open source EDA flow ([Openlane](https://github.com/bol-edu/openlane-lab) & [Efabless Caravel](https://github.com/bol-edu/caravel-lab)) and TSMC 0.18um with commercial EDA flow. We also plan to develop a validation system for the chips that come back as verification.

[FullStack IC Designer Development](https://github.com/bol-edu/caravel-soc/files/10835377/accomdemy-fsic-1st-meeting.pdf)

## Caravel SoC
Caravel SoC is a platform for developing RISC-V CPU based hardware and software referred from [Efabless Caravel “harness” SoC](https://caravel-harness.readthedocs.io/en/latest/#efabless-caravel-harness-soc). You can develop and integrate custom design into this platform, then vefify their functionality with open source toolchain.

<img src="https://user-images.githubusercontent.com/11850122/220771595-250f3dfd-8eb9-4216-9a63-91d4c40e28de.png" width=70%>

More detail can be found in [Caravel's system specification](https://github.com/efabless/caravel/tree/main/docs/pdf).

## Toolchain Prerequisites
* [Ubuntu 20.04+](https://releases.ubuntu.com/focal/)
* [RISC-V GCC Toolchains rv32i-4.0.0](https://github.com/stnolting/riscv-gcc-prebuilt)
* [Icarus Verilog v10.3](http://iverilog.icarus.com/)
* [Icarus Verilog v12 + GTKWave Windows](https://bleyer.org/icarus/) (option)
* [GTKWave v3.3.103](https://gtkwave.sourceforge.net/)
* [vtags-3.11](https://www.vim.org/scripts/script.php?script_id=5494)
* [GDBWave](https://tomverbeure.github.io/2022/02/20/GDBWave-Post-Simulation-RISCV-SW-Debugging.html) 

## Setup and Config

```console
$ sudo apt update
$ sudo apt install iverilog gtkwave vim python gcc git -y
$ sudo wget -O /tmp/riscv32-unknown-elf.gcc-12.1.0.tar.gz https://github.com/stnolting/riscv-gcc-prebuilt/releases/download/rv32i-4.0.0/riscv32-unknown-elf.gcc-12.1.0.tar.gz
$ sudo mkdir /opt/riscv
$ sudo tar -xzf /tmp/riscv32-unknown-elf.gcc-12.1.0.tar.gz -C /opt/riscv
$ sudo wget -O /tmp/vtags-3.11.tar.gz https://www.vim.org/scripts/download_script.php?src_id=28365
$ sudo tar -xzf /tmp/vtags-3.11.tar.gz -C /opt
$ python /opt/vtags-3.11/vim_glb_config.py
$ git clone https://github.com/bol-edu/caravel-soc ~/caravel-soc
$ cd ~/caravel-soc/
$ python /opt/vtags-3.11/vtags.py
$ cd ~/ && rm -rf ~/caravel-soc/
$ echo 'export PATH=$PATH:/opt/riscv/bin' >> ~/.bashrc
$ echo 'alias vtags="python /opt/vtags-3.11/vtags.py"' >> ~/.bashrc
$ echo 'source /opt/vtags-3.11/vtags_vim_api.vim' >> ~/.vimrc
$ source ~/.bashrc
```
validate your [setup & config](https://github.com/bol-edu/caravel-soc/blob/main/setup_config.log)

## Setup GDBWave - Post Simulation Debugging
```console
$ sudo apt install make g++ zlib1g-dev gdb -y
$ git clone https://github.com/tomverbeure/gdbwave.git ~/gdbwave
$ pushd ~/gdbwave/src && make && popd
```
validate your [setup gdbwave - post simulation debugging](https://github.com/bol-edu/caravel-soc/blob/main/setup_gdbwave.log)


## Directory Structure

```
├── cvc-pdk                 # SKY130 OpenRAM SRAM Model
├── firmware                # Caravel System Firmware Libraries
├── rtl                     # Caravel RTL Designs
│   ├── header              # Headers
│   ├── soc                 # Boledu Revised SoC
│   ├── user                # User Project Designs
├── testbench               # Caravel Testbenches
│   ├── counter_la          # Counter with Logic Analyzer Interface
│   ├── counter_wb          # Counter with Wishbone Interface
│   └── gcd_la              # GCD with Logic Analyzer Interface
└── vip                     # Caravel Verification IP
```

## Testbenches for Custom Designs
In each testbench subdirectory contains 
1. Firmware driver (.c).  
2. RTL testbench (.v). 
3. Included RTL files (.list). 
4. Run simulation script calls riscv32 command to compile c source to hex target and invokes iverilog && vvp to run RTL simulation. 
5. GTKWave save file (.gtkw) saves selected signals from caravel-soc modules and corresponded testbench module. 
6. Run debugging script produces gdb elf file, fst waveform file and starts gdbwave service (gdb remote target). 
7. Make files and config file for gdb and gdbwave debugging. 
8. Run clean script removes all simulation and debugging objects. The run debugging script use cases will be demonstrated in next section.

Git Clone Caravel SoC before Running Testbenches
```console
$ git clone https://github.com/bol-edu/caravel-soc ~/caravel-soc
```

### Counter with (LA) logic analyzer interface 
* 32-bit LA input  
* 32-bit LA output
* 16-bit mrpj_io as output
  
Files for simulation:  
```  
caravel-soc/testbench/counter_la/counter_la.c  
caravel-soc/testbench/counter_la/counter_la_tb.v  
caravel-soc/testbench/counter_la/include.rtl.list  
caravel-soc/testbench/counter_la/run_sim  
caravel-soc/testbench/counter_la/waveform.gtkw  
```
  
```console
$ cd ~/caravel-soc/testbench/counter_la
$ ./run_sim
Reading counter_la.hex  
counter_la.hex loaded into memory  
Memory 5 bytes = 0x6f 0x00 0x00 0x0b 0x13  
VCD info: dumpfile counter_la.vcd opened for output.  
LA Test 1 started  
output:  
LA Test 2 passed  
$ gtkwave waveform.gtkw  
```
![counter_la_waveform](https://user-images.githubusercontent.com/11850122/220594971-0dc2047d-6883-445e-944e-4cc736c0ab7e.png)

### Counter with wishbone interface
* 32-bit wishbone input  
* 32-bit wishbone output
* 16-bit mrpj_io as output
  
Files for simulation:  
```
caravel-soc/testbench/counter_wb/counter_wb.c  
caravel-soc/testbench/counter_wb/counter_wb_tb.v  
caravel-soc/testbench/counter_wb/include.rtl.list  
caravel-soc/testbench/counter_wb/run_sim  
caravel-soc/testbench/counter_wb/waveform.gtkw  
```
  
```console
$ cd ~/caravel-soc/testbench/counter_wb
$ ./run_sim
Reading counter_wb.hex  
counter_wb.hex loaded into memory  
Memory 5 bytes = 0x6f 0x00 0x00 0x0b 0x13  
VCD info: dumpfile counter_wb.vcd opened for output.  
Monitor: MPRJ-Logic WB Started  
Monitor: Mega-Project WB (RTL) Passed  
$ gtkwave waveform.gtkw  
```
![counter_wb_waveform](https://user-images.githubusercontent.com/11850122/220597221-3a266f07-1525-4c64-92a8-216b5fe82e25.png)
   
### GCD with (LA) logic analyzer interface
* 32-bit x 2 LA input  
* 32-bit LA output
* 16-bit mrpj_io as output

Files for simulation:  
```  
caravel-soc/testbench/gcd_la/gcd_la.c  
caravel-soc/testbench/gcd_la/gcd_la_tb.v  
caravel-soc/testbench/gcd_la/include.rtl.list  
caravel-soc/testbench/gcd_la/run_sim  
caravel-soc/testbench/gcd_la/waveform.gtkw  
```
```console
$ cd ~/caravel-soc/testbench/gcd_la
$ ./run_sim 
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
$ gtkwave waveform.gtkw
```
![gcd_la_waveform](https://user-images.githubusercontent.com/11850122/220589367-339a7e00-ca5c-4070-a38a-cce3eefb4441.png)

## GDB + GDBWave Debugging for Custom Designs
### Counter with (LA) logic analyzer interface

Files for debugging:  
```  
caravel-soc/testbench/counter_la/counter_la.c  
caravel-soc/testbench/counter_la/counter_la_tb.v  
caravel-soc/testbench/counter_la/gdb.make  
caravel-soc/testbench/counter_la/gdbwave.config  
caravel-soc/testbench/counter_la/gdbwave.make  
caravel-soc/testbench/counter_la/include.rtl.list  
caravel-soc/testbench/counter_la/run_debug  
```
  
execute run_debug to start gdbwave service and wait gdb connection  
```console
$ cd ~/caravel-soc/testbench/counter_la
$ ./run_debug
```
 <img src="https://user-images.githubusercontent.com/11850122/224581458-7b0aceac-e9eb-4489-8395-8f88171d6fef.png" width=40%>

 open another ssh terminal, change directory `cd ~/caravel-soc/testbench/counter_la/gdb.debug` and run `make gdb`, then
 execute gdb debug commands: (1) n (2) b main (3) c (4) b 122 (5) c (6) list (7) n (8) n (9) n (10) n (11) quit   
    
 <img src="https://user-images.githubusercontent.com/11850122/224581467-7908c1cd-e6c3-4788-9005-944a8e314969.png" width=62%>
 
 counter_la.c (section)
  
 <img src="https://user-images.githubusercontent.com/11850122/224581751-93d5b737-3a96-4e55-ace4-69e0eb45ccf0.png" width=60%>

 gdbwave disconnection to gdb
  
 <img src="https://user-images.githubusercontent.com/11850122/224581471-a0cb0406-24f3-48a5-928b-290b6b202f9b.png" width=50%>

### Counter with wishbone interface

Files for debugging:  
```  
caravel-soc/testbench/counter_wb/counter_wb.c  
caravel-soc/testbench/counter_wb/counter_wb_tb.v  
caravel-soc/testbench/counter_wb/gdb.make  
caravel-soc/testbench/counter_wb/gdbwave.config  
caravel-soc/testbench/counter_wb/gdbwave.make  
caravel-soc/testbench/counter_wb/include.rtl.list  
caravel-soc/testbench/counter_wb/run_debug  
```

execute run_debug to start gdbwave service and wait gdb connection  
```console
$ cd ~/caravel-soc/testbench/counter_wb
$ ./run_debug
```
<img src="https://user-images.githubusercontent.com/11850122/224583251-8e50e08f-e6c0-44bf-9b02-6f2ef353e0bd.png" width=40%>

open another ssh terminal, change directory `cd ~/caravel-soc/testbench/counter_wb/gdb.debug` and run `make gdb`, then
execute gdb debug commands: (1) n (2) b main (3) c (4) b 83 (5) c (6) list (7) n (8) n (9) n (10) n (11) quit   
   
 <img src="https://user-images.githubusercontent.com/11850122/224583295-f2485848-9581-484e-82c5-e54b0e5c0af7.png" width=52%>
 
 counter_wb.c (section)
 
 <img src="https://user-images.githubusercontent.com/11850122/224583669-46c423e5-c55c-4be9-b692-4ab6e8315d63.png" width=48%>

 gdbwave disconnection to gdb
   
 <img src="https://user-images.githubusercontent.com/11850122/224583367-87d351e3-ff7c-4cdf-802c-2ff34517c74a.png" width=50%>

 ### GCD with (LA) logic analyzer interface

Files for debugging:  
```  
caravel-soc/testbench/gcd_la/gcd_la.c  
caravel-soc/testbench/gcd_la/gcd_la_tb.v  
caravel-soc/testbench/gcd_la/gdb.make  
caravel-soc/testbench/gcd_la/gdbwave.config  
caravel-soc/testbench/gcd_la/gdbwave.make  
caravel-soc/testbench/gcd_la/include.rtl.list  
caravel-soc/testbench/gcd_la/run_debug  
```
  
 execute run_debug to start gdbwave service and wait gdb connection  
 ```console
 $ cd ~/caravel-soc/testbench/gcd_la
 $ ./run_debug
 ```
 <img src="https://user-images.githubusercontent.com/11850122/224579561-adf3a8a7-bc87-4af8-944f-65d0b2b438dc.png" width=40%>

 open another ssh terminal, change directory `cd ~/caravel-soc/testbench/gcd_la/gdb.debug` and run `make gdb`, then
 execute gdb debug commands: (1) n (2) b main (3) c (4) b 148 (5) c (6) list (7) p i (8) c (9) p i (10) c (11) p i (12) c   
 (13) p i (14) c (15) p i (16) n (17) n (18) n (19) n (20) quit
  
 <img src="https://user-images.githubusercontent.com/11850122/224579568-7efc1292-f6d7-4e6c-9fe4-3f253f3cc947.png" width=48%>
 <img src="https://user-images.githubusercontent.com/11850122/224579572-a17ca83c-2df9-4972-b90a-ece4f6ae6401.png" width=48%>
 
 gcd_la.c (section)
 
 <img src="https://user-images.githubusercontent.com/11850122/224579839-5563fd54-744a-4982-b360-88bc47e1df43.png" width=72%>
 
 gdbwave disconnection to gdb
   
 <img src="https://user-images.githubusercontent.com/11850122/224579580-30b0c4eb-17b9-483b-bad2-90c0afd77070.png" width=50%>

## Trace Verilog Code with Vim + vtags
We use vim + vtags to find signal trace source/drive target. First case, we demonstrate a signal *mprj_io* at gcd_la_tb module (gcd_la_tb.v) can be traced back to caravel module (cavavel.v) and chip_io module (chip_io.v).

```console
$ cd ~/caravel-soc
$ vtags
$ vim vtags.db/
```
----------------Top Module List-------------  
0   : counter_la_tb  
1   : counter_wb_tb  
2   : debug_regs  
3   : gcd_la_tb  
4   : sky130_sram_2kbyte_1rw1r_32x512_8  
5   : wb_rw_test  
Choise Top Module To Open (0-5):  
3  
"~/caravel-soc/testbench/gcd_la/gcd_la_tb.v" 275L, 12459C  
Press ENTER or type command to continue  
ENTER

＜Space＞＜Left＞ *mprj_io* at gcd_la_tb.v:29
![mprj_io_trace_01](https://user-images.githubusercontent.com/11850122/220661210-ea1533cf-edd6-4d1a-b342-4d2cd154956f.png)

vtags shows *mprj_io* connected to caravel module at gcd_la_tb.v:250
![mprj_io_trace_02](https://user-images.githubusercontent.com/11850122/221042505-377fe242-7d9e-43ae-97f5-540f5a4dd6ba.png)

vim goto gcd_la_tb.v:250
![mprj_io_trace_03](https://user-images.githubusercontent.com/11850122/221042971-450f4e17-ce72-413c-af81-a68b1e6a10be.png)

＜Space＞＜Left＞ *mprj_io* at gcd_la_tb.v:250
![mprj_io_trace_04](https://user-images.githubusercontent.com/11850122/221044313-490edc1a-c545-42e1-9aae-56955253bb6d.png)

found *mprj_io* at caravel.v:84
![mprj_io_trace_05](https://user-images.githubusercontent.com/11850122/221044644-638d140f-1e41-40bf-becd-d81b5833cce3.png)

vtags can't fully parse dependencies of caravel.v, we use vim to find *mprj_io* connected to chip_io module at cavavel.v:345, then ＜Space＞＜Left＞ at *mprj_io*
![mprj_io_trace_06](https://user-images.githubusercontent.com/11850122/221045046-95b8fae0-007b-4f7c-b70f-ac7590e49a4a.png)

*mprj_io* at chip_io.v:92
![mprj_io_trace_06](https://user-images.githubusercontent.com/11850122/221045198-c30f4aa1-83e2-49b6-b221-382cd8ae945b.png)

Another case, we demonstrate to find a signal *clock* drive target from gcd_la_tb module (gcd_la_tb.v) to caravel module (cavavel.v) and chip_io module (chip_io.v)

＜Space＞＜Right＞ at gcd_la_tb.v:21
![clock_drive_01](https://user-images.githubusercontent.com/11850122/220786310-33e5244d-0d6c-4e63-887d-e220745ee2fa.png)

vtags shows *clock* connected to caravel module at gcd_la_tb.v:248 (current line), then ＜Space＞＜Right＞ at *clock*
![clock_drive_02](https://user-images.githubusercontent.com/11850122/221049213-5b727542-42a4-44f9-aaf3-ae0af4f4ecfa.png)

found *clock* at caravel.v:85, then ＜Space＞＜Right＞ at *clock*
![clock_drive_03](https://user-images.githubusercontent.com/11850122/221049862-8f8bdc8e-a3df-4395-a8a9-7bc2ff360864.png)

found *clock* connected to chip_io module at caravel.v:346, then ＜Space＞＜Right＞ at *clock*
![clock_drive_04](https://user-images.githubusercontent.com/11850122/221050081-03dc25e3-4bf0-4ff3-ab0e-d9efc11773ef.png)

found *clock* at chip_io.v:62, then ＜Space＞＜Right＞ at *clock*
![clock_drive_05](https://user-images.githubusercontent.com/11850122/221050329-d9aa378f-450c-4ec6-8687-cf1bfe24756d.png)

found *clock* connected to *clock_core* at chip_io.v:140, then ＜Space＞＜Right＞ at *clock_core*
![clock_drive_06](https://user-images.githubusercontent.com/11850122/221052241-8f5407cf-2cda-4add-a296-db4de470dbf5.png)

found *clock_core* declaration at chip_io.v:72
![clock_drive_07](https://user-images.githubusercontent.com/11850122/221051163-2d8ef061-3575-47c6-addf-4fb2835a1be8.png)

## Toolchain Reference Manuals
* [Documentation for Icarus Verilog](https://steveicarus.github.io/iverilog/)
* [GTKWave 3.3 Wave Analyzer User's Guide](https://gtkwave.sourceforge.net/gtkwave.pdf)
* [vtags : verdi like, verilog code signal trace and show topo script](https://www.vim.org/scripts/script.php?script_id=5494)
* [Common GDB Commands](https://people.computing.clemson.edu/~chochri/gdb-basics.pdf)
* [GDBWave - A Post-Simulation Waveform-Based RISC-V GDB Debugging Server](https://tomverbeure.github.io/2022/02/20/GDBWave-Post-Simulation-RISCV-SW-Debugging.html) 

## Research Papers
* [GHAZI: An Open-Source ASIC Implementation of RISC-V based SoC based SoC, 2022](https://www.techrxiv.org/articles/preprint/GHAZI_An_Open-Source_ASIC_Implementation_of_RISC-V_based_SoC/21770456)
* [IBTIDA: Fully open-source ASIC implementation of Chisel-generated System on a Chip, 2021](https://www.researchgate.net/profile/Sajjad-Ahmed-23/publication/355051535_IBTIDA_Fully_open-source_ASIC_implementation_of_Chisel-generated_System_on_a_Chip/links/6176fc903c987366c3e65a68/IBTIDA-Fully-open-source-ASIC-implementation-of-Chisel-generated-System-on-a-Chip.pdf) 
