#import "@preview/modern-g7-32:0.2.0": *
#import "@local/typst-bsuir-core:0.15.3": *
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

Задаем численные значения параметров цепи в матричном виде:

#figure(image("mathcad_7.png", width: 80%), numbering: none)

Где x – неизвестные токи в сопротивлениях ветвей, которые находятся путем умножения обратной матрицы A1 на матрицу B1.

$"x"^"T"$ – численные значения токов в виде вектора строки, которые выводятся путем транспонирования.


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

Определяем напряжение эквивалентного генератора. Для этого исключаем активную ветвь с сопротивлением $R_4$ и источником ЭДС $E_4$ из исходной схемы. Схема представлена на рисунке @meg-xx-circuit.

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

Для нахождения эквивалентного сопротивления генератора заменяем идеальные источники ЭДС короткозамкнутыми участками, а ветви с источниками тока разрываем. Схема для определения эквивалентного сопротивления представлена на рисунке @meg-rgen-circuit.

#lab-figure(
  above: -3em,
  gap: -2em,
  circuit-better(scale-factor: 70%, {
    import zap: *

    // УЗЛЫ
    node-better("3", (0, 8), label: (content: "3", anchor: "top"), visible: true)
    node-better("1", (8, 8), label: (content: "1", anchor: "top"), visible: true)
    node-better("2", (16, 8), label: (content: "2", anchor: "top"), visible: true)
    node-better("6", (16, 0), label: (content: "6", anchor: "right"), visible: true)
    node-better("4", (8, 0), label: (content: "4", anchor: "bottom"), visible: true)
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

// Для наглядности рисуем упрощенную схему. Свернули 1-3-5-4 в R_156, а 1-2-6 в R_23.
Для упрощения расчета преобразовываем последовательно соединенные сопротивления ветвей (рисунок @meg-rgen-simplified).
//Сопротивления $R_2$ и $R_3$ соединены последовательно, сопротивления $R_1$, $R_6$, $R_5$ также соединены последовательно. Ветвь с сопротивлением $R_7$ подключена параллельно эквивалентному сопротивлению $R_156$.

#let R_156 = V.R1 + V.R6 + V.R5
#let R_23 = V.R2 + V.R3
#let R_1567 = (V.R7 * R_156) / (V.R7 + R_156)
#let R_gen = R_23 + R_1567

#lab-figure(
//   caption: [Упрощенная схема для расчета $R_"ген"$],
  above: -3em,
  gap: -2em,
  circuit-better(scale-factor: 70%, {
    import zap: *

    // Сохраняем исходные координаты узлов для визуальной преемственности
    node-better("1", (8, 8), label: (content: "1", anchor: "top"), visible: true)
    node-better("4", (8, 0), label: (content: "4", anchor: "bottom"), visible: true)
    node-better("6", (16, 0), label: (content: "6", anchor: "bottom-right"), visible: true)

    // Эквивалентное сопротивление левой части схемы (R1, R6, R5)
    // Прокладываем путь там, где раньше были узлы 3 и 5
    wire("1", (0, 8))
    resistor-better("R_156", (0, 8), (0, 0), label: (content: $R_156$, anchor: "left"))
    wire((0, 0), "4")

    // Центральная ветвь
    resistor-better("R_7", "1", "4", label: (content: $R_7$, anchor: "right"))

    // Эквивалентное сопротивление правой части схемы (R2, R3)
    // Прокладываем путь там, где раньше был узел 2
    wire("1", (16, 8))
    resistor-better("R_23", (16, 8), "6", label: (content: $R_23$, anchor: "right"))

    // Разрыв для определения эквивалентного сопротивления
    open-branch-better("Rgen", "6", "4", label: (content: $R_"ген"$, anchor: "top"), arrow-side: "top", arrow-dir: "forward")
  })
) <meg-rgen-simplified>

Определяем эквивалентное сопротивление генератора $R_"ген"$.

#mathtype-mimic(receive: true)[
  $ R_156 = R_1 + R_6 + R_5 = #V.R1 + #V.R6 + #V.R5 = #R_156 " Ом"; $
  $ R_23 = R_2 + R_3 = #V.R2 + #V.R3 = #R_23 " Ом"; $
  $ R_1567 = (R_7 R_156) / (R_7 + R_156) = (#V.R7 dot #R_156) / (#V.R7 + #R_156) = #R_1567 " Ом"; $
  $ R_"ген" = R_23 + R_1567 = #R_23 + #R_1567 = #R_gen " Ом". $
]

Рассчитываем напряжение по законам Кирхгофа холостого хода $U_(x x)$ на зажимах ветви 6–4 (рис.~@meg-xx-circuit).

// Для простоты расчета применяем законы Кирхгофа к упрощенной схеме.
// Так как ветвь 6-4 разорвана, ток от узла 1 к узлу 6 замыкается только через источник тока J4.
#let I_23 = V.J4

#mathtype-mimic[
  $ I_23 = J_4 = #I_23 " А". $
]

