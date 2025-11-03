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

#let kljucne_reci = "Keras, TensorFlow Federated, IDE"
#let apstrakt = [
Примарна мотивација овог рада је унапређење алата за претрагу _Search Everywhere_
(SE) у  интегрисаним развојном окружењу (IDE) _IntelliJ_, помоћу модела машинског учења.
Због захтева за приватношћу података корисника, потребна је примена федеративног учења (FL).
Међутим, водеће FL окружење, TensorFlow Federated (TFF) има недостатак подршке
за библиотеку _Keras_ 3. Овај рад се бави анализом, дизајном и имплементацијом решења за
додавање подршке за библиотеку _Keras_ 3 у TFF. Циљ је постигнут имплементацијом паралелне подршке, чиме је очувана пуна компатибилност
са постојећом _Keras_ 2 архитектуром.
]

// На енглеском
#let kljucne_reci_eng = "Keras, TensorFlow Federated, IDE"
#let apstrakt_eng = [
The primary motivation for this paper is the improvement of the Search Everywhere (SE)
tool within the IntelliJ Integrated Development Environment (IDE) using machine learning
models. Due to user data privacy requirements, the application of Federated Learning (FL)
is necessary. However, the leading FL framework, TensorFlow Federated (TFF), lacks support
for the Keras 3 library. This paper addresses the analysis, design, and implementation of a
solution for adding Keras 3 library support to TFF. The objective was achieved by implementing
parallel support, thereby preserving full compatibility with the existing Keras 2 architecture.
]

// TODO: Текст задатка добијате од ментора. Заменити доле #lorem(100) са текстом задатка.
#let zadatak = [
    Анализирати постојећу архитектуру TensorFlow Federated оквира и његову зависност
    од Keras 2 са акцентом на потребно рефакторисање у циљу пружање подршке за
    Keras 3. Имплементирати рефакторисање и адаптацију тако да се обезбеди подршка
    за Keras 3. Проширити скуп тестова тако да буду покривени и случајеви коришћења
    Keras 3 библиотеке.

    При изради користити препоручену праксу из области софтверског инжењерства.
    Детаљно документовати решење.
]

// TODO: Датум одбране и чланове комисије добијате од ментора
#let datum_odbrane = "06.11.2025"
#let komisija_predsednik = "Марко Марковић"
#let komisija_predsednik_zvanje = "ванредни професор"
#let komisija_clan = "Синиша Николић"
#let komisija_clan_zvanje = "доцент"

// На енглеском уписати чланове на латиници
#let komisija_predsednik_eng = "Marko Marković"
#let komisija_clan_eng = "Siniša Nikolić"
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
#let fizicki_opis = physical()
