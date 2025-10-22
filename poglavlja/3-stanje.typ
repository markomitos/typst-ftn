= Имплементација подршке за _Keras_ 3

== Анализа имплементације проблема компатибилности

Архитектонска промена библиотеке _Keras_ из верзије 2 у верзију 3, описана у поглављу
Библиотека _Keras_, је разлог проблема компатибилности библиотеке унутар радног окружења TFF.
Функција tff.learning.from\_keras\_model, била је дизајнирана да очекује
и користи унутрашње API позиве специфичне за Keras 2 (нпр. за директно издвајање
_statefull_ променљивих оптимизатора). Пошто Keras 3 не подржава ове позиве,
директна интеграција је постала немогућа.

Анализа TFF кода показала је да би потпуна миграција целог радног окружења TFF-а на _Keras_ 3
архитектуру била претерано сложена и ризиковала би нарушавање функционалности постојећег,
верификованог кода који се ослања на библиотеку _Keras_ 2. Стога је донета одлука
да се имплементира паралелна подршка за обе верзије библиотеке _Keras_. Овај приступ
је захтевао да се TFF функције модификују тако да могу да рукују и са _Keras_ 2 и са _Keras_ 3
компонентама истовремено.

Паралерлна подршка за обе верзије библиотеке _Keras_ подразумева два примарна техничка
захтева који су формирали оквир рефакторисања:

- Подршка за унију типова: Функције у TFF-у морају бити у стању да прихвате објекте који су или _Keras_ 2 или _Keras_ 3 типови. Ово је решено имплементацијом уније типова за улазне параметре модела, метрика и функција грешке.

- Апстракција логике руковања моделом Креирање засебног механизма који би, на основу верзије _Keras_ објекта, вратио одговарајуће променљиве (нпр. из _stateful_ _Keras_ 2 или _stateless_ _Keras_ 3 API-ја). Ова потреба је директно довела до развоја посебне компоненте keras\_compat.

Рефакторисање се фокусирало на додавање логике компатибилности у кључне TFF
модуле (_models_, _optimizers_, _metrics_ и _algorithms_), омогућавајући рад са обе верзије библиотеке _Keras_,
чиме је изазов миграције претворен у изазов апстракције.

#pagebreak()

== Архитектура рефакторисања

Већина рефакторисаног кода се налази унутар сегмента радног окружења TFF који је
имплементиран у програмском језику _Python_ @python. Унутар _Python_ имплементације
се налази секција _learning_ у којој се налази код одговоран за алгоритме за федеративно учење,
као и модули _models_, _optimizers_, _metrics_, и _algorithms_ који рукују понашањем модела током обучавања @tff.

Модул _models_ представља најважнију тачку за интеграцију _Keras_ модела у TFF.
Његова примарна улога енкапсулација логике _Keras_ модела у TFF-ов интерфејс
tff.learning.Model. TFF интерфејс дефинише потребне атрибуте и методе које су кључне
за FL процес, укључујући: обучиве променљиве (_trainable variables_),
необучиве променљиве (_non-trainable variables_), променљиве стања модела
(_model state variables_), методу forward\_pass за прослеђивање података кроз модел
и методу report\_local\_unfinalized\_metrics за прикупљање локалних статистика @tff.

Модул _optimizers_ садржи логику неопходну за дефинисање и управљање оптимизаторима клијената
(_client optimizers_). У федеративном учењу, оптимизатори имају клијентску и серверску улогу.
На клијентској страни се користе за израчунавање локалних ажурирања модела на основу локалних
података. Њихово стање, које укључује променљиве попут импулса (_momentum_) или
адаптивних стопа учења (_adaptive learning rates_) мора бити укључено у стање сервера
(_server state_). Овај модул обезбеђује да TFF може исправно да серијелизује и десеријелизује
стање оптимизатора приликом дистрибуције и агрегације, омогућавајући континуирано учење
током FL рунди @tff. Промене у понашању _Keras_ 3 оптимизатора директно утичу на то како овај модул
приступа њиховим променљивим стањима.

