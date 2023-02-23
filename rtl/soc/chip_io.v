
/* Copyright (C) 1991-2020 Free Software Foundation, Inc.
   This file is part of the GNU C Library.

   The GNU C Library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2.1 of the License, or (at your option) any later version.

   The GNU C Library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Lesser General Public License for more details.

   You should have received a copy of the GNU Lesser General Public
   License along with the GNU C Library; if not, see
   <https://www.gnu.org/licenses/>.  */




/* This header is separate from features.h so that the compiler can
   include it implicitly at the start of every compilation.  It must
   not itself include <features.h> or any other header that includes
   <features.h> because the implicit include comes before any feature
   test macros that may be defined in a source file before it first
   explicitly includes a system header.  GCC knows the name of this
   header in order to preinclude it.  */

/* glibc's intent is to support the IEC 559 math functionality, real
   and complex.  If the GCC (4.9 and later) predefined macros
   specifying compiler intent are available, use them to determine
   whether the overall intent is to support these features; otherwise,
   presume an older compiler has intent to support these features and
   define these macros by default.  */
/* wchar_t uses Unicode 10.0.0.  Version 10.0 of the Unicode Standard is
   synchronized with ISO/IEC 10646:2017, fifth edition, plus
   the following additions from Amendment 1 to the fifth edition:
   - 56 emoji characters
   - 285 hentaigana
   - 3 additional Zanabazar Square characters */

// SPDX-FileCopyrightText: 2020 Efabless Corporation
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// SPDX-License-Identifier: Apache-2.0

// `default_nettype none
module chip_io(
 // Package Pins
 inout gpio,
 input clock,
 input resetb,
 output flash_csb,
 output flash_clk,
 inout flash_io0,
 inout flash_io1,
 // Chip Core Interface
 input porb_h,
 input por,
 output resetb_core_h,
 output clock_core,
 input gpio_out_core,
 output gpio_in_core,
 input gpio_mode0_core,
 input gpio_mode1_core,
 input gpio_outenb_core,
 input gpio_inenb_core,
 input flash_csb_core,
 input flash_clk_core,
 input flash_csb_oeb_core,
 input flash_clk_oeb_core,
 input flash_io0_oeb_core,
 input flash_io1_oeb_core,
 input flash_io0_ieb_core,
 input flash_io1_ieb_core,
 input flash_io0_do_core,
 input flash_io1_do_core,
 output flash_io0_di_core,
 output flash_io1_di_core,
 // User project IOs
 inout [`MPRJ_IO_PADS-1:0] mprj_io,
 input [`MPRJ_IO_PADS-1:0] mprj_io_out,
 input [`MPRJ_IO_PADS-1:0] mprj_io_oeb,
 input [`MPRJ_IO_PADS-1:0] mprj_io_inp_dis,
 input [`MPRJ_IO_PADS-1:0] mprj_io_ib_mode_sel,
 input [`MPRJ_IO_PADS-1:0] mprj_io_vtrip_sel,
 input [`MPRJ_IO_PADS-1:0] mprj_io_slow_sel,
 input [`MPRJ_IO_PADS-1:0] mprj_io_holdover,
 input [`MPRJ_IO_PADS-1:0] mprj_io_analog_en,
 input [`MPRJ_IO_PADS-1:0] mprj_io_analog_sel,
 input [`MPRJ_IO_PADS-1:0] mprj_io_analog_pol,
 input [`MPRJ_IO_PADS*3-1:0] mprj_io_dm,
 output [`MPRJ_IO_PADS-1:0] mprj_io_in,
 // Loopbacks to constant value 1 in the 1.8V domain
 input [`MPRJ_IO_PADS-1:0] mprj_io_one,
 // User project direct access to gpio pad connections for analog
 // (all but the lowest-numbered 7 pads)
 inout [`MPRJ_IO_PADS-10:0] mprj_analog_io
);

    // To be considered:  Master hold signal on all user pads (?)
    // For now, set holdh_n to 1 internally (NOTE:  This is in the
    // VDDIO 3.3V domain)
    // and setting enh to porb_h.

    wire [`MPRJ_IO_PADS-1:0] mprj_io_enh;

    assign mprj_io_enh = {`MPRJ_IO_PADS{porb_h}};

 wire analog_a, analog_b;
 wire vddio_q, vssio_q;

 // Instantiate power and ground pads for management domain
 // 12 pads:  vddio, vssio, vdda, vssa, vccd, vssd
 // One each HV and LV clamp.

 // HV clamps connect between one HV power rail and one ground
 // LV clamps have two clamps connecting between any two LV power
 // rails and grounds, and one back-to-back diode which connects
 // between the first LV clamp ground and any other ground.
 wire [2:0] dm_all =
      {gpio_mode1_core, gpio_mode1_core, gpio_mode0_core};
 wire[2:0] flash_io0_mode =
  {flash_io0_ieb_core, flash_io0_ieb_core, flash_io0_oeb_core};
 wire[2:0] flash_io1_mode =
  {flash_io1_ieb_core, flash_io1_ieb_core, flash_io1_oeb_core};
    wire [6:0] vccd_const_one = 7'b1111111;  // Constant value for management pins
    wire [6:0] vssd_const_zero = 7'b0; // Constant value for management pins
    assign clock_core = clock;
 assign gpio_in_core = gpio;
 bufif0(flash_io0, flash_io0_do_core, flash_io0_oeb_core);
 bufif0(flash_io1, flash_io1_do_core, flash_io1_oeb_core);
        bufif0(flash_io0_di_core, flash_io0, flash_io0_ieb_core);
     bufif0(flash_io1_di_core, flash_io1, flash_io1_ieb_core);
 assign flash_csb = flash_csb_core;
 assign flash_clk = flash_clk_core;


 // NOTE:  The analog_out pad from the raven chip has been replaced by
     // the digital reset input resetb on caravel due to the lack of an on-board
     // power-on-reset circuit.  The XRES pad is used for providing a glitch-
     // free reset.
 assign resetb_core_h = resetb;
 mprj_io mprj_pads(
  .vddio(vddio),
  .vssio(vssio),
  .vccd(vccd),
  .vssd(vssd),
  .vdda1(vdda1),
  .vdda2(vdda2),
  .vssa1(vssa1),
  .vssa2(vssa2),
  .vddio_q(vddio_q),
  .vssio_q(vssio_q),
  .analog_a(analog_a),
  .analog_b(analog_b),
  .porb_h(porb_h),
  .vccd_conb(mprj_io_one),
  .io(mprj_io),
  .io_out(mprj_io_out),
  .oeb(mprj_io_oeb),
  .enh(mprj_io_enh),
  .inp_dis(mprj_io_inp_dis),
  .ib_mode_sel(mprj_io_ib_mode_sel),
  .vtrip_sel(mprj_io_vtrip_sel),
  .holdover(mprj_io_holdover),
  .slow_sel(mprj_io_slow_sel),
  .analog_en(mprj_io_analog_en),
  .analog_sel(mprj_io_analog_sel),
  .analog_pol(mprj_io_analog_pol),
  .dm(mprj_io_dm),
  .io_in(mprj_io_in),
  .analog_io(mprj_analog_io)
 );

endmodule

// `default_nettype wire