// 1-е уравнение: по первому закону Кирхгофа для узла 1.
// 2-е уравнение: по второму закону Кирхгофа для контура из параллельных ветвей R_156 и R_7.
#mathtype-mimic[
  $
  cases(
    I_156 + I_7 + I_23 + J_7 = 0,
    I_156 R_156 - I_7 R_7 = 0
  )
  $
]

#block(breakable: false)[
Подставляем численные значения:
#mathtype-mimic[
  $
  cases(
    I_156 + I_7 + #I_23 + #V.J7 = 0,
    I_156 dot #R_156 - I_7 dot #V.R7 = 0
  )
  $
]
]

// ВНИМАНИЕ: Здесь подставлены точные расчетные значения для вашей схемы.
#let I_7_xx = -6.84375
#let I_156_xx = -5.15625

#mathtype-mimic(receive: true)[
  $ I_7 = #I_7_xx " А"; $
  $I_156 = #I_156_xx " А". $
]

Определяем напряжение между узлами 1 и 4:
#let U_14_xx = I_7_xx * V.R7

#mathtype-mimic[
  $ U_14 = I_7 R_7 = #I_7_xx dot #V.R7 = #U_14_xx " В". $
]

Определяем $U_(x x)$ по второму закону Кирхгофа для контура 4–1–6–4:
#let U_xx = U_14_xx + V.E2 - I_23 * R_23

#mathtype-mimic[
  $ U_14 + E_2 - I_23 R_23 - U_(x x) = 0. $
]

#mathtype-mimic(receive: true)[
  $ U_64 = U_(x x) = U_14 + E_2 - I_23 R_23 = (#U_14_xx) + #V.E2 - #I_23 dot #R_23 = #U_xx " В". $
]

Определяем ток в заданной ветви по теореме об эквивалентном генераторе:

#let I_4_meg = (U_xx + V.E4) / (R_gen + V.R4)

#mathtype-mimic[
  $ I_4 = (U_(x x) + E_4) / (R_"ген" + R_4) = (#U_xx + #V.E4) / (#R_gen + #V.R4) = #I_4_meg " А". $
]

= Построение потенциальной диаграммы

Для построения потенциальной диаграммы выбираем замкнутый контур a–b–c–d–e–f–a. Задаем потенциал точки a равным нулю.

#lab-figure(
  above: -2em,
  gap: -1em,
  circuit-better(scale-factor: 80%, {
    import zap: *

    // УЗЛЫ
    node-better("3", (0, 8), label: (content: "", anchor: "top"), visible: true)
    node-better("1", (8, 8), label: (content: "b", anchor: "top"), visible: true)
    node-better("2", (16, 8), label: (content: "d", anchor: "top"), visible: true)
    node-better("6", (16, 0), label: (content: "e", anchor: "right"), visible: true)
    node-better("4", (8, 0), label: (content: "a", anchor: "bottom-left", distance: 0.5), visible: true)
    node-better("5", (0, 0), label: (content: "", anchor: "bottom"), visible: true)

    // ВЕТВЬ 1 (3 -> 1)
    resistor-better("R1", "3", "1", label: (content: $R_1$, anchor: "top"), arrow-label: $I_1$, arrow-side: "bottom", arrow-dir: "forward")

    // ВЕТВЬ 2 (1 -> 2)
    node-better("n12", (12, 8), label: (content: "c", anchor: "top"), visible: true)
    source-better("E2", "1", "n12", arrow-dir: "forward", label: (content: $E_2$, anchor: "top"))
    resistor-better("R2", "n12", "2", label: (content: $R_2$, anchor: "top"), arrow-label: $I_2$, arrow-side: "bottom", arrow-dir: "forward")

    // ВЕТВЬ 3 (2 -> 6)
    resistor-better("R3", "2", "6", label: (content: $R_3$, anchor: "right"), arrow-label: $I_3$, arrow-side: "left", arrow-dir: "forward")

    // ВЕТВЬ 4 (6 -> 4)
    node-better("n64", (12, 0), label: (content: "f", anchor: "bottom"), visible: true)
    source-better("E4", "6", "n64", arrow-dir: "forward", label: (content: $E_4$, anchor: "top"))
    resistor-better("R4", "n64", "4", label: (content: $R_4$, anchor: "bottom"), arrow-label: $I_4$, arrow-side: "top", arrow-dir: "forward")

    // J4 параллельно ветви 6-4
    wire("6", (14, -2.5))
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

    ground-better("4", length: 0.8)
  })
)

