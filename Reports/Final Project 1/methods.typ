#import "@preview/fletcher:0.5.8" as fletcher: diagram, edge, node
#import "@preview/cetz:0.5.2"
#import "settings.typ": alt-captions
= Estimation and Verification Methods
About what algorithms have been covered... How results are validated
- Radio sonde..
- Lidar (just referencing literature)
- Via Synthetic data (reference next chapter)

Then list methods:
== Mutual Convolution Cost Function (MCCF)
MCCF is a peak estimation algorithm proposed by Tang et al. @mccf which uses Mutual convolution to improve SNR and a velocity-frequency-weighted cost function to estimate the most prominent peak in the spectrum. It also uses Space-Time doppler window (ST window) to limit the number of candidate peaks as well as to improve the continuity of velocity profile. Space window is used to improve velocity continuity over height ranges and time window is used for improving velocity continuity in specific height over time.

The algorithm is illustrated in @fig_mccf_flow. Here the cylindrical entries are final data as well as intermediate data acquired.
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
=== Preprocessing
Here the FFT of time series raw data (slow sampled) is computed.
Then DC masking is applied in which value of 5 bins near DC bin is replaced with bacground noise with random phase.
It is then converted back to time series data.

=== Setting the Space-Time Doppler Window
This step improves velocity profile continuity by limiting number of candidate peaks.
By setting a doppler window in _space axis_ peaks outside this window is rejected.
This window accounts for maximum wind shear between height bins.
Detting a doppler window in _time axis_ applies the assumption that during a time interval wind velocity changes at some maximum rate.

The Space-Time window is intersection of both windows.

=== Mutual Convolution
In this step the noise is heavily suppressed and SNR is improved.
It works by slicing a spectrum in a height bin $P$ into $n$ slices of length $N\/2$ (where $N$ is length of original spectrum)
then convolving adjacent slices ($X_i = V_i * V_(i+1)$) together to form $n-1$ results.
From these results a optimal solution segment $X_r$ is chosen which contain the highest peak among all results.
Also the segment adjacent to $X_r$ is chosen as suboptimal solution $X'_r$.
Both of these are used in MCLMS filter.

// #figure(
// 	caption: [Slicing power spectrum ($P$) in MCCF],
//   scale(60%, reflow: true)[
//     #cetz.canvas({
//       import cetz.draw: *
//       scale(y: -1)
//       rect((0, 0), (rel: (15 / 2, .9)), name: "r1", fill: red.transparentize(50%))
//       rect((rel: (-15 / 2 + 1.5, 0)), (rel: (15 / 2, .9)), name: "r2", fill: green.transparentize(50%))
//       rect((15 / 2, 4.3), (rel: (15 / 2, .9)), name: "r5", fill: yellow.transparentize(50%))
//       rect((rel: (-15 / 2 - 1.5, -1.9)), (rel: (15 / 2, .9)), name: "r4", fill: blue.transparentize(50%))
//       rect((0, 0), (15, 5.2), name: "v")
//       content("r1", $V_(r 1)$)
//       content("r2", $V_(r 2)$)
//       content("v", $dots$)
//       content("r4", $V_(r (n-1))$)
//       content("r5", $V_(r n)$)
//       content("v.west", [$V:$#h(1cm)], anchor: "east")
//       translate(y: .3)
//       rect((0, 5.5), (15, 6.5), name: "r")
//       rect((0, 5.5), (rel: (2, 1)), name: "p1")
//       rect("p1.south", (rel: (2, 1)), anchor: "west", name: "p2")
//       rect("p2.south", (rel: (2, 1)), anchor: "west", name: "p3")
//       rect("p3.south", (rel: (2, 1)), anchor: "west", name: "p4", stroke: none)
//       rect((15 - 3, 5.5), (rel: (2, 1)), anchor: "west", name: "pn")
//       rect("pn.south", (rel: (-2, 1)), anchor: "east", name: "pn-1", padding: (0em, 5em))
//       content("r", $dots$)
//       content("p1", $p_1$)
//       content("p2", $p_2$)
//       content("p3", $p_3$)
//       content("pn-1", $p_(N-1)$)
//       content("pn", $p_N$)
//       content("r.west", [$P:$#h(1cm)], anchor: "east")
//     })
//   ],
// )

=== MCLMS Adaptive Filtering
MCLMS (Modified Complex Least Mean Square) filter is a adaptive filter. It learns its weight during slicing of spectrums, and after modifying the weight vector final filtered spectra is obrained through the optimal and suboptimal spectras. MCLMS can suppress clutter clutter even more by training a model that tries to match optimal solution with suboptimal solution. In the end the spectrum will have some of the clutter suppressesd.
=== Candidate Peak Selection, Cost Function & Moment Estimation
Peaks in ST doppler window which has amplitude $>=40%$ of maximum peak are chosen as candidate peaks. The algorithm assigns a "cost" to each of these peaks based on their velocity difference between each frequency bin $V_(r+1,j)$ given by: $ V_(r+1,j) = 1 - lr(|(M_(r+1,j) - M_r)d_v/(alpha V_d)|) $
and magnitude of peak itself $M_(r+1, j)$. Here $d_v$ represents the velocity resolution, $V_d$ represents the
maximum wind shear, $alpha$ is the window coefficient. The cost of each peak is given by:
$ F_(r+1,j) = w_1 V_(r+1,j) + w_2 M_(r+1,j) $
The peaks with higest cost value is taken as the spectral peak. From this moments can be estimated based on Hildreth-Seikh method.
The peaks estimated from one height bin is used to set ST window in next height bin, hence the process is iterative and cannot be done in single matrix operation step as in computing spectrum.


