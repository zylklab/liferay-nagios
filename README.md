# Nagios setup for Liferay DXP

## Table of Contents
- [Introduction](#introduction)
- [Using Docker](#using-docker)
- [Tested on](#tested-on)
- [Author](#author)
- [Links](#links)

## Introduction

A well known example for JMX monitoring via JMX is available [here](https://github.com/toniblyx/alfresco-nagios-and-icinga-plugin). General direct monitoring commands (not JMX-based) may be used for Community Edition (CE) too.

The files involved in Nagios/Icinga configuration for Alfresco Community are the following:

- objects/hosts-liferay.cfg (Alfresco hosts definition)
- objects/commands-liferay.cfg (Nagios commands)
- objects/services-liferay.cfg (Non NRPE services)
- objects/commands-elk.cfg (Nagios commands for ELK)
- objects/services-elk.cfg (Non NRPE services for ELK)

For using this setup you need some dependencies like curl, jq, jshon in your Nagios Server.

## Using Docker

You can check this basic Nagios/Icinga setup using Docker in Ubuntu 14.04 LTS. It includes a template for using it in Liferay via check_jmx. You need to enable JMX in Liferay Portal.

0. Clone this project
```
$ git clone https://github.com/zylklab/liferay-nagios
$ cd liferay-nagios
```

1. Configure environment variables in docker-compose.yml file according to your services to monitor. Yo can even use a `.env` file for your sensitive passwords


```
...
    environment:
      - LF_HOST=tomcat.zylk.net
      - JMX_USER=${JMX_USER}
      - JMX_PASS=${JMX_PASS}
      - JXM_PORT=6666
      - ELK_HOST=tomcat.zylk.net
      - ELK_PORT=9200
    extra_hosts:
      - "tomcat.zylk.net:192.168.1.100"
```

2. Run docker compose to start the application

```
$ docker-compose up

```

3. Login on `http://<containet-ip>:<container-port>/icinga` (by default http://localhost:8888/icinga) with `icingaadmin/admin` credentials.

Note: Take into consideration that email alerts are not configured. You should configure postfix and Icinga/Nagios contacts.

## Tested on

- Liferay DXP
- Nagios/Icinga 3
- PNP4Nagios 0.6.0
- Ubuntu 14.04 LTS
- Docker version 1.18.09.1, build 4c52b90
- Docker compose version 1.21.0

## Contributors

- [Cesar Capillas](http://github.com/CesarCapillas)
- [Mikel Asla](https://github.com/mikelasla)

## Links

- [Alfresco Nagios Docker Template](https://raw.githubusercontent.com/zylklab/alfresco-nagios)
