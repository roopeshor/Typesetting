// Create a treemap

#import "@preview/cetz:0.5.2"
// INTERNAL FUNCTIONS not meant to be used by the user

#let pad_rectangle(rect) = {
  if rect.dx > 2 {
    rect.x += 1
    rect.dx -= 2
  }
  if rect.dy > 2 {
    rect.y += 1
    rect.dy -= 2
  }
  return rect
}

#let layoutrow(sizes, x, y, dx, dy) = {
  // generate rects for each size in sizes
  // dx >= dy
  // they will fill up height dy, and width will be determined by their area
  // sizes should be pre-normalized wrt dx * dy (i.e., they should be same units)
  let covered_area = sizes.sum()
  let width = covered_area / dy
  let rects = ()
  for size in sizes {
    rects.push((x: x, y: y, dx: width, dy: size / width))
    y += size / width
  }
  return rects
}

#let layoutcol(sizes, x, y, dx, dy) = {
  // generate rects for each size in sizes
  // dx < dy
  // they will fill up width dx, and height will be determined by their area
  // sizes should be pre-normalized wrt dx * dy (i.e., they should be same units)
  let covered_area = sizes.sum()
  let height = covered_area / dx
  let rects = ()
  for size in sizes {
    rects.push((x: x, y: y, dx: size / height, dy: height))
    x += size / height
  }
  return rects
}

#let treemap-layout(sizes, x, y, dx, dy) = {
  return if dx >= dy {
    layoutrow(sizes, x, y, dx, dy)
  } else {
    layoutcol(sizes, x, y, dx, dy)
  }
}

#let leftoverrow(sizes, x, y, dx, dy) = {
  // compute remaining area when dx >= dy
  let covered_area = sizes.sum()
  let width = covered_area / dy
  let leftover_x = x + width
  let leftover_y = y
  let leftover_dx = dx - width
  let leftover_dy = dy
  return (leftover_x, leftover_y, leftover_dx, leftover_dy)
}

#let leftovercol(sizes, x, y, dx, dy) = {
  // compute remaining area when dx >= dy
  let covered_area = sizes.sum()
  let height = covered_area / dx
  let leftover_x = x
  let leftover_y = y + height
  let leftover_dx = dx
  let leftover_dy = dy - height
  return (leftover_x, leftover_y, leftover_dx, leftover_dy)
}

#let leftover(sizes, x, y, dx, dy) = {
  return if dx >= dy {
    leftoverrow(sizes, x, y, dx, dy)
  } else {
    leftovercol(sizes, x, y, dx, dy)
  }
}

#let worst_ratio(sizes, x, y, dx, dy) = {
  return calc
    .max(
      treemap-layout(sizes, x, y, dx, dy).map(rect => calc.max(rect.dx / rect.dy, rect.dy / rect.dx)),
    )
    .first()
}

/// PUBLIC API

#let squarify(sizes, x, y, dx, dy) = {
  // Compute treemap rectangles.
  // Given a set of values, computes a treemap layout in the specified geometry
  // using an algorithm based on Bruls, Huizing, van Wijk, "Squarified Treemaps".
  // See README for example usage.
  //
  // Parameters:
  // - sizes: list-like of numeric values
  //   The set of values to compute a treemap for. `sizes` must be positive
  //   values sorted in descending order and they should be normalized to the
  //   total area (i.e., `dx * dy == calc.sum(sizes)`)
  // - x, y: numeric
  //   The coordinates of the "origin".
  // - dx, dy: numeric
  //   The full width (`dx`) and height (`dy`) of the treemap.
  //
  // Returns:
  // list[dict]
  //   Each dict in the returned list represents a single rectangle in the
  //   treemap. The order corresponds to the input order.
  let sizes = sizes.map(x => float(x))

  if sizes.len() == 0 {
    return ()
  }

  if sizes.len() == 1 {
    return treemap-layout(sizes, x, y, dx, dy)
  }
  // figure out where 'split' should be
  let i = 1
  // panic(worst_ratio(sizes.slice(0,i), x, y, dx, dy))
  while (
    i < sizes.len() and worst_ratio(sizes.slice(0, i), x, y, dx, dy) >= worst_ratio(sizes.slice(0, i + 1), x, y, dx, dy)
  ) {
    i += 1
  }
  let current = sizes.slice(0, i)
  let remaining = sizes.slice(i)

  let (leftover_x, leftover_y, leftover_dx, leftover_dy) = leftover(current, x, y, dx, dy)
  return treemap-layout(current, x, y, dx, dy) + squarify(remaining, leftover_x, leftover_y, leftover_dx, leftover_dy)
}

#let padded_squarify(sizes, x, y, dx, dy) = {
  // Compute padded treemap rectangles.
  // See `squarify` docstring for details. The only difference is that the
  // returned rectangles have been "padded" to allow for a visible border.
  let rects = squarify(sizes, x, y, dx, dy)
  return rects.map(rect => pad_rectangle(rect))
}

#let normalize_sizes(sizes, dx, dy) = {
  // Normalize list of values.
  // Normalizes a list of numeric values so that `calc.sum(sizes) == dx * dy`.
  //
  // Parameters:
  // - sizes: list-like of numeric values
  //   Input list of numeric values to normalize.
  // - dx, dy: numeric
  //   The dimensions of the full rectangle to normalize total values to.
  //
  // Returns:
  // list[numeric]
  //   The normalized values.
  let total_size = sizes.sum()
  let total_area = dx * dy
  let sizes = sizes.map(size => size * total_area / total_size)
  return sizes
}

#let treemap(
  sizes,
  norm_x: 100,
  norm_y: 100,
  colors: none,
  labels: none,
  pad: false,
  scaler: 1,
) = {
  let normed = normalize_sizes(sizes, norm_x, norm_y)
  //normed=normed.map(x=>x*0.1)

  let rects = if pad {
    padded_squarify(normed, 0, 0, norm_x, norm_y)
  } else {
    squarify(normed, 0, 0, norm_x, norm_y)
  }

  cetz.canvas({
    let draw_rectangles(rects, labels, colors, scaler) = {
      // Import the draw functions from cetz package
      import cetz.draw: *
      // Loop through each dictionary in the data list
      for (idx, item) in rects.enumerate() {
        // Extract the x, y, dx, and dy values from the dictionary
        let (x, y, dx, dy) = (item.x * scaler, item.y * scaler, item.dx * scaler, item.dy * scaler)
        // Draw a rectangle from (x, y) to (x + dx, y + dy)
        let col = white
        if type(colors) == array and idx < colors.len() {
          col = colors.at(idx)
        }

        rect((x, y), (x + dx, y + dy), fill: col)

        if idx < labels.len() {
          content((x + dx / 2, y + dy / 2), [#labels.at(idx)])
        }
      }
    }

    draw_rectangles(rects, labels, colors, scaler)
  })
}

#layout(size => {
  let Nx = 300
  treemap(
    (50, 100, 200, 250, 150, 300, 500, 1000),
    norm_x: Nx,
    norm_y: 300,
    pad: true,
    labels: ("o", "r", "t", "v", "s", "h", "u", "b"),
    colors: (red, green, blue, orange, yellow, maroon, teal, purple),
    scaler: size.width / Nx,
  )
})
