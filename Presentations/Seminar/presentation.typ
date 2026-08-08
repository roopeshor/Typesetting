#import "@preview/touying:0.7.4": *
#import "theme.typ": *

#show: my-theme.with(
  aspect-ratio: "16-9",
  config-info(
    subtitle: [Wind Profile Estimation for K-Band Doppler Radar Based on Mutual Convolution Cost Function Method],
    title: [Seminar Presentation on],
    author: [Roopesh O R (20323085)],
    date: datetime.today(),
  ),
)

#title-slide()

== Outline <touying:hidden>

#components.adaptive-columns(
  outline(title: none, indent: 1em),
)

= Introduction
== Background
#grid(
  column-gutter: 1em,
  columns: (2fr, 1fr),
  [
    - Wind profiles are estimated from Doppler Radars via signal processing techniques. #text(fill: white, size: 0pt)[@tan2024wind]

    - Radar echoes are often heavily corrupted by background noise (gets worse in cold climate)

    - Traditional methods (like coherent accumulation) works well only when SNR is high

    - Under low SNR conditions, multiple peaks are observed
  ],
  link(<st-w-fig>)[#figure([#image("assets/image-1.png", height: 85%)], caption: [Doppler spectrum])<ds>],
)


== Earlier Works
- *Clothiaux et al. @clothiaux1994first* proposed identifying spectral peaks by selecting the longest chain and the maximum sum of power spectra values as the principle
- *Anandan et al. @anandan2005adaptive* proposed a method called adaptive moment estimation (AME) based on SNR and wind shear.
- *Sinha et al. @sinha2017estimation, @sinha2018doppler* proposed the multiparameter cost function (MPCF) method for estimating the wind profile.
- *Li et al. @li2022improved* proposed an improved moment estimation (IME) method for wind estimation.
- *Bhatta et al. @bhatta2020wind* proposed the Viterbi data association (VDA) method to track the wind profile.


In the field of turbulence detection, the traditional denoising method is coherent accumulation (CA)
// - The complex least mean square (CLMS) filter is proposed to adaptively filter the radar echo signal in the complex domain.
- *Took and Mandic @took2008quaternion* proposed the quaternion least mean square (QLMS) for wind vector evaluation based on CLMS.
// - However, the CLMS filter has been proven that its filtering performance will reduce unstable signals [21].
- *Pei and Ding @pei2010fractional* proposed the fractional Fourier transform (FRFT) method to make the energy of unstable signals more concentrated to improve the filtering performance of adaptive filtering for unstable signals.
- *Chen et al. @chen2010novel* proposed the normalized leakage LMS (NL-LMS) to maximize the energy of the target signal and suppress clutter in the FRFT domain.
- *Shi et al. @shi2015shrinkage* proposed shrinkage widely linear CLMS (SWL-CLMS), which significantly improved the convergence speed and reduced the steady-state misalignment.
- *Menguc and Acır @menguc2018augmented* proposed the augmented complex valued least mean kurtosis (ACLMK) filter, which utilizes augmented statistics to define the negative kurtosis of the complex error signal as a cost function.
- *Zhang et al. @zhang2019widely* proposed a wide linear complex estimation input adaptive filter (WLC-EIAF), designed to achieve unbiased estimation in scenarios where input and output signals are affected by noise interference.

== About Proposed Method
- Paper proposes a new method to estimate wind profiles from doppler radars by combining several methods including MCCF. @tan2024wind

- Works well under low SNR and multiple peaks conditions.

- The paper primarily focuses K-Band radar and near surface wind profile and on its potential application to efficient wind energy generation.

= Experimental Setup
#grid(
  column-gutter: 1em,
  columns: (1fr, 1fr),
  [
    - Experiment equipment: K-band Vortex Radar (VORTRAD)

    - Ground truth: LIDAR (usually has 99% accuracy in clear sky)

    - At the end, correlation among LiDAR and Radar is obtained
  ],
  figure(image("assets/setup.jpg"), caption: [Experiment Setup]),
)
== Overview
#align(center + horizon)[
  #figure(
    caption: [Flow diagram of method given by authors],
    image("assets/diagram.jpg"),
  )
]

