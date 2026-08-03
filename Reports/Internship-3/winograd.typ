#import "@preview/numty:0.1.0" as nt
#import "utils.typ": *
#import "settings.typ": COLOR_TWIDDLE_MAPS
#import "@preview/acrostiche:0.7.0": *
#import "@preview/cetz:0.5.2"

#import "images/winograd5.typ": *

#let out-map(txt) = { $Y'(#txt)$ }
#let outr-map(txt) = { $Y(#txt)$ }
#let in-map(txt) = { $x_(#txt)$ }
#let twiddle-map(txt) = {
  if COLOR_TWIDDLE_MAPS { map-colors(txt, $W^(#txt)$) } else { text[$W^(#txt)$] }
}
#let twiddle-map-uncolored(txt) = { text[$W^(#txt)$] }

== Winograd
Winograd algorithm is a fast convolution algorithm which reduces number of multiplications (a strong operation) at the expense of increased number of additions (weak operation). The area and time requirement for a multiplier is relatively higher than adder. Hence for large number of bits ($>=16$), this tradeoff results in less silicon area and power. This method also used in the context of #acr("ASIC") designing @HTC-FFT-GT.

Winograd showed that a prime length DFT can be done as  circular convolution, applying input and output Rader index mapping @FFT-Review>, supplement: [p. 264])@HTC-FFT-GT. The method can be derived for any prime size DFT, however the implementation details vary for different lengths. Here implementation of length 5 DFT is shown.

=== Derivation for 5 point case
The forward transform for 5 point DFT is given by:

$ Y_k = sum_(n=0)^4 x_n W^(n k) $
where $W^(n k) = e^(-j 2 pi n k \/ 5)$. Because $W$ represents roots of unity of 5, the exponent value $n k$ wraps around every 5 cycle: ie. $W^(n k + 5m) = W^(n k)$ for some arbitrary integer $m$.
The operation can be expressed as a matrix multiplication:

#h(1cm)
#let row-col = range(5)
#let row-col-T = transpose_vec(row-col)

#let matc = row-col-T
#let matM = elementwise-transform-2d(matrix-from-rc(row-col, row-col, mod-arith), twiddle-map)
#let matcY = elementwise-transform-2d(row-col-T, outr-map)
#let matcx = elementwise-transform-2d(row-col-T, in-map)

#set math.mat(column-gap: 1em, delim: "[")
$
  mat(..matcY) = quad #place(top + left, dy: -4.3em, dx: 1.7em, math.mat(row-col, delim: none, column-gap: 2.1em))
  #place(dx: -.35em, dy: -2.2em, math.mat(..matc, row-gap: .5em, delim: none))
  mat(..matM)
  mat(..matcx)
$

The first row corresponds to DC sum, and the rest of elements can be written as:
$
  Y_(k) = x_0 + Y'(k) , quad k > 0
$

Where $Y'(k)$ is

#let rc = range(1, 5)
#let rc-T = transpose_vec(rc)

#let matM = elementwise-transform-2d(matrix-from-rc(rc, rc, mod-arith), twiddle-map)
#let matcY = elementwise-transform-2d(rc-T, out-map)
#let matcx = elementwise-transform-2d(rc-T, in-map)

$ mat(..matcY) = mat(..matM)mat(..matcx) $

The matrix operation can be rearranged in such a way that the matrix becomes Toeplitz and eventually Winograd convolution algorithm can be applied.
The Rader method gives a permutation scheme for indices to make matrix entries cyclic:

*Rader Mapping:* When $N$ is a prime number, then a set of non-zero indices $n in {1, 2, …, N-1}$
forms a group under multiplication modulo $N$.
One consequence of number theory of such groups is that there exists
an integer generator $g$ such that $k = g^p thick (mod N)$
for any non-zero index $k$ and for a unique $p in {0, 1, ..., N-2}$
(forming a bijection from $p$ to non-zero $k$).
Similarly $n = g^(-q) thick (mod N)$ for any non-zero index $n$ and for unique $q in {0, 1, ..., N-2}$
also forms a bijection (where negative exponent denotes multiplicative inverse of $g^q thick (mod N)$).
This means that we can write $Y'$ using new indices $p$ and $q$ as:
$ Y'(g^p) = sum_(q = 0)^(N - 2) x(g^(-q)) W^(g^(p-q)) $
The summation above is identical to cyclic convolution of two sequences
$x(g^(-q))$ and $W^(g^(p-q))$ of length $N-1$. For the case where $N = 5$, the generator is 2:
$ Y'(2^p) = sum_(q = 0)^(3) x(2^(-q)) W^(2^(p-q)) $
Corresponding matrix form is:

#let output-mapping = ();
#let input-mapping = ();
#let row = range(0, 4)
#for i in row {
  output-mapping += (mod-arith(calc.pow(2, i), 1),)
  input-mapping += (inv-pow-mod(2, i, 5),)
}


