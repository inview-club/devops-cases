[README (1).md](https://github.com/user-attachments/files/24333209/README.1.md)
# Лабораторная работа 3*

## Выполнили работу Попов Артемий, Попкова София, Ломакина Мария
### Установка Auditor
Скланировать репозиторий 
```
https://gitlab.inview.team/whitespots-public-fork/auditor.git
```

Поднятие докеров
```
docker compose up -d
```

Генерация токена по адресу 127.0.0.1:8080
Добавьте этот токен в переменную ACCESS_TOKEN в .env файл в директории auditor.
Перезапустите контейнеры
```
docker compose down
docker compose up -d
```
### Установка AppSec Portal
Склонировал репозиторий https://gitlab.inview.team/whitespots-public-fork/appsec-portal.git

Выполнил ```./set_vars.sh ```

Добавил версию  IMAGE_VERSION=release_v25.11.3

Запустите докеры портала ```sh run.sh```
Создал  суперпользователя 
```
docker compose exec back python3 manage.py createsuperuser --username admin
```
На сайте по адресу ***127.0.0.1:80*** вошел в аккаунт суперпользователя
<img width="3024" height="1746" alt="2025-12-23_00-24-45" src="https://github.com/user-attachments/assets/15881b81-4c3a-46ae-9bf8-79dd5f7928cb" />

В разделе Auditor - Config. Указал адрес аудитора http://host.docker.internal:8080/ и ваш Access Token, полученный ранее.


Изменил Internal Portal URL на http://host.docker.internal/

Добавьте приватный ключ

### Запуск аудита

Выбрал репозиторий из списка: ***https://gitlab.com/whitespots-public/vulnerable-apps/python-public-example***
Были выявлены ошибки:
<img width="1511" height="679" alt="Снимок экрана 2025-12-24 в 23 22 17" src="https://github.com/user-attachments/assets/dfc9603e-720c-4cbe-a6d9-4a9448b04d1e" />

Также запустил аудит со своим репозиторием(пет проект): ***https://github.com/StalSkyle/car-scene-captioning***
<img width="1512" height="315" alt="Снимок экрана 2025-12-24 в 23 24 20" src="https://github.com/user-attachments/assets/e715fc47-f6cd-484f-ba3e-eb2a769508e2" />

### Интеграция с IDE
К сожалению у меня не получилось подключить portal к visual code. По какой то причине не отображаются ошибки. 
<img width="310" height="67" alt="Снимок экрана 2025-12-24 в 23 46 34" src="https://github.com/user-attachments/assets/9ab2ba1c-6e42-413b-bc5a-1f21942a866c" />

Репозиторий, который я выбрал: ***https://github.com/anxolerd/dvpwa.git***
Ошибки, которые показывает portal%
<img width="3024" height="1140" alt="image" src="https://github.com/user-attachments/assets/0783a2dc-e7e8-45e1-b05f-e5cc22e6b1d2" />

В качестве проверки, что до меня доходит ошикбик я использую команду curl:
```
curl -H "Authorization: Token c00fb4ad85a9d054bede36ab9122e5a300abb870" \
     "http://127.0.0.1:80/api/v1/findings/?repository=https://github.com/anxolerd/dvpwa.git" \
  | jq
```

Часть вывода:
```
{
  "next": null,
  "previous": null,
  "current": 1,
  "count": 8,
  "pages_count": 1,
  "results": [
    {
      "id": 1749,
      "dojo_finding_id": null,
      "name": "pyyaml@3.13 Affected by: CVE-2017-18342",
      "severity": 4,
      "scanner": 11,
      "status": "Active",
      "product": 1,
      "related_objects_meta": {
        "product": {
          "id": 1,
          "name": "Unsorted",
          "is_default": true,
          "business_criticality": 100,
          "related_objects_meta": {
            "product_type": {
              "name": "Common"
            }
          }
        },
        "scanner": {
          "name": "Trivy Scan"
        }
      },
      "line": null,
      "file_path": "requirements.txt",
      "current_sla_level": 0,
      "description": "pyyaml@3.13 Affected by: CVE-2017-18342\n## Version info:\n* InstalledVersion: 3.13\n* FixedVersion: 4.1\n* PrimaryURL: https://avd.aquasec.com/nvd/cve-2017-18342\n* Title:\n\t PyYAML: yaml.load() API could execute arbitrary code\n* Description:\n\t In PyYAML before 5.1, the yaml.load() API could execute arbitrary code if used with untrusted data. The load() function has been deprecated in version 5.1 and the 'UnsafeLoader' has been introduced for backward compatibility with the function.\n## DataSource:\n\tID: ghsa\n\tName: GitHub Security Advisory pip\n\tURL: https://github.com/advisories?query=type%3Areviewed+ecosystem%3Apip\n## References:\n\t1: https://access.redhat.com/security/cve/CVE-2017-18342\n\t2: https://github.com/marshmallow-code/apispec/issues/278\n\t3: https://github.com/pypa/advisory-database/tree/main/vulns/pyyaml/PYSEC-2018-49.yaml\n\t4: https://github.com/yaml/pyyaml\n\t5: https://github.com/yaml/pyyaml/blob/master/CHANGES\n\t6: https://github.com/yaml/pyyaml/commit/7b68405c81db889f83c32846462b238ccae5be80\n\t7: https://github.com/yaml/pyyaml/issues/193\n\t8: https://github.com/yaml/pyyaml/pull/74\n\t9: https://github.com/yaml/pyyaml/wiki/PyYAML-yaml.load%28input%29-Deprecation\n\t10: https://github.com/yaml/pyyaml/wiki/PyYAML-yaml.load(input)-Deprecation\n\t11: https://linux.oracle.com/cve/CVE-2017-18342.html\n\t12: https://linux.oracle.com/errata/ELSA-2022-9341.html\n\t13: https://lists.fedoraproject.org/archives/list/package-announce%40lists.fedoraproject.org/message/JEX7IPV5P2QJITAMA5Z63GQCZA5I6NVZ/\n\t14: https://lists.fedoraproject.org/archives/list/package-announce%40lists.fedoraproject.org/message/KSQQMRUQSXBSUXLCRD3TSZYQ7SEZRKCE/\n\t15: https://lists.fedoraproject.org/archives/list/package-announce%40lists.fedoraproject.org/message/M6JCFGEIEOFMWWIXGHSELMKQDD4CV2BA/\n\t16: https://lists.fedoraproject.org/archives/list/package-announce@lists.fedoraproject.org/message/JEX7IPV5P2QJITAMA5Z63GQCZA5I6NVZ\n\t17: https://lists.fedoraproject.org/archives/list/package-announce@lists.fedoraproject.org/message/KSQQMRUQSXBSUXLCRD3TSZYQ7SEZRKCE\n\t18: https://lists.fedoraproject.org/archives/list/package-announce@lists.fedoraproject.org/message/M6JCFGEIEOFMWWIXGHSELMKQDD4CV2BA\n\t19: https://nvd.nist.gov/vuln/detail/CVE-2017-18342\n\t20: https://security.gentoo.org/glsa/202003-45\n\t21: https://www.cve.org/CVERecord?id=CVE-2017-18342\n",
```

Полный список ошибок, которая вывела мне команда, можно посмотреть в [файле](https://github.com/loxarr/cloud-technologies/blob/main/DevOps/lab3/StarTask/result_of_curl.json).





