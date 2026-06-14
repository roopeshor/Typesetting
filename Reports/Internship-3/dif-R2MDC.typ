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

=== Implementation
The design is fully parametric, in which number of stages, and data width can be changed
The design consists of a controller block that sets the starts the global counter and produces control signals. 
The outputs `out0` and `out1` are passed to cascade of R2MDC Stage blocks as shown in #ref(<fig:r2mdc-ckt>).
Each R2MDC stage is a piplelined design consisting of a butterfly unit, twiddle ROM and commutator.
Butterfly here only computes sum and difference of incoming inputs, the multiplication with twiddle factor is done using a piplelined multiplier.
The required twiddle factors are computed during synthesis and are stored in a LUT.
The control signals are also delayed by the same amount as that of data lines.
#figure(
  fit-to-page(R2MDC_4),
  caption: [Steps in R2MDC algorithm with $N=4$ case],
)<fig:dif-r2mdc-n4>



In each stage the size of delay element reduces by half. No delays, multipliers and commutators are required in final stage. The final output is obtained at `out0` and `out1` corresponding to bit reversed indexed $X[k]$ and $X[k+N\/2]$. The control signals `valid` and `counter` are synchronously passed from one stage to another, using delay. As shown in #ref(<fig:r2mdc-stage>), two time unit delay is used for pipelining: one for splitting addition and multiplication in butterfly and another one for pipelining complex multiplication in multiplier.

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
2 outputs are obtained at same clock cycle. Hence it takes $log_2(N)$ clock cycles to get all ouputs after 1st input has been inserted.
