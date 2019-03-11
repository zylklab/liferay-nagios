##
## Dockerfile
## 
##  for Icinga / Nagios for Liferay DXP 
##
##   by Cesar Capillas
##
##  To run this Dockerfile:
##
##   git clone https://github.com/zylklab/liferay-nagios
##   cd liferay-nagios
##   sudo docker build -t zylklab/icingadxp .
##   sudo docker run -i -t zylklab/icingadxp --name icingadxp 
##
##   sudo docker [stop|start|rm] icingadxp
##

FROM ubuntu:14.04 
MAINTAINER cesar at zylk.net

##
## Icinga Config
##
ENV ICINGA_CONFIG /etc/icinga/objects
ENV ICINGA_PLUGIN /usr/lib/nagios/plugins
ENV ICINGA_ADMIN admin 

##
## Liferay DXP Template
##
ENV LF_HOST dxp.zylk.net 
ENV LF_ADDR 192.168.0.19 
ENV JMX_USER monitorRole
ENV JMX_PASS changeasap 
ENV JMX_PORT 6666 

##
## ELK 
## 
ENV ELK_HOST elk.zylk.net 
ENV ELK_ADDR 192.168.0.19
ENV ELK_PORT 9200 

##
## Ubuntu Packages
##
RUN echo "debconf debconf/frontend select Noninteractive" | debconf-set-selections
RUN echo "postfix postfix/mailname string localhost" | debconf-set-selections
RUN echo "postfix postfix/main_mailer_type string 'Internet Site'" | debconf-set-selections
RUN echo "icinga-common icinga/check_external_commands select true" | debconf-set-selections
RUN echo "icinga-cgi icinga/adminpassword string $ICINGA_ADMIN" | debconf-set-selections
RUN echo "icinga-cgi icinga/adminpassword-repeat string $ICINGA_ADMIN" | debconf-set-selections
RUN apt-get update && apt-get install -y postfix icinga vim jshon jq wget curl openjdk-7-jre pnp4nagios

##
## Icinga config
##
RUN sed -i "s/check_external_commands=0/check_external_commands=1/" /etc/icinga/icinga.cfg 
RUN dpkg-statoverride --update --add nagios www-data 2710 /var/lib/icinga/rw/
RUN dpkg-statoverride --update --add nagios nagios 751 /var/lib/icinga/

##
## PNP4Nagios
##
RUN sed -i "s#/cgi-bin/nagios3#/icinga/cgi-bin#" /etc/pnp4nagios/config.php
RUN sed -i "s/process_performance_data=0/process_performance_data=1/" /etc/icinga/icinga.cfg
RUN echo "broker_module=/usr/lib/pnp4nagios/npcdmod.o config_file=/etc/pnp4nagios/npcd.cfg" >> /etc/icinga/icinga.cfg
RUN sed -i 's/RUN="no"/RUN="yes"/' /etc/default/npcd
RUN sed -i "s/nagios3/icinga/" /etc/pnp4nagios/apache.conf 

ADD pnp/generic-host_icinga.cfg $ICINGA_CONFIG/generic-host_icinga.cfg  
ADD pnp/generic-service_icinga.cfg $ICINGA_CONFIG/generic-service_icinga.cfg  

RUN echo "Include /etc/pnp4nagios/apache.conf" >> /etc/icinga/apache2.conf
RUN mv /usr/share/pnp4nagios/html/install.php /usr/share/pnp4nagios/html/install.php.orig
RUN cp /usr/share/doc/pnp4nagios/examples/ssi/status-header.ssi /usr/share/icinga/htdocs/ssi/
RUN ln -s /etc/apache2/mods-available/rewrite.load /etc/apache2/mods-enabled/rewrite.load
RUN cp /usr/share/icinga/htdocs/images/action.gif /usr/share/icinga/htdocs/images/action.gif.orig
RUN cp /usr/share/icinga/htdocs/images/stats.gif /usr/share/icinga/htdocs/images/action.gif

##
## Liferay Icinga/Nagios configuration
##
ADD objects/hosts-liferay.cfg $ICINGA_CONFIG/hosts-liferay.cfg
ADD objects/services-liferay.cfg $ICINGA_CONFIG/services-liferay.cfg
ADD objects/commands-liferay.cfg $ICINGA_CONFIG/commands-liferay.cfg
ADD objects/services-elk.cfg $ICINGA_CONFIG/services-elk.cfg
ADD objects/commands-elk.cfg $ICINGA_CONFIG/commands-elk.cfg
ADD jmx/check_jmx $ICINGA_PLUGIN/check_jmx
ADD jmx/check_jmx.jar $ICINGA_PLUGIN/check_jmx.jar
ADD scripts/check_elasticsearch.sh $ICINGA_PLUGIN/check_elasticsearch.sh 
ADD images/liferay.gif /usr/share/nagios/htdocs/images/logos/base/liferay.gif
ADD images/liferay.png /usr/share/nagios/htdocs/images/logos/base/liferay.png
ADD images/elk.gif /usr/share/nagios/htdocs/images/logos/base/elk.gif
ADD images/elk.png /usr/share/nagios/htdocs/images/logos/base/elk.png

# Apply template
RUN chmod +x $ICINGA_PLUGIN/check_jmx*
RUN sed -i "s/dxp.melmac.net/$LF_HOST/" $ICINGA_CONFIG/hosts-liferay.cfg 
RUN sed -i "s/elk.melmac.net/$ELK_HOST/" $ICINGA_CONFIG/hosts-liferay.cfg 
RUN sed -i "s/zylk!secret/$JMX_USER!$JMX_PASS/" $ICINGA_CONFIG/services-liferay.cfg 
RUN sed -i "s/elk.melmac.net!9200/$ELK_HOST!$ELK_PORT/" $ICINGA_CONFIG/services-elk.cfg 
 
WORKDIR $ICINGA_PLUGIN 

EXPOSE 80
ENTRYPOINT service apache2 restart && service npcd restart && service icinga restart && echo "$LF_ADDR $LF_HOST" >> /etc/hosts && echo "$ELK_ADDR $ELK_HOST" >> /etc/hosts && bash
