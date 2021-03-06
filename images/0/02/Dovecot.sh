#!/bin/sh
#
# Munin Plugin
# to count logins to your dovecot mailserver
# 
# Created by Dominik Schulz <lkml@ds.gauner.org>
# http://developer.gauner.org/munin/
# Contributions by:
# - Stephane Enten <tuf@delyth.net>
# Modified by Fabián Sellés Rosa <fabian.sellesrosa@alum.uca.es>
# and Arturo Blanco Paramio <mad@madito.es>
#Adapted to OpenBSD: Polyp
# cleaned up and adapted for dovecot 1.2.6 for Ubuntu 10.4
# Parameters understood:
#
#	config		(required)
#	autoconf 	(optional - used by munin-config)
# 
# Config variables:
#
#       logfile      - Where to find the syslog file
#
# Add the following line to a file in /etc/munin/plugin-conf.d:
# 	env.logfile /var/log/your/logfile.log
#
# Magic markers (optional - used by munin-config and installation scripts):
#
#%# family=auto
#%# capabilities=autoconf

######################
# Configuration
######################
##STAT_FILE=${statefile:-/var/lib/munin/plugin-state/plugin-dovecot.state}
STAT_FILE=${statefile:-/var/run/munin/plugin-dovecot.state}
EXPR_BIN=/usr/bin/expr
##LOGFILE=${logfile:-/var/log/dovecot-info.log}
LOGFILE=${logfile:-/var/log/maillog}
######################

if [ "$1" = "autoconf" ]; then
	echo yes
	exit 0
fi

if [ "$1" = "config" ]; then
	echo 'graph_title Logins  Dovecot'
	echo 'graph_args --base 1000 -l 0'
	echo 'graph_vlabel Nombre de Login'
	echo 'graph_total total'
	echo 'graph_category Courrier'

	echo 'login_total.label Total Logins'
	echo 'login_total.min 1'

	echo 'login_tls.label TLS Logins'
	echo 'login_tls.min 1'
	echo 'login_ssl.label SSL Logins'
	echo 'login_ssl.label SSL Logins'
	echo 'login_imap.label IMAP Logins'
	echo 'login_pop3.label POP3 Logins'
	echo 'connected.label Connected Users'
	exit 0
fi

#############################
# Initialization
#############################
if [ ! -r $STAT_FILE ]; then
	echo "TOTAL=0" > $STAT_FILE
	echo "TLS=0" >> $STAT_FILE
	echo "SSL=0" >> $STAT_FILE
	echo "IMAP=0" >> $STAT_FILE
	echo "POP3=0" >> $STAT_FILE
fi
#############################


######################
# Total Logins
######################

##NEW_TOTAL=$(egrep '*Login' $LOGFILE | grep "`date '+%Y-%m-%d'`" | sort | wc -l)
##NEW_TOTAL=$(egrep 'Login' $LOGFILE | grep "`date '+%Y-%m-%d'`" | sort | wc -l)
NEW_TOTAL=$(egrep 'Login' $LOGFILE | grep "`date '+%h %d'`" | sort | wc -l)
OLD_TOTAL=$(grep TOTAL $STAT_FILE | cut -f2 -d '=')
TOTAL=$(($NEW_TOTAL - $OLD_TOTAL))
LOGINVALUE=0
if [ $TOTAL -gt 0 ]; then
	LOGINVALUE=$TOTAL
fi

######################
# Connected Users
######################
##DISCONNECTS=$(egrep '*Disconnected' $LOGFILE | sort | wc -l)
DISCONNECTS=$(egrep 'Disconnected' $LOGFILE | sort | wc -l)
##CONNECTS=$(egrep '.*Login' $LOGFILE | sort | wc -l)
CONNECTS=$(egrep '.Login' $LOGFILE | sort | wc -l)
DISCON=$(($CONNECTS - $DISCONNECTS))
if [ $DISCON -lt 0 ]; then
	DISCON=0
fi

######################
# TLS Logins
######################

##NEW_TLS=$(egrep '.*Login.*TLS' $LOGFILE | grep "`date '+%Y-%m-%d'`" | sort | wc -l)
NEW_TLS=$(egrep '.*Login.*TLS' $LOGFILE | grep "`date '+%h %d'`" | sort | wc -l)
OLD_TLS=$(grep TLS $STAT_FILE | cut -f2 -d '=')
TLS=$(($NEW_TLS - $OLD_TLS))
TLSVALUE=0
if [ $TLS -gt 0 ]; then
	TLSVALUE=$TLS
fi
echo -n
######################
# SSL Logins
######################

##NEW_SSL=$(egrep '.*Login.*SSL' $LOGFILE | grep "`date '+%Y-%m-%d'`" | sort | wc -l)
NEW_SSL=$(egrep '.*Login.*SSL' $LOGFILE | grep "`date '+%h %d'`" | sort | wc -l)
OLD_SSL=$(grep SSL $STAT_FILE | cut -f2 -d '=')
SSL=$(($NEW_SSL - $OLD_SSL))
SSLVALUE=0
if [ $SSL -gt 0 ]; then
	SSLVALUE=$SSL
fi

######################
# IMAP Logins
######################

#NEW_IMAP=$(egrep '.*imap.*Login' $LOGFILE | grep "`date '+%Y-%m-%d'`" | sort | wc -l)
NEW_IMAP=$(egrep '.*imap.*Login' $LOGFILE | grep "`date '+%h %d'`" | sort | wc -l)
OLD_IMAP=$(grep IMAP $STAT_FILE | cut -f2 -d '=')
IMAP=$(($NEW_IMAP - $OLD_IMAP))
IMAPVALUE=0
if [ $IMAP -gt 0 ]; then
	IMAPVALUE=$IMAP
fi

######################
# POP3 Logins
######################

#NEW_POP3=$(egrep '.*pop3.*Login' $LOGFILE | grep "`date '+%Y-%m-%d'`" | sort | wc -l)
NEW_POP3=$(egrep '.*pop3.*Login' $LOGFILE | grep "`date '+%h %d'`" | sort | wc -l)
OLD_POP3=$(grep POP3 $STAT_FILE | cut -f2 -d '=')
POP3=$(($NEW_POP3 - $OLD_POP3))
POP3VALUE=0
if [ $POP3 -gt 0 ]; then
	POP3VALUE=$POP3
fi


#######################
# echo the new values
######################

echo "login_total.value $LOGINVALUE"
echo "connected.value $DISCON"
echo "login_tls.value $TLSVALUE"
echo "login_ssl.value $SSLVALUE "
echo "login_imap.value $IMAPVALUE"
echo "login_pop3.value $POP3VALUE "



######################
# Save the new values
######################
echo "TOTAL=$NEW_TOTAL" > $STAT_FILE
echo "TLS=$NEW_TLS" >> $STAT_FILE
echo "SSL=$NEW_SSL" >> $STAT_FILE 
echo "IMAP=$NEW_IMAP" >> $STAT_FILE
echo "POP3=$NEW_POP3" >> $STAT_FILE

