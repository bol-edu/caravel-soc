# Caravel SoC with CPU Trace
The Caravel SOC verification has two parts, one is the Verilog test bench, another is riscv code. The riscv code is compiled into hex file and loaded into instruction memory. When running the simulation the riscv fetched instructions and execute them to validate the design. When we use waveform tool (gtkwave) to observe the waveform of the system operation, it is very difficult to associate the part of the waveform  and the related code. Here we propose an utility "riscv-tracer". It help us to read the waveform and understand the system operation much easier.

More details in [riscv-tracer spec](https://github.com/bol-edu/caravel-soc/files/11247594/riscv-tracer.pdf).

## CPU Trace Example
Dumped into cpu_exec.log.

    // Cycle :   Count hart    pc    opcode    reg=value   ; mnemonic
    //---------------------------------------------------------------
        1294 :      #0 0000 10000000 0b00006f              ; jal      zero,0x100000b0
        1295 :      #1 0000 10000004 00000013              ; addi     zero, zero,0
        2503 :      #2 0000 100000b0 60000113              ; addi       sp, zero,1536
        2504 :      #3 0000 100000b4 00000517              ; auipc      a0,0x0
        2509 :      #4 0000 100000b8 f6c50513              ; addi       a0,   a0,-148
        2514 :      #5 0000 100000bc 30551073              ; csrrw    zero, mtvec,   a0
        3575 :      #6 0000 100000c0 00000513              ; addi       a0, zero,0
        3576 :      #7 0000 100000c4 00000593              ; addi       a1, zero,0
        3577 :      #8 0000 100000c8 00000617              ; auipc      a2,0x0
        3582 :      #9 0000 100000cc 59860613              ; addi       a2,   a2,1432
        3583 :     #10 0000 100000d0 00b50c63              ; beq        a0,   a1,0x100000e8
        4648 :     #11 0000 100000e8 00000513              ; addi       a0, zero,0
        4649 :     #12 0000 100000ec 00800593              ; addi       a1, zero,8
        4654 :     #13 0000 100000f0 00b50863              ; beq        a0,   a1,0x10000100
        4655 :     #14 0000 100000f4 00052023              ; sw       zero,0(   a0) [00000000]
        4656 :     #15 0000 100000f8 00450513              ; addi       a0,   a0,4
        4657 :     #16 0000 100000fc ff5ff06f              ; jal      zero,0x100000f0
        5720 :     #17 0000 100000f0 00b50863              ; beq        a0,   a1,0x10000100
        5721 :     #18 0000 100000f4 00052023              ; sw       zero,0(   a0) [00000004]
        5722 :     #19 0000 100000f8 00450513              ; addi       a0,   a0,4
        5723 :     #20 0000 100000fc ff5ff06f              ; jal      zero,0x100000f0
        5724 :     #21 0000 10000100 00001537              ; lui        a0,0x1000
        5728 :     #22 0000 100000f0 00b50863              ; beq        a0,   a1,0x10000100
        5729 :     #23 0000 100000f4 00052023              ; sw       zero,0(   a0) [00000008]
        5732 :     #24 0000 10000100 00001537              ; lui        a0,0x1000
        5737 :     #25 0000 10000104 88050513              ; addi       a0,   a0,-1920
        5742 :     #26 0000 10000108 30451073              ; csrrw    zero, mie,   a0
        5743 :     #27 0000 1000010c 1b0000ef              ; jal        ra,0x100002bc
        5744 :     #28 0000 10000110 0000006f              ; jal      zero,0x10000110
        6953 :     #29 0000 100002bc ff010113              ; addi       sp,   sp,-16

[Demonstration link](https://www.youtube.com/watch?v=tQr13wYYrgw#t=101m18s) in Youtube
<img src="https://user-images.githubusercontent.com/11850122/232430620-f8f27f4a-f806-4e75-917f-5f064c78f403.png" width=80%>

## Toolchain Prerequisites
* [Ubuntu 20.04+](https://releases.ubuntu.com/focal/)
* [RISC-V GCC Toolchains rv32i-4.0.0](https://github.com/stnolting/riscv-gcc-prebuilt)
* [Icarus Verilog v13](http://iverilog.icarus.com/)
* [GTKWave v3.3.103](https://gtkwave.sourceforge.net/)

## Install Icarus Verilog v13 from Source Compiling

    $ sudo apt update
    $ sudo apt install git autoconf gperf make build-essential g++ flex bison -y
    $ git clone https://github.com/steveicarus/iverilog
    $ cd iverilog/
    $ sh autoconf.sh
    $ ./configure
    $ make
    $ sudo make install
    $ iverilog -v

validate your [Icarus Verilog v13 installation](https://github.com/bol-edu/caravel-soc/blob/cpu_trace/iverilog_v13_installation.log)

## Setup and Config

    $ sudo apt update
    $ sudo apt install gtkwave gcc -y
    $ sudo wget -O /tmp/riscv32-unknown-elf.gcc-12.1.0.tar.gz https://github.com/stnolting/riscv-gcc-prebuilt/releases/download/rv32i-4.0.0/riscv32-unknown-elf.gcc-12.1.0.tar.gz
    $ sudo mkdir /opt/riscv
    $ sudo tar -xzf /tmp/riscv32-unknown-elf.gcc-12.1.0.tar.gz -C /opt/riscv
    $ git clone -b cpu-trace https://github.com/bol-edu/caravel-soc caravel-soc_cpu-trace
    $ cd caravel-soc_cpu-trace/
    $ chmod +x ./testbench/counter_la/run_sim_trace ./testbench/counter_wb/run_sim_trace ./testbench/gcd_la/run_sim_trace
    $ chmod +x ./testbench/counter_la/run_clean ./testbench/counter_wb/run_clean ./testbench/gcd_la/run_clean
    $ echo 'export PATH=$PATH:/opt/riscv/bin' >> ~/.bashrc
    $ source ~/.bashrc

## Directory Structure

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

## CPU Trace Testbenches for Custom Designs

* Counter with (LA) logic analyzer interface 
  * 32-bit LA input  
  * 32-bit LA output
  * 16-bit mrpj_io as output
  
  Files for cpu trace simulation:  
  ##################################################  
  caravel-soc_cpu-trace/testbench/counter_la/counter_la.c  
  caravel-soc_cpu-trace/testbench/counter_la/counter_la_tb.v  
  caravel-soc_cpu-trace/testbench/counter_la/cpu_trace.v  
  caravel-soc_cpu-trace/testbench/counter_la/dasm.v  
  caravel-soc_cpu-trace/testbench/counter_la/include.rtl.list  
  caravel-soc_cpu-trace/testbench/counter_la/run_sim_trace  
  ##################################################
  
 /caravel-soc_cpu-trace/testbench/counter_la$ ./run_sim_trace  
 Reading counter_la.hex  
 counter_la.hex loaded into memory  
 Memory 5 bytes = 0x6f 0x00 0x00 0x0b 0x13  
 VCD info: dumpfile counter_la.vcd opened for output.  
 LA Test 1 started  
 output:  
 LA Test 2 passed  
 /caravel-soc/testbench/counter_la$ gtkwave counter_la.vcd
 
 * Counter with wishbone interface
  * 32-bit wishbone input  
  * 32-bit wishbone output
  * 16-bit mrpj_io as output
  
  Files for cpu trace simulation:  
  ##################################################  
  caravel-soc_cpu-trace/testbench/counter_wb/counter_wb.c  
  caravel-soc_cpu-trace/testbench/counter_wb/counter_wb_tb.v  
  caravel-soc_cpu-trace/testbench/counter_wb/cpu_trace.v  
  caravel-soc_cpu-trace/testbench/counter_wb/dasm.v  
  caravel-soc_cpu-trace/testbench/counter_wb/include.rtl.list  
  caravel-soc_cpu-trace/testbench/counter_wb/run_sim_trace  
  ##################################################
  
 caravel-soc_cpu-trace/testbench/counter_wb$ ./run_sim_trace  
 Reading counter_wb.hex  
 counter_wb.hex loaded into memory  
 Memory 5 bytes = 0x6f 0x00 0x00 0x0b 0x13  
 VCD info: dumpfile counter_wb.vcd opened for output.  
 Monitor: MPRJ-Logic WB Started  
 Monitor: Mega-Project WB (RTL) Passed  
 caravel-soc/testbench/counter_wb$ gtkwave counter_wb.vcd
 
 * GCD with (LA) logic analyzer interface
  * 32-bit x 2 LA input  
  * 32-bit LA output
  * 16-bit mrpj_io as output
  
  Files for simulation:  
  ##################################################  
  caravel-soc_cpu-trace/testbench/gcd_la/gcd_la.c  
  caravel-soc_cpu-trace/testbench/gcd_la/gcd_la_tb.v  
  caravel-soc_cpu-trace/testbench/gcd_la/cpu_trace.v  
  caravel-soc_cpu-trace/testbench/gcd_la/dasm.v  
  caravel-soc_cpu-trace/testbench/gcd_la/include.rtl.list  
  caravel-soc_cpu-trace/testbench/gcd_la/run_sim_trace  
  ##################################################
  
 caravel-soc_cpu-trace/testbench/gcd_la$ ./run_sim_trace  
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
 caravel-soc/testbench/gcd_la$ gtkwave gcd_la.vcd  

## Toolchain Reference Manuals
* [Documentation for Icarus Verilog](https://steveicarus.github.io/iverilog/)
* [GTKWave 3.3 Wave Analyzer User's Guide](https://gtkwave.sourceforge.net/gtkwave.pdf)
