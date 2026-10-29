#import "@preview/fletcher:0.5.8" as fletcher: diagram, edge, node
#import "@preview/cetz:0.5.2"
#import "settings.typ": alt-captions, acf
#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge

= Estimation and Verification Methods
Various techniques for moment/peak estimations have been devised in the past decade.
Some of them cover general cases while others are better suited for specific environments.
In this chapter, we discuss a generic method and 2 established ones: MCCF and IME. We also discuss mixing IME and MCCF methods.
In the 2nd part, we discuss some methods used to verify the accuracy of algorithms.

== Estimation Methods
=== Mutual Convolution Cost Function (MCCF)
MCCF is a peak estimation algorithm proposed by Tang et al. @mccf which uses Mutual convolution to improve SNR and a velocity-frequency-weighted cost function to estimate the most prominent peak in the spectrum. It also uses a space-time Doppler window (ST window) to limit the number of candidate peaks as well as to improve the continuity of the velocity profile. The space window is used to improve velocity continuity over height ranges, and the time window is used to improve velocity continuity in specific height over time.

The algorithm is illustrated in @fig_mccf_flow. Here, the cylindrical entries are final data as well as intermediate data acquired.
The intermediate data might be useful for other algorithms to work on in further processing steps.
#figure(
  caption: [MCCF Algorithm Flow.],
  [
    #set text(font: "Fira Sans", size: 9pt)
    #diagram(
      node-shape: fletcher.shapes.rect,
      node-corner-radius: 5pt,
      node-stroke: .75pt,
      edge-stroke: 1pt,
      let nodeD(pos, cnt, id, fl: blue.lighten(80%)) = {
        node(
          (rel: pos),
          text(fill: black)[#cnt],
          shape: fletcher.shapes.cylinder,
          name: id,
          fill: fl,
        )
      },
      node((0, 0), [Raw Data]),
      edge("-|>", [FFT]),
      node((rel: (1, 0)), [Spectrum]),
      edge("-|>"),
      node((rel: (.8, 0)), [DC\ masking]),
      edge("-|>", [IFFT]),
      node((rel: (1, 0)), [Time\ Series]),
      edge("-|>"),
      node((rel: (.9, 0)), [Set ST\ Window], name: <st>),
      nodeD((.8, -.8), [ST window Array], <st_dat>),
      edge(<st.north>, "->", <st_dat.west>, bend: 50deg),
      edge(<st.east>, "-|>", <mc_node.west>),
      node((rel: (.35, .8)), [Mutual\ Convolution], name: <mc_node>),
      edge("-|>"),
      node((rel: (0, 2)), [MCLMS Filter], name: <mclms_node>),
      nodeD((-.3, .9), [Denoised Spectra], <spec_dat>),
      edge(<mclms_node.south>, "->", <spec_dat.north>, bend: 10deg),
      edge(<mclms_node.west>, "-|>", <cps_node.east>),
      node((rel: (-.3 - .6, -.9)), [Candiate Peak\ Selection], name: <cps_node>),
      nodeD((-1.2, -1), [Peaks array], <peaks_dat>),
      nodeD((0, 2), [Cost Array], <cost_dat>),
      edge(<cps_node.west>, "-->", <st.south-west>, bend: 50deg),
      edge(<cps_node.west>, "-|>", <me_node.east>),
      edge(<cps_node.west>, "->", <peaks_dat.south>, bend: 20deg, [peak], label-pos: .4, label-side: center),
      edge(<cps_node.south>, "->", <cost_dat.east>, bend: 20deg, [cost], label-pos: .6, label-side: center),
      node((rel: (.8 - 1.2, -1)), [Moment estimation], name: <me_node>),
      edge("->"),
      nodeD((-1, 0), [*Moments\ $M_0$ $M_1$ $M_2$*], <res_blk>, fl: green.lighten(70%)),
    )],
)<fig_mccf_flow>

Individual steps are explained in upcoming subsections. The method applied to a doppler spectrum is shown in @fig_mccf_ps
==== Preprocessing
Here the FFT of time series raw data (slow sampled) is computed.
Then DC masking is applied in which value of 5 bins near DC bin is replaced with bacground noise with random phase.
It is then converted back to time series data.

==== Setting the Space-Time Doppler Window
This step improves velocity profile continuity by limiting number of candidate peaks.
By setting a doppler window in _space axis_ peaks outside this window is rejected.
This window accounts for maximum wind shear between height bins.
Detting a doppler window in _time axis_ applies the assumption that during a time interval wind velocity changes at some maximum rate.
The Space-Time window is intersection of both windows.

