#set text(font: "MLMRoman10")
#align(center)[
	#text(size: 20pt)[Adaptive Signal Processing]\ #v(0pt)
	_Assignment_\
	_Submitted by : Roopesh O R_
]

#set heading(numbering: "1.1")
#show heading.where(level: 4) : set heading(numbering: none);
= Random Search
Random search (RS) is a family of numerical optimization methods that do not require the gradient of the optimization problem, and RS can hence be used on functions that are not continuous or differentiable.
They're also known as direct-search/derivative-free/black-box methods.
Mainly there are 2 types: 
	- Lienar random search
	- Genetic Optimizer
== Linear Random Search (LRS)
Here a small random change -- random vector $U_k$ (with covariance $=sigma^2 I$) is added to weight vector at the beginning of each iteration. that is:

$
	W_(k+1) = W_k + mu/sigma^2 [hat(xi)(W_k) - hat(xi)(W_k + U_k)]U_k		
$

where
- $W_k$ = weight vector
- $mu, sigma$ = convergance parameter
- $hat(xi)(W_k), hat(xi)(W_k + U_k)$ = estimated MSE of present and tentative weight vectors.

The behaviour of LRS is similar to that of steepest descent. As shown in table below, the effect of $mu$ has same effect on misadjustment and time constant in both algorithms. LRS is simpler to implement compared to steepest descent. But it is less efficent than LMS

#table(
	columns: (1fr, 2fr, 2fr),
	[], [*LRS*], [*Steepest Descent*],
	[Misadjustment], [$ mu(L+1)/(N sigma^2)xi_min = (L+1)^2/(4P) (1/T_"mse")_"av" $], [$ mu(L+1)/(N delta^2)xi_min = (L+1)^2/(8P) (1/T_"mse")_"av" $],
	[Perturbation, P], [$ (sigma^2 (L+1)lambda_"av")/(2 xi_min) $], [$ (delta^2 lambda_"av")/(xi_min) $],
	[Time constant of nth mode], [$ 1/(4mu lambda_n) $], [$ 1/(4mu lambda_n) $]
)

== Genetic Optimizer
This is a genetic algorithm. Steps:
+ a population of $M$ values of weight $w$ are created at random
+ $xi(w)$ is estimated for each of these values
+ Revised population of $N>M$ values are created. Here M values are replicated in inverse proportion to $xi$ (wights with lower $xi$ are replicated more).
+ Next, in the 2nd generation, offspring are created as follows. Two values of $w$ are chosen at random and, at an arbitrary point, the binary representations of the two values are split. The first segment of one binary string is concatenated with the second segment of the other to yield the offspring. Eg:
$
a                 &= #text(fill:green)[$a_1 & a_2 & a_3 & a_4 & a_5 & a_6 & a_7 & a_8$] \
b                 &= #text(fill:red)[$b_1 & b_2 & b_3 & b_4 & b_5 & b_6 & b_7 & b_8$] \
"(offspring)  " c &= #text(fill:green)[$a_1 & a_2 & a_3 & a_4$]#text(fill:red)[$& b_5 & b_6 & b_7 & b_8$]
$
The 2nd generation is formed by creating $M$ offspring in this manner and replacing all of the parents in the first generation. 
The population of the second generation is again increased from M to N as above, replicating values of $w$ that have lower values of $xi(w)$, and so on. The entire process converges as the offspring become more and more alike, and may be made to diverge or search the error space by introducing random mutations.

= RLS Algorithm (Recursive Least Squares)
RLS algorithm is an adaptive filtering algorithm used to estimate the optimum filter coefficients by minimizing the sum of squared errors. Unlike the LMS, RLS uses information from previous observations to estimate the optimum coefficients. It is particularly useful when fast convergence is required and the input signal has highly correlated samples.

