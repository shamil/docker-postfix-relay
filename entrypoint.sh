#!/usr/bin/env sh
set -e # exit on error

# Variables
[ -z "$SMTP_LOGIN" -o -z "$SMTP_PASSWORD" ] && {
	echo "SMTP_LOGIN and SMTP_PASSWORD _must_ be defined" >&2
	exit 1
}

export SMTP_LOGIN SMTP_PASSWORD
export EXT_RELAY_HOST=${EXT_RELAY_HOST:-"email-smtp.us-east-1.amazonaws.com"}
export EXT_RELAY_PORT=${EXT_RELAY_PORT:-"25"}
export RELAY_HOST_NAME=${RELAY_HOST_NAME:-"$HOSTNAME"}
export ACCEPTED_NETWORKS=${ACCEPTED_NETWORKS:-"192.168.0.0/16 172.16.0.0/12 10.0.0.0/8"}
export USE_TLS=${USE_TLS:-"no"}
export TLS_VERIFY=${TLS_VERIFY:-"may"}

# Template
export DOLLAR='$'
envsubst < /root/conf/postfix-main.cf > /etc/postfix/main.cf

# Launch
rm -f /var/spool/postfix/pid/*.pid
exec supervisord -n -c /etc/supervisord.conf
