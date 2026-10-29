= Synthetic data creation <chap-synth>

While the algorithms are being developed, it is important to measure their performance with some metric. The metrics can include latency, computational efficiency, accuracy, etc. For ST radar, which completes a full observation across 5 beams every 80 seconds, the first 2 seem irrelevant. To measure accuracy, either as MSE or correlation

// (~5 pages)

// Explain how synthetic observations are made, why they are considered, the components of it, and the process (a figure would be nice), comparing the performance of existing algos.

// #image("images/synth.svg")


// == Spectrum broadening

// @Nathanson

// $ sigma_v = sqrt(sigma_"shear" ^ 2 + sigma_"beam" ^ 2 + sigma_t ^ 2) $

// Wind shear:
// $ sigma_"shear" = (d v)/(d z) thin (Delta r) / sqrt(12) $

// Beam Broadening:
// $  sigma_"beam" = "HPBW" / (4 sqrt(ln 2)) thin abs(v_"cross") $


// Where $v_"cross"$ is wind component perpendicular to the beam axis given by:
// $ v_"cross" = sqrt(U^2 + V^2 + W^2 - v_"radial"^2)  $

// HPBW = $3.3degree$ @titu


// Turbulance: $sigma_"t" = 0.6 "m/s"$

// == DC clutter
// DC spectra is modeled as a gaussian distribution with peak amplitude scaled by $r_"DC"$ times total power of that height range ($P_S = P_"signal" + P_"noise"$) with spectral width $sigma_"DC"$ which is again normally distributed random variable. This spectra is added to signal to finally obtain BeamData
// $ S_"DC" (f, h) =  r_"DC" P_S  exp[-f^2 / (2 sigma_"DC"^2 (h))](exp[h/N] - 0.7) $ <eq_dc_clut>
// Where $N$ is number of range bins.
// #show heading.where(level: 1): it => [
//   #pagebreak()
//   #align(center)[
//     #it.body
//   ]
// ]

// == Bright band
// Similar to DC clutter, bright bands are also modeled by gaussian distribution. A list of height bins are randomly chosen and a gaussian sig
// $ S_"bb" (f, h) = P_S dot 10 ^ (-3.5) dot  chi_N dot exp(-f^2 / (2 sigma_"bb"^2 (h))) $ <eq_bb>
// $chi_N$ is random variable sampled from range [1, 1.333].  $sigma_"bb"^2 (h)$ is spectral width of bright band. $10 ^ (-3.5)$ is chosen to account for -30 to -40dB reflectivity of bright band

== Result
#figure(
  image("images/MSE_summary.pdf", width: 80%),
  caption: [Comparison of MSE of various algorithms]
)