==== Mutual Convolution
In this step the noise is heavily suppressed and SNR is improved.
It works by slicing a spectrum in a height bin $P$ into $n$ slices of length $N\/2$ (where $N$ is length of original spectrum)
then convolving adjacent slices ($X_i = V_i * V_(i+1)$) together to form $n-1$ results.
From these results a optimal solution segment $X_r$ is chosen which contain the highest peak among all results.
Also the segment adjacent to $X_r$ is chosen as suboptimal solution $X'_r$.
Both of these are used in MCLMS filter.


==== MCLMS Adaptive Filtering
MCLMS (Modified Complex Least Mean Square) filter is a adaptive filter. It learns its weight during slicing of spectrums, and after modifying the weight vector final filtered spectra is obrained through the optimal and suboptimal spectras. MCLMS can suppress clutter clutter even more by training a model that tries to match optimal solution with suboptimal solution. In the end the spectrum will have some of the clutter suppressesd.
=== Candidate Peak Selection, Cost Function & Moment Estimation
Peaks in ST doppler window which has amplitude $>=40%$ of maximum peak are chosen as candidate peaks. The algorithm assigns a "cost" to each of these peaks based on their velocity difference between each frequency bin $V_(r+1,j)$ given by: $ V_(r+1,j) = 1 - lr(|(M_(r+1,j) - M_r)d_v/(alpha V_d)|) $
and magnitude of peak itself $M_(r+1, j)$. Here $d_v$ represents the velocity resolution, $V_d$ represents the
maximum wind shear, $alpha$ is the window coefficient. The cost of each peak is given by:
$ F_(r+1,j) = w_1 V_(r+1,j) + w_2 M_(r+1,j) $
The peaks with higest cost value is taken as the spectral peak. From this moments can be estimated based on Hildreth-Seikh method.

#figure(
  caption: alt-captions(
    [
      Power spectrum
      (a) Original,
      (b) after applying DC removal, mutual convoluton and MCLMS,
      (c) Computed moments, reference moment and *Space window [white]* overlayed
    ],
    [Power spectrum plots in MCCF],
  ),
  grid(
    columns: 3,
    row-gutter: 6pt,
    image("images/mccf-raw.svg", height: 7.6cm),
    image("images/mccf-dspec.svg", height: 7.6cm),
    image("images/mccf-stw.svg", height: 7.6cm),

    [(a)], [(b)], [(c)],
  ),
)<fig_mccf_ps>
The peaks estimated from one height bin is used to set ST window in next height bin, hence the process is iterative and cannot be done in single matrix operation step as in computing spectrum.


=== Improved Moments Estimation (IME)

The Improved Moments Estimation (IME) algorithm proposed by Li *et al.*@ime is designed to extract reliable Doppler velocity profiles from ground-based K-band wind radar spectra, particularly when the atmospheric echoes have low SNR and are contaminated by clutter or multiple spectral peaks.
The method combines the adaptive Doppler-window concept of the Adaptive Moments Estimation (AME) method with the cost-function-based profile tracing concept of the Multiparameter Cost Function (MPCF) method.
Its main objective is to reduce the computational search space while maintaining reliable wind-profile detection under low-SNR conditions.

The IME procedure consists of three main stages:

+ Preprocessing of the Doppler power spectra
+ Adaptive Doppler-window selection and identification of prospective spectral peaks
+ Grouping, profile tracing, and cost allocation.

==== Data Preprocessing

Before profile extraction, the Doppler power spectra are processed to suppress unwanted spectral components. First, the zero-frequency region is affected by direct-current (DC) components and ground clutter. These components are suppressed by interpolation, in which the average values of three points around zero frequency are used to replace the contaminated values. Next, a five-point moving-average filter is applied to suppress transient interference while preserving the atmospheric echo characteristics. Finally, the noise power density $S_n$ of each range bin is estimated using the Hildebrand--Sekhon method. The estimated noise level is subtracted from the power spectrum, and negative values are set to zero. The resulting spectrum is therefore more suitable for identifying atmospheric spectral peaks. The preprocessing procedure described in the paper is summarized in @fig_ime


