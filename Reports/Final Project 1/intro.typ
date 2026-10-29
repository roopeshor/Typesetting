#import "@preview/acrostiche:0.7.0": *
#import "images/dbs.typ": dbs-fig
#import "settings.typ": alt-captions
= Introduction
The atmosphere is a chaotic dynamic system with many phenomena happening. For a long time, researchers have been trying to model the atmosphere for weather forecasting and climate modelling. Among them, the gradient of wind velocity is important. In the past, the wind velocity was measured using radiosonde, a balloon-borne instrument released once now and then, at a fixed location. Although radiosondes remain the reference standard, they provide sparse temporal sampling, drift away from the launch site as they ascend, and cannot offer a continuous view of evolving atmosphere. In this context, remote sensing by wind profile radar provides a powerful complement.

== Wind profile radar

A wind profiler radar transmits electromagnetic pulses into the sky and picks up extremely weak echoes returned by minute fluctuations in the refractive index of air produced by turbulence and hydrometeors such as raindrops. Because these scatterers are carried by the wind, the Doppler shift of the returned signal can be used to estimate the velocity of the air along the radar beam. By pointing the beam in different directions, the 3D wind vector can be reconstructed at every range gate, giving a near-continuous record of the wind. The beams can be steered mechanically or electronically. This process is called #acf("DBS").
#figure(
  scale(100%, reflow: true)[#dbs-fig],
  caption: [#acl("DBS") method]
)
However, the quality of the record depends entirely on how reliably the wind velocity is estimated from the measured Doppler spectrum. In this report, we discuss few algorithms used in velocity estimation, as well as a test bench upon which algorithms can be further evaluated and developed. The main focus is on processing radar data obtained from #acf("ST Radar") the  operating at the Cochin University of Science and Technology, Kochi.

#pagebreak()
== The ST Radar Facility at CUSAT 

The ST radar is located at the #acr("ACARR") on the university campus in Kochi. It was proposed to the Department of Science and Technology, Government of India, under its #acs("IRHPA") scheme, with the specific aim of studying the characteristics and dynamics of the Indian summer monsoon at its gateway. Kerala is the point at which the south-west monsoon first makes landfall over the Indian subcontinent, and a continuously operating wind profiler at this location provides a unique vantage point on the onset, progress and intraseasonal variability of the monsoon circulation, as well as on other weather phenomena. The radar was designed, developed and installed indigenously, with the system fabricated by Data Patterns under the guidance of the university's scientists and engineers, and it became fully operational in December 2016. It is regarded as the first atmospheric wind profiler radar to operate successfully in the 205 MHz frequency band.

=== Basic specifications 

The specifications of the radar are summarised in @tab-st-spec
#figure(
  table(
    columns: (6cm, 8cm),

    inset: 5.5pt,
    table.header([Parameter], [Specification]),
    [Frequency],[205 MHz],
[Bandwidth],[5 MHz],
[Type of system],[Active Phased Array],
[Antenna element],[Three Element Yagi-Uda],
[Height coverage],[315 m to 20 km],
[Range gates],[1024 (Programmable)],
[Modes],[DBS/SAM],
[Height resolution],[≈ 45 m to 720m],
[Beam width],[≈ $3degree$],
[Off Zenith Angle],[$0degree$ to $30degree$ in steps of $1degree$],
[Beam positions in Azimuth],[$0degree$ - $360degree$ with $1degree$ resolution],
[Pulse width],[$0.3 mu s$ to $76.8 mu s$],
[Modulation],[Binary Phase Shift Keying(BPSK)],
[Code],[Complementary Code/Barker Code],
[Baud rate],[$0.3 mu s$ to $4.8 mu s$ in steps of 0.3],
[PRF],[100 Hz to 16 kHz Selectable],
[Peak Power],[500 W (typical per element)],
[Duty ratio],[Up to 15 % (Max)],
[Peak power aperture product],[≈ $1.6 times 10^8$ (typical) $"Wm"^2$],
[Radar system sensitivity],[-165 dBm(post processing)],
[Dynamic range],[70 dB(min)],
[Type of receiver],[Direct band with sampling],
[Type of signal processor],[FFT based frequency domain],
[Horizontal wind Velocity],[Up to 70 $"ms"^(-1)$],
[Vertical wind velocity],[Up to 30 $"ms"^(-1)$],
[Radial velocity resolution],[Better than 0.1 $"ms"^(-1)$]
  ),
  caption: alt-captions[Specification of ST Radar from @titu][Specification of ST Radar]
)<tab-st-spec>


The radar has been validated using measurements from radiosonde. The caliberation is performed using radio source Virgo A and by tracking the Moon

== Signal processing chain 

The radar signal processor converts the raw received voltages into geophysical products in a sequence of well-established steps. Complex (in-phase and quadrature) samples are collected for each range gate and beam direction; successive pulses are coherently integrated to improve the signal-to-noise ratio and reduce the data rate; a time series is formed at each gate; and a spectral transform, usually a Fast Fourier Transform, yields the Doppler power spectrum. Ground clutter and other interference are suppressed, the noise floor is estimated, and from the remaining signal spectrum three quantities are derived. These are the zeroth moment, proportional to the received signal power; the first moment, which gives the mean Doppler shift and hence the radial velocity; and the second moment, which gives the spectral width and is related to turbulence intensity. The radial velocities from the different beam directions are finally combined to produce the zonal, meridional and vertical components of the wind. Every one of these final products rests upon the correctness of the moment estimates.

