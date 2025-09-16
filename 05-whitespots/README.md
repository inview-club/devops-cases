# Case #5 - WhiteSpots

## Goal
To get acquainted with a tool for analyzing vulnerabilities in repositories. To study the possibilities of integrating WhiteSpots with other tools.

## Stack
WhiteSpots (https://whitespots.io)

## Checkpoints
1.  Install [AppSec Portal](https://docs.whitespots.io/appsec-portal/deployment/installation) and [Auditor](https://docs.whitespots.io/auditor/deployment/installation). ([Install via Docker Compose](#note-installation-via-docker-compose))
2.  Initial setup:
    -   [Link](https://docs.whitespots.io/appsec-portal/features/vulnerability-discovery/auditor-settings/auditor-config) the portal with the Auditor.
    -   Add an SSH key.
3.  Checking repositories:
    -   Add any repository from the [list](https://gitlab.com/whitespots-public/vulnerable-apps). Start an audit. Analyze the found vulnerabilities.
    -   Add a repository with your pet project (Github, Gitlab). Conduct an audit.
4.  Integration with IDE:
    -   Install the extension for your IDE.
    -   Clone any repository with vulnerabilities. Verify the found vulnerabilities through the portal. Trace their display in the source code in the IDE.
5.  Integration with CI/CD:
    -   Embed into the CI/CD of any of your repositories.
6.  Notifications
    -   Add an [integration](https://docs.whitespots.io/appsec-portal/general-portal-settings/notification-settings/integration) for notifications in Telegram.
    -   Set up a response to any event (for example, a change in the status of a vulnerability) and check the functionality of the notifications.


## Note. Installation via Docker Compose
If you are using Docker Compose to install WhiteSpots and are deploying the portal and auditor on the same device, you need to make the following changes:
- In the `docker-compose.yml` files of the portal and auditor, you need to add the following for each container:
```
extra_hosts:
- "host.docker.internal:host-gateway"
```
- In the portal settings, specify the auditor address: `http://host.docker.internal:8080/` and the external portal address: `http://host.docker.internal/`
All other steps are performed as specified in the documentation.

## Result
- The auditor is linked to the AppSec portal.
- When an audit is run, the found vulnerabilities are displayed in Findings.
- After verification, vulnerabilities are displayed on the Dashboard and highlighted in the IDE.
- Notifications are sent to Telegram (for example, about a change in the status of a vulnerability).
