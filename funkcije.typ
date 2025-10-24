#let physical(citations, appendices) = context {
  let chapters = query(heading.where(level: 1, outlined: true)).len()
  let pages = counter(page).final().first()
  //let citations = 0 //FIXME
  let tables = query(figure.where(kind: table)).len()
  let images = query(
    figure.where(kind: image).or(figure.where(kind: raw))
  ).len()
  let graphics = 0
  //let appendices = 0 //FIXME

  (chapters, pages, citations, tables, images, graphics, appendices).map(str).join("/")
}

#let dodatak(d) = figure(
    kind: "dodatak",
    supplement: [Додатак],
    d
)

// Маркирање потребних измена. Базирано на
// https://github.com/typst/typst/issues/662#issuecomment-1516709607
#let todo(x) = [ #text([TODO: #x <todo>], red) ]

#let todos() = context {
    let elems = query(
        <todo>
    )

    if elems.len() == 0 {
        return
    }

    pagebreak()
    [= TODOs <todos>]

    for body in elems {
        text([+ #link(body.location(), body)], red)
    }
}

#let green(x) = highlight(fill: rgb("#a3d450"), x)
#let red(x) = highlight(fill: rgb("#eb4646"), x)
