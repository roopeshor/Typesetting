#import "@preview/acrostiche:0.7.0": *
#import "@preview/cetz:0.5.2"
#import "images/r2sdc.typ": *
#import "images/r2sdc2.typ": *
#import "settings.typ": fit-to-page
// #import "images/r2mdc_4.typ": *
== Radix-2 Single Path Delay Commutator (R2SDC)

Single path Delay Commutator is a different pipelined implementation of DIF algorithm. Unlike MDC, SDC produces single output per cycle and uses fewer number of shift registers, at the expense of higher latency and higher complexity of stage controllers. It works as following:
+ In first N/2 clock cycles data coming is shifted to shit registers
+ In coming cycles, $x[n]$ and $x[n + N\/2]$ datas are available. The butterfly computes the sum and difference, in which the differnce is shifted back to the same shift register and sum is passed to twiddle factor multiplier.
+ After all inputs are passed (cycles > $N$) the shift register is completely full of differences. It shifts it out to twiddle factor directly.

=== Schematic
The design is fully parametric with parameters:
- `STAGES`: number of stages. (hence total number of input points = $2^"STAGES"$)
- `DW`: Data width (default: 16 bits)
- `FIXP_Q`: Number of bits for decimal part (default: 10)

#figure(
  fit-to-page(schm-r2sdc-3),
  caption: [R2SDC algorithm],
)<fig:r2sdc-schm>

#figure(
  scale(70%, reflow: true)[#ckt-r2sdc],
  caption: [Schematic of R2SDC implementation],
)<fig:r2sdc-ckt>


#figure(
  scale(70%, reflow: true)[#ckt-r2sdc-stage],
  caption: [Inside a single R2SDC Stage. All modules with wedge is clocked],
)<fig:r2sdc-stage>

=== Simulation result
#figure(
  image("images/r2sdc_4_sim.png"),
  caption: [Simulation result for 4 point complex test signal],
)
=== Implementation results
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

  [8], [358], [44.75], [325], [0], [33], [247], [30.87], [0], [0], [8], [1.000],
  [16], [516], [32.25], [450], [0], [66], [327], [20.43], [0], [0], [12], [0.750],
  [32], [678], [21.18], [579], [0], [99], [416], [13], [0], [0], [16], [0.500],
  [64], [852], [13.31], [720], [0], [132], [522], [8.15], [0], [0], [20], [0.312],
  [128], [1072], [8.37], [874], [0], [198], [661], [5.16], [0], [0], [24], [0.187],
  [256], [1341], [5.23], [1011], [0], [330], [865], [3.37], [0], [2], [28], [0.109],
  [512], [1743], [3.40], [1149], [0], [594], [1198], [2.33], [0], [4], [32], [0.062],
  [1024], [2410], [2.35], [1288], [0], [1122], [1788], [1.74], [0], [6], [36], [0.035],
  [2048], [3642], [1.77], [1432], [0], [2210], [2893], [1.41], [0], [8], [40], [0.019],
  [4096], [5853], [1.42], [1563], [0], [4290], [5035], [1.22], [2], [8], [44], [0.010],
  [8192], [10213], [1.24], [1699], [0], [8514], [9196], [1.12], [4], [10], [48], [0.005],
)

#table(
  columns: (.7fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr),
  [N], [All Nets], [Logical Net], [All Nets/N], [Logical Net/N], [Power (mW) \*], [WNS (ns)], [$F_"max"$],
  [8], [3681], [1323], [460.12], [165.37], [145], [1.406], [116.36],
  [16], [5067], [1824], [316.68], [114], [154], [1.549], [118.32],
  [32], [6480], [2340], [202.5], [73.12], [163], [1.218], [113.86],
  [64], [7902], [2874], [123.46], [44.90], [172], [0.951], [110.50],
  [128], [8793], [3499], [68.69], [27.33], [185], [0.920], [110.13],
  [256], [10300], [4265], [40.23], [16.66], [197], [0.735], [107.93],
  [512], [12193], [5293], [23.81], [10.33], [211], [1.219], [113.88],
  [1024], [14553], [6845], [14.21], [6.68], [232], [0.693], [107.44],
  [2048], [16146], [9478], [7.88], [4.62], [263], [0.657], [107.03],
  [4096], [21727], [14150], [5.30], [3.45], [315], [0.715], [107.70],
  [8192], [31227], [22993], [3.81], [2.80], [393], [0.445], [104.65],
)

