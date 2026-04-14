#import "@preview/modern-g7-32:0.2.0": *
#import "@local/typst-bsuir-core:0.14.4": *
#import "@preview/zap:0.5.0"

#set text(font: "Times New Roman", size: 14pt)
#show math.equation: set text(font: "STIX Two Math", size: 14pt)

#show: gost.with(
  title-template: custom-title-template.from-module(toec-typical-template),
  department: "Кафедра теоретических основ электротехники",
  work: (
    type: "",
    number: "",
    subject: "Расчет сложной цепи постоянного тока",
    variant: "558301-14",
  ),
  manager: (
    name: "Батюков С.В.",
  ),
  performer: (
    name: "Ермаков В. С.",
    group: "558301",
  ),
  footer: (city: "Минск", year: 2026),
  city: none,
  year: none,
  add-pagebreaks: false,
  text-size: 14pt,
)

#show: apply-toec-styling

// ИСХОДНЫЕ ДАННЫЕ ВАРИАНТА №14
#let V = (
  R1: 230, R2: 470, R3: 160, R4: 570, R5: 310, R6: 190, R7: 550,
  E2: 500, E4: 500,
  J4: 3, J7: 9,
  VARIANT: 14,
)

= Начертить схему согласно заданному варианту

Исходные данные варианта #V.VARIANT представлены в таблице @src-table, схема электрической цепи представлена на рисунке @src-circuit.

