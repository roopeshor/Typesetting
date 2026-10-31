#import "@preview/acrostiche:0.7.0": *
#import "images/dbs.typ": *
#import "images/rsp.typ": *
#import "settings.typ": alt-captions, fit-to-page
= Introduction
The atmosphere is a chaotic dynamic system with many phenomena happening. For a long time, researchers have been trying to model the atmosphere for weather forecasting and climate modelling. Among them, the gradient of wind velocity is important. In the past, the wind velocity was measured using radiosonde, a balloon-borne instrument released once now and then, at a fixed location. Although radiosondes remain the reference standard, they provide sparse temporal sampling, drift away from the launch site as they ascend, and cannot offer a continuous view of evolving atmosphere. In this context, remote sensing by wind profile radar provides a powerful complement.

== Wind profile radar

A wind profiler radar transmits electromagnetic pulses into the sky and picks up extremely weak echoes returned by minute fluctuations in the refractive index of air produced by turbulence and hydrometeors such as raindrops. Because these scatterers are carried by the wind, the Doppler shift of the returned signal can be used to estimate the velocity of the air along the radar beam. By pointing the beam in different directions, the 3D wind vector can be reconstructed at every range gate, giving a near-continuous record of the wind. The beams can be steered mechanically or electronically. This process is called #acf("DBS").
#figure(
  scale(100%, reflow: true)[#dbs-fig],
  caption: [#acl("DBS") method]
)
However, the quality of the record depends entirely on how reliably the wind velocity is estimated from the measured Doppler spectrum. In this report, we discuss few algorithms used in velocity estimation, as well as a test bench upon which algorithms can be further evaluated and developed. The main focus is on processing radar data obtained from #acf("ST Radar") the  operating at the Cochin University of Science and Technology, Kochi.

== The ST Radar Facility at CUSAT 

The ST radar is located at the #acr("ACARR") on the university campus in Kochi. It was proposed to the Department of Science and Technology, Government of India, under its #acs("IRHPA") scheme, with the specific aim of studying the characteristics and dynamics of the Indian summer monsoon at its gateway. Kerala is the point at which the south-west monsoon first makes landfall over the Indian subcontinent, and a continuously operating wind profiler at this location provides a unique vantage point on the onset, progress and intraseasonal variability of the monsoon circulation, as well as on other weather phenomena. The radar was designed, developed and installed indigenously, with the system fabricated by Data Patterns under the guidance of the university's scientists and engineers, and it became fully operational in December 2016. It is regarded as the first atmospheric wind profiler radar to operate successfully in the 205 MHz frequency band. The specifications of the radar are summarised in @tab-st-spec
#figure(
  table(
    columns: (5.5cm, 8cm),
    inset: 6pt,
    table.header([Parameter], [Specification]),
    [Frequency],[205 MHz],
[Bandwidth],[5 MHz],
[Type of system],[Active Phased Array],
[Antenna element],[Three Element Yagi-Uda],
[Height coverage],[315 m to 20 km],
[Range gates],[1024 (Programmable)],
[Modes],[DBS/SAM],
[Height resolution],[$approx$ 45 m to 720m],
[Beam width],[$approx 3degree$],
[Off Zenith Angle],[$0degree$ to $30degree$ in steps of $1degree$],
[Beam positions in Azimuth],[$0degree$ to $360degree$ with $1degree$ resolution],
[Pulse width],[$0.3 mu s$ to $76.8 mu s$],
[Modulation],[Binary Phase Shift Keying (BPSK)],
[Code],[Complementary Code/Barker Code],
[Baud rate],[$0.3 mu s$ to $4.8 mu s$ in steps of 0.3],
[PRF],[100 Hz to 16 kHz Selectable],
[Peak Power],[500 W (typical per element)],
[Duty ratio],[Up to 15 % (Max)],
[Peak power aperture product],[$approx 1.6 times 10^8$ (typical) $"Wm"^2$],
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


The radar has been validated using measurements from a radiosonde. The caliberation is performed using the radio source Virgo A and by tracking the Moon

== Signal processing chain 


#figure(
  fit-to-page[#rsp-chain-fig],
  caption: [Signal processing chain]
)<fig-rsp-chain>


Complex #acr("IQ") samples are collected for each range gate and beam direction; they are coherently integrated to improve the SNR. All these stages happen at the radar processing computer. Later, windowing is applied to reduce noise. Then the power spectrum is estimated via FFT; clutter algorithms are applied; #acr("NCI") is applied; then the remaining noise level is estimated, which is useful in moment estimation. Finally, wind velocity in each beam direction and then UVW is computed.
== Challenges in Wind Profiler Data Processing

Accurate wind estimation from wind profiler radar data is challenging because atmospheric echoes are generally weak and can be affected by noise, interference, and unwanted reflections. Signal strength often decreases with altitude, making the atmospheric echo difficult to distinguish from background noise. Under low signal-to-noise ratio (SNR) conditions, identifying the correct Doppler peak becomes less reliable and may lead to inaccurate velocity estimates.

The received Doppler spectrum may also contain ground clutter, radio-frequency interference (RFI), and echoes from aircraft, birds, and insects. Ground clutter is generally concentrated around zero Doppler frequency and can mask atmospheric signals, while RFI and moving objects may introduce peaks that are unrelated to atmospheric motion. During rainfall, precipitation echoes can appear along with clear-air echoes, producing multiple peaks in the spectrum. Similarly, reflections from different atmospheric layers may result in overlapping spectral components.

These conditions make Doppler peak identification difficult, as the strongest peak does not always correspond to the actual atmospheric signal.In addition, wind profiler radars continuously generate large volumes of data across multiple beams and range gates. Therefore, the processing method must provide reliable estimates under varying atmospheric conditions while maintaining reasonable computational efficiency. Manual inspection of individual spectra is not practical for continuous operation, highlighting the need for robust and automated methods for Doppler spectrum processing and wind estimation.

== Research motivation and problem definition
The challenges associated with Doppler spectrum processing highlight the need for reliable methods to identify atmospheric signals and estimate wind velocity accurately.

The main problem addressed in this work is the accurate identification of atmospheric Doppler peaks and estimation of their corresponding spectral moments from the radar observations. An incorrect peak selection can lead to errors in radial velocity estimation, which subsequently affect the retrieval of the three-dimensional wind components.

To address this problem, this project investigates the Improved Moments Estimation (IME) and Mutual Convolution Cost Function (MCCF) methods for Doppler spectrum processing. Their performance is evaluated using radar observations, with particular attention to peak identification accuracy. A hybrid approach combining the advantages of these methods is also tried to improve the reliability of wind estimation.

The overall aim is to develop and evaluate a suitable processing approach for the 205 MHz ST radar data that provides reliable Doppler spectral moments and wind profiles under different atmospheric conditions.

