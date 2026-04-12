#import "@preview/modern-g7-32:0.2.0": *
#import "@local/typst-bsuir-core:0.11.21": *
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

// 2. ИСХОДНЫЕ ДАННЫЕ ВАРИАНТА №14
#let V = (
  R1: 230, R2: 470, R3: 160, R4: 570, R5: 310, R6: 190, R7: 550,
  E2: 500, E4: 500,
  J4: 3, J7: 9,
  VARIANT: 14,
)

// --- НАЧАЛО ДОКУМЕНТА ---

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

Расчёт схемы заключается в определении токов во всех ветвях схемы, определении напряжения между узлами, указанными в задании, и составлении баланса мощностей в цепи.

= Преобразование схемы в двухконтурную

Преобразуем источники тока $J_4$ и $J_7$ в эквивалентные источники ЭДС $E_04$ и $E_07$. Направления эквивалентных ЭДС совпадают с направлениями исходных источников тока:

#let E4_prime = V.J4 * V.R4
#let E7_prime = V.J7 * V.R7

#mathtype-mimic[
  $ E_04 &= J_4 R_4 = #V.J4 dot #V.R4 = #E4_prime " В"; $
  $ E_07 &= J_7 R_7 = #V.J7 dot #V.R7 = #E7_prime " В". $
]

В ветви 6–4 эквивалентная ЭДС $E_04$ и исходная ЭДС $E_4$ направлены в одну сторону (от узла 6 к узлу 4). Найдем суммарную ЭДС этой ветви:

#let E4_sum = V.E4 + E4_prime

#mathtype-mimic[
  $ E_404 = E_4 + E_04 = #V.E4 + #E4_prime = #E4_sum " В". $
]

Объединим последовательно соединенные сопротивления $R_1, R_6, R_5$ в эквивалентное сопротивление левой ветви $R_156$. Аналогично объединим $R_2, R_3, R_4$ в эквивалентное сопротивление правой ветви $R_234$, а ЭДС $E_2$ и $E_404$ в эквивалентную ЭДС правой ветви $E_234$:

#let R_156 = V.R1 + V.R6 + V.R5
#let R_234 = V.R2 + V.R3 + V.R4
#let E_2404 = V.E2 + E4_sum

#mathtype-mimic[
  $ R_156 &= R_1 + R_6 + R_5 = #V.R1 + #V.R6 + #V.R5 = #R_156 " Ом"; $
  $ R_234 &= R_2 + R_3 + R_4 = #V.R2 + #V.R3 + #V.R4 = #R_234 " Ом"; $
  $ E_2404 &= E_2 + E_404 = #V.E2 + #E4_sum = #E_2404 " В". $
]

В результате этих преобразований схема будет иметь следующий вид (рис. @two-loop-circuit):

#lab-figure(
  above: 0em,
  circuit-better(scale-factor: 85%, {
    import zap: *

    node-better("1", (8, 6), label: (content: "1", anchor: "top"), visible: true)
    node-better("4", (8, 0), label: (content: "4", anchor: "bottom"), visible: true)

    // ЛЕВАЯ ВЕТВЬ (без ЭДС)
    wire("1", (2, 6))
    resistor-better("R_156", (2, 6), (2, 0), label: (content: $R_156$, anchor: "left"), arrow-label: $I_156$, arrow-side: "right", arrow-dir: "backward")
    wire((2, 0), "4")

    // ЦЕНТРАЛЬНАЯ ВЕТВЬ
    node-better("nc", (8, 3), visible: false)
    source-better("E7_prime", "1", "nc", arrow-dir: "forward", label: (content: $E_07$, anchor: "left"))
    resistor-better("R7", "nc", "4", label: (content: $R_7$, anchor: "left"), arrow-label: $I_7$, arrow-side: "right", arrow-dir: "forward")

    // ПРАВАЯ ВЕТВЬ
    wire("1", (14, 6))
    node-better("nr", (14, 3), visible: false)
    source-better("E_2404", (14, 6), "nr", arrow-dir: "forward", label: (content: $E_2404$, anchor: "right"))
    resistor-better("R_234", "nr", (14, 0), label: (content: $R_234$, anchor: "right"), arrow-label: $I_234$, arrow-side: "left", arrow-dir: "forward")
    wire((14, 0), "4")
  })
) <two-loop-circuit>