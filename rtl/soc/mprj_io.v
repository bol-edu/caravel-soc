
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

/* Define the array of GPIO pads.  Note that the analog project support
 * version of caravel (caravan) defines fewer GPIO and replaces them
 * with analog in the chip_io_alt module.  Because the pad signalling
 * remains the same, `MPRJ_IO_PADS does not change, so a local parameter
 * is made that can be made smaller than `MPRJ_IO_PADS to accommodate
 * the analog pads.
 */

module mprj_io #(
    parameter AREA1PADS = `MPRJ_IO_PADS_1,
    parameter TOTAL_PADS = `MPRJ_IO_PADS
) (
    inout vddio,
    inout vssio,
    inout vdda,
    inout vssa,
    inout vccd,
    inout vssd,

    inout vdda1,
    inout vdda2,
    inout vssa1,
    inout vssa2,

    input vddio_q,
    input vssio_q,
    input analog_a,
    input analog_b,
    input porb_h,
    input [TOTAL_PADS-1:0] vccd_conb,
    inout [TOTAL_PADS-1:0] io,
    input [TOTAL_PADS-1:0] io_out,
    input [TOTAL_PADS-1:0] oeb,
    input [TOTAL_PADS-1:0] enh,
    input [TOTAL_PADS-1:0] inp_dis,
    input [TOTAL_PADS-1:0] ib_mode_sel,
    input [TOTAL_PADS-1:0] vtrip_sel,
    input [TOTAL_PADS-1:0] slow_sel,
    input [TOTAL_PADS-1:0] holdover,
    input [TOTAL_PADS-1:0] analog_en,
    input [TOTAL_PADS-1:0] analog_sel,
    input [TOTAL_PADS-1:0] analog_pol,
    input [TOTAL_PADS*3-1:0] dm,
    output [TOTAL_PADS-1:0] io_in,
    output [TOTAL_PADS-1:0] io_in_3v3,
    inout [TOTAL_PADS-10:0] analog_io,
    inout [TOTAL_PADS-10:0] analog_noesd_io
);

    wire [TOTAL_PADS-1:0] loop0_io; // Internal loopback to 3.3V domain ground
    wire [TOTAL_PADS-1:0] loop1_io; // Internal loopback to 3.3V domain power
    wire [6:0] no_connect_1a, no_connect_1b;
    wire [1:0] no_connect_2a, no_connect_2b;
boledu_io io_pad[TOTAL_PADS -1: 0] (
 .io(io[TOTAL_PADS-1:0]),
 .io_out (io_out[TOTAL_PADS - 1:0]),
 .oeb( oeb[TOTAL_PADS-1:0]),
 .io_in ( io_in[TOTAL_PADS-1:0])
);


endmodule


module boledu_io( inout io,
       input io_out,
       input oeb,
   output io_in);
 // bufif0(io_in, io, oeb);
 assign io_in = io;
 bufif0(io, io_out, oeb);
 pullup (io);

endmodule


// `default_nettype wire
