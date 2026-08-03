#import "@preview/headcount:0.1.1": dependent-numbering
#let mod-inverse(a, m) = {
  let a-mod = calc.rem(a, m)
  // Handle negative inputs safely
  if a-mod < 0 { a-mod = a-mod + m }

  let found = -1
  for i in range(1, m) {
    if calc.rem(a-mod * i, m) == 1 {
      found = i
      break
    }
  }
  found
}

#let power-mod(base, exp, m) = {
  if exp == 0 { return 1 }
  let res = 1
  let b = calc.rem(base, m)
  if b < 0 { b = b + m }

  let e = exp
  while e > 0 {
    if calc.rem(e, 2) == 1 {
      res = calc.rem(res * b, m)
    }
    b = calc.rem(b * b, m)
    e = calc.floor(e / 2)
  }
  res
}

// Function to compute (2^-n) mod m
#let inv-pow-mod(base, n, m) = {
  let inv = mod-inverse(base, m)
  if inv == -1 { return "Inverse does not exist" }
  power-mod(inv, n, m)
}



#let colors = (
  rgb("#000000"),
  rgb("#00b0c7"),
  rgb("#3d8903"),
  rgb("#7527f2"),
  rgb("#e00c01"),
)

#let map-colors(i, txt) = {
  if i < colors.len() {
    return text(fill: colors.at(i))[#txt]
  } else {
    return text()[#txt]
  }
}

#let matrix-from-rc(r, c, fx) = {
  c.map(n => r.map(k => fx(n, k)))
}

#let transpose_vec(mat) = {
  let m = ()
  for (x, i) in mat.enumerate() { m += ((i,),) }
  return m
}

#let def-mapper(i, txt) = text()[#txt]

#let elementwise-transform-2d(mat, mapper) = {
  for (i, r) in mat.enumerate() {
    for (j, c) in r.enumerate() {
      mat.at(i).at(j) = mapper(c)
    }
  }
  return mat
}


#let mod-arith(a, b, MOD: 5) = calc.rem(a * b, MOD)

#let numbered_eq(content) = math.equation(
  block: true,
  numbering: dependent-numbering("(1.1)"),
  content,
)

#let show_eqnum(eq) = context {
  let el = query(eq).first()
  
  numbering(dependent-numbering("(1.1)"), ..counter(math.equation).at(el.location()))
}
