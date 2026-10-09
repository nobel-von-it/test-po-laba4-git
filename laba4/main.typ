// ====================================================================
// НАСТРОЙКИ ДОКУМЕНТА И ШАБЛОНА ПО СТО 7.5.04-2019 (PRAKTIKA)
// ====================================================================
#let work-type = "ОТЧЕТ ПО ЛАБОРАТОРНОЙ РАБОТЕ"
#let work-number = "№ 4"
#let subject = "Тестирование программного обеспечения"
#let theme = "API-тестирование и интеграция в CI/CD"

#let supervisor-name = "А.Е. Алехина"
#let student-name = "М.В. Давыденко"
#let student-group = "БПА23-01"
#let student-id = "23151207"

#let city = "Красноярск"
#let year = "2026 г."

// Вспомогательная функция для таблицы подписантов
#let table_field(body, subtext) = {
  stack(
    spacing: 2pt,
    align(center, body),
    line(length: 100%, stroke: 0.5pt),
    align(center, text(size: 10pt)[#subtext])
  )
}

// --- НАСТРОЙКИ СТРАНИЦЫ И ТЕКСТА ПО СТО ---
#set page(
  paper: "a4",
  margin: (left: 25mm, right: 15mm, top: 20mm, bottom: 20mm),
  footer: context {
    let page_num = counter(page).get().first()
    if page_num > 1 {
      align(center)[#text(size: 14pt)[#page_num]]
    }
  }
)

#set text(
  font: "Liberation Serif",
  size: 14pt,
  lang: "ru"
)

// Абзацный отступ 1.25 см и выравнивание по ширине
#set par(
  justify: true,
  leading: 0.48em,
  first-line-indent: 1.25cm,
  spacing: 0.38em
)

// Настройка списков по СТО
#set list(
  marker: [–],
  indent: 1.25cm,
  body-indent: 0.5em,
  spacing: 0.45em
)

#set enum(
  indent: 1.25cm,
  body-indent: 0.5em,
  spacing: 0.45em
)

// --- ОФОРМЛЕНИЕ ЗАГОЛОВКОВ ПО СТО ---
#show heading: it => {
  set text(size: 14pt, weight: "bold")
  set par(first-line-indent: 1.25cm, justify: true)
  
  let heading-block = if it.level == 1 {
    if not it.outlined {
      block(
        width: 100%,
        above: 0.9em,
        below: 0.4em,
        breakable: false
      )[
        #set par(first-line-indent: 0cm)
        #align(center)[
          #upper(it.body)
        ]
      ]
    } else {
      block(
        width: 100%,
        above: 0.9em,
        below: 0.4em,
        breakable: false
      )[
        #upper(it.body)
      ]
    }
  } else if it.level == 2 {
    block(
      width: 100%,
      above: 0.7em,
      below: 0.35em,
      breakable: false
    )[
      #it.body
    ]
  } else {
    block(
      width: 100%,
      above: 0.6em,
      below: 0.3em,
      breakable: false
    )[
      #it.body
    ]
  }

  heading-block
  par(text(size: 0pt, ""))
}

#show figure: it => { it; par(text(size: 0pt, "")) }

