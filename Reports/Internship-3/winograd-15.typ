#import "@preview/numty:0.1.0" as nt
#import "utils.typ": *
#import "settings.typ": COLOR_TWIDDLE_MAPS
#import "@preview/acrostiche:0.7.0": *
#import "@preview/cetz:0.5.2"

#let out-map(txt) = { $Y'(#txt)$ }
#let in-map(txt) = { $x_(#txt)$ }
#let twiddle-map(txt) = {
  if COLOR_TWIDDLE_MAPS { map-colors(txt, $W^(#txt)$) } else { text[$W^(#txt)$] }
}
#let twiddle-map-uncolored(txt) = { text[$W^(#txt)$] }

== Winograd
Winograd algorithm is actually a fast convolution algorithm which reduces number of multiplications (a strong operation) at the expense of increased number of additions (weak operation). The area requirement for a multiplier is exponential while for an adder it is linear. Hence for large number of bits ($>=16$), this tradeoff results in less silicon area and power. This method finds its use in fully custom designing, but often not used in the settings of FPGA, due to its diminising returns compared to other methods. However the method is explored here for analysis.

Winograd showed that a prime length DFT can be done as  circular convolution, applying input and output Rader index mapping. The method can be derived for any prime size DFT, however the implementation details vary for different lengths. Here implementation of length 5 DFT is shown.

=== Derivation
The forward transform for 5 point DFT is given by:

$ Y_k = sum_(n=0)^4 x_n W^(n k) $
where $W^(n k) = e^(-j 2 pi n k \/ 5)$. Because $W$ represents roots of unity of 5, the exponent value $n k$ wraps around every 5 cycle: ie. $W^(n k + 5m) = W^(n k)$ for some arbitrary integer $m$.
The operation can be expressed as a matrix multiplication:

#h(1cm)
#let row-col = range(5)
#let row-col-T = transpose_vec(row-col)

#let matc = row-col-T
#let matM = elementwise-transform-2d(matrix-from-rc(row-col, row-col, mod-arith), twiddle-map)
#let matcY = elementwise-transform-2d(row-col-T, out-map)
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


#h(1cm)
#let rc = range(1, 5)
#let rc-T = transpose_vec(rc)

#let matM = elementwise-transform-2d(matrix-from-rc(rc, rc, mod-arith), twiddle-map)
#let matcY = elementwise-transform-2d(rc-T, out-map)
#let matcx = elementwise-transform-2d(rc-T, in-map)

$ mat(..matcY) = mat(..matM)mat(..matcx) $

The matrix operation can be rearranged in such a way that the matrix becomes Topelitz and eventually Winograd convolution algorithm can be applied.
The Rader method gives a permutation scheme for indices to make matrix entries cyclic:

*Rader Mapping:* When $N$ is a prime number, then a set of non-zero indices $n in {1, 2, …, N-1}$
forms a group under multiplication modulo $N$.
One consequence of numeber theory of such groups is that there exists
a integer generator $g$ such that $k = g^p thick (mod N)$
for any non-zero index $k$ and for a unique $p in {0, 1, ..., N-2}$
(forming a bijection from $p$ to non-zero $k$).
Similarly $n = g^(-q) thick (mod N)$ for any non-zero index $n$ and for unique $q in {0, 1, ..., N-2}$
also forms a bijection (where negative exponent denotes multiplicative inverse of $g^q thick (mod N)$).
This means that we can write $Y'$ using new indices $p$ and $q$ as:
$ Y'(g^p) = sum_(q = 0)^(N - 2) x(g^(-q)) W^(g^(p-q)) $

The summation above is identical to cyclic convolution of two sequences
$x(g^(-q))$ and $W^(g^(p-q))$ of length $N-1$. For the case where $N = 5$, the generator is 2:
$ Y'(2^p) = sum_(q = 0)^(5) x(2^(-q)) W^(2^(p-q)) $
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
  b_(p-q) & = W^(2^(p-q)) = {matW} \
  Y'(2^p) & = sum_(q = 0)^3 a_q dot b_((p-q)thick (mod 4))
$

Now we apply Winograd Fast convolution algorithm. For that we are representing this sequence as polynomials with complex coefficients:
$
  x'(z) = x_1 + x_3 z + x_4 z^2 + x_2 z^3#h(1cm)
  W'(z) = W_1 + W_3 z + W_4 z^2 + W_2 z^3
$

The circular convolution is given by:
$Y'(z) = x'(z)W'(z)tthick (mod z^4-1)$. The required values are coefficients of $Y'(z)$

*Winograd algorithm:*
+ Choose a polynomial $m(z)$ with degree higher than the degree of $W'(z)x'(z)$ and factor it into $k+1$ relatively prime polynomials with real coefficients,  i.e., $m(z) = m^((0)) m^((1)) ... m^((k))$
+ Let $M^((i)) = m \/ m^((i))$ and use Euclidean GCD algorithm to solve following Bezout's idendity and find $N^((i))$: $ m^((i))n^((i)) + M^((i)) N^((i)) = 1 $
+ Compute:
  #numbered_eq($ w^((i)) & = W'(z) & mod m^((i)) $)
  #numbered_eq($ x^((i)) & = x'(z) & mod m^((i)) $)
  #numbered_eq($ y^((i)) & = w^((i)) x^((i)) tthick & mod m^((i)) $) <eq:ymodeq>
  for $i = 0, 1, ..., k$.
+ Compute $Y'(z)$ using:
  #numbered_eq($ Y'(z) = [sum_(i=0)^(k) y^((i)) N^((i)) M^((i))] tthick mod m(z) $) <eq:yfinal>

Here $m(z) = z^4 - 1 = (z - 1)(z + 1)(z^2 + 1)$. Required factors are:

#align(center)[
  #table(
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
    [0], [$z-1$], [$z^3 + z^2 + z + 1$], [$x_1 + x_3 + x_4 + x_2$], [$W^1 + W^3 + W^4 + W^2$], [$1\/4$],
    [1], [$z+1$], [$z^3 - z^2 + z - 1$], [$x_1 - x_3 + x_4 - x_2$], [$W^1 - W^3 + W^4 - W^2$], [$-1\/4$],
    [2], [$z^2+1$], [$z^2 - 1$], [$x_1 - x_4 + z(x_3 - x_2)$], [$W^1 - W^4 + z(W^3 - W^2)$], [$-1\/2$],
  )
]

