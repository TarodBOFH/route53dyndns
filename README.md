# route53dyndns
I am a small set of scripts to dynamically update a given domain name record on Amazon Route53 service based on the
current IP address of the machine running the script (or another machine that accepts a remote ssh command).

It can be used as a docker container, either running 24/7 or by having `/change_ip.sh` as command.
The docker entrypoint is a permanent loop launches `/change_ip.sh` script every minute.
To avoid incurring AWS cost by using the API, a very basic change detection has been implemented:
- Store last known ip from AWS on `/var/lastip` (or 0.0.0.0 to force running the script)
- Compare router's ip with the one stored
- If the IPs are not equal, call AWS Route 53 to update the DNS with the actual public IP
  obtained (check `change_ip.sh`)
- If they are equal, do not call AWS at all.
- Every 60 cycles, force a refresh (around every hour) by force updating `/var/lastip` with `0.0.0.0` 
  
##Additional information:

* change_ip.sh contains a couple of ways of obtaining the IP address
* route53.py is a small python script using boto3 to update a set of given DNS records (MX, TXT, A... whatever).
* The following dependencies are expected:
  * `change_ip.sh` (using ssh to connect to your router)
    * Environment variables
      * `$GW_USER` User for connecting to the gateway (additionally, use .ssh/config)
      * `$GW_IP` IP Address from your gateway
    * `/root/.ssh` configuration (keys, known hosts, etc)
      * Can be mounted as a docker volume (see dockerfile)
  * `route_53.py`
    * Environment variables
      * `AWS_ROUTE53_ZONES` a python-compatible list of pairs, with `[(zone_id,zone_name),...]` format
      * `AWS_ROUTE53_A_RECORD` a DNS `A` type record to look for ip changes (i.e. `dynip` if you have `dynip.yourdomain.com`)
        This is to avoid changing several records at once. A good idea is to have a single `A` record and then as many `CNAME` records you need
        pointing to that `A` record
      * Uses python [`get_docker_secret`](https://pypi.org/project/get-docker-secret/) to read the secrets either from 
        docker secrets exposed file (usual location) or from environment.
        Be aware that docker secrets need docker swarm. Use env. variables if you don't have a swarm.
        The docker secrets variables used are the [standard AWS credentials environment variables](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-envvars.html):
          * `AWS_ACCESS_KEY_ID`
          * `AWS_SECRET_ACCESS_KEY`
  * `entrypoint.sh` just forces a permanent loop ensuring AWS is called at least every hour.  