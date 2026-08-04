#import "settings.typ": flex-caption
= Results

The authors have evaluated the algorithm in four ways: Delay time for mutual convolution, effectiveness in reducing clutter and improving SNR, comparing wind profile estimate with existing algorithm, validating the estimated wind velocities against LiDAR using correlation coefficient.
Each experiment methods gives a different aspect of the proposed algorithm.
#v(-10pt)
== Performance Evaluation at Different Delay Times
This experiment investigates how the delay time used in the Mutual Convolution stage affects clutter suppression. The algorithm correlates the original signal with delayed versions of itself. If the delay is too short, the clutter and noise remain highly correlated and are not sufficiently suppressed. If the delay is too large, even the atmospheric echo begins to decorrelate, reducing the effectiveness of the filtering.

#figure(
  caption: [Range-Doppler power spectra after preprocessing],
  image("images/res1a.jpg", height: 4cm),
)<img:res1a>

The researchers begin by showing the preprocessed Doppler spectra in @img:res1a. These spectra correspond to echoes between 220 m and 300 m altitude. The red dots represent all spectral peaks that satisfy the candidate selection criteria. One important observation is that only the 240 m range bin exhibits a clearly distinguishable atmospheric peak, while the remaining range bins contain numerous peaks of nearly equal amplitude. This illustrates the primary challenge addressed by the paper: under low SNR conditions, simply selecting the strongest peak can easily lead to an incorrect wind estimate because many clutter and noise peaks have comparable power.

To determine the best delay, the researchers repeat the mutual convolution process using eight different delay values, ranging from $d_t$ to $8d_t$. The filtering results are presented in @img:delays. Each subfigure shows the Doppler spectra obtained using a different delay. From this we can conclude that the optimal delay is not same for every altitude.

#figure(
  caption: flex-caption([Effect of delay in optimal solutions (marked by red dotted box) of different range bin after mutual convolution], [Effect of delay in optimal solutions of different range bin after mutual convolution]),
  image("images/delays.jpg"),
)<img:delays>
#v(-10pt)
To further analyze this behavior, the authors process 2500 radar frames collected on January 11, 2023. The atmosphere is divided into eight 40 m range intervals, and for every frame they record which delay produces the strongest mutual convolution result. These statistics are summarized in @tab:stats. Although different delays occasionally become optimal, the smallest delay $d_t$
is selected far more frequently than the others across all range bins. The frequency of selecting larger delays decreases steadily. Based on these statistics, the authors conclude that while the optimal delay varies with atmospheric conditions, shorter delays generally provide the most reliable filtering performance and excessively large delays should be avoided because they reduce signal correlation.
#set text(size: 11pt)
#figure(
  caption: [Statistics of optimal delay time for mutual convolution],
  table(
    columns: (2fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr),
    stroke: none,
    inset: 3pt,
    table.hline(),
    [Delay], table.vline(), [RI], [R2], [R3], [R4], [R5], [R6], [R7], [R8],
    table.hline(),
    [$d_t$], [1543], [1503], [1568], [1471], [1486], [1488], [1498], [1568],
    [$2d_t$], [444], [404], [430], [420], [398], [397], [406], [403],
    [$3d_t$], [179], [203], [195], [224], [214], [218], [223], [196],
    [$4d_t$], [128], [129], [91], [119], [114], [127], [122], [126],
    [$5d_t$], [70], [72], [68], [73], [85], [80], [78], [70],
    [$6d_t$], [39], [63], [58], [69], [75], [71], [66], [35],
    [$7d_t$], [42], [60], [38], [63], [59], [51], [48], [47],
    [$8d_t$], [55], [66], [52], [61], [69], [68], [59], [55],
    table.hline(),
  ),
)<tab:stats>
#set text(size: 12pt)
== Peak Number and SNR
// #set par(leading: .7em)
Here researchers have compared number of candidate spectral peaks and the SNR obtained from CA and proposed MCLMS filters. Ideally, each Doppler spectrum should contain only one dominant atmospheric peak. If many peaks remain, the peak-selection algorithm becomes much more likely to choose an incorrect target. Using 5000 radar data sets, the researchers compare the conventional CA with the proposed MCLMS filter. The results are shown in @img:ca-mclms-peaks, which plots the proportion of spectra containing more than six candidate peaks. Across every altitude, the CA produces a high percentage of multi-peak spectra, typically between 45% and 70%. After applying the MCLMS filter, this proportion decreases dramatically to approximately 10--17%. This demonstrates that the adaptive filtering stage effectively suppresses clutter peaks while preserving the dominant atmospheric echo. The observations were recorded in following conditions:
- *Time*: 6pm -- 8pm (Dec 17, 2022)
- *Temperature*: -2 \~ 9 $degree$C
- *Wind speed*: 4 \~ 8 m/s
- *Wind direction*: southeast

#figure(
  caption: [Proportion of the number exceeding 6 of candidate spectral peaks after applying the CA and the MCLMS filter respectively],
  image("images/ca-mclms-peaks.jpg", height: 4cm),
)<img:ca-mclms-peaks>

