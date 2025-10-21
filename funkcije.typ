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