#figure(
  caption: [Исходные данные варианта #V.VARIANT],
  table(
    columns: (auto, auto, auto, auto, auto),
    align: center + horizon,
    table.header(
      table.cell(rowspan: 2)[Номер\ ветви],
      table.cell(rowspan: 2)[Начало-Конец],
      table.cell(rowspan: 2)[Сопротивления,\ Ом],
      table.cell(colspan: 2)[Источники],
      [ЭДС, В], [Тока, А]
    ),
    [1], [3–1], [#V.R1], [0], [0],
    [2], [1–2], [#V.R2], [#V.E2], [0],
    [3], [2–6], [#V.R3], [0], [0],
    [4], [6–4], [#V.R4], [#V.E4], [#V.J4],
    [5], [4–5], [#V.R5], [0], [0],
    [6], [5–3], [#V.R6], [0], [0],
    [7], [1–4], [#V.R7], [0], [#V.J7],
  )
) <src-table>

#lab-figure(
  caption: [Исходная схема электрической цепи],
  above: -1em,
  circuit-better(scale-factor: 80%, {
    import zap: *

    // УЗЛЫ
    node-better("3", (0, 8), label: (content: "3", anchor: "top"), visible: true)
    node-better("1", (8, 8), label: (content: "1", anchor: "top"), visible: true)
    node-better("2", (16, 8), label: (content: "2", anchor: "top"), visible: true)
    node-better("6", (16, 0), label: (content: "6", anchor: "right"), visible: true)
    node-better("4", (8, 0), label: (content: "4", anchor: "bottom-left"), visible: true)
    node-better("5", (0, 0), label: (content: "5", anchor: "bottom"), visible: true)

    // ВЕТВЬ 1 (3 -> 1)
    resistor-better("R1", "3", "1", label: (content: $R_1$, anchor: "top"), arrow-label: $I_1$, arrow-side: "bottom", arrow-dir: "forward")

    // ВЕТВЬ 2 (1 -> 2)
    node-better("n12", (12, 8), visible: false)
    source-better("E2", "1", "n12", arrow-dir: "forward", label: (content: $E_2$, anchor: "top"))
    resistor-better("R2", "n12", "2", label: (content: $R_2$, anchor: "top"), arrow-label: $I_2$, arrow-side: "bottom", arrow-dir: "forward")

    // ВЕТВЬ 3 (2 -> 6)
    resistor-better("R3", "2", "6", label: (content: $R_3$, anchor: "right"), arrow-label: $I_3$, arrow-side: "left", arrow-dir: "forward")

    // ВЕТВЬ 4 (6 -> 4)
    node-better("n64", (12, 0), visible: false)
    source-better("E4", "6", "n64", arrow-dir: "forward", label: (content: $E_4$, anchor: "top"))
    resistor-better("R4", "n64", "4", label: (content: $R_4$, anchor: "bottom"), arrow-label: $I_4$, arrow-side: "top", arrow-dir: "forward")

    // J4 параллельно ветви 6-4
    wire("6", (14, -2.5))
    // Используем стандартный source, если jsource нет, либо ваш кастомный
    jsource-better("J4", (14, -2.5), (10, -2.5), arrow-dir: "forward", label: (content: $J_4$, anchor: "bottom"))
    wire((10, -2.5), "4")

    // ВЕТВЬ 5 (4 -> 5)
    resistor-better("R5", "4", "5", label: (content: $R_5$, anchor: "top"), arrow-label: $I_5$, arrow-side: "bottom", arrow-dir: "forward")

    // ВЕТВЬ 6 (5 -> 3)
    resistor-better("R6", "5", "3", label: (content: $R_6$, anchor: "right"), arrow-label: $I_6$, arrow-side: "left", arrow-dir: "forward")

    // ВЕТВЬ 7 (1 -> 4)
    resistor-better("R7", "1", "4", label: (content: $R_7$, anchor: "left"), arrow-label: $I_7$, arrow-side: "right", arrow-dir: "forward")

    // J7 параллельно ветви 1-4
    wire("1", (6, 6))
    jsource-better("J7", (6, 6), (6, 2), arrow-dir: "forward", label: (content: $J_7$, anchor: "left"))
    wire((6, 2), "4")
  })
) <src-circuit>

Расчет схемы заключается в определении токов во всех ветвях схемы, определении напряжения между узлами, указанными в задании, и составлении баланса мощностей в цепи.

= Преобразование схемы в двухконтурную

Преобразуем источники тока $J_4$ и $J_7$ в эквивалентные источники ЭДС $E_04$ и $E_07$. Направления эквивалентных ЭДС совпадают с направлениями исходных источников тока:

#let E4_prime = V.J4 * V.R4
#let E7_prime = V.J7 * V.R7

#mathtype-mimic[
  $ E_04 &= J_4 R_4 = #V.J4 dot #V.R4 = #E4_prime " В"; $
  $ E_07 &= J_7 R_7 = #V.J7 dot #V.R7 = #E7_prime " В". $
]

Определяем суммарную ЭДС ветви 4:

#let E4_sum = V.E4 + E4_prime

#mathtype-mimic[
  $ E_404 = E_4 + E_04 = #V.E4 + #E4_prime = #E4_sum " В". $
]

Объединяем сопротивления $R_1, R_6, R_5$ в $R_156$ и $R_2, R_3, R_4$ в $R_234$:

#let R_156 = V.R1 + V.R6 + V.R5
#let R_234 = V.R2 + V.R3 + V.R4
#let E_2404 = V.E2 + E4_sum

#mathtype-mimic[
  $ R_156 &= R_1 + R_6 + R_5 = #V.R1 + #V.R6 + #V.R5 = #R_156 " Ом"; $
  $ R_234 &= R_2 + R_3 + R_4 = #V.R2 + #V.R3 + #V.R4 = #R_234 " Ом". $
]

В результате этих преобразований схема будет иметь следующий вид (рис. @two-loop-circuit):

#lab-figure(
  above: -2em,
  circuit-better(scale-factor: 85%, {
    import zap: *

    node-better("1", (8, 7), label: (content: "1", anchor: "top"), visible: true)
    node-better("4", (8, 0), label: (content: "4", anchor: "top-left"), visible: true)

    // ЛЕВАЯ ВЕТВЬ (без ЭДС)
    wire("1", (2, 7))
    resistor-better("R_156", (2, 7), (2, 0), label: (content: $R_156$, anchor: "left"), arrow-label: $I_156$, arrow-side: "right", arrow-dir: "backward")
    wire((2, 0), "4")

    // ЦЕНТРАЛЬНАЯ ВЕТВЬ
    node-better("nc", (8, 3), visible: false)
    source-better("E7_prime", "1", "nc", arrow-dir: "forward", label: (content: $E_07$, anchor: "left"))
    resistor-better("R7", "nc", "4", position: 30%, label: (content: $R_7$, anchor: "left"), arrow-label: $I_7$, arrow-side: "right", arrow-dir: "forward")

    // ПРАВАЯ ВЕТВЬ
    wire("1", (14, 7))
    node-better("nr", (14, 0), visible: false)
    source-better("E_2", (11, 7), (), arrow-dir: "forward", label: (content: $E_2$, anchor: "top"))
    resistor-better("R_234", (14, 7), "nr", label: (content: $R_234$, anchor: "right"), arrow-label: $I_234$, arrow-side: "left", arrow-dir: "forward")
    source-better("E_404", "nr", (8, 0), arrow-dir: "forward", label: (content: $E_404$, anchor: "top"))
    wire((14, 0), "4")

    ground-better("4", length: 0.8)
  })
) <two-loop-circuit>

Объединяем $E_2$ и $E_404$ в эквивалентную ЭДС $E_2404$.

#mathtype-mimic(receive: true)[
  $ E_2404 &= E_2 + E_404 = #V.E2 + #E4_sum = #E_2404 " В". $
]

= Расчет двухконтурной схемы

Далее целесообразно использовать метод двух узлов. Составляем уравнение для нахождения узлового напряжения $U_14$:

#let U_14 = (-E7_prime / V.R7 - E_2404 / R_234) / (1 / R_156 + 1 / V.R7 + 1 / R_234)

//todo fix
#mathtype-mimic[
  $ U_14 = (-E_07/R_7 - E_2404/R_234) / (1/R_156 + 1/R_7 + 1/R_234) = (-#E7_prime/#V.R7 - #E_2404/#R_234) / (1/#R_156 + 1/#V.R7 + 1/#R_234) = #U_14 " В". $
]

Примем потенциал четвертого узла равным нулю. Определяем токи в ветвях эквивалентной схемы по обобщенному закону Ома.

#let I_156 = (0 - U_14) / R_156
#let I_77 = (U_14 + E7_prime) / V.R7
#let I_234 = (U_14 + E_2404) / R_234

#mathtype-mimic(receive: true)[
  $ I_156 &= -U_14 / R_156 = -(#U_14) / #R_156 = #I_156 " А"; $
  $ I_"77" &= (U_14 + E_07) / R_7 = (#U_14 + #E7_prime) / #V.R7 = #I_77 " А"; $
  $ I_234 &= (U_14 + E_2404) / R_234 = (#U_14 + #E_2404) / #R_234 = #I_234 " А". $
]

= Разворачивая схему в обратном порядке, находим токи в исходной схеме

Для ветвей 1, 5, 6 токи равны эквивалентному току $I_156$:

#mathtype-mimic[
  $ I_1 = I_5 = I_6 = I_156 = #I_156 " А". $
]

Токи в ветвях 2 и 3 равны эквивалентному току $I_234$:

#mathtype-mimic[
  $ I_2 = I_3 = I_234 = #I_234 " А". $
]

Определяем неизвестные токи ветвей с источниками тока ($I_4$ и $I_7$) изобразим схему с указанием групповых и полных токов (рис. @unrolled-circuit).

#lab-figure(
  above: -1em,
  gap: -1em,
  circuit-better(scale-factor: 80%, {
    import zap: *

    node-better("3", (0, 8), label: (content: "3", anchor: "top"), visible: true)
    node-better("1", (8, 8), label: (content: "1", anchor: "top"), visible: true)
    node-better("2", (16, 8), label: (content: "2", anchor: "top"), visible: true)
    node-better("6", (16, 0), label: (content: "6", anchor: "right"), visible: true)
    node-better("4", (8, 0), label: (content: "4", anchor: "bottom-left"), visible: true)
    node-better("5", (0, 0), label: (content: "5", anchor: "bottom"), visible: true)

    // Группа левой ветви (I_156)
    resistor-better("R1", "3", "1", label: (content: $R_1$, anchor: "top"), arrow-label: $I_156$, arrow-side: "bottom", arrow-dir: "forward")
    resistor-better("R5", "4", "5", label: (content: $R_5$, anchor: "top"), arrow-label: $I_156$, arrow-side: "bottom", arrow-dir: "forward")
    resistor-better("R6", "5", "3", label: (content: $R_6$, anchor: "right"), arrow-label: $I_156$, arrow-side: "left", arrow-dir: "forward")

    // Группа правой ветви (I_234)
    node-better("n12", (12, 8), visible: false)
    source-better("E2", "1", "n12", arrow-dir: "forward", label: (content: $E_2$, anchor: "top"))
    resistor-better("R2", "n12", "2", label: (content: $R_2$, anchor: "top"), arrow-label: $I_234$, arrow-side: "bottom", arrow-dir: "forward")
    resistor-better("R3", "2", "6", label: (content: $R_3$, anchor: "right"), arrow-label: $I_234$, arrow-side: "left", arrow-dir: "forward")

    // Ветвь 4 (ищем I_4)
    node-better("n64", (12, 0), visible: false)
    source-better("E4", "6", "n64", arrow-dir: "forward", label: (content: $E_4$, anchor: "top"))
    resistor-better("R4", "n64", "4", label: (content: $R_4$, anchor: "bottom"), arrow-label: $I_4$, arrow-side: "top", arrow-dir: "forward")

    wire("6", (14, -2.5))
    jsource-better("J4", (14, -2.5), (10, -2.5), arrow-dir: "forward", label: (content: $J_4$, anchor: "bottom"))
    wire((10, -2.5), "4")

    // Ветвь 7 (ищем I_7)
    resistor-better("R7", "1", "4", label: (content: $R_7$, anchor: "left"), arrow-label: $I_7$, arrow-side: "right", arrow-dir: "forward")

    wire("1", (6, 6))
    jsource-better("J7", (6, 6), (6, 2), arrow-dir: "forward", label: (content: $J_7$, anchor: "left"))
    wire((6, 2), "4")
  })
) <unrolled-circuit>

