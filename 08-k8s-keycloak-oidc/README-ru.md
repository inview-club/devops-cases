# Case №8 - Kubernetes: идентификация пользователей (Keycloak + OIDC)

<div align="center">

  ![Result diagram dark](img/08-k8s-keycloak-oidc-dark.png#gh-dark-mode-only)

</div>

<div align="center">

  ![Result diagram light](img/08-k8s-keycloak-oidc-light.png#gh-light-mode-only)

</div>

- [Case №8 - Kubernetes: идентификация пользователей (Keycloak + OIDC)](#case-8---kubernetes-идентификация-пользователей-keycloak--oidc)
  - [Цель](#цель)
  - [Стэк](#стэк)
  - [Контрольные точки](#контрольные-точки)
  - [Результат](#результат)
  - [Контакты](#контакты)

## Цель

По умолчанию кластер Kubernetes, развёрнутый самостоятельно, содержит единственный kubeconfig для администратора. Подключите kube-apiserver к Keycloak и настройстве провайдера идентификации, чтобы каждый инженер работал в кластере по персональному kubeconfig.

## Стэк

![k8s](https://img.shields.io/badge/k8s-326CE5.svg?style=for-the-badge&logo=kubernetes&logoColor=white)
![keycloak](https://img.shields.io/badge/Keycloak-4D4D4D.svg?style=for-the-badge&logo=keycloak&logoColor=white)
![OIDC](https://img.shields.io/badge/OpenID-F78C40.svg?style=for-the-badge&logo=openid&logoColor=white)

## Контрольные точки

1. **Установите кластер Kubernetes:**
   - Управляемые решения, такие как Yandex Cloud, не подходят для данного кейса, так как они уже содержат встроенную аутентификацию.
   - Для быстрого развертывания используйте [minikube](https://minikube.sigs.k8s.io/docs/start/?arch=%2Fmacos%2Farm64%2Fstable%2Fbinary+download).
   - Для приближённой к продакшену установки разверните кластер с помощью [kubeadm](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/), [kubespray](https://github.com/kubernetes-sigs/kubespray/blob/master/docs/getting_started/getting-started.md) или любого другого инструмента на ваш выбор.

2. **Установите Keycloak в ваш кластер:**
   - Для самого быстрого старта воспользуйтесь официальным руководством [Getting Started](https://www.keycloak.org/getting-started/getting-started-kube), применив манифесты напрямую.
   - Для более продакшен-подхода рассмотрите установку через Helm Chart. Официальных чартов нет, но [чарт](https://github.com/codecentric/helm-charts/tree/master/charts/keycloakx) от Codecentric протестирован и работает.
   - Также можно воспользоваться официальным [Keycloak Operator](https://www.keycloak.org/operator/installation).
   - Примечание: для Keycloak в продакшене требуется PostgreSQL. В данном кейсе можно использовать встроенную файловую базу H2. Если хотите запустить PostgreSQL в кластере, рассмотрите [CloudNative-PG](https://github.com/cloudnative-pg/cloudnative-pg).

3. **Настройте провайдера идентификации в Keycloak:**
   - Рекомендуем использовать GitHub как провайдера, хотя доступны и другие интеграции (Google, GitLab и т.д.).
   - Создайте новую [организацию](https://docs.github.com/en/organizations/collaborating-with-groups-in-organizations/creating-a-new-organization-from-scratch) (или используйте существующую).
   - Создайте OAuth-приложение для вашей организации (**Organization → Settings → Developer Settings → OAuth Apps**).
   - В Keycloak создайте новый [Realm](https://www.keycloak.org/docs/latest/server_admin/index.html#_configuring-realms) и настройте вашу организацию GitHub как [Identity Provider](https://www.keycloak.org/docs/latest/server_admin/index.html#_identity_broker).  
     В качестве примера можно использовать [это руководство](https://blog.elest.io/setting-up-sign-in-with-github-using-keycloak/).
   - Если в вашей компании используется LDAP, настройте [User Federation](https://www.keycloak.org/docs/latest/server_admin/index.html#configuring-federated-ldap-storage) и свяжите атрибуты с группами LDAP.

4. **Создайте Keycloak-клиент, представляющий kube-apiserver:**
   - Создайте [OpenID Connect клиент](https://www.keycloak.org/docs/latest/server_admin/index.html#assembly-managing-clients_server_administration_guide) для kube-apiserver.
   - Укажите redirect URI в зависимости от приложения, которое вы используете для генерации kubeconfig.  
     Популярный вариант — [kubelogin](https://github.com/int128/kubelogin).
   - В качестве справочного примера можно использовать [руководство по OIDC-аутентификации Kubernetes](https://geek-cookbook.funkypenguin.co.nz/kubernetes/oidc-authentication/keycloak/).

5. **Настройте kube-apiserver для использования OIDC-токенов:**
   - См. официальную [документацию Kubernetes](https://kubernetes.io/docs/reference/access-authn-authz/authentication/#openid-connect-tokens).
   - Если вы используете kubeadm, вы можете либо вручную изменить манифесты на нодах (временное решение), либо обновить [ConfigMap kubeadm](https://kubernetes.io/docs/reference/setup-tools/kubeadm/kubeadm-config/) и проапгрейдить ноды (рекомендуемый способ).

6. **Настройте клиент для генерации токенов kubeconfig:**
   - Установите [kubelogin](https://github.com/int128/kubelogin) или аналогичное приложение, которое будет генерировать и вставлять OIDC-токены в kubeconfig.
   - Альтернативный вариант — [Loginapp](https://github.com/fydrah/loginapp).

7. **Создайте ClusterRoleBinding:**
   - Создайте [ClusterRoleBinding (CRB)](https://kubernetes.io/docs/reference/access-authn-authz/rbac/#rolebinding-and-clusterrolebinding), связывающий вашу группу GitHub с ролью **cluster-admin**.
   - Для тестирования более строгих ограничений создайте собственную [ClusterRole](https://kubernetes.io/docs/reference/access-authn-authz/rbac/#clusterrole-example) для вашей организации и привяжите её к группе.
   - Для повышения безопасности можно реализовать механизм «повышения прав» наподобие sudo с помощью impersonation. См. [эту статью](https://johnharris.io/2019/08/least-privilege-in-kubernetes-using-impersonation/) для примера.

## Результат

Keycloak развернут в кластере Kubernetes и настроен с провайдером идентификации (GitHub, LDAP и т.д.).  
Члены команды могут аутентифицироваться в кластере с помощью **kubelogin**, а права доступа гибко управляются через RBAC.  
Если включить аудит в kube-apiserver, все действия инженеров могут быть однозначно идентифицированы.

## Контакты

Нужна помощь? Пиши в [наш Telegram чат](https://t.me/+nSELCyIX8ltlNjU6)!