#import "@preview/cetz:0.5.3"
#figure(
scale(50%, reflow: true)[
  #cetz.canvas({
    import cetz.draw: *

    let ink = rgb("#222222")
    let arrow-gray = rgb("#999999")

    // ------------------------------------------------------------------
    // Adaptive-weight feedback arrow. It is drawn first so the filter
    // rectangle masks the part of the path that passes through the block.
    // ------------------------------------------------------------------
    line(
      (6.05, 4.30), (6.05, 4.82), (9.05, 7.98),
      stroke: (paint: ink, thickness: 9pt),
    )
    line(
      (6.05, 4.30), (6.05, 4.82), (9.05, 7.98),
      stroke: (paint: arrow-gray, thickness: 6pt),
    )
    // Up-right arrow head.
    line(
      (8.87, 8.20), (9.48, 8.42), (9.30, 7.80),
      close: true,
      fill: arrow-gray,
      stroke: (paint: ink, thickness: 1pt),
    )

    // ------------------------------------------------------------------
    // Input vector: main path to the transversal filter.
    // ------------------------------------------------------------------
    line((0.20, 6.60), (4.38, 6.60),
      stroke: (paint: ink, thickness: 10pt))
    line((0.20, 6.60), (4.38, 6.60),
      stroke: (paint: arrow-gray, thickness: 7pt))
    line((4.34, 6.91), (4.75, 6.60), (4.34, 6.29),
      close: true, fill: arrow-gray,
      stroke: (paint: ink, thickness: 1pt))

    // The same input branches downward to the adaptive mechanism.
    line((2.45, 6.60), (2.45, 3.28), (4.38, 3.28),
      stroke: (paint: ink, thickness: 10pt))
    line((2.45, 6.60), (2.45, 3.28), (4.38, 3.28),
      stroke: (paint: arrow-gray, thickness: 7pt))
    line((4.34, 3.59), (4.75, 3.28), (4.34, 2.97),
      close: true, fill: arrow-gray,
      stroke: (paint: ink, thickness: 1pt))

    // ------------------------------------------------------------------
    // Main processing blocks.
    // ------------------------------------------------------------------
    rect((4.75, 5.50), (10.10, 7.80),
      fill: white, stroke: (paint: ink, thickness: 1.3pt))
    rect((4.75, 2.15), (10.10, 4.40),
      fill: white, stroke: (paint: ink, thickness: 1.3pt))

    // ------------------------------------------------------------------
    // Filter output and its branch to the summing junction.
    // ------------------------------------------------------------------
    line((10.10, 6.60), (15.55, 6.60),
      stroke: (paint: ink, thickness: 1.2pt))
    line((15.48, 6.79), (15.88, 6.60), (15.48, 6.41),
      close: true, fill: ink, stroke: ink)

    line((13.15, 6.60), (13.15, 4.43),
      stroke: (paint: ink, thickness: 1.2pt))
    line((12.98, 4.47), (13.15, 4.16), (13.32, 4.47),
      close: true, fill: ink, stroke: ink)

    // ------------------------------------------------------------------
    // Error signal from the summer back to the adaptive mechanism.
    // ------------------------------------------------------------------
    line((12.47, 3.50), (10.40, 3.50),
      stroke: (paint: ink, thickness: 1.2pt))
    line((10.42, 3.68), (10.10, 3.50), (10.42, 3.32),
      close: true, fill: ink, stroke: ink)

    // Desired response enters the negative input of the summer.
    line((13.15, 0.48), (13.15, 2.48),
      stroke: (paint: ink, thickness: 1.2pt))
    line((12.98, 2.48), (13.15, 2.78), (13.32, 2.48),
      close: true, fill: ink, stroke: ink)

    // Summing junction, drawn over the connector ends.
    circle((13.15, 3.50), radius: 0.68,
      fill: white, stroke: (paint: ink, thickness: 1.3pt))

    // ------------------------------------------------------------------
    // Labels and mathematical notation.
    // ------------------------------------------------------------------
    content((2.40, 7.34), [Input vector $X_k$])

    content((7.425, 6.53), align(center)[Transversal filter \ $W_(k - 1)$])

    content((7.425, 3.3), align(center)[Adaptive \ weight-control \ mechanism])

    content((12.83, 7.03), [$W^T_(k - 1) X_k$])
    content((17, 6.60), [Output])

    content((11.5, 4.00), [Error $epsilon(k)$])

    content((13.15, 3.50), [$Sigma$])
    content((13.53, 4.79), [+])
    content((13.58, 2.58), [−])

    content((14.95, 1.63), [Desired response\ $d(n)$])
  }, length: 1cm)]
)

== Formulation

The goal is to minimize:
$ xi = sum_(i=0)^k e^2_i $
where $ e_k = d_k -W^T x_k $
Minimizing $xi$ and solving gives:

$ W_k = R^(-1)_k P_k $
$ R_k = sum_(i=0)^k X_i X^T_i #h(1cm) "and" #h(1cm) P_k = sum_(i=0)^k X_i d_i $
To make this recursive consider next iteration:
$ R_(k+1) &= sum_(i=0)^(k+1) X_i X^T_i \
arrow.double R_(k+1) &= R_k + X_(k+1) X^T_(k+1) $
Similarly: 
$ P_(k+1) &= P_k + d_(k+1) X_(k+1) $

The weight vector is 

$ W_(k+1) = R^(-1)_(k+1) P_(k+1) $
To calculate $R^(-1)_(k+1)$ we use _matrix inversion lemma_:

Let $Q_k = R^(-1)_k$, RLS gain vector is:
$ K_k = (Q_(k-1)X_k) / (1 + X^T_k Q_(k-1)X_k) $