#figure(
  caption: alt-captions(
    [
      Power spectrum
      (a) Original,
      (b) after applying DC removal, mutual convoluton and MCLMS,
      (c) Computed moments [red] and Space window [black] overlayed on top of original spectrum
    ],
    [Power spectrum plots in MCCF],
  ),
  grid(
    columns: 3,
    row-gutter: 6pt,
    image("images/mccf-og-spectra.png", height: 7.6cm),
    image("images/mccf-mclmc-spectra.png", height: 7.6cm),
    image("images/ST Window.svg", height: 7.6cm),

    [(a)], [(b)], [(c)],
  ),
)<fig_mccf_ps>


== Improved Moments Estimation (IME)

The Improved Moments Estimation (IME) algorithm proposed by Li *et al.*@ime is designed to extract reliable Doppler velocity profiles from ground-based K-band wind radar spectra, particularly when the atmospheric echoes have low SNR and are contaminated by clutter or multiple spectral peaks.
The method combines the adaptive Doppler-window concept of the Adaptive Moments Estimation (AME) method with the cost-function-based profile tracing concept of the Multiparameter Cost Function (MPCF) method.
Its main objective is to reduce the computational search space while maintaining reliable wind-profile detection under low-SNR conditions.

The IME procedure consists of three main stages:

+ Preprocessing of the Doppler power spectra
+ Adaptive Doppler-window selection and identification of prospective spectral peaks
+ Grouping, profile tracing, and cost allocation.

=== Data Preprocessing

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


These preprocessing operations are important because atmospheric echoes in the surface boundary layer are often weak and may be obscured by random noise, radio-frequency interference, and sidelobe clutter.

=== Adaptive Doppler Window and Prospective Peak Selection

The IME algorithm starts at the lowest range bin and searches for candidate spectral peaks only within an adaptive Doppler window. Unlike the MPCF method, which selects five prominent peaks from the complete Doppler spectrum, IME restricts the search region using information obtained from the previous range bin. This substantially reduces the number of spectral components that must be considered.

For a selected spectral component, the algorithm determines the peak position and the left and right zero-crossing points, from which the radial velocity, spectral width, and SNR are calculated. A peak is retained as a prospective atmospheric component when its SNR is greater than $0$ dB. Up to three prospective peaks are retained for each range bin. The procedure stops earlier when no spectral component with power greater than the estimated noise level remains in the current Doppler window.

For the first range bin, no previous information is available. Therefore, the most prominent spectral component is initially selected and its radial velocity is used as the mean Doppler velocity. The Doppler window for the next range bin is then centered around the candidate whose radial velocity is closest to the previous mean Doppler velocity. This process is repeated sequentially with increasing range. The paper states that the wind Doppler signal is generally not expected to change by more than $20\%$ of the total coherent-filter bandwidth, and therefore the Doppler-window width is restricted to less than $20\%$ of the complete Doppler-axis width.

The adaptive-window procedure is represented in @fig_ime_adaptive


#figure(
  caption: [IME Method],
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


This restriction prevents noise and unrelated spectral components outside the expected velocity region from entering the profile-tracing stage.

=== Grouping and Cost-Function-Based Profile Tracing

After the prospective peaks have been identified, the algorithm constructs possible traces between adjacent range bins.
A trace represents a possible Doppler velocity profile through height.
Constructing all possible traces over the complete range would result in a large computational load; therefore, the spectra are divided into small groups containing at least three consecutive range bins.
Candidate peaks within each group are then connected from one range bin to the next.
For the first group, the initial value is the Doppler velocity of the most prominent peak, while subsequent groups use the velocity at the highest range bin of the preceding group as their initial value.
@fig_ime_group shows all links in a group and $M_j^r$
indicates the $j$ th peak of the
$r$ th range bin.

#figure(
  caption: [Grouping and profile tracing. Each circle represents a candidate spectral peak],
  [
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
The cost assigned to a connection between two candidate peaks is based on two characteristics: the continuity of wind shear and the relative SNR of the candidate. The paper determines the maximum allowable radial-velocity shear as

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

The weights determine the relative importance of wind-profile continuity and spectral strength. Based on experiments performed by the authors, the selected values are

$
  w_1 = 0.4,
  quad w_2 = 0.6.
$

Thus, the IME algorithm gives greater weight to the normalized SNR while still enforcing continuity between adjacent range bins. The total cost of each possible trace is calculated, and the trace with the largest total cost is selected as the final Doppler velocity profile for the corresponding group. The velocity at the highest range bin of the selected group is then used as the initial value for the next group, allowing the profile to be traced progressively over altitude.

Overall, the IME algorithm can be summarized as

#align(center)[
  cleaned spectra
  $arrow$
  adaptive Doppler windows
  $arrow$
  prospective peaks
  $arrow$
  grouping and trace construction
  $arrow$
  cost evaluation
  $arrow$
  maximum-cost Doppler profile.
]

The main advantage of IME is that it searches only a limited Doppler region and retains at most three prospective peaks per range bin, unlike MPCF, which searches five peaks over the full Doppler spectrum. The paper reports that this reduction in the search space decreases computational time while retaining good profile-extraction performance, particularly for low-SNR atmospheric echoes.

== Hybrid
mixing and matching various algorithms (spectra computing, denoising, moment estimation) of different methods (MCCF, IME, etc.). Is there any better results?

Add figures for comparison of algorithms.


== Verification methods
=== Radiosonde

=== Lidar

=== Synthetic data
