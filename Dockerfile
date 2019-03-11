##
## Dockerfile
## 
##  Icinga / Nagios for Liferay DXP (CC/CE)
##
##   by Cesar Capillas
##

FROM ubuntu:14.04 
LABEL maintainer="cesar at zylk.net"
LABEL collaborator="mikel.asla at zylk.net"

##
## Icinga Config
##
ENV ICINGA_CONFIG="/etc/icinga/objects" ICINGA_PLUGIN="/usr/lib/nagios/plugins" ICINGA_ADMIN="admin"

##
## Liferay DXP Template
##
ENV LF_HOST="dxp.zylk.net" LF_ADDR="localhost" JMX_USER="monitorRole" JMX_PASS="changeasap" JMX_PORT="6666"

##
## ELK 
## 
ENV ELK_HOST="elk.zylk.net" ELK_ADDR="localhost" ELK_PORT="9200"

##
## Ubuntu Packages
##
RUN set -x \
	&& echo "debconf debconf/frontend select Noninteractive" | debconf-set-selections \
    && echo "postfix postfix/mailname string localhost" | debconf-set-selections \
	&& echo "postfix postfix/main_mailer_type string 'Internet Site'" | debconf-set-selections \
	&& echo "icinga-common icinga/check_external_commands select true" | debconf-set-selections \
	&& echo "icinga-cgi icinga/adminpassword string $ICINGA_ADMIN" | debconf-set-selections \
	&& echo "icinga-cgi icinga/adminpassword-repeat string $ICINGA_ADMIN" | debconf-set-selections \
	&& apt-get update \
	&& apt-get install -y postfix icinga vim jshon jq wget curl openjdk-7-jre pnp4nagios \
	&& sed -i "s/check_external_commands=0/check_external_commands=1/" /etc/icinga/icinga.cfg \
	&& dpkg-statoverride --update --add nagios www-data 2710 /var/lib/icinga/rw/ \
	&& dpkg-statoverride --update --add nagios nagios 751 /var/lib/icinga/ \
	&& sed -i "s#/cgi-bin/nagios3#/icinga/cgi-bin#" /etc/pnp4nagios/config.php \
	&& sed -i "s/process_performance_data=0/process_performance_data=1/" /etc/icinga/icinga.cfg \
	&& echo "broker_module=/usr/lib/pnp4nagios/npcdmod.o config_file=/etc/pnp4nagios/npcd.cfg" >> /etc/icinga/icinga.cfg \
	&& sed -i 's/RUN="no"/RUN="yes"/' /etc/default/npcd \
	&& sed -i "s/nagios3/icinga/" /etc/pnp4nagios/apache.conf \
	&& echo "Include /etc/pnp4nagios/apache.conf" >> /etc/icinga/apache2.conf \
	&& mv /usr/share/pnp4nagios/html/install.php /usr/share/pnp4nagios/html/install.php.orig \
	&& cp /usr/share/doc/pnp4nagios/examples/ssi/status-header.ssi /usr/share/icinga/htdocs/ssi/ \
	&& ln -s /etc/apache2/mods-available/rewrite.load /etc/apache2/mods-enabled/rewrite.load \
	&& cp /usr/share/icinga/htdocs/images/action.gif /usr/share/icinga/htdocs/images/action.gif.orig \
	&& cp /usr/share/icinga/htdocs/images/stats.gif /usr/share/icinga/htdocs/images/action.gif

##
## Liferay Icinga/Nagios configuration
##
ADD pnp/generic-host_icinga.cfg $ICINGA_CONFIG/generic-host_icinga.cfg  
ADD pnp/generic-service_icinga.cfg $ICINGA_CONFIG/generic-service_icinga.cfg  
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
ADD entrypoint.sh /entrypoint.sh

# Apply template
RUN set -x \
	&& chmod +x $ICINGA_PLUGIN/check_jmx* \
	&& chmod +x /entrypoint.sh

EXPOSE 80
ENTRYPOINT ["/entrypoint.sh", "run"]