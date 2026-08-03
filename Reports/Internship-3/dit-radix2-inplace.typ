#import "@preview/acrostiche:0.7.0": *
#import "@preview/cetz:0.5.2"
#import "images/radix2-dit-fft.typ": *

== Cooley-Tukey: Radix-2 DIT <CT-radix-2inplace>
Cooley-Tukey algorithm re-expresses the #acr("DFT") of an arbitrary composite size $N = N_1 N_2$ in terms of $N_1$ smaller DFTs of sizes $N_2$, recursively, to reduce the computation time to $cal(O)(N log N)$ for highly composite $N$. Because of the algorithm's importance, specific variants and implementation styles have become known by their own names, such as Radix-2, Radix-4, mixed-radix, etc. Because the Cooley-Tukey algorithm breaks the DFT into smaller DFTs, it can be combined with any fast implementation of smaller size DFTs.

#figure(
  image("images/Cooley-tukey-general.png", width: 50%),
  caption: [Steps involved in Cooley-Tukey algorithm ],
)

A radix-2 #acr("DIT") FFT is the simplest and most common form of the Cooley-Tukey algorithm. Radix-2 DIT divides a DFT of size $N$ into two interleaved DFTs of size $N \/ 2$ with each recursive stage. Hence the overall time complexity of algorithm is $cal(O)(N log N)$. The following is the derivation of radix-2 DIT:

DFT of sequence $x_n$ is defined by:

$ X_k = sum_(n=0)^(N-1) x_n exp(-j (2 pi)/N n k) $

The radix-2 DIT algorithm rearranges the DFT of the function $x_n$  into two parts: a sum over the even-numbered indices $n = 2 m$ and a sum over the odd-numbered indices $n = 2 m + 1$:

$
  X_k & = sum_(m=0)^(N \/ 2-1) x_(2m) exp(-j (2 pi)/N (2m) k) + sum_(m=0)^(N \/ 2-1) x_(2m+1) exp(-j (2 pi)/N (2m+1) k) \
$ $
  X_k&= underbrace(sum_(m=0)^(N \/ 2-1) x_(2m) exp(-j (2 pi)/(N/2) m k), "DFT of even-indexed part of "x_n) + exp(-j (2 pi)/N k) underbrace(sum_(m=0)^(N \/ 2-1) x_(2m+1) exp(-j (2 pi)/(N/2) m k), "DFT of odd-indexed part of "x_n) \
$
The even and odd parts can be written as:
$
  X_k & = E_k + exp(-j (2 pi)/N k) O_k
$

Using the periodicity of the complex exponential, $X_(k + N/2)$ is also obtained from $E_k$ and $O_k$ as:
$ X_(k + N/2) = E_k - exp(-j (2 pi)/N k) O_k $

We can write $X_k$ and $X_(k + N/2)$ as:

$
        X_(k) & = E_k + exp(-j (2 pi)/N k) O_k \
  X_(k + N/2) & = E_k - exp(-j (2 pi)/N k) O_k
$

This result, expressing the DFT of length N recursively in terms of two DFTs of size N/2, is the core of the radix-2 DIT FFT. The algorithm gains its speed by re-using the results of intermediate computations to compute multiple DFT outputs. The final outputs are obtained by combination of $E_k$, $O_k$ and $exp(-j 2 pi k \/ N)$ (called "twiddle factor" or phase rotation factor) which is simply a size-2 DFT (also called "Butterfly"). This recursive splitting of terms into even and odd terms results in shuffling of input terms, while preserving the order of output. The operation can be expressed as a signal flow graph shown in @fig:bf8r2. @wikipedia-cooley-tukey

#figure(
  scale(reflow: true, x: 80%, y: 80%)[#DIT-fft(N: 8, v-scale: 1, h-scale: 2, bf-gap: 1.5)],
  caption: [Signal flow graph of 8-point radix-2 DIT-FFT],
)<fig:bf8r2>

In the software, assuming we have array of input $x$, the computation begins with reordering the array by swapping element at index $i$ with element at an index which is bit reverse of $i$ @digit-rev-FFT-HT. Then subsequently performing radix-2 recursively. The advantage of hardware design (in some algorithms) is that the reordering can be done with appropriate wiring wiring, hence no need of a separate reordering stage. The technique outlayed in this subsection, however, does not takes advantage of this property, due to the very nature of implementation.

=== Implementation
The implementation accepts a _fixed point_ complex number (given through 2 separate buses for real and imaginary part) and returns computed DFT through another 2 separate buses. This is a burst architecture, hence it waits for all inputs to arrive before starting the computation. Also next inputs can be given to the module only after it finishes previous computation.

#figure(
	ckt-radix2,
	caption: [Circuit of Radix-2 In-place implementation]
)

The operation described below:

+ A reset pulse is applied
+ Start signal is issued which starts a counter inside the module.
+ `input_valid` signal is applied and input is passed in each positive edge of clock.
+ After N clock cycle, when all input are be given, `input_valid` is reset and module starts computing
+ After $N log_2(N) \/ 2$ clock cycles the output will be available
+ To read output, output read enable is raised and read address is passed. In the next clock cycle the output will be obtained.

Later designs described in this chapter follows similar operation. The whole process takes $N + N log_2(N) \/ 2 + 1$ clock cycles from passing first input to getting first output: $N$ cycles for applying input and getting output and $N log_2(N) \/ 2 + 1$ cycles for computation.

The design is fully parametric -- the number of points and data width can be changed. The twiddle factor is generated using a python script. Design is limited in terms of throughput and latency and is not useful for high performance use cases. In theory, this should be most area efficient design, however due to multiple access to the memory, the synthesizer couldn't infer a BRAM, instead it went for flip-flops. As a result the design is not scalable to a very large extent.

The implementation is by no means efficient for practical use, but serves as a base upon which other algorithms can be implemented and evaluated.

*About FSM:*

When a start signal is sent, the internal counter starts running. Based on the value of the counter, the addresses of relevant data -- inputs to butterfly and twiddle factor -- is generated by address generator. A portion of the counter is bit reversed to produce an address that will be used to store the input. The computing modules and FSM all also run in parallel. The FSM has 4 states:
- IDLE (not doing any processing)
- LOAD(loading input to internal memory)
- COMPUTE (computing the results and storing it in the memory)
- DONE: All computations are done and ready for next cycle.

The operation of FSM is summarized in @fig:fsm_ditr2.
After the ouput is ready, the can be read by raising `output_read_en` and passing the address to be read in `output_read_addr`.
#figure(
  ckt-radix2-dit-fft-fsm,
  caption: [Working of FSM in Radix-2 DIT FFT],
)<fig:fsm_ditr2>
// #figure(
//   scale(80%, reflow: true)[#ckt-radix2-dit-fft],
//   caption: [Block diagram of Radix-2 DIT FFT implementation],
// )



=== Simulation result
Here 4 point DFT is computed in which input is real valued ramp signal. In the @fig:output-ditr2, the output is observed at `dout_re` and `dout_im`. The results were verified using MATLAB.
From this we can notice that there is a 9 clock cycle ($N + N/2 log_2(N) + 1$) latency to get first output (one additional clock cycle for shift register at output)
#figure(
  image("images/radix2-dit-N=4.png"),
  caption: [Simulation result of 4 point Radix-2 DIT-FFT for a ramp input],
)<fig:output-ditr2>
