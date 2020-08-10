# iDev-FSD external NOC

<!-- TOC titleSize:2 tabSpaces:2 depthFrom:1 depthTo:6 withLinks:1 updateOnSave:1 orderedList:0 skip:1 title:1 charForUnorderedList:* -->
## Table of Contents
* [About](#about)
* [Pre-requisites](#pre-requisites)
  * [Installation](#installation)
  * [Keybase](#keybase)
* [Deployment](#deployment)
* [Project's bricks](#projects-bricks)
* [Usage](#usage)
* [Links](#links)
<!-- /TOC -->

# About

This project aims to set up a Network Operations Center (so called
[NOC](https://en.wikipedia.org/wiki/Network_operations_center)) providing an
external monitoring for our School. In short, it will set up
[Prometheus](https://prometheus.io/docs/introduction/overview/), [Prometheus
Pushgateway](https://prometheus.io/docs/practices/pushing/), [Prometheus
Blackbox exporter](https://github.com/prometheus/blackbox_exporter), [Prometheus
Alertmanager](https://prometheus.io/docs/alerting/alertmanager/), [Prometheus
Node Exporter](https://github.com/prometheus/node_exporter) and
[Grafana](https://prometheus.io/docs/visualization/grafana/) on a server, using
docker containers and deployed with [Ansible](https://www.ansible.com). On top
of that, [Traefik](https://traefik.io/) reverse proxy / load balancer handle the
HTTP requests.

# Pre-requisites

We assume that the NOC will be deployed on a Ubuntu server, on which you can
access with your SSH key with the root rights. Ansible is needed on the machine
you are using to deploy. As the secret are hidden using `eyaml`, you will also
need it on your machine.

## Installation

Ansible and modules installation are described in the [INSTALL.md](./INSTALL.md)
file.

## Keybase

The secrets in this project are handled with eyaml, and the decryption key is on
keybase. You'll need the keybase drive to be mounted with access to the
`/keybase/team/epfl_ressenti/private_key.pkcs7.pem` relevant private key.

# Deployment

In our case, the deployment in done on a virtual machine hosted on a OpenStack
setup by [SWITCHEngines](https://www.switch.ch/engines/). Thus, some of the
explanations might be related to that, more particularly the access rules which
depends on [OpenStack Neutron Security
Groups](https://wiki.openstack.org/wiki/Neutron/SecurityGroups).

# Project's bricks

Each bricks of the project is meant to be self-contained. It should be possible
to deploy each brick individually, either using ansible tags or docker-compose
commands — we're still not there when these lines are typed. The glue between
the bricks is the **noc** folder which contains the project's
[docker-compose.yml](./ansible/noc/templates/docker-compose.yml) file and the
deployed [Makefile](./ansible/noc/templates/Makefile).

# Usage

0. On his machine verify Keybase:
```
ls /keybase/team
```

1. On his machine, Deploy the jam to the server :  
```
cd external-noc
git pull
cd ansible/
```
For the ***prod*** machine:
```
make prod arg='ansible arguments'
```
For the ***test*** machine:
```
make dev arg='ansible arguments'
```
Example:
```
make dev arg='-t pushgateway_copy'
```


2. On the server, go to the **/srv/noc** directory :
```
cd /srv/noc
```

3. Use the *Makefile* to spawn the containers:  
```
make up
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