#let I_7_val = I_7
#let I_2_val = I_2
#let I_3_val = I_3
#let I_4_val = I_4

#let phi_a = 0
#let phi_b = phi_a + I_7_val * V.R7
#let phi_c = phi_b + V.E2
#let phi_d = phi_c - I_2_val * V.R2
#let phi_e = phi_d - I_3_val * V.R3
#let phi_f = phi_e + V.E4
#let phi_a_check = phi_f - I_4_val * V.R4

Рассчитываем потенциалы всех точек выбранного контура:

#mathtype-mimic[
  $ phi_"a" = 0 " В"; $
  $ phi_"b" = phi_"a" + I_7 R_7 = #phi_a + (#I_7_val) dot #V.R7 = #phi_b " В"; $
  $ phi_"c" = phi_"b" + E_2 = #phi_b + #V.E2 = #phi_c " В"; $
  $ phi_"d" = phi_"c" - I_2 R_2 = #phi_c - (#I_2_val) dot #V.R2 = #phi_d " В"; $
  $ phi_"e" = phi_"d" - I_3 R_3 = #phi_d - (#I_3_val) dot #V.R3 = #phi_e " В"; $
  $ phi_"f" = phi_"e" + E_4 = #phi_e + #V.E4 = #phi_f " В"; $
  $ phi_"a" = phi_"f" - I_4 R_4 = #phi_f - (#I_4_val) dot #V.R4 = #phi_a_check " В". $
]

По полученным данным построим потенциальную диаграмму (рисунок~@potential-diagram-fig).

#lab-figure(
  caption: [Потенциальная диаграмма для контура a-b-c-d-e-f-a],
  potential-diagram((
    (r: 0, phi: phi_a, label: [a], anchor: "south-east"),
    (r: V.R7, phi: phi_b, label: [b], anchor: "north", r-label: $R_7$),
    (r: V.R7, phi: phi_c, label: [c], anchor: "north-west", e-label: move(dy: 1.3em, $E_2$), show-phi: false),
    (r: V.R7 + V.R2, phi: phi_d, label: [d], anchor: "north", r-label: $R_2$, show-phi: false),
    (r: V.R7 + V.R2 + V.R3, phi: phi_e, label: [e], anchor: "north", r-label: $R_3$, show-phi: false),
    (r: V.R7 + V.R2 + V.R3, phi: phi_f, label: [f], anchor: "west", e-label: move(dy: 1.3em, $E_4$)),
    (r: V.R7 + V.R2 + V.R3 + V.R4, phi: phi_a_check, label: [a], anchor: "south-west", r-label: $R_4$),
  ), r-label-pos: "top")
) <potential-diagram-fig>

= Таблица ответов

#figure(
  table(
    columns: (1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr),
    align: center + horizon,
    stroke: 0.5pt,
    // Заголовки оставляем горизонтальными
    table.header(
      ..format-cells(
        [$I_1$, А], [$I_2$, А], [$I_3$, А], [$I_4$, А], [$I_5$, А], [$I_6$, А], [$I_7$, А],
        [$U_36$, В], [$U_(x x)$, В], [$R_"ген"$, Ом], [$P$, Вт],
        size: 14pt
      )
    ),
    // Значения форматируем и поворачиваем на -90 градусов
    ..rotate-cells(
      format-cells(
        I_1, I_2, I_3, I_4, I_5, I_6, I_7,
        U_36, U_xx, R_gen, P_rec,
        size: 14pt,
        dec: 3 // Количество знаков после запятой как на скриншоте
      )
    )
  )
)