Составляем уравнение по первому закону Кирхгофа для шестого узла:

#mathtype-mimic[
  $ I_234 = I_4 + J_4. $
]

#let I_4 = I_234 - V.J4

#mathtype-mimic(receive: true)[
  $ I_4 = I_234 - J_4 = #I_234 - #V.J4 = #I_4 " А". $
]

Определяем ток в седьмой ветви:

#mathtype-mimic[
  $ I_77 = I_7 + J_7. $
]

#let I_7 = I_77 - V.J7

#mathtype-mimic(receive: true)[
  $ I_7 = I_77 - J_7 = #I_77 - #V.J7 = #I_7 " А". $
]

= Нахождение напряжения между узлами 3 и 6

Определяем потенциал третьего узла, обойдя контур от четвертого к третьему узлу через пятый:

#let U_34 = 0 - I_156 * V.R5 - I_156 * V.R6

#mathtype-mimic[
  $ U_34 = - I_156 R_5 - I_156 R_6 = - #I_156 dot #V.R5 - (#I_156) dot #V.R6 = #U_34 " В". $
]

Определяем потенциал шестого узла, составив уравнение по второму закону Кирхгофа для ветви между шестым и четвертым узлами:

#mathtype-mimic[
  $ U_64 + E_4 = I_4 R_4. $
]