The a-priori error is:
$ e_k = d_k - W^T_(k-1)X_k $

updated wight update equation becomes:
$ W_k = W_(k-1) + K_k e_k $

The inverse correlation matrix is updated as:
$ Q_k = Q_(k-1) - (Q_(k-1)X_k X^T_k Q_(k-1))/(1 + X^T_k Q_(k-1)X_k) $


=== With forgetting factor:
In practical adaptive filtering applications, the input statistics may change with time. If all previous observations are given equal importance, the algorithm may become slow in responding to changes in the system. To overcome this, a forgetting factor $lambda$ is introduced. The modified cost function becomes exponentially weighted sum of squared error:

$ #h(4cm)  xi_k = sum_(i=0)^k lambda^(k-1) e^2_i #h(3cm) 0 < lambda <= 1 $

Where $lambda < 1 arrow.double$ older observations gradually lose importance. The gain vector now is:
$ K_k = (Q_(k-1)X_k) / (lambda + X^T_k Q_(k-1)X_k) $

weight update equation becomes remains smae. The inverse correlation matrix is updated as:
$ Q_k = 1/lambda [Q_(k-1) - (K_k X^T_k Q_(k-1)] $

= Matrix Inversion Lemma
This is a mathematical identity that allows the inverse of a modified matrix to be calculated using the inverse of an existing matrix.
It is also known as the Woodbury identity. This allows efficient computation of matrix inverses and solutions to linear systems after low-rank modifications.
This identity is particularly important in  algorithms such as RLS which require the inverse of an input correlation matrix.

The general matrix inversion lemma is
$
(A+U C V)^(-1) = A^(-1) - A^(-1)U (C^(-1)+V A^(-1)U)^(-1)V A^(-1)
$
where 
- $A$ is an invertible matrix.
- $U$ and $V$ are appropriately dimensioned matrices.
- $C$ is an invertible matrix.


if $U,V$ are vectors, it reduces to:

$ (A+U V^T)^(-1)=A^(-1)-((A^(-1)U V^T A^(-1)) / (1+V^T A^(-1)U)) $

Here $U V^T$ is the outer product of vectors $U, V$




= Convergence
Convergence refers to the process by which the filter coefficients approach their optimum values as more input-output samples are processed. In an adaptive filter, the coefficients are continuously modified according to the estimation error. The objective is to reach a state where the error becomes sufficiently small and the coefficient values become close to their optimum values.
Consider an adaptive filter with output
$
y_k=w^T_k x_k
$

The error is
$
e_k=d_k-y_k
$

The objective is to minimize the mean-square error:
$
xi(w)=E[e^2_k]
$


From this optimum coefficient vector is
$ W = R^(-1) P $
Convergence means that the adaptive coefficient vector approaches this optimum solution.

== Convergence of RLS
RLS minimizes the exponentially weighted SSE. Initially, the coefficients may be far from their optimum values. Consequently, the estimation error can be relatively large. As more samples arrive:
+ The algorithm gathers more information about the input signal.
+ The inverse correlation matrix is updated.
+ The gain vector determines the required coefficient correction.
+ The coefficient vector moves towards the least squares solution.
+ The estimation error generally decreases as the estimate improves.

Under suitable conditions, the algorithm approaches the optimum least squares coefficient vector.


== Convergence speed
Convergence speed indicates how quickly an adaptive algorithm approaches its optimum coefficient values. RLS generally converges faster than LMS. The reason is that RLS uses the inverse input correlation matrix to adjust its coefficient updates. LMS, on the other hand, uses a gradient-based update with a fixed step-size parameter.

LMS convergence is strongly affected by the eigenvalue spread of the input correlation matrix. The eigenvalue spread is
$
kappa = (lambda_max (R)) / (lambda_min (R))
$
where $lambda_max (R)$ and  $lambda_min (R)$ are the largest and smallest eigenvalues. A large eigenvalue spread generally causes slower convergence of LMS. RLS compensates for differences in input signal scaling and correlation through its inverse correlation matrix.
== Factors affecting convergence of RLS
==== Forgetting factor ($lambda$)
The forgetting factor controls how much importance is given to previous observations.
- A value close to 1 produces a longer memory.
- A smaller value gives more importance to recent observations.

==== Input signal characteristics

The statistical properties of the input signal influence the information available for estimating the filter coefficients. For reliable estimation, the input should sufficiently excite the filter.
This property is commonly described using the term _persistent excitation_.

==== Filter order

The number of filter coefficients affects computational requirements and estimation complexity. A higher filter order generally requires more data and computational resources.

==== Numerical precision

RLS involves repeated matrix updates. Finite-precision arithmetic can introduce round-off errors, which may affect the symmetry and positive definiteness of the inverse correlation matrix.