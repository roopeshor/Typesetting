#import "@preview/acrostiche:0.7.0": *
#import "@preview/cetz:0.5.2"
#import "images/r2sdc.typ": *
#import "images/r2sdc2.typ": *
#import "settings.typ": fit-to-page
// #import "images/r2mdc_4.typ": *
== Radix-2 Single Path Delay Commutator (R2SDC)

Single path Delay Commutator is a different pipelined implementation of DIF algorithm. Unlike MDC, SDC produces single output per cycle and uses fewer number of shift registers, at the expense of higher latency and higher complexity of stage controllers @pFFT-new-approach @zero-pad-pFFT . The whole operation is described in @fig:r2sdc-algo-steps. An overview is given below: 
+ In first N/2 clock cycles data coming is shifted to shift registers
+ In coming cycles, $x[n]$ and $x[n + N\/2]$ datas are available. The butterfly computes the sum and difference, in which the difference is shifted back to the same shift register and sum is passed to twiddle factor multiplier.
+ After all inputs are passed (cycles > $N$) the shift register is completely full of differences. It shifts it out to twiddle factor directly.

=== Implementation
The design is similar to that of MDC, with the difference that each stage now has its own counter that creates control signal for that stage.
#figure(
  scale(70%, reflow: true)[#ckt-r2sdc],
  caption: [Schematic of R2SDC implementation],
)<fig:r2sdc-ckt>

#figure(
  scale(70%, reflow: true)[#ckt-r2sdc-stage],
  caption: [Inside a single R2SDC Stage. All modules with wedge is clocked],
)<fig:r2sdc-stage>
From this point onwards, the twiddle factors are computed using `initial` blocks, which is expected to be  synthesized to a LUT. 

#figure(
  fit-to-page(schm-r2sdc-3),
  caption: [Steps involved in a 4 point R2SDC algorithm],
)<fig:r2sdc-algo-steps>




=== Simulation result
The result is similar to that of MDC case. But here due slightly different architecture, the output arrives one  clock cycle earlier.
#figure(
  image("images/r2sdc_4_sim.png"),
  caption: [Simulation result for 4 point complex test signal in R2SDC],
)