#let U_64 = 0 + I_4 * V.R4 - V.E4

#mathtype-mimic(receive: true)[
  $ U_64 = I_4 R_4 - E_4 = #I_4 dot #V.R4 - #V.E4 = #U_64 " В". $
]

Определяем искомое напряжение:

#let U_36 = U_34 - U_64

#mathtype-mimic[
  $ U_36 = U_34 - U_64 = #U_34 - (#U_64) = #U_36 " В". $
]

= Составление баланса мощностей

// Для удобства вычислений явно зададим переменные полных токов,
// которые в предыдущих пунктах были равны групповым
#let I_1 = I_156
#let I_2 = I_234
#let I_3 = I_234
#let I_5 = I_156
#let I_6 = I_156

Определяем суммарную мощность, отдаваемую источниками энергии:

#let P_E2 = V.E2 * I_2
#let P_E4 = V.E4 * I_4
#let U_46 = -U_64
#let U_41 = -U_14
#let P_J4 = U_46 * V.J4
#let P_J7 = U_41 * V.J7

#let P_src = P_E2 + P_E4 + P_J4 + P_J7

#mathtype-mimic[
  $ P_"ист" &= E_2 I_2 + E_4 I_4 + U_46 J_4 + U_41 J_7 = $
  $ &= E_2 I_2 + E_4 I_4 - U_64 J_4 - U_14 J_7 = $
  $ &= #V.E2 dot (#I_2) + #V.E4 dot (#I_4) - (#U_64) dot #V.J4 - (#U_14) dot #V.J7 = $
  $ &= #P_src " Вт". $
]

