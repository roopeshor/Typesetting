#import "@preview/cetz:0.5.0"
#import "@preview/cetz-plot:0.1.3"
#import cetz.draw as ctx;
#set page(margin: 2cm);

#let _qn = counter("qn")
#_qn.step();
#let qn(tx) = context {
  line(length: 100%)
  text(weight: "bold")[#_qn.display(). ]
  _qn.step()

  tx

  v(10pt)
  text(size: 13pt, weight: "bold")[Answer: \ ]
}
#let arrow(x, y) = {
  ctx.line(x, y, mark: (end: "triangle"), fill: rgb(0, 0, 0))
}
#let cetzt(pos, txt) = {
  ctx.content(pos, txt, anchor: "text")
}
#let cetzc(pos, txt) = {
  ctx.content(pos, txt, anchor: "base")
}

#let axes(xend, yend, xlabel, ylabel, xs: 0.2) = {
  ctx.scope({
    ctx.stroke(.5pt)
    arrow((xend.at(0), 0), (xend.at(1), 0))
    arrow((0, yend.at(0)), (0, yend.at(1)))
    cetzt((xend.at(1), -.5), xlabel)
    cetzt((xs, yend.at(1)), ylabel)
  })
}


#let signal(x, y, txt) = {
  arrow((x, 0), (x, y))
  cetzc((x, -.4), txt)
}

#place(top + center, float: true, scope: "column")[
  #text(size: 24pt)[Signals and system]

  #text(size: 14pt)[Answers to some of the internal questions]

  #text(size: 12pt)[#link("https://github.com/roopeshor/Typesetting/tree/main/Notes/SAS")[#text(fill: rgb("#0074d9"),)[#underline[Typst Source]]]]
]

#qn([Plot the spectrum of the following signals:
  - $x(t) = delta(t + 2)$
  - $x(t) = 2sin(50pi n) + 5cos(100pi n)$
  - $x(n) = e^(j 20 pi n)$
  - $x(t) = e^(j 20 pi t)$
])

#let scale-to-container(body) = layout(ly => {
  let body-size = measure(body)

  scale(
    x: { ly.width / body-size.width * ly.width },
    y: { ly.width / body-size.width * body-size.height },
    reflow: true,
    body,
  )
})

#let f1 = cetz.canvas({
  axes((-5, 5), (-1, 5), $omega "(rad/s)"$, $|X(j w)|$)
  cetzt((.2, 2.2), "1")
  ctx.line((-5, 2), (5, 2))
})
#let f3 = cetz.canvas({
  axes((-5, 5), (-1, 4), $omega "(rad/s)"$, $|X(j w)|$)
  cetzt((.2, 2), "1")
  signal(0, 2, "0")
})
#let f4 = cetz.canvas({
  axes((-5, 5), (-1, 5), $omega "(rad/s)"$, $|X(j w)|$)
  cetzt((.2, 2), "1")
  signal(2, 2, $20 pi$)
})
#let f2 = cetz.canvas({
  axes((-5, 6), (-1, 4), $omega "(rad/s)"$, $|X(j w)|$)
  cetzt((.2, 1), "1")
  cetzt((.2, 2.5), "2.5")
  signal(-2, 1, $-50 pi$)
  signal(2, 1, $50 pi$)

  signal(-4, 5, $-100 pi$)
  signal(4, 5, $100 pi$)
});
#table(
  columns: 2,
  inset: 10pt,
  stroke: .5pt,
  [$x(t) = delta(t + 2)$
    #scale-to-container(f1)],
  [
    $x(t) = 2sin(50pi n) + 5cos(100pi n)$
    #scale-to-container(f2)
  ],

  [
    $x(n) = e^(j 20 pi n)$

    $x(n) = e^(j 20 pi n) = (e^(j 2 pi n))^10 = 1^10 = 1$

    (since n is an integer, $e^(2pi j n)= 1$)

    This is a DC value

    #scale-to-container(f3)
  ],

  [
    $x(t) = e^(j 20 pi t)$
    #scale-to-container(f4)
  ],
)

#qn([Find the sampling frequency of the signal both the continuous time and the discrete time signal.
  $ x(t) = sin(50pi t)cos(100pi t) $
])

