# route53dyndns
I am a small set of scripts to dynamically update a given domain name record on Amazon Route53 service based on the current IP address of the machine running the script (or another machine that accepts a remote ssh command).

* change_ip.sh contains a couple of ways of obtaining the IP address 
* route53.py is a small python script using boto to update a set of given DNS records (MX, TXT, A... whatever). It uses default boto.cfg configuration based on your installation base (i.e. /etc/boto.cfg). Read boto documentation about how to install, setup and get your credentials and AWS Route53 documentation to retrieve your different zone id(s) to be able to update them.
