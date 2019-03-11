# Nagios setup for Liferay DXP

## Table of Contents
- [Introduction](#introduction)
- [Using Dockerfile](#using-dockerfile)
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

## Using Dockerfile

You can check this basic Nagios/Icinga setup using Docker in Ubuntu 14.04 LTS. It includes a template for using it in Liferay via check_jmx. You need to enable JMX in Liferay Portal.

0. Clone this project
```
$ git clone https://github.com/zylklab/liferay-nagios
$ cd liferay-nagios
```

1. Configure environment variables in Dockerfile according to your services to monitor.

```
##
## Icinga Config
##
ENV ICINGA_CONFIG /etc/icinga/objects
ENV ICINGA_PLUGIN /usr/lib/nagios/plugins
ENV ICINGA_ADMIN admin

```

2. Run docker commands

```
$ sudo docker build -t zylklab/icingadxp .
$ sudo docker run -i -t zylklab/icingadxp
```

3. Login http://docker-server-ip/icinga (by default http://172.17.0.2/icinga) with icingaadmin/admin credentials.

Note: Take into consideration that email alerts are not configured. You should configure postfix and Icinga/Nagios contacts.

## Tested on

- Liferay DXP
- Nagios/Icinga 3
- PNP4Nagios 0.6.0
- Docker version 1.12.6
- Ubuntu 14.04 LTS

## Contributors

- [Cesar Capillas](http://github.com/CesarCapillas)
- [Mikel Asla](https://github.com/mikelasla)

## Links

- [Alfresco Nagios Docker Template](https://raw.githubusercontent.com/zylklab/alfresco-nagios)
