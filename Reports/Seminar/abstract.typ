#import "settings.typ": addToPDFBookmark, fontsizes

#align(center)[
  #addToPDFBookmark("Abstract")
  #text(size: fontsizes.heading2)[*ABSTRACT*]
]
K-band Doppler wind profile radars are widely used to estimate atmospheric wind velocity and direction; however, weak atmospheric echoes are often corrupted by noise, clutter, and multiple Doppler spectral peaks under low signal-to-noise ratio (SNR) conditions. This paper proposes a Mutual Convolution Cost Function (MCCF) algorithm to improve the robustness of wind-profile estimation. The method preprocesses the radar echoes, adaptively constructs a space-time Doppler window based on wind continuity and wind-shear constraints, applies Mutual Convolution with multiple delay times to suppress uncorrelated noise while preserving coherent atmospheric echoes, and employs an improved Mutual Convolution Complex Least Mean Square (MCLMS) adaptive filter for further clutter suppression. Candidate Doppler peaks are then evaluated using a cost function that jointly considers spectral power and velocity continuity to identify the most probable atmospheric echo. Experimental evaluation using real VORTRAD K-band radar data demonstrates that the proposed method improves echo SNR by approximately 2–4 dB, significantly reduces false spectral peaks, produces smoother and more physically consistent wind profiles, and achieves correlation coefficients of approximately 0.95 with collocated LiDAR measurements, outperforming the AME, MPCF, and IME methods under low-SNR and multiple-peak conditions.

#pagebreak()