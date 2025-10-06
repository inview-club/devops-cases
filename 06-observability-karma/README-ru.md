# Кейс №6 – Observability & Karma

<div align="center">

  ![Result diagram dark](img/06-observability-karma-dark.png#gh-dark-mode-only)

</div>

<div align="center">

  ![Result diagram light](img/06-observability-karma-light.png#gh-light-mode-only)

</div>

- [Кейс №6 – Observability \& Karma](#кейс-6--observability--karma)
  - [Цель](#цель)
  - [Стэк](#стэк)
  - [Чекпоинты](#чекпоинты)
  - [Результат](#результат)
  - [Контакты](#контакты)

## Цель

При настройке observability знакомый устаревший интерфейс Alertmanager может быть заменен на более современный аналог, чтобы улучшить визуальное восприятие сервиса.

## Стэк

![VictoriaMetrics](https://img.shields.io/badge/victoriametrics-621773.svg?style=for-the-badge&logo=victoriametrics&logoColor=white)
![Grafana](https://img.shields.io/badge/Grafana-F46800.svg?style=for-the-badge&logo=grafana&logoColor=white)
![Alertmanager](https://img.shields.io/badge/Alertmanager-E6522C.svg?style=for-the-badge&logo=prometheus&logoColor=white)
![Karma](https://img.shields.io/badge/Karma-88F387.svg?style=for-the-badge&logo=keras&logoColor=white)

## Чекпоинты

1. Запустить VictoriaMetrics:
   - Для быстрой проверки навыков рекомендуем [версию Single-node](https://docs.victoriametrics.com/victoriametrics/single-server-victoriametrics/).
   - Чуть более тонкая настройка потребуется для [кластерной версии](https://docs.victoriametrics.com/victoriametrics/cluster-victoriametrics/).
     - В качестве доп. чтения рекомендуем интересную [статью](https://victoriametrics.com/blog/dont-default-to-microservices-you-will-thank-us-later/) о том, почему зачастую лучше использовать single-node решение вместо кластера.
   - Если ставите в Kubernetes, вы можете воспользоваться чартом [`victoria-metrics-k8s-stack`](https://docs.victoriametrics.com/helm/victoria-metrics-k8s-stack/), тогда сразу сможете выполнить пункты 2-5.
   - Если выполняете кейс в виртуальных машинах, могут быть полезными официальные [Ansible-плейбуки](https://github.com/VictoriaMetrics/ansible-playbooks).
2. Запустить Grafana:
   - Если не воспользовались `victoria-metrics-k8s-stack`, вы можете установить Grafana в кластер [вручную](https://grafana.com/docs/grafana/latest/setup-grafana/installation/kubernetes/) или через [Helm](https://grafana.com/docs/grafana/latest/setup-grafana/installation/helm/).
   - При выполнении кейса на виртуальных машинах воспользуйтесь инструкцией по установке на [Debian](https://grafana.com/docs/grafana/latest/setup-grafana/installation/debian/) или [RHEL](https://grafana.com/docs/grafana/latest/setup-grafana/installation/redhat-rhel-fedora/) дистрибутивы.
   - В Grafana выполните настройку Victoria Metrics в качестве [datasource](https://grafana.com/docs/grafana/latest/datasources/prometheus/) типа `prometheus`.
3. Запустить Alertmanager:
   - Если не воспользовались `victoria-metrics-k8s-stack`, для установки в k8s используйте чарты сообщества [Prometheus](https://prometheus-community.github.io/helm-charts/).
   - Можете воспользоваться [рекомендациями](https://github.com/prometheus/alertmanager) по установке от авторов.
4. Установить Node Exporter
   - Если не воспользовались `victoria-metrics-k8s-stack`, для установки в k8s используйте чарты сообщества [Prometheus](https://prometheus-community.github.io/helm-charts/).
   - Для установки на Linux также есть штатная [документация](https://prometheus.io/docs/guides/node-exporter/).
   - Убедитесь, что в Grafana у вас есть дашборд для отсмотра метрик Node Exporter. Если нет, воспользуйтесь [поиском](https://grafana.com/grafana/dashboards/) и импортируйте к себе.
   - Убедитесь, что vmagent настроен на сбор метрик с Node Exporter.
5. Настроить несколько базовых правил алертинга:
   - Скорее всего, если вы устанавливали Victoria Metrics по одному из мануалов, у вас уже будут преднастроенные правила.
   - В поисках вдохновения можете воспользоваться источниками:
     - [Проверка алертов и маршрутов для Alertmanager](https://prometheus.io/webtools/alerting/routing-tree-editor/).
     - Огромный [список](https://samber.github.io/awesome-prometheus-alerts/rules) алертов по многим областям.
     - [То же самое](https://github.com/monitoring-mixins/website/tree/master/assets), что в предыдущем пункте, но больше примеров.
   - За алертинг в Victoria Metrics отвечает компонент vmalert, он должен быть настроен на отправку алертов в Alertmanager.
   - Предлагаем вам настроить отправку уведомлений в Telegram канал или супергруппу. Можно посмотреть пример настройки receiver и шаблон [здесь](https://gist.github.com/sanchpet/7641275a42243d3667b3146c5402be40).
6. Запустить [Karma](https://github.com/prymitive/karma)
   - Инструкция из репозитория предлагает установку через Docker.
   - Для установки в k8s можно воспользоваться наиболее актуальным [чартом](https://artifacthub.io/packages/helm/wiremind/karma). На момент написания кейса Karma не имеет в своём репозитории официального чарта, так что для поиска наиболее свежего варианта от сообщества пользуйтесь [Artifacthub](https://artifacthub.io/packages/search?ts_query_web=karma&sort=relevance&page=1).

7. Связать Karma и Alertmanager:
   - Обновите `ALERTMANAGER_URI` согласно рекомендациям в репозитории.
   - Для Helm-чарта в values также будет необходимо обновить `ALERTMANAGER_URI`. Если устанавливали `victoria-metrics-k8s-stack`, необходимо будет указать подобное:

   ```yaml
   env:
    - name: ALERTMANAGER_URI
      value: http://vmalertmanager-victoria-metrics-k8s-stack:9093
   ```

8. Настроить в Karma постановку алертов на мьют:
   - Karma позволяет настраивать [ACL](https://github.com/prymitive/karma/blob/main/docs/ACLs.md), которые контролируют мьюты, создаваемые пользователями. С их помощью вы можете проконтролировать, что `Team A` случайно не замьютит алерты для `Team B`, либо можете вообще оставить право создавать мьюты только команде SRE.

## Результат

Запущенный Node Exporter отдает данные о состоянии машины. Данные собираются с помощью vmagent в Victoria Metrics и визуализируются в виде графиков в Grafana. Alertmanager получает алерты от vmalert и направляет их в Telegram. В Karma можно видеть какие алерты активны в данный момент и отключать отправку сообщений на определенное время.

## Контакты

Нужна помощь? Пиши в [наш Telegram чат](https://t.me/+nSELCyIX8ltlNjU6)!
