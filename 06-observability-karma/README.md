# Case #6 – Observability & Karma

<div align="center">

  ![Result diagram dark](img/06-observability-karma-dark.png#gh-dark-mode-only)

</div>

<div align="center">

  ![Result diagram light](img/06-observability-karma-light.png#gh-light-mode-only)

</div>

- [Case #6 – Observability \& Karma](#case-6--observability--karma)
  - [Goal](#goal)
  - [Stack](#stack)
  - [Checkpoints](#checkpoints)
  - [Result](#result)
  - [Contacts](#contacts)

## Goal

When setting up observability, the familiar outdated Alertmanager interface can be replaced with a more modern alternative to improve the visual perception of the service.

## Stack

![VictoriaMetrics](https://img.shields.io/badge/victoriametrics-621773.svg?style=for-the-badge&logo=victoriametrics&logoColor=white)
![Grafana](https://img.shields.io/badge/Grafana-F46800.svg?style=for-the-badge&logo=grafana&logoColor=white)
![Alertmanager](https://img.shields.io/badge/Alertmanager-E6522C.svg?style=for-the-badge&logo=prometheus&logoColor=white)
![Karma](https://img.shields.io/badge/Karma-88F387.svg?style=for-the-badge&logo=keras&logoColor=white)

## Checkpoints

1. Launch VictoriaMetrics:
   - For a quick skill check, we recommend the [Single-node version](https://docs.victoriametrics.com/victoriametrics/single-server-victoriametrics/).
   - A slightly more refined setup is needed for the [Cluster version](https://docs.victoriametrics.com/victoriametrics/cluster-victoriametrics/).
     - As additional reading, we recommend an interesting [article](https://victoriametrics.com/blog/dont-default-to-microservices-you-will-thank-us-later/) on why it is often better to use a single-node solution instead of a cluster.
   - If installing in Kubernetes, you can use the [`victoria-metrics-k8s-stack` chart](https://docs.victoriametrics.com/helm/victoria-metrics-k8s-stack/), which allows you to complete tasks 2-5 right away.
   - If working on virtual machines, the official [Ansible playbooks](https://github.com/VictoriaMetrics/ansible-playbooks) may be helpful.
2. Launch Grafana:
   - If you did not use the `victoria-metrics-k8s-stack`, you can install Grafana into the cluster [manually](https://grafana.com/docs/grafana/latest/setup-grafana/installation/kubernetes/) or via [Helm](https://grafana.com/docs/grafana/latest/setup-grafana/installation/helm/).
   - When working on virtual machines, follow installation guides for [Debian](https://grafana.com/docs/grafana/latest/setup-grafana/installation/debian/) or [RHEL](https://grafana.com/docs/grafana/latest/setup-grafana/installation/redhat-rhel-fedora/) distributions.
   - Configure Victoria Metrics as a [datasource](https://grafana.com/docs/grafana/latest/datasources/prometheus/) of type `prometheus` in Grafana.
3. Launch Alertmanager:
   - If you did not use the `victoria-metrics-k8s-stack`, use community Prometheus charts for installation in Kubernetes [here](https://prometheus-community.github.io/helm-charts/).
   - You can also refer to the [installation recommendations](https://github.com/prometheus/alertmanager) from the authors.
4. Install Node Exporter:
   - If you did not use the `victoria-metrics-k8s-stack`, use community Prometheus charts for Kubernetes installation [here](https://prometheus-community.github.io/helm-charts/).
   - For Linux installation, refer to the official [documentation](https://prometheus.io/docs/guides/node-exporter/).
   - Ensure you have a dashboard in Grafana to view Node Exporter metrics. If not, use the [dashboard search](https://grafana.com/grafana/dashboards/) and import one.
   - Ensure vmagent is configured to collect metrics from Node Exporter.
5. Configure some basic alerting rules:
   - Most likely, if you installed Victoria Metrics using one of the manuals, you will already have preconfigured rules.
   - For inspiration, you can use sources like:
     - [Alert and route testing for Alertmanager](https://prometheus.io/webtools/alerting/routing-tree-editor/).
     - A huge [list](https://samber.github.io/awesome-prometheus-alerts/rules) of alerts covering many domains.
     - [The same](https://github.com/monitoring-mixins/website/tree/master/assets) as the previous, but with more examples.
   - Alerting in Victoria Metrics is handled by the vmalert component, which should be configured to send alerts to Alertmanager.
   - We suggest setting up notifications to a Telegram channel or supergroup. An example of receiver configuration and template can be found [here](https://gist.github.com/sanchpet/7641275a42243d3667b3146c5402be40).
6. Launch [Karma](https://github.com/prymitive/karma):
   - The repository instructions suggest installation using Docker.
   - For Kubernetes installation, you can use the most current [chart](https://artifacthub.io/packages/helm/wiremind/karma). At the time of writing, Karma does not have an official chart in its own repository, so use [Artifacthub](https://artifacthub.io/packages/search?ts_query_web=karma&sort=relevance&page=1) to find the latest community chart.
7. Connect Karma and Alertmanager:
   - Update the `ALERTMANAGER_URI` according to the recommendations in the repository.
   - For the Helm chart, you will also need to update `ALERTMANAGER_URI` in the values. If installed via `victoria-metrics-k8s-stack`, configure something like:

   ```yaml
   env:
    - name: ALERTMANAGER_URI
      value: http://vmalertmanager-victoria-metrics-k8s-stack:9093
   ```

8. Configure alert muting in Karma:
   - Karma allows configuring [ACLs](https://github.com/prymitive/karma/blob/main/docs/ACLs.md) that control user-created mutes. With these, you can ensure that `Team A` does not accidentally mute alerts for `Team B`, or you can restrict mute creation rights only to the SRE team.

## Result

The running Node Exporter provides machine status data. The data is collected by vmagent to Victoria Metrics and visualized as graphs in Grafana. Alertmanager receives alerts from vmalert and forwards them to Telegram. In Karma, you can see which alerts are currently active and mute notifications for a certain time.

## Contacts

Need help? Write in [our Telegram chat](https://t.me/+nSELCyIX8ltlNjU6)
