#counter(heading).update(1)
#set heading(numbering: "A.1")
#set page(margin: (left: 1.2in, right: 1in, top: 1.4in, bottom: 1in))

#heading(numbering: none)[Appendices]
== Source code
#rect(
  inset: 10pt,
  [All source code (SystemVerilog) for the algorithms and testbenches are posted in GitHub. `https://github.com/roopeshor/FFT-implementations`],
)
#v(-10pt)
== 16 point Winograd algorithm <ap:w16>

Let  $u = 2pi \/ 16$, $C_1 = cos(u)$, $C_2 = cos(2u)$, $C_3 = cos(3u)$
$S_1 = sin(u)$, $S_2 = sin(2u)$, $S_3 = sin(3u)$\
*Pre-additions*
#grid(
  column-gutter: 1cm,
  columns: 5,
  [$
    t_1 & = x_0 + x_8 \
    t_2 & = x_4 + x_12 \
    t_3 & = x_2 + x_10 \
    t_4 & = x_2 - x_10 \
    t_5 & = x_6 + x_14 \
    t_6 & = x_6 - x_14 \
  $],
  [$
      & t_7 = x_1 + x_9 \
      & t_8 = x_1 - x_9 \
      & t_9 = x_3 + x_11 \
      & t_10 = x_3 - x_11 \
      & t_11 = x_5 + x_13 \
    $
  ],
  [
    $
      t_12 & = x_5 - x_13 \
      t_13 & = x_7 + x_15 \
      t_14 & = x_7 - x_15 \
      t_15 & = t_1 + t_2 \
      t_16 & = t_3 + t_5 \
    $
  ],
  [
    $
      t_17 & = t_15 + t_16 \
      t_18 & = t_7 + t_11 \
      t_19 & = t_7 - t_11 \
      t_20 & = t_9 + t_13 \
      t_21 & = t_9 - t_13 \
    $
  ],
  [
    $
      t_22 & = t_18 + t_20 \
      t_23 & = t_8 + t_14 \
      t_24 & = t_8 - t_14 \
      t_25 & = t_10 + t_12 \
      t_26 & = t_12 - t_10 \
    $
  ],
)

*Multiplications*
#grid(
  column-gutter: 0.6cm,
  columns: 4,
  [
    $
      m_0 & = 1 (t_17 + t_22) \
      m_1 & = 1 (t_17 - t_22) \
      m_2 & = 1 (t_15 - t_16) \
      m_3 & = 1 (t_1 - t_2) \
      m_4 & = 1 (x_0 - x_8) \
    $

  ],
  [
    $
      m_5 & = C_2 (t_19 - t_21) \
      m_6 & = C_2 (t_4 - t_6) \
      m_7 & = C_3 (t_24 + t_26) \
      m_8 & = (C_1 + C_3) t_24 \
      m_9 & = (C_3 - C_1) t_26 \
    $
  ],
  [
    $
      m_10 & = j (t_20 - t_18) \
      m_11 & = j (t_5 - t_3) \
      m_12 & = j (x_12 - x_4) \
    $
  ],
  [
    $
      m_13 & = -j S_2 (t_19 + t_21) \
      m_14 & = -j S_2 (t_4 + t_6) \
      m_15 & = -j S_3 (t_23 + t_25) \
      m_16 & = j (S_3 - S_1) t_23 \
      m_17 & = -j (S_1 + S_3) t_25 \
    $
  ],
)

*Post-additions*
#grid(
  column-gutter: 1cm,
  columns: 4,
  [
    $
      s_1 & = m_3 + m_5 \
      s_2 & = m_3 - m_5 \
      s_3 & = m_11 + m_13 \
      s_4 & = m_13 - m_11 \
      s_5 & = m_4 + m_6 \
    $
  ],
  [
    $
      & s_6 = m_4 - m_6 \
      & s_7 = m_8 - m_7 \
      & s_8 = m_9 - m_7 \
      & s_9 = s_5 + s_7 \
      & s_10 = s_5 - s_7 \
    $
  ],
  [
    $
      s_11 & = s_6 + s_8 \
      s_12 & = s_6 - s_8 \
      s_13 & = m_12 + m_14 \
      s_14 & = m_12 - m_14 \
      s_15 & = m_15 + m_16 \
    $
  ],
  [$
    s_16 & = m_15 - m_17 \
    s_17 & = s_13 + s_15 \
    s_18 & = s_13 - s_15 \
    s_19 & = s_14 + s_16 \
    s_20 & = s_14 - s_16
  $],
)

*Output Mapping (Final output)*
#grid(
  column-gutter: 1cm,
  columns: 4,
  [
    $
      X_0 & = m_0 \
      X_1 & = s_9 + s_17 \
      X_2 & = s_1 + s_3 \
      X_3 & = s_12 - s_20 \
    $
  ],
  [$
    X_4 & = m_2 + m_10 \
    X_5 & = s_11 + s_19 \
    X_6 & = s_2 + s_4 \
    X_7 & = s_10 - s_18 \
  $],
  [$
    & X_8 = m_1 \
    & X_9 = s_10 + s_18 \
    & X_10 = s_2 - s_4 \
    & X_11 = s_11 - s_19 \
  $],
  [$
      X_12 & = m_2 - m_10 \
      X_13 & = s_12 + s_20 \
      X_14 & = s_1 - s_3 \
      X_15 & = s_9 - s_17
    $
  ],
)