Определяем суммарную мощность, потребляемую активными сопротивлениями:

#let P_R1 = I_1*I_1 * V.R1
#let P_R2 = I_2*I_2 * V.R2
#let P_R3 = I_3*I_3 * V.R3
#let P_R4 = I_4*I_4 * V.R4
#let P_R5 = I_5*I_5 * V.R5
#let P_R6 = I_6*I_6 * V.R6
#let P_R7 = I_7*I_7 * V.R7

#let P_rec = P_R1 + P_R2 + P_R3 + P_R4 + P_R5 + P_R6 + P_R7

#mathtype-mimic[
  $ P_"пр" &= I_1^2 R_1 + I_2^2 R_2 + I_3^2 R_3 + I_4^2 R_4 + I_5^2 R_5 + I_6^2 R_6 + I_7^2 R_7 = $
  $ &= (#I_1)^2 dot #V.R1 + (#I_2)^2 dot #V.R2 + (#I_3)^2 dot #V.R3 + (#I_4)^2 dot #V.R4 + $
  $ &+ (#I_5)^2 dot #V.R5 + (#I_6)^2 dot #V.R6 + (#I_7)^2 dot #V.R7 = $
  $ &= #P_rec " Вт". $
]

Проверяем баланс мощностей:

#mathtype-mimic[
  $ P_"ист" &= P_"пр" = #P_rec. $
]


= Определение токов в ветвях исходной схемы методом законов Кирхгофа

Задаём численные значения параметров цепи в матричном виде:

#figure(image("mathcad_7.png", width: 80%), numbering: none)

Где x – неизвестные токи в сопротивлениях ветвей, которые находятся путём умножения обратной матрицы A1 на матрицу B1.

$"x"^"T"$ – численные значения токов в виде вектора строки, которые выводятся путём транспонирования.


= Определение токов в ветвях исходной схемы методом контурных токов

#figure(image("mathcad_8.png", width: 80%), numbering: none)

Где $R$ – вектор-столбец сопротивлений цепи;

$R D = op("diag")(R)$ – формирование диагональной матрицы $R D$ из матрицы $R$;

$J$ – вектор-столбец источников тока цепи;

$E$ – вектор-столбец источников ЭДС цепи;

$B$ – контурная матрица.


= Определение токов в ветвях исходной схемы методом узловых напряжений

#figure(image("mathcad_9.png", width: 80%), numbering: none)

Где $A$ – узловая матрица;

$G$ – диагональная матрица проводимостей ветвей;

$F$ – вектор-столбец узловых напряжений по отношению к базисному узлу;

$U$ – вектор-столбец напряжений на всех ветвях цепи.


= Определение тока в ветви с сопротивлением методом эквивалентного генератора напряжения

Определяем напряжение эквивалентного генератора (напряжение холостого хода). Для этого исключаем активную ветвь с сопротивлением $R_4$ и источником ЭДС $E_4$ из исходной схемы. Схема представлена на рисунке @meg-xx-circuit.

