#import "settings.typ": *
= Results
To test the accuracy of methods, many metrics can be used, such as latency, computational efficiency, accuracy, etc. For ST radar, which completes a full observation across 5 beams every 80 seconds for wind profiling, the first two seem irrelevant.
Hence, to measure accuracy, we have used #acr("MSE") and Pearson's linear correlation @corr-fx.
Here we present evaluation with synthetic data and real data. Since IME produces discontinuities in certain cases, a fair evaluation of algorithms are difficult. If we set zero value for all height bins where IME is not able to find velocity, it systematically gets much lower MSE (as in higher altitudes, wind tend to be much slower). Hence throughout the analysis, MSE and correlation of each algorithm is computed only in height ranges in which IME has a defined output.

== Evaluation with synthetic data
In this method of evaluation, 500 raw data points were synthesised. Each of which was produced from the UVW array synthesised using randomised parameters. Additionally, ground clutter and bright bands at random altitudes were added to the spectrum. The mean MSE in each of the beams are shown in @fig-mse-plot. The distribution of MSE is summarised in @fig-mse-distr. @tab-mse shows exact values.

#figure(
  image("images/MSE_summary.pdf", width: 65%),
  caption: [Comparison of mean MSE value of various algorithms in simulation],
)<fig-mse-plot>


#figure(
  caption: [Mean Square error produced in each beam in simulation run],
  table(
    columns: 6,
    align: (x, y) => {
      if x > 0 { center } else { left }
    },
    [], [IME], [MC+DN+IME], [MC+IME], [MCCF], [Basic],
    [East], [0.233], [0.299], [0.300], [0.368], [1.065],
    [North], [0.092], [0.161], [0.162], [0.201], [0.525],
    [South], [0.094], [0.161], [0.163], [0.211], [0.495],
    [Vertical], [0.030], [0.071], [0.073], [0.104], [0.157],
    [West], [0.072], [0.133], [0.134], [0.161], [0.421],
  ),
)<tab-mse>

#figure(
  image("images/mse_distr.pdf", width: 65%),
  caption: [Comparison of distribution MSE in various algorithms in simulation],
)<fig-mse-distr>


From @fig-mse-plot, it is clear that IME has better accuracy amongst all methods. The least error in the vertical direction is expected because in that direction, wind velocity is close to zero most of the time. However, the high error in the east beam is unexpected, and we couldn't trace any specific cause for it. From @fig-mse-distr, the distribution of MSE is much more spread out in the basic method. The hybrid method shows no difference and is suboptimal compared to IME, indicating that the combination of IME and mutual convolution is inefficient compared to IME alone.

#figure(
  image("images/corr.pdf", width: 68%),
  caption: [Distribution of correlation between reference and computed value in simulated data],
)<fig-corr-distr>

#figure(
  caption: [Table of correlation values],
  table(
    columns: 6,
    align: (x, y) => {
      if x > 0 { center } else { left }
    },
    [], [IME], [MC+DN+IME], [MC+IME], [MCCM], [Basic],
    [East], [0.987], [0.992], [0.992], [0.984], [0.701],
    [North], [0.988], [0.990], [0.990], [0.978], [0.732],
    [South], [0.985], [0.987], [0.987], [0.968], [0.750],
    [Vertical], [0.977], [0.958], [0.955], [0.913], [0.752],
    [West], [0.987], [0.990], [0.989], [0.973], [0.761],
  ),
)<tab-corr>


#figure(
  image("images/corr_mean.pdf", width: 65%),
  caption: [Correlation in each beam in simulated data],
)<fig-corr-mean>

The Pearson's linear correlation between computed wind velocity and the reference is plotted in @fig-corr-distr and @fig-corr-mean, the exact values are given in @tab-corr. The correlation turns out to be a poor measure compared to MSE. This is partly due to the scale invariance of the correlation function. However, the correlation is used in the literature. Hence, we decided to include it in this report. Paradoxically, here, the east beam has the highest correlation among all beams (except in basic algorithm). The difference is minute, which can result from slight numerical error in the computation flow.

