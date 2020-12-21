#!/usr/bin/python

import sys, getopt, time, boto3, ast, os
from get_docker_secret import get_docker_secret

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

    print(f"Refreshing IP {ip}")
    unparsed_zones = os.environ["AWS_ROUTE53_ZONES"]
    a_record = os.environ["AWS_ROUTE53_A_RECORD"]

    zones = list(ast.literal_eval(unparsed_zones))
    spf_records = ["SPF", "TXT"]
    spf_format = "\"v=spf1 include:_spf.google.com ipv4:"+ip+" ~all\""

    client = boto3.client(
        "route53",
        aws_access_key_id=get_docker_secret("AWS_ACCESS_KEY_ID"),
        aws_secret_access_key=get_docker_secret("AWS_SECRET_ACCESS_KEY"),
    )
    for zone_id, zone_name in zones:
        print(f"Processing {zone_id} ({zone_name})")
        response = client.list_resource_record_sets(HostedZoneId=zone_id)
        change_request = []

        for record in response['ResourceRecordSets']:
            if record['Type'] == 'A' and record["Name"] == f"{a_record}.{zone_name}.":
                for resource in record.get("ResourceRecords") or []:
                    if resource['Value'] != ip:
                        print(f"Updating {a_record}.{zone_name} type {record['Type']} from {resource['Value']} to {ip}")
                        resource['Value'] = ip
                        change_request.append({'Action': 'UPSERT', 'ResourceRecordSet': record})
            if record['Type'] in spf_records:
                for resource in record.get("ResourceRecords") or []:
                    if resource['Value'] != spf_format:
                        print(f"Updating {a_record}.{zone_name} type {record['Type']} from {resource['Value']} to {ip}")
                        resource['Value'] = spf_format
                        change_request.append({'Action': 'UPSERT', 'ResourceRecordSet': record})
        if change_request:
            client.change_resource_record_sets(
                HostedZoneId=zone_id,
                ChangeBatch= {
                    'Comment': f"autoupdate dynamic ip with {ip}",
                    'Changes': change_request
                }
            )
    f = open("/var/lastip", "w")
    f.write(ip)
    f.close()

if __name__ == "__main__":
    main(sys.argv[1:])
