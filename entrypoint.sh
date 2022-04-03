#!/usr/bin/env sh
set -e # exit on error

# Variables
[ -z "$SMTP_LOGIN" -o -z "$SMTP_PASSWORD" ] && {
	echo "SMTP_LOGIN and SMTP_PASSWORD _must_ be defined" >&2
	exit 1
}

if [ -n "$RECIPIENT_RESTRICTIONS" ]; then
	RECIPIENT_RESTRICTIONS="inline:{$(echo $RECIPIENT_RESTRICTIONS | sed 's/\s\+/=OK, /g')=OK}"
else
	RECIPIENT_RESTRICTIONS=static:OK
fi

export SMTP_LOGIN SMTP_PASSWORD RECIPIENT_RESTRICTIONS
export SMTP_HOST=${SMTP_HOST:-"email-smtp.us-east-1.amazonaws.com"}
export SMTP_PORT=${SMTP_PORT:-"25"}
export ACCEPTED_NETWORKS=${ACCEPTED_NETWORKS:-"192.168.0.0/16 172.16.0.0/12 10.0.0.0/8"}
export USE_TLS=${USE_TLS:-"no"}
export TLS_VERIFY=${TLS_VERIFY:-"may"}

# Render template and write postfix main config
cat <<- EOF > /etc/postfix/main.cf
	#
	# Just the bare minimal
	#

	# write logs to stdout
	maillog_file = /dev/stdout

	# network bindings
	inet_interfaces = all
	inet_protocols = ipv4

	# general params
	compatibility_level = 3.6
	myhostname = $HOSTNAME
	mynetworks = 127.0.0.0/8 [::1]/128 $ACCEPTED_NETWORKS
	relayhost = [$SMTP_HOST]:$SMTP_PORT

	# smtp-out params
	smtp_sasl_auth_enable = yes
	smtp_sasl_password_maps = static:$SMTP_LOGIN:$SMTP_PASSWORD
	smtp_sasl_security_options = noanonymous
	smtp_tls_CAfile = /etc/ssl/certs/ca-certificates.crt
	smtp_tls_security_level = $TLS_VERIFY
	smtp_tls_session_cache_database = lmdb:\$data_directory/smtp_scache
	smtp_use_tls = $USE_TLS

	# RCPT TO restrictions
	smtpd_recipient_restrictions = check_recipient_access $RECIPIENT_RESTRICTIONS, reject

	# some tweaks
	biff = no
	delay_warning_time = 1h
	mailbox_size_limit = 0
	readme_directory = no
	recipient_delimiter = +
	smtputf8_enable = no
	EOF

# Generate default alias DB
newaliases

# Launch
rm -f /var/spool/postfix/pid/*.pid
exec postfix -c /etc/postfix start-fg
