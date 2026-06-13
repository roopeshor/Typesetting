#import "@preview/acrostiche:0.7.0": *
#import "@preview/cetz:0.5.2"
#import "images/r2mdc.typ": *
#import "settings.typ": fit-to-page
#import "images/r2mdc_4.typ": *
== Radix-2 Multi Path Delay Commutator (R2MDC)

This algorithm is based on the #acf("DIF") method. In DIF, the inputs are applied in order, while output obtained will be in bit-reversed form. This allows the input to be fed sequencially. The DIF still gives similar signal flow graph as that of DIT. However the final output has particular pattern that can be used to transform this parallel structure to a pipelined multistaged architecture.

The usual stucture of DIF in the case where $N=4$ is shown in #ref(<fig:dif-signalflow-n4>).
Notice that in stage 0, $k$th and $(k+N/2)$th inputs are required ($x_0, x_2$ and $x_1, x_3$). If the data is fed sequentially then one can store first 2 data into a shift register and pop out the value afterwards. This gives the input required for butterfly in the next stage. So the corresponding outputs in each stages are: $x'_0, x'_2$ and $x'_1, x'_3$. But the next stage needs pairs $x'_0, x'_1$ and $x'_2, x'_3$. So twiddle multiplied output of this stage needs to be stored for 1 cycle. Which will satisfy condition for next stage.

In general at stage $s$($= 0,1,...S$ where $S = ceil(log_2(N))$ = number of stages) needs shift register of size $2^(S-s)$ in upper input arm of butterfly and $2^(S-s-1)$ shift register after the twiddle path. For last stage, multipliers and commuters are not needed For higher point FFT, design can be scaled easily by cascading more and more R2MDC stages.

#figure(
  R2MDC_4_signalflow,
  caption: [Signal flow graph of 4-point radix-2 DIF-FFT],
)<fig:dif-signalflow-n4>
#figure(
  fit-to-page(R2MDC_4),
  caption: [Steps in R2MDC algorithm with $N=4$ case],
)<fig:dif-r2mdc-n4>


=== Schematic
The design is fully parametric with parameters:
- `STAGES`: number of stages. (hence total number of input points = $2^"STAGES"$)
- `DW`: Data width (default: 16 bits)
- `FIXP_Q`: Number of bits for decimal part (default: 10)

The design consists of a controller block that sets the starts the global counter and produces control signals. The outputs `out0` and `out1` are passed to cascade of R2MDC Stage blocks as shown in #ref(<fig:r2mdc-ckt>). Each R2MDC stage is a piplelined design consisting of a butterfly unit, twiddle ROM and commutator. Butterfly here only computes sum and difference of incoming inputs, the multiplication with twiddle factor is done using a piplelined multiplier. The required twiddle factors are computed during synthesis and are stored in a LUT. The control signals are also delayed by the same amount as that of data lines.

In each stage the size of delay element reduces by half. No delays, multipliers and commutators are required in final stage. The final output is obtained at `out0` and `out1` corresponding to bit reversed indexed $X[k]$ and $X[k+N\/2]$. The control signals `valid` and `counter` are synchronously passed from one stage to another, using delay. As shown in #ref(<fig:r2mdc-stage>), 2 time unit delay is used for pipelining: one for splitting addition and multiplication in butterfly and another one for pipelining complex multiplication in multiplier.

#figure(
  scale(70%, reflow: true)[#ckt-r2mdc],
  caption: [Schematic of R2MDC implementation],
)<fig:r2mdc-ckt>

#figure(
  fit-to-page(ckt-r2mdc-stage),
  caption: [Inside a single R2MDC Stage. All modules with wedge is clocked],
)<fig:r2mdc-stage>

=== Simulation result
#figure(
  image("images/r2mdc_4_sim.png"),
  caption: [Simulation result for 4 point complex test signal],
)
2 outputs are obtained at same clock cycle. Hence it takes $N + N\/2$ clock cycles to get all ouputs after 1st input has been inserted.
=== Implementation result

[
#set text(size: 9pt)
==== Memory, Nets & DSP
#table(
  columns: (0.6fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr),
  [N],
  [Total LUT],
  [LUT/N],
  [Logic LUT],
  [LUT RAM],
  [SRL],
  [FF],
  [FF/N],
  [RAMB 36],
  [RAMB 18],
  [DSP Block],
  [DSP Block/N],

  [8], [279], [34.8], [246], [0], [33], [404], [50.5], [0], [0], [8], [1],
  [16], [419], [26.1], [352], [0], [67], [645], [40.3], [0], [0], [12], [0.75],
  [32], [613], [19.1], [479], [0], [134], [862], [26.9], [0], [0], [16], [0.50],
  [64], [809], [12.6], [606], [0], [203], [1091], [17.0], [0], [0], [20], [0.312],
  [128], [1049], [8.1], [744], [0], [305], [1340], [10.4], [0], [0], [24], [0.187],
  [256], [1315], [5.1], [804], [0], [511], [1627], [ 6.3], [0], [8], [28], [0.109],
  [512], [1779], [3.4], [923], [0], [856], [1967], [ 3.8], [0], [10], [32], [0.062],
  [1024], [2831], [2.7], [1040], [0], [1791], [2217], [ 2.1], [0], [12], [36], [0.035],
  [2048], [4789], [2.3], [1166], [0], [3623], [3214], [ 1.5], [0], [12], [40], [0.019],
  [4096], [8156], [1.9], [1269], [0], [6887], [4455], [ 1.0], [14], [0], [44], [0.010],
  [8192], [15189], [1.8], [1390], [0], [13799], [6746], [ 0.8], [16], [16], [48], [0.005],
)

#table(
  columns: (.7fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr),
  [N], [All Nets], [Logical Net], [All Nets/N], [Logical Net/N], [Power (mW) \*], [WNS (ns)], [$F_"max"$],
  [8], [3531], [1357], [441.3], [169.6], [176], [3.129], [145.53],
  [16], [5139], [1982], [321.1], [123.8], [187], [2.709], [137.15],
  [32], [6811], [2657], [212.8], [ 83.0], [197], [2.655], [136.14],
  [64], [8511], [3347], [132.9], [ 52.2], [209], [2.403], [131.63],
  [128], [10269], [4092], [ 80.2], [ 31.9], [221], [1.755], [121.28],
  [256], [12541], [5030], [ 48.9], [ 19.6], [250], [1.745], [121.13],
  [512], [14734], [6192], [ 28.7], [ 12.0], [264], [1.589], [118.89],
  [1024], [17278], [7695], [ 16.8], [  7.5], [293], [1.459], [117.08],
  [2048], [21627], [10929], [ 10.5], [  5.3], [332], [1.257], [114.37],
  [4096], [27581], [15826], [  6.7], [  3.8], [419], [1.430], [116.68],
  [8192], [38364], [25434], [  4.6], [  3.1], [571], [1.569], [118.60],
)
]
\* - on chip power (Confidence Level:  Medium)