#figure(
  caption: [IME Method],
  [
    #set text(size: 10pt, font: "Fira Sans")
    #diagram(
      node-stroke: 1pt,
      node-corner-radius: 5pt,
      node-inset: 10pt,
      edge-stroke: 1pt,
      spacing: 16pt,
      node((0, 0), [Raw Power \ Spectrum]),
      edge("->"),
      node((1, 0), [DC and\ ground clutter\ removal]),
      edge("->"),
      node((2, 0), [5 Point\ smoothing]),
      edge("->"),
      node((3, 0), [Noise\ estimation and\ reduction]),
      edge("->"),
      node((4, 0), [Clean\ spectrum]),
    )
  ],
)<fig_ime>

These preprocessing operations help identify weak atmospheric echoes by reducing the effects of random noise, radio-frequency interferenc.,


==== Adaptive Doppler Window and Prospective Peak Selection

The IME algorithm starts at the lowest range bin and searches for candidate spectral peaks only within an adaptive Doppler window. 
For a selected spectral component, the algorithm determines the peak position and the left and right zero-crossing points, from which the radial velocity, spectral width, and SNR are calculated. A peak is retained as a prospective atmospheric component when its SNR is greater than $0$ dB. Up to three prospective peaks are retained for each range bin. The procedure stops earlier when no spectral component with power greater than the estimated noise level remains in the current Doppler window.

For the first range bin, no previous information is available. Therefore, the most prominent spectral component is initially selected and its radial velocity is used as the mean Doppler velocity. The Doppler window for the next range bin is then centered around the candidate whose radial velocity is closest to the previous mean Doppler velocity. This process is repeated sequentially with increasing range. 

The adaptive-window procedure is represented in @fig_ime_adaptive


#figure(
  caption: [IME Adaptive window procedure],
  [
    #set text(size: 10pt, font: "Fira Sans")
    #diagram(
      node-stroke: 1pt,
      node-corner-radius: 5pt,
      node-inset: 10pt,
      edge-stroke: 1pt,
      spacing: 23pt,
      node-shape: fletcher.shapes.rect,
      node((0, 0), [Previous \ range velocity]),
      edge("->"),
      node((1, 0), [Adaptive\ Doppler\ window]),
      edge("->"),
      node((2, 0), [Candidate\ peaks]),
      edge("->"),
      node((3, 0), [SNR test]),
      edge("->"),
      node((4, 0), [Select\ 3 prospective\ peaks]),
    )
  ],
)<fig_ime_adaptive>

The wind Doppler signal is generally not expected to change by more than $20\%$ of the total coherent-filter bandwidth, and therefore the Doppler-window width is restricted to less than $20\%$ of the complete Doppler-axis width.


==== Grouping and Cost-Function-Based Profile Tracing
In this step the algorithm constructs possible traces between adjacent range bins.
A trace represents a possible Doppler velocity profile through height.
Constructing all possible traces over the complete range would result in a large computational load; therefore, the spectra are divided into small groups containing at least three consecutive range bins.
Candidate peaks within each group are then connected from one range bin to the next.
For the first group, the initial value is the Doppler velocity of the most prominent peak, while subsequent groups use the velocity at the highest range bin of the preceding group as their initial value.
@fig_ime_group shows all links in a group and $M_j^r$
indicates the $j$ th peak of the $r$ th range bin.

