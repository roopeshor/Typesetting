#import "@preview/acrostiche:0.7.0": *
#import "@preview/cetz:0.5.2"
#import "images/r2mdc.typ": *
#import "images/r2mdc_4.typ": *
== Radix-2 Multi Path Delay Commutator

This algorithm is based on the #acf("DIF") method. Stucture and flow of this algorithm in the case where $N=4$ is shown in #ref(<fig:dif-r2mdc-n4>). The derivation is as following. Consider a general $N=4$ DIF Signal flow graph shown in #ref(<fig:dif-n4>). To obtain the final output input pairs $a$, $c$ and $b$ and $d$  must be present at the time of processing. To do this, the first $N\/2 = 2$ inputs has to be delayed (using shift registers). So at first, a commutator (shown as a demuxer) commutes inital $N\/2$ samples to delay block and commutes rest of the samples to bottom part of butterfly.
#figure(
  R2MDC_4_signalflow,
  caption: [Signal flow graph of 4-point radix-2 DIF-FFT],
)<fig:dif-n4>
+ In Cycle 0 represents initial state where first input is available at demux.
+ In Cycle 1 and 2, the first 2 inputs are loaded into memory.
+ In Cycle 3, the 3rd input is commuted to bottom part of 1st stage butterfly, the output is available to latch in the flip flops in the next stage.
+ In cycle 4 and 5, all inputs have been given and meaningful outputs from the FFT block will be obtained -- $X[0]$ and $X[2]$ in cycle 4 and $X[1]$ and $X[3]$ in cycel 5.
#figure(
  R2MDC_4,
	caption: [Steps in R2MDC algorithm with $N=4$ case]
)<fig:dif-r2mdc-n4>


=== Schematic
The design is fully parametric with parameters:
- `STAGES`: number of stages. (hence total number of input points = $2^"STAGES"$)
- `DW`: Data width (default: 16 bits)
- `FIXP_Q`: Number of bits for decimal part (default: 10)

The design consists of a input delay block that sets the initial delay of $N\/2$. The outputs `delayed` and `undelayed` are passed to cascade of R2MDC Stage blocks. Each R2MDC stage is a piplelined design consisting of a butterfly unit, twiddle ROM and commutator. Butterfly here only computes sum and difference of incoming inputs, the multiplication with twiddle factor is done using a piplelined multiplier. The required twiddle factors are computed during synthesis and are stored in a LUT. The control signals are also delayed by the same amount as that of data lines.

In each stage the size of delay element reduces by half. No delays, multipliers and commutators are required in final stage. The final output is obtained at `out0` and `out1` corresponding to bit reversed indexed $X[k]$ and $X[k+N\/2]$

#figure(
	scale(65%, reflow: true)[#ckt-r2mdc],
	caption: [Schematic of R2MDC implementation]
)

=== implementation result
table: for 16 Bit FIXP=10, N=8 obtained by:

#text(size: 6pt)[```
  >> report_utilization -hierarchical
  +--------------------------------+------------------------------+------------+------------+---------+------+-----+--------+--------+------------+
  |            Instance            |            Module            | Total LUTs | Logic LUTs | LUTRAMs | SRLs | FFs | RAMB36 | RAMB18 | DSP Blocks |
  +--------------------------------+------------------------------+------------+------------+---------+------+-----+--------+--------+------------+
  | R2MDC                          |                        (top) |        281 |        248 |       0 |   33 | 404 |      0 |      0 |          8 |
  |   (R2MDC)                      |                        (top) |          0 |          0 |       0 |    0 |   7 |      0 |      0 |          0 |
  |   gen_stages[1].stage_inst     |                  R2MDC_stage |         84 |         84 |       0 |    0 | 166 |      0 |      0 |          4 |
  |     (gen_stages[1].stage_inst) |                  R2MDC_stage |          0 |          0 |       0 |    0 |  68 |      0 |      0 |          0 |
  |     gen_stage.comm             |                   Commutator |         80 |         80 |       0 |    0 |  98 |      0 |      0 |          0 |
  |   gen_stages[2].stage_inst     |  R2MDC_stage__parameterized0 |         83 |         82 |       0 |    1 |  99 |      0 |      0 |          4 |
  |     (gen_stages[2].stage_inst) |  R2MDC_stage__parameterized0 |          1 |          0 |       0 |    1 |  66 |      0 |      0 |          0 |
  |   gen_stages[3].stage_inst     |  R2MDC_stage__parameterized1 |          0 |          0 |       0 |    0 |  65 |      0 |      0 |          0 |
  |     (gen_stages[3].stage_inst) |  R2MDC_stage__parameterized1 |          0 |          0 |       0 |    0 |  65 |      0 |      0 |          0 |
  |   s2p                          |                   S2P_Buffer |        114 |         82 |       0 |   32 |  67 |      0 |      0 |          0 |
  |     d_r                        | Delay_pipe__parameterized3_0 |         56 |         40 |       0 |   16 |  32 |      0 |      0 |          0 |
  |     d_i                        |   Delay_pipe__parameterized3 |         56 |         40 |       0 |   16 |  32 |      0 |      0 |          0 |
  +--------------------------------+------------------------------+------------+------------+---------+------+-----+--------+--------+------------+
  ```
  ```
  >> llength [get_nets -hierarchical]
  3898
  >> report_route_status -show_all
  Design Route Status
                                                 :      # nets :
     ------------------------------------------- : ----------- :
     # of logical nets.......................... :        1541 :
         # of nets with no placed pins.......... :        1541 :
         # of nets not needing routing.......... :           0 :
         # of routable nets..................... :           0 :
         # of nets with routing errors.......... :           0 :
     ------------------------------------------- : ----------- :

  ```

]