In continuous time:
$
  x(t) & = sin(50pi t)cos(100pi t) \
       & = 1/2(sin(50pi t + 100pi t) - sin(50pi t - 100pi t) \
       & = 1/2(sin(150pi t) + sin(50pi t) \
$

Here maximum frequency is $150pi$ rad/s. Hence sampling frequency should be $300pi$ rad/s


In discrete time:
$
  x[n] = 1/2(sin[150pi n] + sin[50pi n]
$

since $n$ is integer, sin of every even multiple of $2pi$ is 0
$
  x[n] & = 1/2(sin[150pi n] + sin[50pi n] \
       & = 1/2(sin[75 times 2pi n] + sin[ 25 times 2pi n] \
       & = 0 \
$
#table(
  columns: 2,
  stroke: .5pt,
  [continuous time spectrum:
    #scale-to-container({
      cetz.canvas({
        axes((-5, 5), (-1, 5), $omega "(rad/s)"$, $|X(j w)|$)
        cetzt((.1, 2), "1/4")
        signal(-1, 2, "-50")
        signal(1, 2, "50")
        signal(-3, 2, "-150")
        signal(3, 2, "150")
      })
    })
    )],
  [discrete time spectrum:
    #scale-to-container({
      cetz.canvas({
        axes((-5, 5), (-1, 5), $omega "(rad/s)"$, $|X(j w)|$)
        ctx.line((-5, 0), (5, 0))
      })
    })
    )],
)


#qn([Find inverse Z transform of
  $
    H(z) & = (1 - 1/2 z^(-2)) / ((1 - z^(-1))(1 + 2z^(-1))) \
  $

  given $|z| > 2$. Comment on stability
])
#v(10pt)
-> Convert to positive powers of $z$:
$
  H(z) & = (1 - 1/2 z^(-2)) / ((1 - z^(-1))(1 + 2z^(-1))) \
       & = (z^2 - 0.5) / ((z - 1)(z + 2))
$

Divide by $z$ for partial fraction expansion:
$ H(z) / z = (z^2 - 0.5) / (z(z - 1)(z + 2)) = A/z + B/(z - 1) + C/(z + 2) $

