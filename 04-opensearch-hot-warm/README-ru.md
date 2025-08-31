# Кейс №4 - Hot-Warm архитектура

- [Кейс №4 - Hot-Warm архитектура](#кейс-4---hot-warm-архитектура)
  - [Цель](#цель)
  - [Стэк](#стэк)
  - [Чекпоинты](#чекпоинты)
  - [Результат](#результат)
  - [Контакты](#контакты)

<div align="center">

  ![Result diagram dark](img/04-opensearch-hot-warm-dark.png#gh-dark-mode-only)

</div>

<div align="center">

  ![Result diagram light](img/04-opensearch-hot-warm-light.png#gh-light-mode-only)

</div>

## Цель

Для экономии места при хранении логов, необходимо подготовить архитектуру и настроить жизненный цикл индексов с логами.

## Стэк

![Opensearch](https://img.shields.io/badge/opensearch_2.19-005EB8.svg?style=for-the-badge&logo=OpenSearch&logoColor=white)

## Чекпоинты

1. Развернуть [кластер](https://docs.opensearch.org/latest/tuning-your-cluster/#advanced-step-7-set-up-a-hot-warm-architecture) из 5 нод со следующими настройками:
   - 1 master-нода
   - 4 data-ноды:
     - 2 ноды c атрибутом hot
     - 2 ноды с атрибутом температуры warm
2. Создать [шаблон](https://docs.opensearch.org/latest/im-plugin/index-templates/) для индекса со следующими настройками:
   - Тип шаблона: Data streams
      - Поле времени: timestamp
   - Паттерн индекса: logs
   - 1 шард
   - 1 реплика
   - Новые шарды создаются на ноде с атрибутом hot
   - Маппинги индекса:
      - level: keyword
      - trace_id: keyword
      - service: keyword
      - host: keyword
      - timestamp: data
      - message: text
3. Настроить [политику](https://docs.opensearch.org/latest/im-plugin/ism/index/), которая выглядит следующим образом:
    - Начальное состояние: hot.
      - Действия:
        - Rollover:
          - Минимальное время жизни индекса: 1 минута
          - Минимальный размер индекса: 100 mb
      - Переход:
        - Целевое состояние: warm
        - Триггер: Минимальное время жизни индекса: 1 минута
    - Состояние: warm
      - Действия:
        - Allocation:
          - Нода должна иметь температуру: warm
      - Переход:
        - Целевое состояние: delete
        - Триггер: Минимальное время жизни индекса: 1 минута
    - Состояние delete
      - Действия:
        - Delete
4. Загрузить данные любым инструментом и посмотреть как шарды проходят все этапы жизненного цикла. Можно воспользоваться нашим [инструментом](https://github.com/inview-club/synthetica)
5. (Дополнительно) Повторить настройку шаблона индекса и политики, используя **Dev Tools**.

## Результат

1. При использовании запроса **GET _cat/nodeattrs** получаем атрибут температуры у нод.
2. На вкладке **Policy managed indexes** отображаются дата стримы, к которым привязана созданная политика, а также можем увидеть текущее состояние и узнать выполняемое действие.
3. При использовании запроса **GET _cat/shards?v** все шарды индекса должны иметь статус **STARTED** и находиться сначала на нодах с атрибутом **hot**, потом с атрибутом **warm** и в конце они должны удаляться.

## Контакты

Нужна помощь? Пиши в [наш Telegram чат](https://t.me/+nSELCyIX8ltlNjU6)!