Модул metrics је одговоран за израчунавање, прикупљање и агрегацију статистичких мера перформанси
модела, као што су тачност (_accuracy_) и губитак (_loss_) током процеса федеративног учења.
У радном окружењу TFF, метрике се деле на две фазе: нефинализоване метрике и финализоване метрике.
Клијенти израчунавају нефинализоване метрике (сирове вредности, као што су укупна сума губитака и
број обрађених примера) и враћају их серверу. Овај модул садржи логику за агрегацију
нефинализованих метрика преко свих клијената, као и логику за њихову финализацију
(нпр. израчунавање просечне вредности)  @tff. Прелазак _Keras_ 3 метрика на _stateless_ парадигму
је захтевао рефакторисање модула, како би се обезбедило исправно извлачење и враћање
нефинализованих тензора неопходних за централизовану агрегацију на серверу.

Модул _algorithms_ садржи имплементације самих алгоритама федеративног учења и
федеративне евалуације. Модул делује као координатор, користећи функционалности дефинисане
у модулима _models_, _optimizers_ и _metrics_ за креирање комплетног итеративног процеса
(_Iterative Process_). Итеративни процес је основна структура у TFF-у, која дефинише стање
сервера (_server state_) и следећи корак (_next step_) FL рунде. Модул _algorithms_ је одговоран
за имплементацију специфичних FL алгоритама, као што је федеративни просек (FedAvg). Због тога
је рефакторисање овог модула било неопходно како би се осигурало да алгоритми функционишу
са новим структурама података и функционалностима добијеним из рефакторисаних _models_, _optimizers_
и _metrics_ компоненти, обезбеђујући да је целокупни FL процес компатибилан са _Keras_ 3 моделима.

== Апстракција логике руковања моделом

Апстракција логике руковањем моделом је неопходна за несметано руковање
различитим верзијама библиотеке _Keras_. Будући да постоје измене у руковању
свостава модела између верзија библиотеке, потребно је увести компоненту која
ће на основу библиотеке прикладно руковати са имплементацијом модела. Креирана је
компонента keras_compat која садржи функције наведене у табели @tbl:keras_compat_funkcije.

#figure(
    table(
        columns: 2,
        align: (col, row) => (left, left).at(col),
        inset: 6pt,
        [#strong[Назив функције]], [#strong[Сврха функције]],

        [`is_compiled`], [Проверава да ли је модел претходно компајлиран.],
        [`keras_dtype_to_tf`], [Претвара Keras типове података у TensorFlow типове података.],
        [`is_keras3`], [Проверава да ли објекат потиче из имплементације библиотеке Keras 3.],
        [`get_optimizer_variables`], [Добавља променљиве асоциране са оптимизатором (_optimizer_).],
        [`ref`], [Враћа референцу на променљиву која може бити Keras или TensorFlow типа.],
        [`get_variable и get_variables`], [Добавља променљиве Keras или TensorFlow модела.],
        [`clone_model`], [Враћа копију прослеђеног модела.],
        [`int_shape`], [Враћа облик модела као тип _int_.]
    ),
    caption: [Функције компоненте keras\_compat за апстракцију руковања моделом]
)<tbl:keras_compat_funkcije>

===  Функција \_is_compiled

Функција \_is_compiled служи да провери да ли је прослеђени модел компајлиран,
што је неопходан предуслов за започињање процеса машинског учења. Због разлика у
интерним API позивима, функција мора експлицитно да разликује верзије, где се + за објекте
типа tf\_keras.Model (имплементација _Keras_ 2) провера врши преко приватног атрибута model.\_is\_compiled,
док се за објекте типа keras.Model (имплементација _Keras_ 3) користи директан атрибут
model.compiled. Уколико је модел различитог типа од _Keras_ типова модела, функција враћа грешку.
Функција осигурава да радно окружење TFF увек може да потврди спремност модела за рад, без обзира
 на верзију _Keras_ библиотеке. На листрингу @lst:_is_compiled приказан је код функције.

#figure(
    (
    ```python
    def is_compiled(model: Model):
        if isinstance(model, tf_keras.Model):
            return model._is_compiled
        elif isinstance(model, keras.Model):
            return model.compiled
        else:
            raise TypeError(
                'Expected an instance of a tf_keras.Model, or a '
                'keras.Model; found a model of type '
                f'{type(model)}'
            )
    ```
  ),
  caption: [Функција \_is_compiled из компоненте keras\_compat]
)<lst:_is_compiled>

=== Функција keras_dtype_to_tf