Solve for coefficients:
$
  A & = ((z^2 - 0.5) / ((z - 1)(z + 2)))lr(|, size: #300%)_(z=0) = 1/4 \
  B & = ((z^2 - 0.5) / (z(z + 2)))lr(|, size: #300%)_(z=1) = 1/6 \
  C & = ((z^2 - 0.5) / (z(z - 1)))lr(|, size: #300%)_(z=-2) = 7/12
$

From this :
$
  H(z) & = 1/4 + 1/6 (z / (z - 1)) + 7/12 (z / (z + 2)) \
       & = 1/4 + 1/6 (1 / (1 - z^(-1))) + 7/12 (1 / (1 + 2z^(-1))) \
$

Given the ROC $|z| > 2$, the sequence is entirely causal:
$ h(n) = 1/4 delta(n) + 1/6 u(n) + 7/12 (-2)^n u(n) $

For a causal system to be stable all poles must lie inside the unit circle (their magnitude must be $|z|<1$). Or the ROC should contain unit circle. Since one of the pole is on -2, (outside of $|z|=1$) the system is unstable.


#qn([The difference equation of LTI is given by:
  $ y(n) + 2y(n-1)+2y(n-2)=x(n) $

  What is output when $x(n) = u(n)$
])
Apply the Z-transform to both sides of the difference equation, assuming zero initial conditions:
$ Y(z) + 2z^(-1)Y(z) + 2z^(-2)Y(z) = X(z) $

Factor out $Y(z)$ to find the transfer function $H(z)$:
$
  X(z) & = Y(z)(1 + 2z^(-1) + 2z^(-2)) \
  H(z) & = Y(z) / X(z) \
       & = 1 / (1 + 2z^(-1) + 2z^(-2))
$

To get output for given input, substitute Z-transform of the unit step input, $X(z) = 1 / (1 - z^(-1))$, and convert to positive powers of $z$:
$
  Y(z) & = (1 / (1 + 2z^(-1) + 2z^(-2))) (1 / (1 - z^(-1))) \
       & = (z^2 / (z^2 + 2z + 2)) (z / (z - 1)) \
       & = z^3 / ((z - 1)(z^2 + 2z + 2))
$

Divide by $z$ and factor quadratic term to get partial fraction expansion:
$
  Y(z) / z & = z^2 / ((z - 1)(z^2 + 2z + 2)) \
           & = z^2 / ((z - 1)(s + 1 - j)(s +1 + j)) \
           & = z^2 / ((z - 1)(s - p_1)(s - p_2)) \
           & = K_0 / (z - 1) + K_1 / (z - p_1) + K_2 / (z - p_2)
$


Where:

$ p_1 = -1+j, #h(10pt) p_2 = -1+-j $

in polar form:
$ p_1 = sqrt(2)exp(j (3pi)/4), quad p_2 = sqrt(2)exp(-j (3pi)/4) $



Solve for Coefficients:

$
  K_0 & = ((z^2) / ((z - p_1)(z - p_2)))lr(|, size: #300%)_(z = 1) = 1/5 \
  K_1 & = ((z^2) / ((z - 1)(z - p_2)))lr(|, size: #300%)_(z = -1 + j) \
      & = (-2j) / (-4j - 2)
        = j / (1 + 2j) \
      & = 2/5 + 1/5j \
  K_2 & = ((z^2) / ((z - 1)(z - p_2)))lr(|, size: #300%)_(z = -1 - j) \
      & = j / (1 + 2j) \
      & = 2/5 - 1/5j \
$


From these,
$
  Y(z) & = K_0 z / (z - 1) + K_1 z / (z - p_1) + K_2 z / (z - p_2) \
  Y(z) & = K_0 1 / (1 - z^(-1)) + K_1 1 / (1 - p_1z^(-1)) + K_2 1 / (1 - p_2z^(-1)) \
$
Apply the inverse Z-transform rule $a^n u(n)$:
$
  y(n) & = K_0u[n] + K_1(p_1)^n u[n] + K_2(p_2)^n u[n] \
  y(n) & = [1/5 + (2/5 + j(1/5))(p_1)^n + (2/5 - j(1/5))(p_2)^n] u(n)
$

Substitute the polar forms of $p_1, p_2$:

$ p_1 = sqrt(2)exp(j (3pi)/4), quad p_2 = sqrt(2)exp(-j (3pi)/4) $

$
  y(n) & = [ 1/5 \
       & + (2/5 + 1/5j)(sqrt(2)exp(j (3pi)/4))^n \
       & + (2/5 - 1/5j)(sqrt(2)exp(-j (3pi)/4))^n \
       & ] u(n)
$

factoring $(sqrt(2))^n$ and expanding inner bracket:
$
  y(n) & = u(n)[ 1/5 \
       & + (sqrt(2))^n [ text(
             fill: #rgb("#00f"), 2/5exp(j (3pi)/4n) + 1/5j exp(j (3pi)/4n) \
             & #h(40pt) + 2/5exp(-j (3pi)/4n) - 1/5j exp(-j (3pi)/4n)
           )] \
       & #h(20pt)]
$

Here term in blue can be simplfied as:
$
  & text(
    fill: #rgb("#00f"), 2/5exp(j (3pi)/4n) + 1/5j exp(j (3pi)/4n)
    + 2/5exp(-j (3pi)/4n) - 1/5j exp(-j (3pi)/4n)
  ) \
  & = 2/5 underbrace([exp(j (3pi)/4n) + exp(-j (3pi)/4n)], inline(2cos((3pi)/4n))) + 1/5 underbrace(j[exp(j (3pi)/4n) - exp(-j (3pi)/4n)], inline(-2sin((3pi) / 4n))) \
  & = 4/5 cos(3/4 pi n) - 2/5 sin(3/4 pi n)
$

Substituting this in $y(n)$ gives:

#box(stroke: 1pt, inset: 10pt)[$ y(n) = [ 1/5 + 4/5 (sqrt(2))^n cos((3pi)/4 n) - 2/5 (sqrt(2))^n sin((3pi)/4 n) ] u(n) $
]

#qn(
  [The Z transform of a input sequence x(n) is given as $ X(z) = 2z + 4 - 4z^(-1) + 3z^(-2) $
    and if $y(n) = x(n-1)$, find $Y(z)$],
)
given $y(n) = x(n-1)$

*Using time shifting property*:
$Y(z) = z^(-1)X(z)$

Substituting given $X(z)$ gives:
$Y(z) &= z^(-1) (2z + 4 - 4z^(-1) + 3z^(-2))$

#box(stroke: 1pt, inset: 10pt)[$Y(z) = 2 + 4z^(-1) - 4z^(-2) + 3z^(-3)$]


#qn([Classify signal $x(t) = e^(j 10 t)u(t)$ into various classes of signals])

#cetz.canvas({
  import cetz.draw: *

  // Set up the orthographic 3D space
  ortho(x: 25deg, y: 30deg, z: 0deg, {
    // 1. Draw the 3D Axes
    // t-axis maps to x
    line((-1, 0, 0), (3.5, 0, 0), mark: (end: ">"), stroke: gray)
    content((3.8, 0, 0), [$t$])

    // Re-axis maps to y
    line((0, -2.5, 0), (0, 2.5, 0), mark: (end: ">"), stroke: gray)
    content((0, 2.5, 0), [$Im(x(t))$])

    // Im-axis maps to z
    line((0, 0, -2.5), (0, 0, 2.5), mark: (end: ">"), stroke: gray)
    content((0, 0, 2.5), [$Re(x(t))$])

    // 2. Plot the signal for t < 0 (Zero due to u(t))
    let points-zero = range(-20, 1).map(i => {
      let t = i / 10
      (t, 0, 0)
    })
    line(..points-zero, stroke: 1pt + blue)

    // 3. Plot the signal for t >= 0 (Complex Helix)
    let points-helix = range(0, 300).map(i => {
      let t = i / 100
      let theta = 10 * t // Frequency = 10 rad/s

      let im = calc.cos(theta * 1rad)
      let re = calc.sin(theta * 1rad)

      // Pass coordinates natively as (x, y, z)
      (t, re, im)
    })
    line(..points-helix, stroke: 1pt + blue)
  })
})

Plot of $x(t) = e^(j 10 t)u(t)$

*Duration: Infinite Duration*\
The unit step function $u(t)$ turns the signal "on" at $t = 0$. Because the complex exponential $e^(j 10 t)$ oscillates endlessly as time progresses, the signal extends from $t = 0$ to $t -> infinity$. Therefore, it is an *infinite duration* signal.
#v(10pt)
*Power Signal*\
Magnitude of the signal is:
$ |x(t)| = |e^(j 10 t) dot u(t)| = |e^(j 10 t)| dot u(t) = u(t) $

From this energy and power is computed:
- Energy:
  $ E = integral_(-infinity)^infinity |x(t)|^2 d t = integral_0^infinity 1^2 d t = infinity $
- Power:
  $
    P = lim_(T -> infinity) 1/(2T) integral_(-T)^T |x(t)|^2 d t = lim_(T -> infinity) 1/(2T) integral_0^T 1 d t = lim_(T -> infinity) T/(2T) = 1/2
  $

Because average power is finite and non-zero this is a Power signal.

#v(10pt)
*Periodicity: Aperiodic*\
For a signal to be periodic, it must satisfy $x(t) = x(t + T)$ for all values of $t$ from $-infinity$ to $infinity$. The signal is zero for negative time but oscillating for positive time, meaning it does not repeat its past behavior. Therefore, it is *aperiodic*.

#v(10pt)
*Symmetry: Neither Even nor Odd*\
Because $x(t)$ is entirely zero for $t < 0$ and non-zero for $t > 0$, it is asymmetrical around the y-axis. It is *neither even nor odd*.

#v(10pt)
*Causal*\
A system or signal is strictly causal if it equals zero for all negative time ($x(t) = 0$ for $t < 0$).
Because the entire expression is multiplied by the unit step function $u(t)$ the signal only exists for $t>=0$  hence it is a *causal* signal.

#v(10pt)
*Deterministic*\
A signal is deterministic if its value can be predicted at any given point in time using a mathematical equation. Since given input is a well-defined mathematical function, it is entirely predictable. It is a *deterministic* signal.


#qn([Find Z transform of $x(n) = (n-2)0.8^(n-2) u(n-2)$
])

