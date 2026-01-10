# Case №7 - Kubernetes: user identification (Keycloak + OIDC)

<div align="center">

  ![Result diagram dark](img/08-k8s-keycloak-oidc-dark.png#gh-dark-mode-only)

</div>

<div align="center">

  ![Result diagram light](img/08-k8s-keycloak-oidc-light.png#gh-light-mode-only)

</div>

- [Case №7 - Kubernetes: user identification (Keycloak + OIDC)](#case-7---kubernetes-user-identification-keycloak--oidc)
  - [Goal](#goal)
  - [Stack](#stack)
  - [Checkpoints](#checkpoints)
  - [Result](#result)
  - [Contacts](#contacts)

## Goal

By default, a self-hosted Kubernetes cluster is deployed with a single kubeconfig for the administrator. Connect the kube-apiserver to Keycloak and configure an identity provider so that each engineer in the team can use a personal kubeconfig file.

## Stack

![k8s](https://img.shields.io/badge/k8s-326CE5.svg?style=for-the-badge&logo=kubernetes&logoColor=white)
![keycloak](https://img.shields.io/badge/Keycloak-4D4D4D.svg?style=for-the-badge&logo=keycloak&logoColor=white)
![OIDC](https://img.shields.io/badge/OpenID-F78C40.svg?style=for-the-badge&logo=openid&logoColor=white)

## Checkpoints

1. **Install the Kubernetes cluster:**
   - Managed solutions such as Yandex Cloud are not applicable for this case since they already include built-in authentication.
   - For quick setup, use [minikube](https://minikube.sigs.k8s.io/docs/start/?arch=%2Fmacos%2Farm64%2Fstable%2Fbinary+download).
   - For a more production-like installation, bootstrap your cluster using [kubeadm](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/), [kubespray](https://github.com/kubernetes-sigs/kubespray/blob/master/docs/getting_started/getting-started.md), or any other tool you prefer.

2. **Install Keycloak in your cluster:**
   - For the fastest setup, follow the official [Getting Started](https://www.keycloak.org/getting-started/getting-started-kube) guide using raw manifests.
   - For a more production-like installation, consider using a Helm chart. Keycloak does not provide one officially, but [this chart](https://github.com/codecentric/helm-charts/tree/master/charts/keycloakx) by Codecentric is tested and works well.
   - Alternatively, try the official [Keycloak Operator](https://www.keycloak.org/operator/installation).
   - Note: A production-grade Keycloak instance requires PostgreSQL. For this case, you can use an in-memory or file-based H2 database. If you prefer to run PostgreSQL inside the cluster, consider [CloudNative-PG](https://github.com/cloudnative-pg/cloudnative-pg).

3. **Configure an identity provider in Keycloak:**
   - We recommend using GitHub as the provider, though other integrations (Google, GitLab, etc.) are available.
   - Create a new [organization](https://docs.github.com/en/organizations/collaborating-with-groups-in-organizations/creating-a-new-organization-from-scratch) (or use an existing one).
   - Create an OAuth app for your organization (**Organization → Settings → Developer Settings → OAuth Apps**).
   - In Keycloak, create a new [Realm](https://www.keycloak.org/docs/latest/server_admin/index.html#_configuring-realms) and set your GitHub organization as an [Identity Provider](https://www.keycloak.org/docs/latest/server_admin/index.html#_identity_broker).  
     You can follow [this guide](https://blog.elest.io/setting-up-sign-in-with-github-using-keycloak/) as an example.
   - If you use LDAP in your company, configure a [User Federation](https://www.keycloak.org/docs/latest/server_admin/index.html#configuring-federated-ldap-storage) and map claims to LDAP groups.

4. **Create a Keycloak client representing the kube-apiserver:**
   - Create an [OpenID Connect client](https://www.keycloak.org/docs/latest/server_admin/index.html#assembly-managing-clients_server_administration_guide) for the kube-apiserver.
   - Configure redirect URIs based on the application you’ll use to generate kubeconfig files.  
     One popular option is [kubelogin](https://github.com/int128/kubelogin).
   - You can follow the [OIDC authentication for Kubernetes guide](https://geek-cookbook.funkypenguin.co.nz/kubernetes/oidc-authentication/keycloak/) as reference.

5. **Configure the kube-apiserver to use OIDC tokens:**
   - Refer to the official [Kubernetes documentation](https://kubernetes.io/docs/reference/access-authn-authz/authentication/#openid-connect-tokens).
   - If using kubeadm for cluster management, you can either edit the node manifests (temporary changes) or update the [kubeadm ConfigMap](https://kubernetes.io/docs/reference/setup-tools/kubeadm/kubeadm-config/) and upgrade the nodes — the recommended approach.

6. **Set up an authentication client for kubeconfig token generation:**
   - Install [kubelogin](https://github.com/int128/kubelogin) or a similar tool to generate and insert OIDC tokens into the kubeconfig.
   - Alternatively, you can use [Loginapp](https://github.com/fydrah/loginapp).

7. **Create a ClusterRoleBinding:**
   - Create a [ClusterRoleBinding (CRB)](https://kubernetes.io/docs/reference/access-authn-authz/rbac/#rolebinding-and-clusterrolebinding) to map your GitHub group to the **cluster-admin** ClusterRole.
   - To test more restrictive access, create a custom [ClusterRole](https://kubernetes.io/docs/reference/access-authn-authz/rbac/#clusterrole-example) for your organization and bind it to the desired group.
   - For enhanced security, you can implement a sudo-like least-privilege mechanism for administrators using impersonation. See [this guide](https://johnharris.io/2019/08/least-privilege-in-kubernetes-using-impersonation/) for details.

## Result

Keycloak is running in the Kubernetes cluster with a configured identity provider (GitHub, LDAP, etc.).  
Team members can authenticate to the cluster using **kubelogin**, and access rights can be managed flexibly through RBAC.  
If the kube-apiserver audit log is enabled, every engineer’s actions can be uniquely traced.

## Contacts

Need help? Message us in our [Telegram chat](https://t.me/+nSELCyIX8ltlNjU6)!