We initialize some intermediate values:
#grid(
  columns: (1fr, auto),
  align: horizon,
  [$
    c_00 = x_1 + x_4 #h(1cm) d_00 & = W^1 + W^4 = 2 cos(2pi\/5) \
    #v(13pt)
    c_01 = x_3 + x_2 #h(1cm) d_01 & = W^3 + W^2 = 2 cos(4pi\/5) \
    #v(13pt)
    c_20 = x_1 - x_4 #h(1cm) d_20 & = W^1 - W^4 = 2 sin(2pi\/5)j \
    #v(13pt)
    c_21 = x_3 - x_2 #h(1cm) d_21 & = W^3 - W^2 = 2 sin(4pi\/5)j
  $],
  cetz.canvas({
    import cetz.draw: *
    let s = 1.3
    scale(s)
    circle((0, 0), stroke: (dash: "dashed", paint: gray, thickness: 1pt))

    let r = 1.2
    line((0, -r), (0, r), stroke: (paint: gray, thickness: .5pt))
    line((-r, 0), (r, 0), stroke: (paint: gray, thickness: .5pt))
    let cols = (0, red, blue, blue, red)
    for t in range(1, 5) {
      let xy = (calc.cos(2 * calc.pi / 5 * t), -calc.sin(2 * calc.pi / 5 * t))
      let xy2 = (r * calc.cos(2 * calc.pi / 5 * t), -r * calc.sin(2 * calc.pi / 5 * t))
      line(
        (0, 0),
        xy,
        mark: (end: ">"),
        fill: cols.at(t),
        stroke: cols.at(t),
        name: "p",
      )
      content(xy2, $W^(#t)$)
    }
  }),
)
and rewrite $x^((i))$ and $w^((i))$ as : \

$x^((0)) & = c_00 + c_01 #h(1cm) & w^((0)) & = d_00 + d_01 = -1 \
x^((1)) & = c_00 - c_01 #h(1cm) & w^((1)) & = d_00 - d_01 = 2.236068 \
x^((1)) & = c_20 - c_21z #h(1cm) & w^((1)) & = d_20 - d_21z = j 1.902113 - j 1.175570z \ $


$y^((i))$ are computed using #ref(<eq:ymodeq>):
$
  y^((0)) & = - (c_00 + c_01) #h(1cm) = y_0 \
  y^((1)) & = (c_00 - c_01) 2.236068 #h(1cm) = y_1 \
  y^((2)) & = c_20 d_20 - c_21 d_21 -z(c_20 d_21 + c_21 d_20) \
          & = y_20 - z y_21
$

Finally using #ref(<eq:yfinal>):

$
  Y'(z) & = y_0 / 4 (z^3 + z^2 + z + 1) - y_1 / 4 (z^3 - z^2 + z - 1) - 1/2 (y_20 - z y_21)(z^2 - 1) \
        & = z^3 [y_0/4 - y_1/4 + 0 + y_21 / 2] + z^2 [y_0/4 + y_1/4 - y_20 / 2 + 0] + \
        & #h(16pt)z[y_0/4 - y_1/4 + 0 - y_21 / 2] + [y_0/4 + y_1/4 + y_20/ 2 + 0]
$

Hence corresponding coefficients are:

#let multMat = (
  (1, -1, 0, 1),
  (1, 1, -1, 0),
  (1, -1, 0, -1),
  (1, 1, 1, 0),
)

$
  mat(..matcY) = mat(..multMat) mat(
    - (c_00 + c_01)\/4;
    (c_00 - c_01) 2.236068 \/4;
    (c_20 d_20 - c_21 d_21)\/2;
    (c_20 d_21 + c_21 d_20)\/2;
  )
$
$
  mat(..matcY) = mat(..multMat) mat(
    y_0\/4;
    y_1\/4;
    y_20\/2;
    y_21\/2;
  )
$