The second performance metric is the SNR improvement, presented in @img:snr. Before filtering, the average SNR across all range bins remains below 5 dB, indicating very weak atmospheric echoes. After MCLMS filtering, the SNR increases by approximately 2--4 dB at every altitude. The higher SNR produces cleaner Doppler spectra and improves the reliability of subsequent peak selection.

#figure(
  caption: [SNR after applying the CA and the MCLMS filter
    respectively],
  image("images/snr.jpg", height: 4cm),
)<img:snr>

== Wind Profile Estimation Results
The researchers next evaluated the complete MCCF algorithm by comparing its wind estimates with three existing spectral estimation methods: AME, MPCF, and IME.

@img:4compar and @img:4compar2 present two radar observations recorded only one second apart. In Figure (a) each case shows the original Doppler spectra together with the wind profiles estimated by all four algorithms, while Figure (b) shows the spectra after MCLMS filtering together with the final MCCF estimates.

The researchers have observed that the AME and IME methods sometimes select clutter peaks in the lower range bins. Since subsequent peak selection depends on previous estimates, these initial errors propagate upward, producing unstable wind profiles with large deviations. The MPCF method performs somewhat better but still exhibits considerable fluctuations, particularly above 100 m, because its candidate selection region is relatively broad. In contrast, the MCCF algorithm generates a much smoother and more continuous wind profile. The selected Doppler peaks follow a physically realistic gradual change in atmospheric wind velocity with altitude. Even though the two observations are separated by only one second, the other algorithms produce noticeably different wind profiles, whereas MCCF maintains nearly identical estimates, demonstrating superior temporal stability.

#grid(
  columns: 1,
  row-gutter: 10pt,
  [#figure(
    caption: [Comparison of four methods based on the data recorded on December 18, 2022 (15:19:32)],
    grid(
      columns: 2,
      row-gutter: 10pt,
      image("images/allW32.jpg", height: 6cm), image("images/mccfW32.jpg", height: 6cm),
    ),
  )<img:4compar>],
  [#figure(
    caption: [Comparison of four methods based on the data recorded on December 18, 2022 (15:19:33)],
    grid(
      columns: 2,
      row-gutter: 10pt,
      image("images/allW33.jpg", height: 6cm), image("images/mccfW33.jpg", height: 6cm),
    ),
  )<img:4compar2>],
)

== Scatter Plot and Correlation with LiDAR Observation
The final experiment validates the estimated wind velocities using an independent reference instrument -- LiDAR. During March 3 to March 7, 2023, the VORTRAD radar and nearby LiDAR measured horizontal wind velocity. Because LiDAR generally has highest accuracy among all instruments, it provides a suitable reference for evaluating the radar algorithms.

For each method, the researchers compared 2500 pairs of radar and LiDAR measurements at an altitude of 200 m. The scatter plots shown in @img:scp display radar-estimated velocity on the vertical axis and LiDAR velocity on the horizontal axis. The diagonal line represents perfect agreement between the two instruments.

The scatter plots clearly show that the MCCF estimates are much more tightly clustered around the diagonal than those produced by AME, MPCF, or IME. This indicates that the proposed algorithm produces wind velocity estimates much closer to the LiDAR measurements. The improvement is quantified using the correlation coefficient (CC), summarized in @tab:cc. Across all heights from 40 m to 280 m, the MCCF method consistently achieves correlation coefficients between 0.9576 and 0.9651, whereas the IME method reaches approximately 0.85--0.88, MPCF remains around 0.82--0.84, and AME performs worst, typically below 0.84. Since a correlation coefficient closer to unity indicates stronger agreement between two independent measurements, these results shows that the MCCF algorithm provides the most accurate wind velocity estimation among the four methods.

#figure(
  caption: flex-caption(
    [Scatter plot showing correlation among AME, MPCF, IME, MCCF methods against LiDAR. Color bars indicate data density],
    [Scatter plot showing correlation among AME, MPCF, IME, MCCF methods against LiDAR],
  ),
  grid(
    columns: 1,
    row-gutter: 20pt,
    image("images/sp1.jpg", height: 6cm),
    image("images/sp2.jpg", height: 6cm),
  ),
)<img:scp>


#set text(size: 11pt)
#figure(
	caption: [Comparison of the correlation coefficient for VORTRAD
and LiDAR data by using AME, MPCF, IME, MCCF],
  table(
		stroke: none,
    columns: 5,
		table.hline(),
    [*Height(m)*], [*AME*], [*MPCF*], [*IME*], [*MCCF*],
		table.hline(),
    [40], [0.8417], [0.8368], [0.8369], [0.9576],
    [80], [0.8319], [0.8350], [0.8461], [0.9609],
    [120], [0.8320], [0.8431], [0.8695], [0.9625],
    [160], [0.8137], [0.8353], [0.8761], [0.9641],
    [200], [0.7908], [0.8276], [0.8764], [0.9647],
    [240], [0.7830], [0.8202], [0.8738], [0.9650],
    [280], [0.7837], [0.8219], [0.8744], [0.9651],
		table.hline(),
  ),
)<tab:cc>
#set text(size: 12pt)