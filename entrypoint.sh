#!/bin/bash
set -e

if [ "$1" == "run" ]
then
 	sed -i "s/dxp.melmac.net/$LF_HOST/" $ICINGA_CONFIG/hosts-liferay.cfg 
 	sed -i "s/elk.melmac.net/$ELK_HOST/" $ICINGA_CONFIG/hosts-liferay.cfg 
 	sed -i "s/zylk!secret/$JMX_USER!$JMX_PASS/" $ICINGA_CONFIG/services-liferay.cfg 
 	sed -i "s/elk.melmac.net!9200/$ELK_HOST!$ELK_PORT/" $ICINGA_CONFIG/services-elk.cfg 


	chmod +x $ICINGA_PLUGIN/check_jmx* 

	service npcd start
	service icinga start
	/usr/sbin/apache2ctl -D FOREGROUND
else
	exec "$@"
fi