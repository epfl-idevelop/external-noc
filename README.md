# iDev-FSD external NOC

# About

## Setup notes
This project aim to finalize some [previous
attempts](https://en.wikipedia.org/wiki/Network_operations_center) to set up a
Network Operations Center (so called
[NOC](https://en.wikipedia.org/wiki/Network_operations_center)) providing an
external monitoring for our School. In short, it will set up
[Prometheus](https://prometheus.io/docs/introduction/overview/), [Prometheus
Pushgateway](https://prometheus.io/docs/practices/pushing/), [Prometheus
Blackbox exporter](https://github.com/prometheus/blackbox_exporter), [Prometheus
Alertmanager](https://prometheus.io/docs/alerting/alertmanager/) and
[Grafana](https://prometheus.io/docs/visualization/grafana/) from a single
`docker-compose.yml` file.

This repository is organized with the [`docker-compose.yml`](docker-compose.yml)
a the top and all "docker bricks" under the respective directories. While I
tried to stick as much as possible with the default original docker images of
each project, some configuration was needed. I've tried to keep things resistant
to normal docker cycles and easily backupable if needed. Furthermore, the
[`.env`](sample.env) file should highlight the configurable options of the setup
([see this guide on docker arg/env
variable](https://vsupalov.com/docker-arg-env-variable-guide/)).

## Deployment
The deployment of this project in done on a virtual machine hosted on a
OpenStack setup by [SWITCHengines](https://www.switch.ch/engines/). Thus, some
of the explanations might be related to that, more particularly the access rules
which depends on [OpenStack Neutron Security
Groups](https://wiki.openstack.org/wiki/Neutron/SecurityGroups).

# New instance
As it stands, this need a few manual actions to deploy this setup on a new
place:
  1. Copy of the [`sample.env`](sample.env) to a `.env` file, and configuration
     of the project's variables;
  1. Get new secrets for the GitHub authentication (`GF_AUTH_GITHUB_CLIENT_ID`
     and `GF_AUTH_GITHUB_CLIENT_SECRET`) variables from
     [GitHUb](https://github.com): https://github.com > Organization >
     Settings > Developer settings > OAuth Apps. Be sure to set app's "Homepage
     URL" and "Authorization callback URL" as defined in the
     [Grafana's GitHub OAuth2 Authentication page](http://docs.grafana.org/auth/github/#configure-github-oauth-application);
  1. Use [Let's encrypt certbot](https://certbot.eff.org/) to get a certificate
     for the Grafana's frontend;
  1. You may want to tune some target URLs in the
     [`prometheus/prometheus.yml`](prometheus/prometheus.yml) file.

After that, the `docker-compose up` command might pop the stuff up for you.

## .env
This file will be sourced by docker-compose and will serve environment variables
in the container. While it would not be necessary to explicitly named the
variables in the [`docker-compose.yml`](docker-compose.yml) file, it surely is
more exhaustive and readable that way.

Regarding the Grafana's variables, here again they can completely set the
content of the [`./grafana/conf/grafana.ini`](./grafana/conf/grafana.ini) file.
Still, the `grafana.ini` file has been kept for comfort and comprehension
purpose.

## Auth
The authentication setup is straight forward if you replace the variables. You
can specify access to an entire organization or add the teams ids, to limit the
access scope. The mechanism won't work without the
`GF_AUTH_GITHUB_ALLOW_SIGN_UP` set to true unless the users already exist in
Grafana. Last but not least, newly created user will be granted the "Viewer"
right which can be set to "Editor" or "Admin" visiting your instance
`/org/users`.

## Certificate
Using [Let's encrypt certbot](https://certbot.eff.org/) to get a certificate is
damn easy:
  1. On your server, install the [certbot](https://certbot.eff.org/) package,
     e.g. `# apt install certbot`;
  1. One can not get a cetificate without a domaine name (i.e. with only an IP),
     you can use `dig +short ptr -x [[YOUR IP]]` to get the correct name;
  1. Run the following certbot command:  
     `# certbot certonly --standalone --preferred-challenges http --renew-by-default -d instance.cloud.example.com`
  1. certbot will generate certificates in the
     `/etc/letsencrypt/live/instance.cloud.example.com/` directory;
  1. Last step is to copy newly generated `fullchain.pem` and `privkey.pem`
     files to the grafana ssl's directory (mounted as follow in docker):
     * `./grafana/ssl/fullchain.pem:/var/ssl/server.crt`
     * `./grafana/ssl/privkey.pem:/var/ssl/server.key`

## Prometheus & Blackbox exporter
Prometheus configuration stands in the
[`prometheus/prometheus.yml`](prometheus/prometheus.yml) file. The Blackbox
exporter is used to probe some URLs which are defined in the config file. You
may need to understand how the [Blackbox exporter
modules](https://github.com/prometheus/blackbox_exporter/blob/master/CONFIGURATION.md#module),
defined in
[`blackbox-exporter/config/blackbox.yml`](blackbox-exporter/config/blackbox.yml)
work in order to define new
[scrape_config](https://prometheus.io/docs/prometheus/latest/configuration/configuration/#scrape_config)
for Prometheus. The Blackbox exporter allow probing of endpoints over HTTP,
HTTPS, DNS, TCP and ICMP.

## Export for C2C
C2C will pull all metrics starting with `vpsi_wwp_federation:` that are recorded
in a dedicated rule file `rules/c2c_federate.yml`. The command used by C2C to fetch the metrics looks like the followint:
```
curl --globoff -u USERNAME:PASSWORD 'http://prometheus-86-119-37-70.nip.io/federate?match[]={__name__=~%22^vpsi_wwp_federation:.*%22}'
```

A recording rule will looks like the following example:
```
   - record: vpsi_wwp_federation:probe_duration_seconds
     expr: probe_duration_seconds{c2c='yes'}
```
Since we will have multiple *probe_duration_seconds* metrics, we filter with an *ad-hoc*
label (`c2c='yes'`) so we don't send to C2C all our metrics.
The label is sticked to the metric in two ways:
 1. it is added to all targets of a given job as a *target_label* in the *relabel_configs* section:

    ```
    relabel_configs:
      - source_labels: [__address__]
        target_label: __param_target
      - source_labels: [__param_target]
        target_label: instance
      - target_label: c2c                       <- look
        replacement: yes                        <- here
      - target_label: __address__
        replacement: prob.86.119.40.68.nip.io
    ```
 2. or it is a label assigned on a per-taraget base in the list of targets:
    ```
    - job_name: 'ressenti_test2'
      metrics_path: /ressentiprobe
      params:
        module: [ressenti_firefox]
      static_configs:
        - targets:
          - https://www.epfl.ch
          - https://memento.epfl.ch
          labels:
            c2c: 'yes'
        - targets:        
          - https://go.epfl.ch
          labels:
            c2c: 'no'
    ```

# Links
  * [Prometheus](https://prometheus.io/docs/introduction/overview/)
    * [Grafana](https://prometheus.io/docs/visualization/grafana/)
    * [Alertmanager](https://prometheus.io/docs/alerting/alertmanager/)
    * [Blackbox exporter](https://github.com/prometheus/blackbox_exporter)
    * [Pushgateway](https://prometheus.io/docs/practices/pushing/)
    * [node_exporter](https://github.com/prometheus/node_exporter) 
  * [Grafana](https://grafana.com/)
    * [Configuration](http://docs.grafana.org/installation/configuration/)
    * [Docker](http://docs.grafana.org/installation/docker/)
    * [Auth GitHub](http://docs.grafana.org/auth/github/)
    * [Provisionning DataSource](http://docs.grafana.org/administration/provisioning/#example-datasource-config-file)
