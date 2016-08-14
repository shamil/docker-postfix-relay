Postfix Mail Relay
==================

Simple SMTP relay, originally based on [alterrebe/docker-mail-relay](https://github.com/alterrebe/docker-mail-relay), but has been rewritten since.

**Description**

The container provides a simple SMTP relay for environments like Amazon VPC where you may have private servers with no Internet connection
and therefore with no access to external mail relays (e.g. Amazon SES, SendGrid and others). You need to supply the container with your 
external mail relay address and credentials. The image is tested with `Amazon SES`, `Sendgrid`, `Gmail` and `Mandrill`

**Changes from `alterrebe/docker-mail-relay`**

* Uses `alpine` image instead of `ubuntu`.
* Uses `envsubst` for templating instead of `j2cli`.
* All output goes to `stdout` and `stderr` including `maillog`.
* Included `superviserd` event watcher which will exit the `supervisord` process if one of the monitored processes dies unexpectedly.
* Doesn't use TLS on `smtpd` side.
* And other changes to make the image as **KISS** as possible

**Exports**

Postfix on port `25`

**Environment variables**

* `ACCEPTED_NETWORKS=192.168.0.0/16 172.16.0.0/12 10.0.0.0/8`: A network (or a list of networks) to accept mail from
* `SMTP_HOST=email-smtp.us-east-1.amazonaws.com`: External relay DNS name
* `SMTP_PORT=25`: External relay TCP port
* `SMTP_LOGIN=`: Login to connect to the external relay (required, otherwise the container fails to start)
* `SMTP_PASSWORD=`: Password to connect to the external relay (required, otherwise the container fails to start)
* `USE_TLS=`: Remote require tls. Might be "yes" or "no". Default: no.
* `TLS_VERIFY=`: Trust level for checking the remote side cert. (none, may, encrypt, dane, dane-only, fingerprint, verify, secure). Default: may.

**Example**

Launch Postfix container:

    $ docker run -d -h relay.example.com --name="mailrelay" -e SMTP_LOGIN=myLogin -e SMTP_PASSWORD=myPassword -p 25:25 shamil/postfix-relay

