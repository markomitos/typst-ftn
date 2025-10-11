#let format_strane = "iso-b5"         // могуће вредности: iso-b5, a4
#let naslov = "Додавање подршке за библиотеку Keras 3 у радно окружење TensorFlow Federated"
#let autor = "Марко Митошевић"

// На енглеском
#let naslov_eng = "Adding support for the Keras 3 library to the TensorFlow Federated framework"
#let autor_eng = "Marko Mitosevic"

#let indeks = "SV56/2021"

// Име и презиме ментора
#let mentor = "Игор Дејановић"
// Звање: редовни професор, ванредни професор, доцент
#let mentor_zvanje = "редовни професор"

// Скинути коментаре са одговарајућих линија
#let studijski_program = "Софтверско инжењерство и информационе технологије"
//#let studijski_program = "Рачунарство и аутоматика"
//#let stepen = "Мастер академске студије"
#let stepen = "Основне академске студије"

#let godina = [#datetime.today().year()]

// FIXME: Аутоматизовати бројање цитата и прилога
// За сада унети ручно број референци из поглавља Литература.
#let broj_citata = 4
// Такође унети ручно и број прилога.
#let broj_priloga = 0

#let kljucne_reci = "Keras, TensorFlow Federated, IDE"
#let apstrakt = [
     Овај документ представља упутство за писање завршних радова на Факултету
     техничких наука Универзитета у Новом Саду. У исто време је и шаблон за Typst.
]

// На енглеском
#let kljucne_reci_eng = "Keras, TensorFlow Federated, IDE"
#let apstrakt_eng = [
     This document provides guidelines for writing final theses at the Faculty
     of Technical Sciences, University of Novi Sad. At the same time, it serves
     as a Typst template.
]

// TODO: Текст задатка добијате од ментора. Заменити доле #lorem(100) са текстом задатка.
#let zadatak = [
     #lorem(100)
]

// Одбрана
#let datum_odbrane = "01.01.2025"
// Комисија
#let komisija_predsednik = "Петар Петровић"
#let komisija_predsednik_zvanje = "ванредни професор"
#let komisija_clan = "Марко Марковић"
#let komisija_clan_zvanje = "доцент"

// На енглеском уписати чланове на латиници
#let komisija_predsednik_eng = "Petar Petrović"
#let komisija_clan_eng = "Marko Marković"
#let mentor_eng = "Igor Dejanović"


// Ово даље углавном не треба мењати.

#let zvanje_eng = (
     "редовни професор": "full professor",
     "ванредни професор": "assoc. professor",
     "доцент": "asist. professor",
)
#let komisija_predsednik_zvanje_eng = zvanje_eng.at(komisija_predsednik_zvanje)
#let komisija_clan_zvanje_eng = zvanje_eng.at(komisija_clan_zvanje)
#let mentor_zvanje_eng = zvanje_eng.at(mentor_zvanje)


#let vrsta_rada = if stepen == "Мастер академске студије" {
    "Дипломски - мастер рад"
} else {
    "Дипломски - бечелор рад"
}

#let oblast = "Електротехничко и рачунарско инжењерство"
#let oblast_eng = "Electrical and Computer Engineering"
#let disciplina = "Примењене рачунарске науке и информатика"
#let disciplina_eng = "Applied computer science and informatics"

#import "funkcije.typ": *
// Поглавља/страна/цитата/табела/слика/графика/прилога
#let fizicki_opis = physical(broj_citata, broj_priloga)