== Existing Challenges in Wind Profiler Data Processing
=== Weak signals and low signal-to-noise ratio 

Atmospheric backscatter at VHF is extraordinarily weak, and its strength decreases rapidly with height as the air becomes drier and the turbulence less intense. In the upper troposphere and lower stratosphere the echo can sink to, or below, the level of the receiver and sky noise. In the Doppler spectrum, the atmospheric peak then becomes only marginally higher than the fluctuations of the noise floor, and the estimation of its position and width becomes uncertain. 

=== Contamination of the spectrum 

The Doppler spectrum is rarely a clean, single Gaussian peak. Several forms of contamination commonly appear, particularly in a tropical coastal location such as Kochi: 

- Ground clutter and fixed echoes from nearby buildings, trees and terrain, concentrated near zero Doppler and capable of masking genuine low-velocity signals. 

- Radio-frequency interference and spurious spikes from other transmitters and from electronic equipment, which show up as narrow, strong lines at arbitrary frequencies.

- Aircraft, birds and insects, which produce transient, strong echoes that bear no relation to the wind and which can easily be mistaken for the true atmospheric peak. 

- Precipitation, which in the monsoon can add a second peak to the spectrum, since raindrops fall relative to the air; the radar then sees both the clear-air signal and the hydrometeor signal at once. 

- Multiple atmospheric layers within a single range gate, producing multi-peaked or broadened spectra.

=== Ambiguity in peak identification 

When the spectrum contains more than one local maximum, the strongest peak is not always the correct one, and a simple search for the highest value can lock onto interference. Conversely, if the true signal is weak, a too-conservative threshold will discard it. The result of a wrong choice is an outlier in the velocity profile: a sudden, unphysical jump in wind speed at a single height, which then propagates into derived quantities such as shear, momentum flux and kinetic energy. 

=== Computational and operational demands 

A phased-array wind profiler running continuously generates very large volumes of data. Methods applied to this data need to be fast enough to operate in near real time, robust enough to run without constant human supervision, and consistent across seasons and atmospheric conditions. Manual inspection of spectra, which is feasible for a short campaign, is not a viable option for a multi-year archive. 

== Existing Solutions and Their Limitations 
The wind profiler community has developed a range of approaches to these difficulties over several decades. They can be grouped broadly into the following families. 

Direct moment computation with thresholding. The simplest approach computes the moments of the spectrum directly over a window around the strongest peak, after subtracting the estimated noise level. It is fast and straightforward, but it depends heavily on a good noise estimate and a sensible choice of integration limits, and it fails when interference or a second peak lies inside the window. 

Gaussian fitting. Here a Gaussian curve is fitted to the signal peak, from which the power, mean Doppler and width are obtained as the fitted parameters. This approach resists noise better than raw moments and gives physically meaningful widths, but it assumes a single Gaussian-shaped peak, it is iterative and therefore more costly, and its result is sensitive to the starting guess. For multi-peaked spectra it may converge to the wrong feature. 

Spectral averaging and filtering. Incoherent averaging of consecutive spectra reduces noise variance and makes the true peak stand out, and median or similar filters can remove isolated outliers from the resulting velocity profiles. The cost is reduced time resolution, and the fact that post-hoc filtering cannot recover information that has already been misidentified.

Continuity and consensus methods. Procedures that exploit the continuity of the wind field in height and time, or that apply consensus averaging across neighbouring estimates, can reject outliers effectively. They do, however, rely on the assumption that most estimates in a neighbourhood are correct, and in conditions of rapidly changing wind or extensive contamination that assumption may fail. 

Advanced and adaptive techniques. More recent work employs wavelet-based denoising, fuzzy-logic and neural-network classifiers, and multi-peak detection algorithms to separate atmospheric signal from interference. These can be very effective, but they are often complex, require tuning or training data, and may not transfer easily from one radar, frequency or site to another. 

In summary, no single technique is satisfactory under all conditions. Most are tuned to a particular radar and climatology, and many were developed for 50 MHz or 400 MHz systems. The 205 MHz radar at CUSAT is relatively new, operates in a humid tropical environment with a strong monsoon cycle, and has its own noise characteristics and interference environment. Existing methods therefore need to be examined and reevaluated for this system, rather than adopted without question. 

== Problem Addressed in This Work
The problem addressed in this report is the reliable estimation of the Doppler spectral moments, and especially the location of the spectral peak, from the 205 MHz ST radar at CUSAT. Because the first moment gives the radial velocity, a failure to identify the correct peak translates directly into an erroneous wind. The objective is to obtain estimates that are accurate in low signal-to-noise conditions, resistant to contamination from clutter, interference and precipitation, and efficient enough for routine processing of the continuous data stream. To this end, two principal algorithms were investigated and compared: 
 1. Improved Moment Estimation (IME). This method refines the conventional moment calculation by objectively delimiting the portion of the spectrum that belongs to the atmospheric signal and by treating the noise level in a more careful way, so that the moments are computed only over the genuine signal region. It is computationally light and well suited to routine processing, and its behaviour on weak and contaminated spectra is of particular interest. 
 2. MCCF. This is a correlation-function-based approach that identifies the signal peak by exploiting the coherence and consistency of the signal across the data, instead of relying only on the amplitude of individual spectral bins. It offers a different principle of operation from IME and hence a useful basis of comparison.
 The two methods were applied to the radar data and compared in terms of their accuracy, their robustness in the presence of noise and interference, and their computational cost. The aim of the comparison is not merely to name a "winner", but to understand the circumstances under which each method succeeds, where it breaks down, and how the two may complement each other.