#figure(
  caption: alt-captions[Grouping and profile tracing in IME. Each circle represents a candidate spectral peak][Grouping and profile tracing in IME],
  scale(80%, reflow: true)[
    #show math.equation: set text(size: 9pt, weight: "bold")
    #let nodepos = (
      ((0, 2.6), (1, 2.6), (2.0, 2.6)),
      ((-.4, 1.3), (.9, 1.3), (2.4, 1.3)),
      ((0, 0), (1, 0), (2.0, 0)),
    )
    #let nodeTxt = (
      ($M_(r-1)^1$, $M_(r-1)^2$, $M_(r-1)^3$),
      ($M_r^1$, $M_r^2$, $M_r^3$),
      ($M_(r+1)^1$, $M_(r+1)^2$, $M_(r+1)^3$),
    )
    #diagram(
      node-stroke: 1pt,
      node-corner-radius: 5pt,
      node-inset: 3pt,
      edge-stroke: 1.2pt,
      spacing: 30pt,
      node-shape: fletcher.shapes.circle,
      mark-scale: 60%,
      ..(
        for j in range(0, 3) {
          for k in range(0, 3) {
            // peaks
            (node(nodepos.at(j).at(k), [#nodeTxt.at(j).at(k)], radius: 15pt),)
            // peaks-peak links
            for i in range(0, 2) {
              (
                edge(
                  (
                    nodepos.at(i).at(j).at(0),
                    nodepos.at(i).at(j).at(1) - .3,
                  ),
                  (
                    nodepos.at(i + 1).at(k).at(0),
                    nodepos.at(i + 1).at(k).at(1) + .25,
                  ),
                  "--|>",
                ),
              )
            }
          }
          /// r's in left side
          (node((-1.5, nodepos.at(j).at(0).at(1)), [$r #(j + 1)$:], stroke: none),)
        }
      ),

      node((1, 3.5), [Initial], stroke: none, shape: fletcher.shapes.rect),
      edge((1, 3.35), nodepos.at(0).at(2), "--|>"),
      edge((1, 3.35), nodepos.at(0).at(1), "-|>"),
      edge((1, 3.35), nodepos.at(0).at(0), "--|>"),
    )
  ],
)<fig_ime_group>
The cost assigned to a connection between two candidate peaks is based on two characteristics: the continuity of wind shear and the relative SNR of the candidate. The maximum allowable radial-velocity shear is determined by;

$ abs(Delta v_"m") <= 0.05 sin(theta) Delta R $
<ime-shear>

where $Delta v_"m"$ is the maximum radial-velocity shear, $theta$ is the radar beam tilt angle, and $Delta R$ is the range resolution.

To represent the continuity of the Doppler profile, a trapezoidal membership function is used:

$
  T(x) =
  cases(
    1 & abs(x) <= Delta v_"m",
    (2 Delta v_"m" - abs(x)) \/ Delta v_"m" #h(7pt) & Delta v_"m" < abs(x) < 2 Delta v_"m",
    0 & abs(x) >= 2 Delta v_"m"
  )
$
<ime-continuity>

Here, $x$ represents the wind-shear difference between two connected candidate peaks. A high membership value indicates that the change in velocity between adjacent range bins is consistent with the expected continuity of the atmospheric wind profile.

The relative SNR of a candidate peak is normalized with respect to the largest candidate SNR in the same range bin:

$ P_(r,j) = alpha_(r,j) / max(alpha_r) $
<ime-snr>

where $alpha_(r,j)$ denotes the SNR of the $j$-th candidate peak in the $r$-th range bin. The complete link cost is then formed by combining the continuity term and the normalized SNR term:

$
  C = w_1 T + w_2 P,
  quad w_1 + w_2 = 1.
$
<ime-cost>

The weights determine the relative importance of wind-profile continuity and spectral strength. Based on experiments the selected values are,

$
  w_1 = 0.4,
  quad w_2 = 0.6.
$

Thus, the IME algorithm gives greater weight to the normalized SNR while still enforcing continuity between adjacent range bins. The total cost of each possible trace is calculated, and the trace with the largest total cost is selected as the final Doppler velocity profile for the corresponding group. The velocity at the highest range bin in the selected group then becomes the initial value for the next group.

Thus, @fig_ime_res illustrates how IME narrows the peak-search region and identifies a more consistent atmospheric Doppler profile.
#figure(
   image("images/Screenshot 2026-10-12 222941.png",width:95%),
   caption: alt-captions[Doppler beam spectra a) Original b) after IME processing, c) Adaptive Doppler-window selection.][Power spectrum plots in IME]
)<fig_ime_res>

=== Hybrid Methods
The 2 algorithms discussed have several individual working components -- computing spectrum, denoising, estimating peaks/moments, etc. The mutual convolution process in MCCF appears to suppress noise very effectively. In this light, we tried a method that combines both of these methods. 

To make such mixing easier, our main focus was to first create a software architecture in MATLAB that encapsulates each of these components and provides a common interface. Then the individual components can be cascaded easily.
@fig_hyb1 Shows the method in which Mutual Convolution (MC) from MCCF is first used to determine the spectrum, and then later processing is done by IME itself.
#figure(
  caption: [Flow of Hybrid-1 method],
  [
    #set text(size: 10pt, font: "Fira Sans")
    #diagram(
      node-stroke: 1pt,
      node-corner-radius: 5pt,
      node-inset: 10pt,
      edge-stroke: 1pt,
      spacing: 16pt,
      node((0, 0), [Raw Data], shape: fletcher.shapes.cylinder),
      edge("->"),
      node((rel: (1, 0)), [MC & spectrum\ computing]),
      edge("->"),
      node((rel: (1, 0)), [IME denoising]),
      edge("->"),
      node((rel: (1, 0)), [IME peak selection]),
      edge("->"),
      node((rel: (1, 0)), [Peaks], shape: fletcher.shapes.cylinder),
    )
  ],
)<fig_hyb1>