Функција keras_dtype_to_tf осигурава конзистентности типова података (_data types_)
у радном окружењу TFF. TFF је изграђен на библиотеци _TensorFlow_, која захтева специфичне
tf.dtype објекте. Пошто _Keras_ може да излаже типове података као једноставне _string_
репрезентације (нпр. "float32"), функција мапира string вредности у њихове одговарајуће
tf.dtype објекте. Поред стандардних типова, функција такође подржава и новије типове података
уведене у библиотеци _TensorFlow_, као што су float8_e4m3fn и float8_e5m2, осигуравајући
компатибилност са хардверски оптимизованим типовима. На листрингу @lst:keras_dtype_to_tf
приказан је код функције.

#figure(
    (
    ```python
def keras_dtype_to_tf(dtype_str):
    if not isinstance(dtype_str, str):
        return dtype_str
    return {
        "float16": tf.float16,
        "float32": tf.float32,
        "float64": tf.float64,
        "uint8": tf.uint8,
        "uint16": tf.uint16,
        "uint32": tf.uint32,
        "uint64": tf.uint64,
        "int8": tf.int8,
        "int16": tf.int16,
        "int32": tf.int32,
        "int64": tf.int64,
        "bfloat16": tf.bfloat16,
        "bool": tf.bool,
        "string": tf.string,
        "float8_e4m3fn": tf.dtypes.experimental.float8_e4m3fn,
        "float8_e5m2": tf.dtypes.experimental.float8_e5m2
    }.get(dtype_str, tf.float32)
    ```
  ),
  caption: [Функција keras_dtype_to_tf из компоненте keras\_compat]
)<lst:keras_dtype_to_tf>

=== Функција is_keras3

Функција is_keras3 утдрђује да ли прослеђени објекат (нпр. модел, променљива, метрика)
потиче из Keras 3 библиотеке. Провера се врши коришћењем isinstance методе уграђене
у програмски језик _Python_ над унијом различитих _Keras_ 3 класа као што су keras.Model,
keras.Variable, keras.Metric, keras.Layer. Провера омогућава осталим функцијама
компоненте да изаберу исправан API позив. На листрингу @lst:is_keras3 приказан је
код функције.

#figure(
    (
    ```python
    def is_keras3(obj: object):
        return isinstance(obj, (keras.Model, keras.Variable, keras.Metric, keras.Layer, keras.Loss, keras.Optimizer, keras_common.KerasVariable))
    ```
  ),
  caption: [Функција is_keras3 из компоненте keras\_compat]
)<lst:is_keras3>

=== Функција get_optimizer_variables

Функција get_optimizer_variables решава проблем некомпатибилности у приступу
променљивама оптимизатора између различитих верзија библиотеке _Keras_.
У верзији 2, где су оптимизатори често имплементирани као OptimizerV2 или сличне класе,
атрибут optimizer.variables је функција (_callable_), која се мора позвати ради добијања
листа променљивих. Насупрот томе, у верзији 3, optimizer.variables је директни атрибут.
Функција апстрахује разлику и ако је variables функција, она је позива, у супротном,
враћа атрибут директно, чиме се осигурава пренос стања оптимизатора током FL рунди.
Уколико прослеђени оптимизатор не припада ни једној од имплементација библиотеке _Keras_,
функција враћа грешку. На листрингу @lst:get_optimizer_variables приказан је код функције.

#figure(
    (
    ```python
    def get_optimizer_variables(optimizer: Union[tf_keras.optimizers.Optimizer, keras.optimizers.Optimizer, optimizer_v2.OptimizerV2]):
      if isinstance(optimizer, (tf_keras.optimizers.Optimizer, keras.optimizers.Optimizer, optimizer_v2.OptimizerV2)):
        if callable(optimizer.variables):
          return optimizer.variables()
        return optimizer.variables
      else:
        raise TypeError(
          'Expected an instance of a tf_keras.optimizers.Optimizer, or a '
          'keras.optimizers.Optimizer; found an optimizer of type '
          f'{type(optimizer)}'
        )
    ```
  ),
  caption: [Функција get_optimizer_variables из компоненте keras\_compat]
)<lst:get_optimizer_variables>

=== Функција ref

