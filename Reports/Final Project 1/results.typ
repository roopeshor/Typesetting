#import "settings.typ": *
= Results
To test the accuracy of methods, many metrics can be used, such as latency, computational efficiency, accuracy, etc. For ST radar, which completes a full observation across 5 beams every 80 seconds for wind profiling, the first two seem irrelevant.
Hence, to measure accuracy, we have used #acr("MSE") and Pearson's linear correlation @corr-fx.
Here we present validation with synthetic data and real data

== Validation with synthetic data
In this method of evaluation, 500 raw data points were synthesised. Each of which was produced from the UVW array synthesised using randomised parameters. Additionally, ground clutter and bright bands at random altitudes were added to spectrum. The mean MSE in each of beams are shown in @fig-mse-plot. The distribution of MSE is summarized in @fig-mse-distr. @tab-mse shows exact values.

#figure(
  image("images/MSE_summary.pdf", width: 68%),
  caption: [Comparison of mean MSE value of various algorithms in simulation runs]
)<fig-mse-plot>

#figure(
  image("images/mse_distr.pdf", width: 68%),
  caption: [Comparison of distribution MSE in various algorithms in simulation runs]
)<fig-mse-distr>

#figure(
  caption: [Mean Square error produced in each beams in simulation run],
  table(
    columns: 6,
    align: (x, y) => {
      if x > 0 { center }
      else { left }
    },
    [], [IME], [MC+DN+IME], [MC+IME], [MCCF] , [Simple], 
    [East]    , [0.233], [0.299], [0.300], [0.368], [1.065],
    [North]   , [0.092], [0.161], [0.162], [0.201], [0.525],
    [South]   , [0.094], [0.161], [0.163], [0.211], [0.495],
    [Vertical], [0.030], [0.071], [0.073], [0.104], [0.157],
    [West]    , [0.072], [0.133], [0.134], [0.161], [0.421],
  )
)<tab-mse>

From @fig-mse-plot, it is clear that IME has better accuracy amongst all methods. The least error in the vertical direction is expected because in that direction, wind velocity is close to zero most of the time. However, the high error in the east beam is unexpected, and we couldn't trace any specific cause for it. From @fig-mse-distr, the distribution of MSE is much more spread out in the simple method. The hybrid method shows no difference and is suboptimal compared to IME, indicating that the combination of IME and mutual convolution is inefficient compared to IME alone.

#figure(
  image("images/corr.pdf", width: 80%),
  caption: [Distribution of correlation between reference and computed value in simulated data]
)<fig-corr-distr>
#figure(
  image("images/corr_mean.pdf", width: 80%),
  caption: [Correlation in each beam in simulated data]
)<fig-corr-mean>

#figure(
  caption: [Table of correlation values],
  table(
    columns: 6,
    align: (x, y) => {
      if x > 0 { center }
      else { left }
    },
    [], [IME], [MC+DN+IME], [MC+IME], [MCCM], [Simple], 
    [East]    , [0.987], [0.992], [0.992], [0.984], [0.701],
    [North]   , [0.988], [0.990], [0.990], [0.978], [0.732],
    [South]   , [0.985], [0.987], [0.987], [0.968], [0.750],
    [Vertical], [0.977], [0.958], [0.955], [0.913], [0.752],
    [West]    , [0.987], [0.990], [0.989], [0.973], [0.761],
  ),
)<tab-corr>

The correlation among computed wind velocity and reference is plotted in @fig-corr-distr and @fig-corr-mean, the exact values are given in @tab-corr. The correlation turns out to be a poor measure compared to MSE. This is partly due to the scale invariance of the correlation function. However, the correlation is used in the literature. Hence, we decided to include it in this report. Paradoxically, here, the east beam has the highest correlation among all beams (except in simple algorithms). The difference is minute, which can result from slight numerical error in the computation flow.