#let rader-perm-mat = matrix-from-rc(input-mapping, output-mapping, mod-arith)

#let matM = elementwise-transform-2d(rader-perm-mat, twiddle-map)
#let matcY = elementwise-transform-2d(transpose_vec(output-mapping), out-map)
#let matcx = elementwise-transform-2d(transpose_vec(input-mapping), in-map)

$ mat(..matcY) = mat(..matM)mat(..matcx) $
Now the operation has become a length-4 cyclic convolution of sequences
#let tthick = $thick thick$
#let matcx = matcx.join().join($,tthick$)
#let matW = matM.at(0).join($,tthick$)
$
      a_q & = x(2^(-q)) = {matcx} \
  b_(p-q) & = W^(2^(p-q)) = {W^1, tthick W^2, tthick W^4, tthick W^3} \
  Y'(2^p) & = sum_(q = 0)^3 a_q dot b_((p-q)thick (mod 4))
$

Now we apply Winograd Fast convolution algorithm. For that we are representing this sequence as polynomials:
$
  a
  x'(z) = x_1 + x_3 z + x_4 z^2 + x_2 z^3#h(1cm)
  W'(z) = W^1 + W^2 z + W^4 z^2 + W^3 z^3
$

The circular convolution is given by:
$Y'(z) = x'(z)W'(z)tthick (mod z^4-1)$. The required values are coefficients of $Y'(z)$

*Winograd algorithm:*
+ Choose a polynomial $m(z)$ with degree higher than the degree of $W'(z)x'(z)$ and factor it into $k+1$ relatively prime polynomials with real coefficients,  i.e., $m(z) = m^((0)) m^((1)) ... m^((k))$
+ Let $M^((i)) = m \/ m^((i))$ and use Euclidean GCD algorithm to solve following Bezout's identity and find $N^((i))$: $ m^((i))n^((i)) + M^((i)) N^((i)) = 1 $
+ For $i = 0, 1, ..., k$.compute:
  #numbered_eq($ w^((i)) & = W'(z) & mod m^((i)) $)#v(-1pt)
  #numbered_eq($ x^((i)) & = x'(z) & mod m^((i)) $)
  #numbered_eq($ y^((i)) & = w^((i)) x^((i)) tthick & mod m^((i)) $) <eq:ymodeq>
+ Compute $Y'(z)$ using:
  #numbered_eq($ Y'(z) = [sum_(i=0)^(k) y^((i)) N^((i)) M^((i))] tthick mod m(z) $) <eq:yfinal>

Here $m(z) = z^4 - 1 = (z - 1)(z + 1)(z^2 + 1)$. Required factors are listed in @tabl:win5coeff:

