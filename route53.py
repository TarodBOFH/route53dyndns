#!/usr/bin/python

import boto.route53, sys, getopt

def main(argv):
	ip=''
	try:                                
        	opts, args = getopt.getopt(argv, "hi:d", ["help", "ip="])
	except getopt.GetoptError:          
	        sys.exit(2)                     
	if len(args) > 0:
		ip=args[0]
	else:
		sys.exit(2)
	zone_id = "XXXXXXXXXXXXX" #check your route53 documentation
	zone_name= "domain_name" #example.com
	a_record = "record"+"."+zone_name #www.example.com (MUST BE A record)
	#check /etc/boto.cfg for credentials
	conn = boto.connect_route53()
	zone = conn.get_zone(zone_name)
	old_ip = zone.get_a(a_record)
	#only change ip if needed
	if ip not in old_ip.resource_records:
		zone.update_a(a_record,ip,ttl=300)
	#update spf entries
        spf = zone.find_records(zone_name,"SPF")
        txt = zone.find_records(zone_name,"TXT")
        if ip not in spf.resource_records:
                zone.update_record(spf,"\"v=spf1 include:_spf.google.com ipv4:"+ip+" ~all\"")
        if ip not in txt.resource_records:
                zone.update_record(txt,"\"v=spf1 include:_spf.google.com ipv4:"+ip+" ~all\"")

if __name__ == "__main__":
    main(sys.argv[1:])
