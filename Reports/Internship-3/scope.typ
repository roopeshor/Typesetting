
= Future scope
The current work can be expanded in few different ways:
- Later in the course, I found that the area required during the synthesis of inplace technique can be drastically reduced by explicitly instantiating BRAM. It requires some modifications to control logic.

- In theory Winograd requires fewer number of multipliers than any Cooley-Tukey techniques. The current Winograd implementation consumes more CT techniques. This is possibly due to optimizations done by the synthesizer. Similarly other implementation can be optimized further.

- At this time, all verilog code are written to be tool agnostic and portable across different FPGA boards. This makes prototyping and learning easier as I can switch between editors and compilers. However higher performance is expected when using specific arithmetic IP core for the targetted FPGA. The performance might be drastically differnt in different FPGA families, hence various techniques can be implemented and tested in them.

- For real-valued input signals, chip area can be reduced by eliminating certain data path. Because real inputs produce symmetric DFT outputs, the hardware footprint can be pruned as the imaginary calculation pipeline and the redundant upper-frequency bins are removed. However somewhere down the pipeline, the conjugates might have to be reconstructed. But it is fairly simple as it involes changing sign of imaginary part.