#figure(
  caption: [Polynomial coefficients in winograd algorithm],
  table(
    stroke: none,
    columns: 6,
    table.header(
      [*$i$*],
      table.vline(),
      [*$m^((i))$*],
      table.vline(),
      [*$M^((i))$*],
      table.vline(),
      [*$x^((i))$*],
      table.vline(),
      [*$w^((i))$*],
      table.vline(),
      [*$N_i$*],
    ),
    table.hline(),
    [0], [$z-1$], [$z^3 + z^2 + z + 1$], [$x_1 + x_3 + x_4 + x_2$], [$W^1 + W^2 + W^4 + W^3$], [$1\/4$],
    [1], [$z+1$], [$z^3 - z^2 + z - 1$], [$x_1 - x_3 + x_4 - x_2$], [$W^1 - W^2 + W^4 - W^3$], [$-1\/4$],
    [2], [$z^2+1$], [$z^2 - 1$], [$x_1 - x_4 + z(x_3 - x_2)$], [$W^1 - W^4 - z(W^3 - W^2)$], [$-1\/2$],
  ),
)<tabl:win5coeff>

We initialize some intermediate values:
#v(-15pt)
#grid(
  columns: (1fr, .2fr),
  align: horizon,
  column-gutter: 1cm,
  [#numbered_eq(
    $c_00 = x_1 + x_4 #h(1cm) d_00 & = W^1 + W^4 = 2 cos(2pi\/5) \
    c_01 = x_3 + x_2 #h(1cm) d_01 & = W^3 + W^2 = 2 cos(4pi\/5) \
    c_20 = x_1 - x_4 #h(1cm) d_20 & = W^1 - W^4 = -2 sin(2pi\/5)j \
    c_21 = x_3 - x_2 #h(1cm) d_21 & = W^3 - W^2 = 2 sin(4pi\/5)j$,
  )<eq:c_d>],
  cetz.canvas({
    import cetz.draw: *
    let s = 1.2
    scale(s)
    circle((0, 0), stroke: (dash: "dashed", paint: gray, thickness: 1pt))

    let r = 1.2
    line((0, -r), (0, r), stroke: (paint: gray, thickness: .5pt), name: "yaxis")
    line((-r, 0), (r, 0), stroke: (paint: gray, thickness: .5pt))
    let cols = (0, red, blue, blue, red)
    for t in range(0, 5) {
      let xy = (calc.cos(2 * calc.pi / 5 * t), -calc.sin(2 * calc.pi / 5 * t))
      let xy2 = (r * calc.cos(2 * calc.pi / 5 * t), -r * calc.sin(2 * calc.pi / 5 * t))
      line(
        (0, 0),
        xy,
        mark: (end: ">"),
        fill: black,
        name: "p",
      )
      content(xy2, $W^(#t)$)
      content("yaxis.start", text(size: 9pt)[5 Roots of unity], anchor: "north", padding: +.4)
    }
  }),
)
#v(-15pt)
and rewrite $x^((i))$ and $w^((i))$ as : \

$x^((0)) & = c_00 + c_01 #h(1cm) & w^((0)) & = d_00 + d_01 = -1 \
x^((1)) & = c_00 - c_01 #h(1cm) & w^((1)) & = d_00 - d_01 = 2.236068 \
x^((2)) & = c_20 + c_21z #h(1cm) & w^((2)) & = d_20 - d_21z = -j 1.902113 - j 1.175570z \ $


$y^((i))$ are computed using @eq:ymodeq:
#numbered_eq(
  $
    y^((0)) & = - (c_00 + c_01)                                  && = -y_00 \
    y^((1)) & = (c_00 - c_01) w^((1))                            && = y_10 w^((1)) \
    y^((2)) & = c_20 d_20 + c_21 d_21 + z(c_21 d_20 - c_20 d_21) && = y_20 + z y_21 \
  $,
)<eq:smally>

Finally using @eq:yfinal:

$
  Y'(z) & = -y_00 / 4 (z^3 + z^2 + z + 1) - y_10 / 4 (z^3 - z^2 + z - 1) - 1/2 (y_20 + z y_21)(z^2 - 1) \
        & = z^3 [-y_00/4 - y_10/4 + 0 - y_21 / 2] + z^2 [-y_00/4 + y_10/4 - y_20 / 2 + 0] + \
        & #h(16pt)z[-y_00/4 - y_10/4 + 0 + y_21 / 2] + [-y_00/4 + y_10/4 + y_20/ 2 + 0]