= Proposed Method

== Signal Preprocessing

=== Coherent Accumulation
The CA adds and averages short segments of radar signals improving SNR\
Result after N-order CA is represented as:

$ X = lr([x_(c 1)^T, x_(c 2)^T, dots, x_(c (N-1))^T, x_(c N)^T]) $

Where $x_(c i)$ is result of $i^"th"$ CA.

=== Slow Sampling
- On every Pulse Repetition Interval (PRI), a pulse is transmitted, radar receives echoes from all range bins (heights)

- For a single height, there will be 1 echo sample from every transmitted pulse.

- To obtain this, a row vector from $X$ is used. This process is called _slow sampling_ in the distance dimension

=== DC and Clutter Removal
- VORTRAD produces large DC power and ground clutter due to its zero-IF RF transceiver architecture.
- Here these are removed.
- The paper doesn't mention a particular clutter removal method

== Setting Space-Time Doppler Window
#grid(
  column-gutter: 1em,
  columns: (1fr, 1.1fr),
  link(<ds>)[#figure([#image("assets/windows.jpg")], caption: [ST--W Window])],
  [
    - Idea is to restrict search region in both space and time (ST--W) for findng candidate peaks <st-w-fig>
    - Assumes wind velocity changes smoothly with altitude (space) and between successive radar scans (time).
    - In the figure
      - Red -> Space window
      - Black -> Time window
  ],
)
#pagebreak()
Space window: $W_1 = (F_0 - alpha d_f, F_0 + alpha d_f)$

Time window: $W_2 = (T_0 - alpha d_f, T_0 + alpha d_f)$

$
  "Space Time window:  ST"-"W" = cases(
    W_1 inter.big W_2 quad quad & "if" W_1 inter.big W_2 >= alpha d_f,
    W_1 & "else"
  )
$

// #v(5pt)
Where
#v(-30pt)
$ "wind shear " d_f = V_d / d_v = V_d /(f_(d"min") lambda \/ L) $

#grid(
  columns: (1fr, 1fr),
  [
    $V_d$ = maximum value of wind shear

    $L$ = number
    of points in FFT.

    $alpha$ = window coefficient
  ],
  [
    $F_0$ and $T_0$: Space and time spectrum estimation result of the previous range bin
  ],
)

== Mutual Convolution<MC-method>
- Main idea is to use the temporal correlation of echoes to suppress uncorrelated noise.

*Method*:
+ Take a row vector $P = lr([p_1, p_2 , dots , p_N])$ of one range bin from $X$
+ Create new vectors from $P$ with equal length (say half size) $V_(r 1) = [p_1, p_2 , dots , p_(N\/2)]$
+ From this a new vector V can be written as: $V = lr([V_(r 1), V_(r 2), dots , V_(r n)])$ Where $V_(r i)$ is segment of datas from different intervals in same range bin
#align(center)[
  #scale(80%, reflow: true)[
    #link(<perf-an>)[#cetz-canvas({
        import cetz.draw: *
        scale(y: -1)
        rect((0, 0), (rel: (15 / 2, 1)), name: "r1", fill: red.transparentize(50%))
        rect((1.5, 1.1), (rel: (15 / 2, 1)), name: "r2", fill: green.transparentize(50%))
        rect((15 / 2 - 1.5, 3.2), (rel: (15 / 2, 1)), name: "r4", fill: blue.transparentize(50%))
        rect((15 / 2, 4.3), (rel: (15 / 2, 1)), name: "r5", fill: yellow.transparentize(50%))
        rect((0, -.1), (15, 5.4), name: "v")
        content("r1", $V_(r 1)$)
        content("r2", $V_(r 2)$)
        content("v", $dots$)
        content("r4", $V_(r (n-1))$)
        content("r5", $V_(r n)$)
        content("v.west", [$V:$#h(1cm)], anchor: "east")
        translate(y: 1)

        rect((0, 5.5), (15, 6.5), name: "r")
        rect((0, 5.5), (rel: (2, 1)), name: "p1")
        rect("p1.south", (rel: (2, 1)), anchor: "west", name: "p2")
        rect("p2.south", (rel: (2, 1)), anchor: "west", name: "p3")
        rect("p3.south", (rel: (2, 1)), anchor: "west", name: "p4", stroke: none)
        rect((15 - 3, 5.5), (rel: (2, 1)), anchor: "west", name: "pn")
        rect("pn.south", (rel: (-2, 1)), anchor: "east", name: "pn-1", padding: (0em, 5em))
        content("r", $dots$)
        content("p1", $p_1$)
        content("p2", $p_2$)
        content("p3", $p_3$)
        content("pn-1", $p_(n-1)$)
        content("pn", $p_n$)

        content("r.west", [$P:$#h(1cm)], anchor: "east")
      })
    ]
  ]
]
#set math.mat(row-gap: .2em);
4. Mutual convolution is performed:	$     V_(C 1) & = V_(r 2) * V_(r 1)^"HR" \
      V_(C 2) & = V_(r 3) * V_(r 1)^"HR" \
              & dots.v \
  V_(C (n-1)) & = V_(r n) * V_(r 1)^"HR" quad quad quad x^"HR" arrow "take conjugate and then reverse order" $
