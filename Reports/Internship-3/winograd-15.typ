#import "@preview/numty:0.1.0" as nt
#import "utils.typ": *
#import "settings.typ": COLOR_TWIDDLE_MAPS

#let out-map(txt) = { $X'(#txt)$ }
#let in-map(txt) = { $x_(#txt)$ }
#let twiddle-map(txt) = {
	if COLOR_TWIDDLE_MAPS {map-colors(txt, $W^(#txt)$)}
	else {text[$W^(#txt)$]}
}

== Winograd
Winograd algorithm is actually a fast convolution algorithm. It can be used as a FFT algorithm when when transform size is a prime number.
Here usual compute flow of DFT is modified using Rader's method to convert FFT to a circular convolution, which is later efficiently solved using Winograd algorithm.

=== Derivation
Here we assume a 7 point DFT. The forward transform is given by:

$ X_k = sum_(n=0)^6 x_n W^(n k) $
where $W^(n k) = e^(-j 2 pi n k \/ 7)$. Because $W$ represents roots of unity of 7, the exponent value $n k$ wraps around every 7 cycle: ie. $W^(n k + 7m) = W^(n k)$ for some arbitrary integer $m$.
The operation can be expressed as a matrix multiplication:

#h(1cm)
#let row-col = range(7)
#let row-col-T = transpose_vec(row-col)

#let matc = row-col-T
#let matM = elementwise-transform-2d(matrix-from-rc(row-col, row-col, mod-arith), twiddle-map)
#let matcX = elementwise-transform-2d(row-col-T, out-map)
#let matcx = elementwise-transform-2d(row-col-T, in-map)

#set math.mat(column-gap: 1em, delim: "[")
$
  mat(..matcX) = quad #place(top + left, dy: -5.6em, dx: 1.7em, math.mat(row-col, delim: none, column-gap: 2.1em))
  #place(dx: -.35em, dy: -3.5em, math.mat(..matc, row-gap: .5em, delim: none))
  mat(..matM)
  mat(..matcx)
$

The first row corresponds to DC sum, and the rest of elements can be written as:

$
  X_(k) = x_0 + X'(k) , quad k > 0
$

Where $X'(k)$ is


#h(1cm)
#let rc = range(1, 7)
#let rc-T = transpose_vec(rc)

#let matM = elementwise-transform-2d(matrix-from-rc(rc, rc, mod-arith), twiddle-map)
#let matcX = elementwise-transform-2d(rc-T, out-map)
#let matcx = elementwise-transform-2d(rc-T, in-map)

$ mat(..matcX) = mat(..matM)mat(..matcx) $

The whole operation can be rearranged, in such a way that the matrix becomes Topelitz and eventually a cyclic convolution algorithm like Winograd can be applied.
The following method gives a permutation scheme for indices to make matrix entries cyclic:

When $N$ is a prime number, then a set of non-zero indices $n in {1, 2, …, N-1}$
forms a group under multiplication modulo $N$. 
One consequence of numeber theory of such groups is that there exists
a integer generator $g$ such that $k = g^p thick (mod N)$
for any non-zero index $k$ and for a unique $p in {0, 1, ..., N-2}$
(forming a bijection from $p$ to non-zero $k$).
Similarly $n = g^(-q) thick (mod N)$ for any non-zero index $n$ and for unique $q in {0, 1, ..., N-2}$
also forms a bijection (where negative exponent denotes multiplicative inverse of $g^q thick (mod N)$).
This means that we can write $X'$ using new indices $p$ and $q$ as:
$ X'(g^p) = sum_(q = 0)^(N - 2) x(g^(-q)) W^([g^(p-q) thick (mod N)]) $

The summation above is precicely a cyclic convolution of two sequences
$a_q = x(g^(-q))$ and $b_q  = W^(g^(p-q))$ of length $N-1$. For the case where $N = 7$, the generator is 3:
$ X'(3^p) = sum_(q = 0)^(5) x(3^(-q)) W^([3^(p-q) thick (mod 7)] $
Corresponding matrix form is:


#let output-mapping = ();
#let input-mapping = ();
#let row = range(0, 6)
#for i in row {
  output-mapping += (mod-arith(calc.pow(3, i), 1),)
  input-mapping += (inv-pow-mod(3, i, 7),)
}


#let rader-perm-mat = matrix-from-rc(input-mapping, output-mapping, mod-arith)

#let matM = elementwise-transform-2d(rader-perm-mat, twiddle-map)
#let matcX = elementwise-transform-2d(transpose_vec(output-mapping), out-map)
#let matcx = elementwise-transform-2d(transpose_vec(input-mapping), in-map)

$ mat(..matcX) = mat(..matM)mat(..matcx) $

Now the operation has become a length-6 cyclic convolution.