$

Entire operation can be described as matrix operations:

#let multMat = (
  (1, 0, 0, 0, 0),
  (0, 1, 1, 1, 0),
  (0, 1, -1, 0, 1),
  (0, 1, 1, -1, 0),
  (0, 1, -1, 0, -1),
)

#numbered_eq(
  $
    mat(
      Y(0);
      Y(1);
      Y(2);
      Y(4);
      Y(3)
    ) = mat(
      x_0;
      x_0;
      x_0;
      x_0;
      x_0;
    ) + mat(..multMat)
    mat(
      y_00;
      -y_00\/4;
      y'_1;
      y'_20;
      y'_21;
    )
  $,
)<eq:Yfinal>
where #numbered_eq($ y'_1 & = y_10 [w^((1))/4] #h(1cm)
       y'_20 & = c_20 [d_20/2] + c_21 [d_21/2] #h(1cm)
               y'_21 & = c_21 [d_20/2] - c_20 [d_21/2] #h(1cm) $)<eq:interm_subst>
Equations
#show_eqnum(<eq:c_d>),
#show_eqnum(<eq:smally>),
#show_eqnum(<eq:Yfinal>),
#show_eqnum(<eq:interm_subst>) are used for explicitly writing the computations and hence complexity.
With this method the total number of complex additions and multiplications went from 20 and 25 to 22 and 5 respectively (That is 44 real additions and 10 multiplications). Multiplication 1/4 is right shifts and multiplication by -1 is left as implementation specific as it requires one addition when 2's complement is used. Multiplication by $d_20$ and $d_21$ needs exchange of real and imaginary components.
Due to large number of dependent additions, the whole operation can be pipelined and high throughput can be achieved at the cost of extensive number of intermediate registers. Full operation is shown in @fig:winograd-ckt. It is slightly different from standard winograd graph. Some additions were paired with multiplication stage in hope to effectively utilize the delay caused by multiplier.

#figure(
  winograd5-ckt,
  caption: [Signal flow of modified Winograd algorithm for 5 point DFT.],
)<fig:winograd-ckt>

Moreover a direct evaluation on FPGA is not possible as it requires $D W times 20$ I/O pins which makes it impossible to synthesize in Artix-7. Hence a wrapper is needed that takes serial input and puts them into a buffer and pass it to core compute module. To stream output serially, the output has to be split into two (either even/odd sample or chunks of $N/2$ samples) and be sent to outside world. This guarantees that output will never lag behind the input.

=== 16 Point Winograd algorithm
The 16-point winograd can be directly obtained by considering similar permutation of inputs and outputs as discussed in the previous section. This algorithm requires 18 multiplications and 74 additions. The complete algorithm is detailed in @ap:w16 which was obtained from @FFT-cv-HJN. Non-pipelined implementation has maximum operating frequency of 41MHz. However after a 4 stage pipelining of additions and multiplications, the operating frequency increased to 136.4MHz with total of 19 clock cycle latency.

The the output of test signals ($x_1(n) = cos(2 pi (2 \/ 16) n) + 1$ and
$x_2(n) = cos(2 pi (4 \/ 16) n) + cos(2 pi (6 \/ 16) n)$
) are shown in @fig:w16o. The 2 colored regions highlights the inputs and their corresponding outputs.
The latency is 16+2 clock cycles. It takes 2 clock cycles to finish the computations. But since the output is split to 2 paths, it takes only 8 clock cycles to completely display all outputs. Hence the system can work in real time. The output of DUT (precision is 16 bit) is compared against MATLAB in @fig:w16om . The maximum relative error between the outputs is in the order of $10^(-4)$
#figure(
  caption: [Output of 16 point 4-stage pipelined Winograd implementation for 2 consecutive inputs.],
  image("images/winograd16-waveform.png"),
)<fig:w16o>
#figure(
  caption: [Comparison of output of FFT in MATLAB and simulation],
  image("images/wing16-matlab.svg"),
)<fig:w16om>