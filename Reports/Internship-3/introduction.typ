#import "@preview/acrostiche:0.7.0": *

= Overview of internship
== Introduction
In #acr("DSP"), the need to express a time domain signal to frequency domiain often comes in verious settings. For this #acr("FT") is widely employed. However #acr("FT") is computationally expensive. In past century various algorithms have been proposed to comptue #acr("FT") of signals with limited compute power and memory. Even to this date, various forms of #acr("FT") algorithms have been proposed. These set are now commonly called #acr("FFT") algorithms. 

My internship is involved in implementing few of these algorithms using SystemVerilog suitable for FPGA. The architecture and operation of these algorithms are detailed in the following chapter, as well as the hardware requirements and some performance aspects are also discussed along with them. In the last chapter, a comparative analysis of all algorithms are outlayed.

For analysis purpose Artix-7 FPGA is used in all the implementation. Operating frequency of 100 MHz is targeted in all algorithms. However as we will some algorithm cannot achive this while others can go beyond this point.


== Artix-7