== Evaluation with Radiosonde
Matching data with radiosonde was a difficult task as it requires stitching different raw data. This is because a radiosonde covers 9km in about 30 minutes; hence, it smears the wind velocity. Moreover, the radiosonde is only able to measure horizontal wind velocity.

#figure(
  image("images/rs.pdf", height: 7cm),
  caption: [Projection of radiosonde observation along with wind velocity estimation using MCCF algorithm],
)<fig-rs-comp>
However, the radar observation in cardinal directions contains both horizontal and vertical wind components; hence, matching them is very difficult.
@fig-rs-comp shows the projection of radiosonde observations on the north beam. The radiosonde was launched on 20th June 2026 at 14:20:25 IST. The radar data shown here was taken on the same day at 14:22:11 IST. Being taken on a season which has stable atmosphere, the radiosonde measurement matches the one with radar observation to some extend. The time-averaged velocity obtained from radar can be compared.


== Evaluation with Data Pattern's estimation algorithm
226 radar observations taken on 20 January 2026 were analysed in batch similar to how it was done on synthetic data. The radar data was fed to 5 different algorithms, and their MSE and correlation were computed with respect to moments estimated by Data Pattern's algorithm. The results are shown in @fig-mse-distr-dp and @fig-corr-distr-dp

#figure(
  image("images/mse-distr-dp.pdf", width: 68%),
  caption: [Distribution of MSE between Data Pattern's moments and computed value in real-world data],
)<fig-mse-distr-dp>
#figure(
  image("images/corr-dp.pdf", width: 68%),
  caption: [Distribution of correlation between Data Pattern's moments and computed value in real-world data],
)<fig-corr-distr-dp>

In this case, MC+IME method was marginally better than other methods. However, the Data Pattern's algorithm is not robust in all scenarios. One such case is shown in @fig-obs54, showing heavy deviation from normal. We also found certain cases where IME didn't produce any estimate, returning an empty array and forcing the `corr` function to return -1. 

#figure(
  image("images/dp-obs54.pdf"),
  caption: alt-captions[Observation taken on 20 January 2026 11:00:41 IST. The red plot shows the Data Pattern algorithm's estimate, and the black plot is MCCF's estimate][Observation taken on 20 January 2026 11:00:41 IST],
)<fig-obs54>

In this observation, the estimate of moments in Meridional directions by Data Pattern's algorithm was extremely off from normal estimates. However, neither estimation from our algorithms was perfect, as shown in @fig-obs96. Here, both algorithms fell short because the initial estimate of wind velocity in the first height bin was wrong. Perhaps an algorithm that takes different approach needs to be developed.


#figure(
  image("images/obs-96.pdf", height: 8cm),
  caption: [Observation taken on 20 January 2026 13:39:06 IST, estimation from MCCF],
)<fig-obs96>

These issues highlight the requirement for a synthetic data-driven testing framework.




= Future Scope
The existing work can be extended further in many ways. Below is a list of a few of them;

+ *Wavelet-Based Denoising*: Wavelet denoising is a signal processing technique that removes unwanted background noise while preserving sharp edges, spikes, and fine details. The method could improve weak Doppler peak detection under low-SNR conditions.
+ *ML-Based Peak Detection*: Machine learning-based methods can be applied to improve identification of suitable peaks in multi-peak scenarios @ml-method. The approach can be further extended to separate rain echo from the spectrum.
+ Making synthesised radar data more realistic by adding more features. The current implementation still looks artificial. One critical issue with the current approach is that the signal is always detectable in lower height bins, due to how background noise is generated.
+ Distinguish rain echoes from clear-air atmospheric echoes in Doppler spectra to improve the estimation of wind velocity.
+ Synthetic data creation can be used to fill gaps between observations in the lower atmosphere while the experiment is being conducted at higher altitudes. However, this needs extensive modelling of the local atmosphere.
+ Sufficiently realistic synthetic data can be used to train reinforcement learning-based algorithms in estimating wind profiles.
