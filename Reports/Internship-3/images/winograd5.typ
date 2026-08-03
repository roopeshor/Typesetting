#import "@preview/cetz:0.5.2"
#let winograd5-ckt = cetz.canvas({
  import cetz.draw: *
  let ar = .15
  let pad(a, x, y) = (a.at(0) + x, a.at(1) + y)
  let sub(p, name: "") = {
    line(p, (rel: (ar, 0)), stroke: none, name: "anc")
    circle("anc.end", radius: ar, name: name)
    line("anc.end", (rel: (ar * 13 / 20, 0)))
    line("anc.end", (rel: (-ar * 13 / 20, 0)))
  }
  let adder(p, name: "") = {
    line(p, (rel: (ar, 0)), stroke: none, name: "anc")
    circle("anc.end", radius: ar, name: name)
    line("anc.end", (rel: (ar * 13 / 20, 0)))
    line("anc.end", (rel: (-ar * 13 / 20, 0)))
    line("anc.end", (rel: (0, -ar * 13 / 20)))
    line("anc.end", (rel: (0, ar * 13 / 20)))
  }

  let mul(p, txt, h: .6, w: 1.1, name: "", pdy: .15, anchor: "north", pos: ".40%", ah: "straight") = {
    line(p, (rel: (w, 0)), name: name)
    mark(name + pos, (rel: (1, 0)), symbol: ah)
    content(name + pos, txt, anchor: anchor, padding: pdy)
  }

  let draw_stage(bboxp1, bboxp2, s) = {
    let cols = (
      "1": green,
      "2": red,
      "3": orange,
      "4": blue,
      "5": color.aqua,
    )
    rect(
      bboxp1,
      bboxp2,
      name: "stage" + s,
      fill: cols.at(s).transparentize(85%),
      // stroke: (dash: "dashed", thickness: .5pt),
      stroke: none,
    )
    content("stage" + s + ".north", [Stage #s], anchor: "north", padding: .1)
  }
  scale(y: -1)
  let x0 = (0, .5)
  let x1 = (0, 1)
  let x4 = (0, 3.3)
  let x2 = (0, 4.4)
  let x3 = (0, 6.7)
  let x0n = x0
  let x1n = x1
  let x4n = x4
  let x2n = x2
  let x3n = x3
  let bboxp1 = x0
  let bboxp2 = x0
  let ext0 = .2
  let ext1 = 1
  let ext2 = 3
  let ext3 = 2
	let ext4 = 1
	let ext5 = 1.2
	let ext6 = 1.5
  let ext7 = 1.5
  let ext8 = 1.2

	line(pad(x1, -1, 0), (rel: (1, 0)), name: "x1")
	line(pad(x4, -1, 0), (rel: (1, 0)), name: "x4")
	line(pad(x2, -1, 0), (rel: (1, 0)), name: "x2")
	line(pad(x3, -1, 0), (rel: (1, 0)), name: "x3")
  content("x1.start", [*$x_1$*], name: "x1", anchor: "east")
  content("x4.start", [*$x_4$*], name: "x4", anchor: "east")
  content("x2.start", [*$x_2$*], name: "x2", anchor: "east")
  content("x3.start", [*$x_3$*], name: "x3", anchor: "east")

  bboxp1 = pad(x0, 0, 0)

  x1n = pad(x1, ext1, 0)
  x4n = pad(x4, ext1, 0)
  x2n = pad(x2, ext1, 0)
  x3n = pad(x3, ext1, 0)

  ///// stage 1 (c_xx)
  adder(x4n, name: "c00")
  adder(x2n, name: "c01")
  sub(x1n, name: "c20")
  sub(x3n, name: "c21")

  line(x4, "c00")
  line(x2, "c01")
  line(x1, "c20")
  line(x3, "c21")

  line(x4, "c20")
  line(x2, "c21")
  line(x1, "c00")
  line(x3, "c01")

  line("c00", (rel: (ext2, 0)), name: "c00")
  line("c01", (rel: (ext2, 0)), name: "c01")

  line("c20", (rel: (ext2 / 2.45, 0)), name: "c20")
  line("c21", (rel: (ext2 / 2.45, 0)), name: "c21")
  content("c20.30%", $c_20$, anchor: "south", padding: .1)
  content("c21.30%", $c_21$, anchor: "south", padding: .1)

  x1 = x1n
  x4 = x4n
  x2 = x2n
  x3 = x3n
  bboxp2 = pad(x3n, .9, 1)
  x1n = pad(x1n, ext2, 0)
  x4n = pad(x4n, ext2, 0)
  x2n = pad(x2n, ext2, 0)
  x3n = pad(x3n, ext2, 0)
  content("c00.10%", $c_00$, anchor: "south", padding: .1)
  content("c01.10%", $c_01$, anchor: "south", padding: .1)

  

  ///// stage 2 (y_x)
  import "../circucetz/lib.typ": L-wire, joint
  adder("c01.end", name: "c00+c01")
  sub("c00.end", name: "c00-c01")

  line("c00.40%", "c00+c01")
  joint("c00.40%").draw
  line("c01.40%", "c00-c01")
  joint("c01.40%").draw

  let mulpy = .8
  let mulpx = .5
  let mulw = 3
  line("c00+c01", (rel: (ext3, 0)), name: "y00")
  content("y00.20%", text(size: 9pt)[$y_00$], anchor: "south", padding: .1)

  line("c00-c01", (rel: (ext3, 0)), name: "y10")
  content("y10.20%", text(size: 9pt)[$y_10$], anchor: "south", padding: .1)

  mul("c20.end", text(size: 9pt)[$d_20\/2$], w: mulw, name: "c20d20")
  line("c20.end", (rel: (0, mulpy)), name: "c20d21-start")

  mul("c20d21-start.end", text(size: 9pt)[$d_21\/2$], name: "c20d21", w: mulw)

  mul("c21.end", text(size: 9pt)[$d_20\/2$], w: mulw, name: "c21d20")
  line("c21.end", (rel: (0, -mulpy)), name: "c21d21-start")

  mul("c21d21-start.end", text(size: 9pt)[$d_21\/2$], name: "c21d21", w: mulw)

  joint("c20d21-start.start").draw
  joint("c21d21-start.start").draw

  ///// stage 3

  line("c21d20.end", (rel: (ext4, 0)), name: "c21d20")
  line("c20d20.end", (rel: (ext4, 0)), name: "c20d20")
  sub("c21d20.end", name: "c21d20-c20d21")
  adder("c20d20.end", name: "c20d20+c21d21")
  line("c20d21.end", "c21d20-c20d21")
  line("c21d21.end", "c20d20+c21d21")

  line("y10.end", (rel: (ext4 - .5, 0)), name: "y10")
  line("y00.end", (rel: (ext4 - .5, 0)), name: "y00")
  line("y00.end", (rel: (0, mulpy)), name: "y00'")

  mul("y00.end", text(size: 9pt)[$-1\/4$], name: "y00/4", ah: "[]", w: mulw / 2.7)
  joint("y00.end").draw
  line("y00'.end", (rel: (mulw / 1.5, 0)), name: "y00")

  mul("y10.end", text(size: 9pt)[$w^((1))\/4$], name: "y1'")

  line("y00/4.end", (rel: (.9, 0)), name: "y00/4")
  line("y1'.end", (rel: (.9, 0)), name: "y1'")

  content("y00/4.end", text(size: 9pt)[$-y_00\/4$], anchor: "south-east", padding: .1)
  content("y00.end", text(size: 9pt)[$y_00$], anchor: "south-east", padding: .1)
  content("y1'.end", text(size: 9pt)[$y'_1$], anchor: "south-east", padding: .1)
  line("c20d20+c21d21", (rel: (mulw / 1.3, 0)), name: "y20")
  line("c21d20-c20d21", (rel: (mulw / 1.3, 0)), name: "y21")
  content("y20.end", text(size: 9pt)[$y_20$], anchor: "south-east", padding: .1)
  content("y21.end", text(size: 9pt)[$y_21$], anchor: "south-east", padding: .1)

  // stage4
  
  line("y1'.end", (rel: (ext5, 0)), name: "y1'_ext")
  line("y00/4.end", (rel: (ext5, 0)), name: "y00/4_ext")

  sub("y00/4_ext.end", name: "y00/4-y1'")
  adder("y1'_ext.end", name: "y00/4+y1'")

  line("y00/4.end", "y00/4+y1'")
  line("y1'.end", "y00/4-y1'")

	//tmp stroke
	line("y20.end", (rel: (0, mulpy)), name: "x0_1", stroke: none)
  content("x0_1.end", [*$x_0$*], name: "x0", anchor: "east")

  line("y20.end", (rel: (ext5, 0)), name: "y20")
  line("x0_1.end", (rel: (ext5, 0)), name: "x0_1")

  sub("x0_1.end", name: "x0-y20")
  adder("y20.end", name: "x0+y20")

  line("x0_1.start", "x0+y20")
  line("y20.start", "x0-y20")

	line("y21.end", (rel: (0, -mulpy - .1)), name: "x0_2-start", stroke: none)
  content("x0_2-start.end", [*$x_0$*], name: "x0_2", anchor: "east")

  line("y21.end", (rel: (ext5, 0)), name: "y21")
  line("x0_2.east", (rel: (ext5, 0)), name: "x0_2")

  sub("x0_2.end", name: "x0-y21")
  adder("y21.end", name: "x0+y21")

  line("y21.start", "x0-y21")
  line("x0_2.start", "x0+y21")

  line("y00.end", (rel: (ext5, 0)), name: "y00")

  adder("y00.end", name: "x0+y00")
  line("x0_2-start.end", "x0+y00")

  ///// stage 5

  line("x0+y20.east", (rel: (ext6, 0)), name: "x0+y20")
  // line("y00/4+y1'.east", (rel: (ext6, 0)), name: "y00/4+y1'")

  adder("x0+y20.end", name: "Y1")
  // adder("y00/4+y1'.end", name: "Y2")
  line("y00/4+y1'.east", "Y1")
  line("x0+y00.east", (rel: (ext7 + ext6, 0)), name: "Y0")
  line("Y1.east", (rel: (ext8, 0)), name: "Y1")

	line("y00/4+y1'.east", (rel: (ext7, 0)), name: "y00/4+y1'")
	adder("y00/4+y1'.end", name: "Y4")
	line("x0-y20", "Y4")
	line("Y4.east", (rel: (ext8, 0)), name: "Y4")

	line("y00/4-y1'.east", (rel: (ext7, 0)), name: "y00/4-y1'")
	adder("y00/4-y1'.end", name: "Y2")

	line("x0+y21", "Y2")
	line("Y2.east", (rel: (ext8, 0)), name: "Y2")

	line("x0-y21.east", (rel: (ext7, 0)), name: "x0-y21")
	adder("x0-y21.end", name: "Y3")
	line("y00/4-y1'.start", "Y3")
	line("Y3.east", (rel: (ext8, 0)), name: "Y3")


  content("Y1.end", text(size: 9pt)[*$Y(1)$*], name: "Y(1)", anchor: "west", padding: .2)
  content("Y0.end", text(size: 9pt)[*$Y(0)$*], name: "Y(0)", anchor: "west", padding: .2)
  content("Y4.end", text(size: 9pt)[*$Y(4)$*], name: "Y(4)", anchor: "west", padding: .2)
  content("Y2.end", text(size: 9pt)[*$Y(2)$*], name: "Y(2)", anchor: "west", padding: .2)
  content("Y3.end", text(size: 9pt)[*$Y(3)$*], name: "Y(3)", anchor: "west", padding: .2)

  group(name: "my-group", ctx => {
    let (ctx, pos) = cetz.coordinate.resolve(ctx, "c21d20.end")
    let (ctx, pos2) = cetz.coordinate.resolve(ctx, "y1'.end")
    let (ctx, pos3) = cetz.coordinate.resolve(ctx, "x0-y21.start")
    let (ctx, pos4) = cetz.coordinate.resolve(ctx, "Y4.start")
		draw_stage(bboxp1, bboxp2, "1")
    draw_stage("stage1.south-east", (pos.at(0) - 1.2, bboxp2.at(1)), "2")
    draw_stage("stage2.south-east", (pos2.at(0), bboxp2.at(1)), "3")
    draw_stage("stage3.south-east", (pos3.at(0) + .1, bboxp2.at(1)), "4")
    draw_stage("stage4.south-east", (pos4.at(0), bboxp2.at(1)), "5")
  })
})
