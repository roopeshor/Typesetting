#import "@preview/acrostiche:0.7.0": *

= Overview of internship
== Introduction
In #acr("DSP"), the need to express a time domain signal in the frequency domain arises in various problems. For this, the #acr("FT") is widely used. However #acr("FT") is computationally expensive. In past century various  techniques have been proposed to compute #acr("FT") of signals with limited compute power and memory. These set of techniques are now commonly called #acr("FFT") algorithms.

My internship involves understanding, analyzing and implementing few of these algorithms using SystemVerilog in the context of FPGA. The architecture, derivation and operation of these algorithms are detailed in the following chapters. Mainly 4 algorithms are examined, namely: Inplace, R2MDC, R2SDC and Winograd. The hardware requirements and performance aspects are also discussed in @comparison. In the summary, an overall analysis of all algorithms are outlined.

For analysis, Artix-7 family of FPGA was targeted in all the implementation. Artix-7 was chosen as I found it frequently appearing in various papers. Operating frequency of 100MHz was targeted in all algorithms. However as we will see that some algorithm cannot achieve this while others can go beyond this point.

== Artix-7
Artix-7 is a family of cost-optimized FPGAs developed by AMD suitable for low power applications requiring serial transceivers and high DSP and logic throughput while providing the lowest total bill of materials.
Built on state-of-the-art, high-performance, low-power (HPL), 28 nm, high-k metal gate (HKMG) with 1.0V core voltage process technology and 0.9V core voltage option for even lower power. The specific part number used is `xc7a100tcsg324-1`.  Its salient features are: @artix-7
- 15,850 CLB slices (each containing four 6-input LUTs and eight flip-flops. Some slices can use their LUTs as distributed RAM)
- 4860 Kb dual-port block RAM
- 240 DSP slices with 25 x 18 multiplier, 48-bit accumulator, and pre-adder @dsp48
//929 GMAC/s
- 101,440 Logic cells
- 13 Mb Block RAM
- 300 User I/O with 1.2V -- 3.3V voltage rating