+ Extracting the middle of the vector (To "maintain the same time complexity and velocity resolution of calculation"):$ lr([V'_C]) =
  mat(
    delim: "[",
    V'_(C 1);
    V'_(C 2);
    dots.v;
    V'_(C (n-1))
  ) =
  mat(
    delim: "[",
    display(V_(C 1)lr((N/4:(3N)/4)));
    display(V_(C 2)lr((N/4:(3N)/4)));
    display(dots.v);
    display(V_(C (n-1))lr((N/4:(3N)/4)))
  ) $
+ Then maximum of power spectra of each spectrum is computed: $ V'_(c f) = lr(
    [
      max{
        lr(|cal(F)lr(([V'_c]), size: #1.5em)|, size: #1.5em)
      }
    ]
  ) $
+ We take a optimial solution $X_r$ from convolution results based on maximum power $V'_(c f)$ in . Also  convolution results of adjacent delays are recorded as suboptimal solutions $X'_r$

== MCLMS
#v(-10pt)
#let tthick = $thick thick$;
- \~ An "adaptive filter", pretrained.
- $X_r$ and $X'_r$ are taken input and desired signal of the filter.
- After the coefficients have been fully updated, filter can recognize stable signals and removes multiple strong clutter.

*For finding Filter coefficients:*

+ Calculate the normalized parameters of filter coefficients as: $ u = 1 slash.big (sum_(j=1)^(N\/2)|X_r (j)|^2) $
+ Construct "$X$" from the samples of $X_r$: $ X = cases(
    gap: #.5em,
    display("zeros"lr((1,tthick k-j), tthick X_r (1:j)) quad & "," j < k),
    display(X_r (j-k+1:j) quad quad & "," j >= k)
  ) quad quad j in {1, tthick 2, tthick dots, N\/2} $($k$ - length of "coefficent vector")
+ Initialize filter coefficients as $W_1 = 0$. The coefficients are then updated using: $  Y_j & = W_1 X^T \
   e_j & = X'_(r j) - Y_j \
  W'_1 & = 0.98W_1 + u e_j X^H $
+ Repeat above steps until all data are filtered, the coefficients have been fully updated
+ We will use this coefficent to obtain the filtering result $Y_r$
== Generating the Cost Function
- To find out _candidate peaks_.
*Steps*
+ Calculate the average value corresponding to the power spectrum of the first range bin and pick out the prominant peak: $ M_(1,1) = max lr(|1/(n-1) sum_(i=1)^(n-1) cal(F)lr((V'_(C i)))|) $ Use this as starting point for ST--W
+ Compute doppler spectrum of each height bin $ M_r = |cal(F) (Y_r)| $
+ In each ST--W, spectral peaks are sorted and up to 3 peaks are selected.
+ If $M_(r"max")$ is spectral peak, then candidate peaks are: $ M_(r,j) >= 0.4 M_(r"max") $
+ Cost value for each peak is: $ V_(r+1, j) = 1 - lr(|((M_(r+1) - M_r)d_v)/(alpha V_d)|) quad quad  quad quad [d_v = "velocity resolution"] $
+ MCCF cost function: $ F_(r+1, j) = w_1 V_(r+1, j) + w_2 M_(r+1, j) quad quad "and" w_1 + w_2 = 1 $  $w_1, w_2$ are constraint weights
+ The peak with the highest cost value is selected
+ Repeat this for all height bins

= Results
== Performance at Different Delay Times <perf-an>
#link(<MC-method>)[#image("assets/delays.jpg")]
#v(-10pt)
#text(
  size: 15pt,
)[*Fig*: Optimal solutions are marked by red dotted box of different range bin after mutual convolution (a)--(h) Represent the filtering
  effect of dt -- 8dt delay time respectively.]
#grid(
  columns: 2,
  column-gutter: 1.5em,
  [
    - As the delay time  increases, the number of statistics gradually decreases
    - Still not possible to determine a specific optimal delay time.
  ],
  [
    #set text(size: 12pt)
    #show math.equation: set text(size: 13pt)
    #figure(
      caption: [Statistics of optimal delay time for mutual convolution],
      table(
        columns: (1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr),
        stroke: none,
        inset: 4pt,
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
    )],
)

== Comparison of Peak Number and SNR
#grid(
  columns: (1fr, 1fr),
  column-gutter: 1.5em,
  [
    - Average SNR for all bins plotted for CA and proposed MCLMS filters at different altitudes
  ],
  [
    #align(center)[#text(size: 12pt)[SNR comparison]]
    #v(-20pt)
    #image("assets/snr.jpg", height: 44%)
    #v(14pt)
  ],

  [- Proportion of spectra containing more than six candidate peaks],
  [
    #align(center)[#text(size: 12pt)[Number of candidate peaks]]
    #v(-20pt)
    #image("assets/ca-mclms-peaks.jpg", height: 44%)
  ],
)

== Wind Profile Estimation Results
#grid(
  columns: 2,
  column-gutter: 1cm,
  grid(
    columns: 2,
    column-gutter: 20pt,
    row-gutter: 10pt,
    image("assets/allW32.jpg", height: 47%), image("assets/mccfW32.jpg", height: 47%),
    image("assets/allW33.jpg", height: 47%), image("assets/mccfW33.jpg", height: 47%),
  ),
  [
    #v(1cm) Comparison of four methods based on the data recorded on
    - Dec 18, 2022 (15:19:*32*) (top row)
    - Dec 18, 2022 (15:19:*33*) (bottom row)
  ],
)


== Correlation with LiDAR observation
#grid(
  columns: 2,
  [
    - IME shows some improvements over the AME and MPCF
    - However MCCF aligns noticeably well with the LIDAR
    - Correlation coefficients are summarized below: #set text(size: .8em)
      #table(
        stroke: none,
        columns: 5,
        align: center,
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
      )
  ],
  [#grid(
    row-gutter: 20pt,
    image("assets/sp1.jpg", height: 47%),
    image("assets/sp2.jpg", height: 47%),
  )],
)

= Conclusion & Limitations
- The proposed algorithm was applied on data collected by the VORTRAD K-band wind profiler and verified against LiDAR observation
- Method reduced false spectral peaks and improved the SNR ratio by approximately 2--4 dB
- Algorithm produces smoother and more continuous wind profiles
- Achieves highest correlation coefficient (0.96) with LiDAR observation.
- Authors note that the current method is validated only for clear-weather conditions and does not account for precipitation echoes such as rain or snow

= References  <touying:skip>
#set text(size: .87em)
#set par(leading: .4em, spacing: .6em)
#bibliography("bib.yaml", title: none)
#focus-slide[
  Thank You
]