#lab-figure(
  above: -1em,
  gap: -1em,
  circuit-better(scale-factor: 80%, {
    import zap: *

    // УЗЛЫ
    node-better("3", (0, 8), label: (content: "3", anchor: "top"), visible: true)
    node-better("1", (8, 8), label: (content: "1", anchor: "top"), visible: true)
    node-better("2", (16, 8), label: (content: "2", anchor: "top"), visible: true)
    node-better("6", (16, 0), label: (content: "6", anchor: "right"), visible: true)
    node-better("4", (8, 0), label: (content: "4", anchor: "bottom-left"), visible: true)
    node-better("5", (0, 0), label: (content: "5", anchor: "bottom"), visible: true)

    // ВЕТВЬ 1
    resistor-better("R1", "3", "1", label: (content: $R_1$, anchor: "top"), arrow-label: $I_1$, arrow-side: "bottom", arrow-dir: "forward")

    // ВЕТВЬ 2
    node-better("n12", (12, 8), visible: false)
    source-better("E2", "1", "n12", arrow-dir: "forward", label: (content: $E_2$, anchor: "top"))
    resistor-better("R2", "n12", "2", label: (content: $R_2$, anchor: "top"), arrow-label: $I_2$, arrow-side: "bottom", arrow-dir: "forward")

    // ВЕТВЬ 3
    resistor-better("R3", "2", "6", label: (content: $R_3$, anchor: "right"), arrow-label: $I_3$, arrow-side: "left", arrow-dir: "forward")

    // ВЕТВЬ 4 (Исключена, используем наш новый компонент для явного разрыва и Uxx)
    open-branch-better("XX2", "6", "4", label: $U_(x x)$, arrow-side: "top", arrow-dir: "forward", show-terminals: true)

    wire("6", (14, -2.5))
    jsource-better("J4", (14, -2.5), (10, -2.5), arrow-dir: "forward", label: (content: $J_4$, anchor: "bottom"))
    wire((10, -2.5), "4")

    // ВЕТВЬ 5
    resistor-better("R5", "4", "5", label: (content: $R_5$, anchor: "top"), arrow-label: $I_5$, arrow-side: "bottom", arrow-dir: "forward")

    // ВЕТВЬ 6
    resistor-better("R6", "5", "3", label: (content: $R_6$, anchor: "right"), arrow-label: $I_6$, arrow-side: "left", arrow-dir: "forward")

    // ВЕТВЬ 7
    resistor-better("R7", "1", "4", label: (content: $R_7$, anchor: "left"), arrow-label: $I_7$, arrow-side: "right", arrow-dir: "forward")

    wire("1", (6, 6))
    jsource-better("J7", (6, 6), (6, 2), arrow-dir: "forward", label: (content: $J_7$, anchor: "left"))
    wire((6, 2), "4")
  })
) <meg-xx-circuit>

Для нахождения эквивалентного (внутреннего) сопротивления генератора заменяем идеальные источники ЭДС короткозамкнутыми участками, а ветви с источниками тока разрываем. Схема для определения эквивалентного сопротивления представлена на рисунке @meg-rgen-circuit.

#lab-figure(
  above: -1em,
  gap: -1em,
  circuit-better(scale-factor: 80%, {
    import zap: *

    // УЗЛЫ
    node-better("3", (0, 8), label: (content: "3", anchor: "top"), visible: true)
    node-better("1", (8, 8), label: (content: "1", anchor: "top"), visible: true)
    node-better("2", (16, 8), label: (content: "2", anchor: "top"), visible: true)
    node-better("6", (16, 0), label: (content: "6", anchor: "right"), visible: true)
    node-better("4", (8, 0), label: (content: "4", anchor: "bottom-left"), visible: true)
    node-better("5", (0, 0), label: (content: "5", anchor: "bottom"), visible: true)

    // ВЕТВЬ 1
    resistor-better("R1", "3", "1", label: (content: $R_1$, anchor: "top"))

    // ВЕТВЬ 2 (E2 закорочен, остался только R2)
    resistor-better("R2", "1", "2", label: (content: $R_2$, anchor: "top"))

    // ВЕТВЬ 3
    resistor-better("R3", "2", "6", label: (content: $R_3$, anchor: "right"))

    // Разрыв на месте ветви 4
    open-branch-better("Rgen", "6", "4", label: (content: $R_"ген"$, anchor: "top"), arrow-side: "top", arrow-dir: "forward")

    // ВЕТВЬ 5
    resistor-better("R5", "4", "5", label: (content: $R_5$, anchor: "top"))

    // ВЕТВЬ 6
    resistor-better("R6", "5", "3", label: (content: $R_6$, anchor: "right"))

    // ВЕТВЬ 7 (J7 разорван, остался только R7)
    resistor-better("R7", "1", "4", label: (content: $R_7$, anchor: "left"))
  })
) <meg-rgen-circuit>