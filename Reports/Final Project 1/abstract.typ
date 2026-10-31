#import "settings.typ": addToPDFBookmark
#align(center+top)[
  #addToPDFBookmark("Abstract")
  #text(size: 16pt)[*Abstract*]
]
Accurate wind profile estimation from wind profiler radar data is important for atmospheric studies and weather forecasting, yet it remains a challenging area due to low signal-to-noise ratio and other interferences. This project investigates and evaluates Doppler spectrum processing algorithms for the 205 MHz Stratosphere-Troposphere (ST) radar facility at the Cochin University of Science and Technology (CUSAT). Specifically, we analyse the Mutual Convolution Cost Function (MCCF) and Improved Moments Estimation (IME) algorithms, alongside hybrid approaches combining mutual convolution with IME pipelines.

To assess algorithmic performance without the limitations of conventional validation tools like radiosondes, a synthetic data test bench was developed by reversing the radar signal processing chain. Diverse raw data samples incorporating crude approximations of atmospheric wind phenomena, turbulence, and clutter were generated. The algorithms were evaluated using mean square error and Pearson’s correlation coefficient. Simulation results demonstrate that the IME algorithm achieves superior accuracy and lower error rates compared to MCCF and other hybrid configurations.

#pagebreak()