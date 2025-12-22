# Отчёт по кейсу №1

Выполнил (и переоценил свои силы) Янин Егор

Это история о том, как простая на вид задача может затянуться на несколько недель из-за неочевидных моментов.
![problems](https://github.com/user-attachments/assets/3cde370f-4080-467a-9310-622d3d61e56d)


### Начало

Первый шаг - создание и установка виртуальных машин. Для гитлаба я взял уже существующую машину с ubuntu и выделенными 10 ГБ оперативной памяти, остальные две машины - Ubuntu Server по 2 ГБ для Nexus и Gitlab Runner. Для ноутбука на 16 ГБ оперативной памяти это адача не из простых, и позже это аукнется, но пока все вроде бы идёт хорошо.

### Первые звоночки

Для приложения я взял предложенный репозиторий `docker-gs-ping`/ Сначала всё шло ровно - гитлаб установился и даже вроде бы запустился, однако то, что машина была не свежей, а использованной, вылезло не самым приятным образом. Гитлабовский nginx начал конфликтовать с nginx, установленным на машине. Пришлось убить локальный nginx и всё поехало... да ведь? 

### Сети...

Гитлаб открывался, я авторизировался, сменил пароль и приступил к регистрации runner. Однако достучаться до гитлаба раннер не мог, и тут я вспомнил про то, что совершенно не менял сетевые настройки машин. Я быстренько поставил сетевой мост, нашёл ip машин и все поехало дальше, но... Через несколько дней ip-адреса уже были другие, и вспомнил я про DHCP, который быстро и удобно поставил машинам ip, и так же быстро и удобно его переставил. Здесь я просто решил поставить фильтр по MAC-адресу, чтобы ip не скакал, и больше сеть меня не беспокоила.

### Dind.

```
ERROR: Cannot connect to the Docker daemon at tcp://docker:2375. Is the docker daemon running?
```

Мне кажется эта ошибка будет сниться по ночам. Настолько она меня извела. И это - ещё одно ружьё, которое я сам себе повесил, когда приступал к кейсу. 
Всё началось на 7 шаге. `Добавить в пайплайн новую джобу для загрузки собранных образов на Nexus`. Полазил я по интернетам, и решил использовать для сборки образов Docker-in-docker. И пришёл я к такому файлу:
```yml
stages:
  - build
  - push

image: docker:24

services:
  - name: docker:dind
    command: ["--insecure-registry=192.168.1.50:5000"]

variables:
  DOCKER_TLS_CERTDIR: ""

build_image:
  stage: build
  script:
    - docker build -t demo-app:latest .
    - docker tag demo-app:latest $NEXUS_REGISTRY/demo-app:latest

push_image:
  stage: push
  script:
    - echo "$NEXUS_PASSWORD" | docker login $NEXUS_REGISTRY -u "$NEXUS_USER" --password-stdin
    - docker push $NEXUS_REGISTRY/demo-app:latest

```

Переменные засунул в настройки CI/CD проекта на гитлабе, всё по красоте. И тут приходит ошибка, над которой я сидел суммарно более 3 часов. Я искал по форумам gitlab, делал запросы в нейронку, коммитил файл в общей сложности 12 раз. В итоге дело оказалось в том, что на раннере не хватало ресурсов для запуска и команда `sleep 30` вывела меня на другую цепь ошибок, по которым я смог все починить и разобраться с файлом. Ох...

### Успех

Было множество ошибок помельче из-за невнимательности/незнания/неопытности, на которых быстро учишься. Но в конце концов я увидел зелёный свет в конце туннеля - галочку напротив джобы.

Актуальный `gitlab-ci.yml`:
```yml
image: docker:latest

variables:
  DOCKER_HOST: unix:///var/run/docker.sock
  DOCKER_TLS_CERTDIR: ""
  IMAGE_NAME: demo-app
  IMAGE_TAG: $CI_COMMIT_SHORT_SHA
  DOCKER_BUILDKIT: "1"
  GOPROXY: "http://192.168.1.104:8081/repository/go-proxy/,direct"

stages:
  - build
  - push

build-image:
  stage: build
  services: []
  script:
    - docker info
    - docker build -f Dockerfile.multistage -t 192.168.1.104:5000/$IMAGE_NAME:$IMAGE_TAG .

push-image:
  stage: push
  script:
    - echo "$NEXUS_PASSWORD" | docker login 192.168.1.104:5000 -u "$NEXUS_USER" --password-stdin
    - docker push 192.168.1.104:5000/$IMAGE_NAME:$IMAGE_TAG
```
Nexus репохитории:
<img width="1548" height="544" alt="image" src="https://github.com/user-attachments/assets/09022ae3-b0ab-4fca-b78b-a3e9875d5230" />
`docker-hosted` содержит образы `demo-app`  
`docker-proxy` проксирует docker, чтобы иметь доступ к образам даже офлайн  
`go-proxy` проксирует Golang, чтобы зависимости кэшировались и были доступны  

Pipeline проходит даже без интернета на машине runner, так что я считаю, что кейс выполнен.