@fig_hyb2 shows another method in which we eliminated denoising part of IME (since MC already performs some amount of denoising, we suspect that further denoising eliminates candidate peaks in low SNR regions)
#figure(
  caption: [Flow of Hybrid-2 method],
  [
    #set text(size: 10pt, font: "Fira Sans")
    #diagram(
      node-stroke: 1pt,
      node-corner-radius: 5pt,
      node-inset: 10pt,
      edge-stroke: 1pt,
      spacing: 16pt,
      node((0, 0), [Raw Data], shape: fletcher.shapes.cylinder),
      edge("->"),
      node((rel: (1, 0)), [MC & spectrum\ computing]),
      edge("->"),
      node((rel: (1, 0)), [IME peak selection]),
      edge("->"),
      node((rel: (1, 0)), [Peaks], shape: fletcher.shapes.cylinder),
    )
  ],
)<fig_hyb2>

In practice, the parts of MCCF work iteratively in each height bin, taking feedback from previous bin, setting ST window appropriately, then selecting the best solution from MC that contains a peak falling in the ST window. For this mixing purpose, we took the MC part alone and let it run without the feedback.

== Verification methods
To verify the algorithms we need a reliable ground truth to compare against the output of the algorithm. Below are few methods generally used in literature.
=== Radiosonde
A radiosonde is a battery-powered telemetry instrument carried into the atmosphere usually by a weather balloon that measures various atmospheric parameters and transmits them by radio to a ground receiver. Modern radiosondes measure or calculate the following variables: altitude, pressure, temperature, relative humidity, wind (both speed and direction), and some are also capable of cosmic ray readings at high altitude.
#figure(
  caption: [Radiosonde attached to weather balloon],
  image("images/radiosonde.jpg", height: 8cm),
)


The radiosonde reaches an altitude of 20 km to 30 km; thereafter, due to the low density of the atmosphere, the balloon explodes, and it falls down. The altitude reached in various radiosonde experiments is plotted in @fig-rs-alts	data = data[::30]


#figure(
  caption: [Altitude reached by various radiosonde.],
  image("images/radiosonde-heightplots.png", height: 7cm),
)<fig-rs-alts>

In order for the data from the radiosonde to be useful for evaluating the algorithm, the balloon must hover over the same geographic area throughout the desired height range. For perspective, the ST radar has a beamwidth of $3degree$, Considering 30km target height, ideally, the ballon should be within $tan(3degree\/2)times 30 "km" approx 1 "km" $ radius within the launch site. But this can be much higher, considering that the atmosphere can be slowly varying in certain seasons. However, the radiosondes often drift too far from their initial destinations. This is illustrated in @fig-rs-traj-feb and @fig-rs-traj-nov. Data collected in the summer season is used for testing the algorithm. However, in those seasons, wind velocities are not turbulent enough to rigorously test the algorithm.

#figure(
  grid(
    columns: 2,
    column-gutter: 10pt,
  image("images/rs-7-nov-2023-trajectory.jpg", ),
  image("images/rs-11-nov-2023-trajectory.jpg", ),
  ),
  caption: [Trajectory of Radiosonde in the month of November 2023]
)<fig-rs-traj-nov>

#figure(
  image("images/rs-feb-2021.jpg", height: 5cm),
  caption: [Trajectory of Radiosonde in the month of February 2021]
)<fig-rs-traj-feb>


=== LIDAR
#acf("LIDAR") is a method for determining ranges by targeting an object or a surface with a laser and measuring the time for the reflected light to return to the optical receiver. Lidar may operate in a fixed direction (e.g., vertical), or it may scan directions, in a special combination of 3D scanning and laser scanning. In @mccf and @ime, the researchers used a ground-based lidar for measuring the wind velocity of the lower atmosphere (up to 1 km). In @mccf, it is mentioned that the lidar can achieve 99% accuracy in clear atmospheric conditions. Hence, lidar serves as an excellent ground reference for evaluating the algorithm's performance.

#figure(
  image("images/lidar.jpg", height: 6cm),
  caption: [A Lidar mounted on the rooftop of a building]
)
=== Synthetic data
Synthetic radar data are artificially generated radar observation data made from a predefined array of wind velocities. This is done by starting with a UVW array and reversing the process of a typical radar signal processing pipeline, starting from UVW estimation to writing a raw file onto disk. The primary advantage of this method is that we have a ground truth to compare the algorithm's output as well as control to create data that can test the algorithms in various ways, which otherwise would require waiting to get suitable outputs from radar and manually going through them to pick a good one. This method is discussed depth in @chap-synth