// --- ТИТУЛЬНЫЙ ЛИСТ ---
#block(width: 100%)[
  #set text(hyphenate: false)
  #set par(justify: false, first-line-indent: 0cm, spacing: 0.5em) 

  #block(width: 100%)[
    #set par(leading: 0.65em) 
    #align(center)[
      #text(size: 11pt, weight: "bold")[
        МИНИСТЕРСТВО НАУКИ И ВЫСШЕГО ОБРАЗОВАНИЯ \ РОССИЙСКОЙ ФЕДЕРАЦИИ
      ]
      
      #v(0.3em)
      #text(size: 12pt, weight: "regular")[
        ФЕДЕРАЛЬНОЕ ГОСУДАРСТВЕННОЕ БЮДЖЕТНОЕ \ ОБРАЗОВАТЕЛЬНОЕ \ УЧРЕЖДЕНИЕ ВЫСШЕГО ОБРАЗОВАНИЯ
      ]
      
      #v(0.3em)
      #text(size: 12pt, weight: "bold")[
        «СИБИРСКИЙ ГОСУДАРСТВЕННЫЙ УНИВЕРСИТЕТ НАУКИ И \ ТЕХНОЛОГИЙ ИМЕНИ АКАДЕМИКА М.Ф. РЕШЕТНЕВА»
      ]
    ]
  ]

  #v(1.5em)

  #align(center)[
    Институт информатики и телекоммуникаций \ #v(0.3em)
    Кафедра информационно-управляющих систем
  ]

  #v(2.5em)

  #align(center)[
    #text(size: 14pt, weight: "bold")[
      #work-type #if work-number != "" [ #work-number ]
    ] \ #v(0.6em)
    #text(size: 14pt, weight: "bold")[
      по дисциплине «#subject»
    ]
    #v(0.3em)
    #line(length: 100%, stroke: 0.5pt)
    #v(0.2em)
    #text(size: 14pt)[Тема: #theme]
  ]

  #v(3em)

  #grid(
    columns: (auto, 1fr, 1.2fr),
    column-gutter: 15pt,
    row-gutter: 1.2em,
    
    [Преподаватель],
    table_field(box(height: 14pt), [подпись, дата]),
    table_field([#supervisor-name], [инициалы, фамилия]),

    grid(
      columns: (auto, auto),
      column-gutter: 0.5em,
      [Обучающийся],
      stack(
        spacing: 2pt,
        align(center)[#student-group #student-id],
        align(center)[#text(size: 10pt)[номер группы, зачетной книжки]]
      )
    ),
    table_field(box(height: 14pt), [подпись, дата]),
    table_field([#student-name], [инициалы, фамилия]),
  )

  #v(1fr)

  #align(center)[
    #city #year
  ]
]

#pagebreak()
// --- КОНЕЦ ТИТУЛЬНОГО ЛИСТА ---

= 1 Цель работы

Научиться тестировать API (REST) как вручную, так и автоматически; спроектировать набор API-тестов; интегрировать автотесты (UI и API) в CI-пайплайн с помощью GitHub Actions.

= 2 Описание API и ручные тесты

Для тестирования используется учебный стенд Contact List App (`https://thinking-tester-contact-list.herokuapp.com`). API предоставляет методы для управления пользователями и контактами в формате JSON. Авторизация происходит с помощью Bearer-токена, выдаваемого при регистрации или входе.

Перед автоматизацией была составлена коллекция из 10 ручных запросов (с использованием Postman), покрывающая основные маршруты:
- `POST /users` — регистрация нового пользователя.
- `POST /users/login` — вход и получение токена авторизации.
- `GET /users/me` — получение данных профиля.
- `POST /contacts` — создание контакта (требует токен).
- Ошибочные запросы (без токена, дубликат email, неверный пароль).

= 3 Автоматизация API-тестов

Для автоматизации был выбран язык Python и библиотека `requests`, а для запуска — фреймворк `pytest`. Этот выбор обусловлен простотой написания HTTP-запросов и отличной читаемостью кода.

Было реализовано 10 автотестов, покрывающих позитивные, негативные сценарии и проверки безопасности. Результаты прогона представлены в таблице 1.

#align(center)[
  #text(size: 11pt)[Таблица 1 – Реализованные API-автотесты]
  #text(size: 10pt)[
    #table(
      columns: (0.4fr, 3.5fr, 1.2fr, 1fr),
      align: (center, left, center, center),
      stroke: 0.5pt,
      inset: (x: 4pt, y: 3pt),
      fill: (col, row) => if row == 0 { rgb("eef2f7") } else { none },
      [#strong("№")], [#strong("Название проверки")], [#strong("Тип")], [#strong("Ожидание")],
      
      [1], [Успешная регистрация / создание ресурса], [Positive], [201 Created],
      [2], [Регистрация с невалидным email], [Negative], [400 Bad Request],
      [3], [Дубликат email], [Negative], [400 Bad Request],
      [4], [Успешная авторизация (логин)], [Positive], [200 OK + token],
      [5], [Логин с неверным паролем], [Negative], [401 Unauthorized],
      [6], [Запрос профиля без токена], [Security], [401 Unauthorized],
      [7], [Запрос профиля с невалидным токеном], [Security], [401 Unauthorized],
      [8], [Проверка структуры ответа профиля], [Contract], [200 OK],
      [9], [Метод не поддерживается (`POST /users/me`)], [Negative], [404 Not Found],
      [10], [Создание контакта с авторизацией], [Positive], [201 Created]
    )
  ]
]

= 4 Настройка CI-пайплайна

Для непрерывной интеграции (CI) был выбран GitHub Actions. Пайплайн настроен на автоматический запуск тестов при каждом пуше (push) или создании Pull Request в ветку `main`. 

Сценарий (`tests.yml`) включает следующие шаги:
1. Загрузка исходного кода из репозитория.
2. Установка Python 3.12 и зависимостей (`pytest`, `requests`, `playwright`).
3. Запуск написанных API-тестов (`pytest test_api.py`).
4. Запуск UI smoke-тестов из ЛР3 (`pytest test_registration.py`).
5. Публикация результатов в виде артефактов JUnit XML для отчётности.

= 5 Рефлексия

API-тестирование оказалось гораздо быстрее и стабильнее UI-тестов. В отличие от UI, где нужно ждать рендеринга страницы, загрузки скриптов и обходить защиты вроде CAPTCHA, API-запросы выполняются за миллисекунды и дают точный HTTP-статус.
Интеграция тестов в CI с помощью GitHub Actions показала важность принципа Shift-Left: разработчик получает обратную связь о сломанном функционале сразу после пуша кода, ещё до того, как изменения попадут на рабочий сервер.

= 6 Выводы

В ходе лабораторной работы изучены методы ручного и автоматизированного API-тестирования. Разработан набор из 10 автотестов с помощью библиотеки `requests`, покрывающий основные проверки безопасности, контрактов и бизнес-логики. Тесты успешно интегрированы в CI-пайплайн GitHub Actions, что обеспечивает постоянный контроль качества при внесении изменений в код.
