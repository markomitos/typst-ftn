// У овом фајлу је потребно да укључите поглавља. Видети TODO доле.
// Такође, видите metadata.typ

#import "metadata.typ": *
#set page(paper: format_strane, margin: (y: 2.5cm, inside: 2cm, outside: 1.5cm))
#include "naslovna.typ"
#pagebreak()
#pagebreak()
#include "zadatak.typ"
#pagebreak()
#pagebreak()
#include "kljucna.typ"
#pagebreak()
#include "sukob-interesa.typ"

#set text(lang: "sr")

#set document(title: "Наслов рада", author: "Аутор")
#set heading(numbering: "1.1")
#set text(font: "Liberation Serif", size: 11pt)
#set par(justify: true)
#show link: set text(blue)
#show cite: set text(blue)
#show ref: set text(blue)
#show heading: set text(hyphenate: false)

#show figure.where(
  kind: table
): set figure.caption(position: top)
#show figure.where(kind: raw): set figure(supplement: [Листинг])
#set ref(supplement: none)


#import "@preview/hydra:0.6.2": hydra

#show heading.where(level: 1): (it) => {
    pagebreak(to: "odd", weak: true)
    set block(spacing: 8pt)
    if heading.numbering != none {
        text("Глава " + counter(heading).display(), size: 22pt)
    }
    set par(justify: false)
    line(length: 100%)
    rect(align(right + horizon, text(it.body, size: 22pt)), fill: white, width: 100%)
    line(length: 100%)
    v(1em)
}

#outline(title: [Садржај], depth: 2)

#set page(header: context {
     // Хедери са текућим секцијама не иду на страницу са поглављима
     if not (query(heading.where(level: 1)).any(h => h.location().page() == here().page())) {
        if calc.odd(here().page()) {
            align(right, emph(hydra(1)))
        } else {
            align(left, emph(hydra(2)))
        }
        line(length: 100%)
     }
})

#pagebreak(to: "odd", weak: false)
#set heading(numbering: "1.1")
#set page(numbering: "1")
#counter(page).update(1)


// TODO: Овде укључујете поглавља
#include "poglavlja/1-uvod.typ"
#include "poglavlja/2-teorija.typ"
#include "poglavlja/3-stanje.typ"
#include "poglavlja/4-evaluacija.typ"
#include "poglavlja/7-zakljucak.typ"



#outline(title: "Списак слика", target: figure.where(kind: image))
#outline(title: "Списак листинга", target: figure.where(kind: raw))
#outline(title: "Списак табела", target: figure.where(kind: table))


#set heading(numbering: none)
#show figure: it => {
    set text(size: 9pt)
    set block(breakable: true)
    set table(
        columns: (1fr, 4fr),
        align: left,
        inset: 8pt,
        stroke: 0pt)
    it
}

// TODO: Додаци - искоментарисати ако се не користе
#include "poglavlja/dodatak 1 - skracenice.typ"
#include "poglavlja/dodatak 2 - pojmovi.typ"

#include "biografija.typ"

#bibliography(title: [Литература], "literatura.bib")