Let $w(n) = n 0.8^n u(n)$, hence $x(n) = w(n-2)$

Let $v(n) = 0.8^n u(n)$, hence $w(n) = n v(n)$

Z Z-transform of $x(n)$ is:
$
  X(z) & = Z[w(n-2)] \
       & = z^(-2)Z[w(n)] \
       & = z^(-2)W(z) \
  W(z) & = Z[n v(n)] \
       & = -z (d Z[v(n)])/(d z) #h(1cm) "[Differentiation in Z domain]" \
       & = -z (d V(z))/(d z) \
  V(z) & = Z[0.8^n u(n)] \
       & = 1/(1-0.8z^(-1)) \
       & = z/(z-0.8)
$

Hence substituting back:
$
            W(z) & = -z (d V(z))/(d z) \
                 & = -z d/(d z)[z/(z-0.8)] \
                 & = -z (z-0.8 - z)/(z-0.8)^2 = -z (-0.8)/(z-0.8)^2 \
                 & = (0.8z)/(z-0.8)^2 \
$

$
  therefore X(z) & = z^(-2)W(z) \
                 & = z^(-2)(0.8z)/(z-0.8)^2 \
                 & = (0.8z^(-1))/(z-0.8)^2
$
#box(stroke: 1pt, inset: 10pt)[$ X(z) & = (0.8z^(-1))/(z-0.8)^2 $]