Функција ref служи за добијање јединствене референце (ID) за променљиву, што је важно
за интерно праћење стања у радном окружењу TFF. За tf.Variable (који се типично користи у
имплементацији _Keras_ 2), функција користи variable.ref() да би добила _TensorFlow_ референцу.
Међутим, за имлементацију _Keras_ 3 променљивих (keras.Variable или keras_common.KerasVariable),
које су апстрахованије, функција враћа Python ID објекта користећи id(variable).
Уколико прослеђена промењљива не припада и једној од имплементација библиотеке _Keras_,
функција враћа грешку. Овај механизам омогућава TFF-у да поуздано идентификује и
мапира променљиве без обзира на њихов основни тип. На листрингу @lst:ref приказан
је код функције.

#figure(
    (
    ```python
     def ref(variable: Union[tf.Variable, keras.Variable, keras_common.KerasVariable]):
       if isinstance(variable, tf.Variable):
         return variable.ref()
       elif isinstance(variable, (keras.Variable, keras_common.KerasVariable)):
         return id(variable)
       else:
         raise TypeError(f'Expected keras.Variable, keras.backend.common.KerasVariable or tf.Variable, but got {type(variable)}')
    ```
  ),
  caption: [Функција ref из компоненте keras\_compat]
)<lst:ref>

=== Функције get_variable и get_variables

Функције get_variable и get_variables служе за издвајање стварне вредности променљиве.
У _Keras_ 3, променљиве су представљене класама које имају атрибут variable.value,
који садржи сам тензор. Функција get_variable проверава да ли је у питању имплементација _Keras_ 3
променљиве и, уколико јесте, враћа њену вредност. У супротном, враћа саму променљиву
(што важи за tf.Variable у имплементацији _Keras_ 2). Функција get_variables је помоћна
функција која примењује get_variable на колекцију променљивих (листу или торку),
обезбеђујући да радно окружење TFF увек рукује само са сировим тензорским вредностима.
На листрингу @lst:get_variable приказан је код функције get_variable, док је на листингу
@lst:get_variables приказан код функције get_variables.

#figure(
    (
    ```python
    def get_variable(variable: Union[tf.Variable, keras.Variable, keras_common.KerasVariable]):
      if isinstance(variable, (keras.Variable, keras_common.KerasVariable)):
        return variable.value
      else:
        return variable
    ```
  ),
  caption: [Функција get_variable из компоненте keras\_compat]
)<lst:get_variable>

#figure(
    (
    ```python
    def get_variables(variables: Union[list, tuple]):
      return [get_variable(var) for var in variables]
    ```
  ),
  caption: [Функција get_variables из компоненте keras\_compat]
)<lst:get_variables>

=== Функције clone_model

Функција clone_model је одговорна за стварање копије модела са новим, неиницијализованим
тежинама, што је неопходно у FL окружењу (нпр. приликом иницијализације клијентских модела).
Будући да _Keras_ 3 и _Keras_ 2 имају засебне модуле за клонирање модела
(keras.models.clone_model и tf_keras.models.clone_model), функција користи функцију is_keras3
да одреди коју верзију функције за клонирање треба позвати, чиме се осигурава да радно окружење TFF
поуздано реплицира модел за сваког клијента, одржавајући исту архитектуру уз нове тежине.
На листрингу @lst:clone_model приказан је код функције get_variable.

#figure(
    (
    ```python
    def clone_model(model: Union[tf_keras.Model, keras.Model]):
      if is_keras3(model):
        return keras.models.clone_model(model)
      else:
        return tf_keras.models.clone_model(model)
    ```
  ),
  caption: [Функција clone_model из компоненте keras\_compat]
)<lst:clone_model>

=== Функција int_shape

Функција int_shape враћа облик (_shape_) прослеђеног тензора или променљиве као торку целих
бројева. Функција је стандардна помоћна функција која се користи у нижим
слојевима машинског учења за ефикасно руковање димензијама, обезбеђујући да се димензије,
које могу бити враћене као _TensorFlow_ објекти, увек буду претворене у стандардни имплементацију
торке (_tuple_) у програмском језику _Python_, чиме се поједностављује логика за проверу типова
унутар радног окружења TFF. На листрингу @lst:int_shape приказан је код функције get_variable.

#figure(
    (
    ```python
    def int_shape(x):
      try:
        shape = x.shape
        if not isinstance(shape, tuple):
          shape = tuple(shape.as_list())
        return shape
      except ValueError:
        return None
    ```
  ),
  caption: [Функција int_shape из компоненте keras\_compat]
)<lst:int_shape>