#qn([Check whether following signal is energy or power signal

  #cetz.canvas(x: 400pt, y: 45pt, {
    axes((0, 1), (0, 2.5), "t", "x(t)", xs: 0.2 / 10)
    for t in range(0, 10) {
      ctx.content((t / 10, -.2), [#(t / 10)])
    }
    for t in range(1, 5) {
      ctx.content((-.3 / 10, t / 2), [#(t / 2)])
    }

    for v in range(0, 5) {
      ctx.line((v * 0.2 + 0, 0.5), (v * 0.2 + 0.1, 2))
      ctx.line((v * 0.2 + 0.1, 2), (v * 0.2 + 0.2, 0.5))
    }
  })

])


The signal consists of periodic triangular wave. By definition, all continuous periodic signals are power signals.

*Because the wave repeats indefinitely, the total area under its squared magnitude curve is infinite. Therefore, the total energy $E = oo$.*

Because the signal period is finite (between 0.5 and 2), the energy over a single period is finite. Averaging this over time yields a finite average power $0 < P < oo$.

To calculate power, the piecewise equations for the signal during the first period ($0 <= t <= 0.2$) has to be obtained:

$
  x(t) = cases(
    15t + 0.5 & "for" 0 <= t <= 0.1,
    -15t + 3.5 & "for" 0.1 < t <= 0.2
  )
$

Thus average power is:
$ P = 1/T integral_0^T |x(t)|^2 d t $

Here $T = 0.2$, split the integral for the two segments:
$ P = 1/0.2 [ integral_0^0.1 (15t + 0.5)^2 d t + integral_0.1^0.2 (-15t + 3.5)^2 d t ] $

Evaluate the first integral using the reverse chain rule: $ integral (a t+b)^2 d t = (a t+b)^3 / (3a) $

#v(10pt)
$
  integral_0^0.1 (15t + 0.5)^2 d t & = [ ((15t + 0.5)^3) / (3 (15)) ]_0^0.1 \
                                   & = ( (15(0.1) + 0.5)^3 - (15(0) + 0.5)^3 ) / 45 \
                                   & = (2^3 - 0.5^3) / 45 = (8 - 0.125) / 45 = 7.875 / 45 = 0.175
$

Because the triangle is symmetric, the second integral evaluates to the same area:
$ integral_0.1^0.2 (-15t + 3.5)^2 d t = 0.175 $

Final average power:
$ P = 1/0.2 [ 0.175 + 0.175 ] = 5 [ 0.35 ] = 1.75 $

Since $P = 1.75$ (a finite, non-zero value) and $E = oo$, the signal is a power signal.
