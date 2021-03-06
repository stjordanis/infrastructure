#!/usr/bin/env python

"""
Simple script that takes a ansible-inventory JSON output (stdin) 
and dumps inventory markdown grouped by environment.

Examples
----------
ansible-inventory --list | ./dump_inventory.py

"""
 
import sys, json, re

env_group_prefix = 'tag_env_'

data = json.load(sys.stdin)
all_groups = data['all']['children']
filtered_groups = [g for g in all_groups]
env_groups = [g for g in filtered_groups if g.startswith(env_group_prefix)]

# source https://stackoverflow.com/a/16090640/3967231
def natural_sort_key(s, _nsre=re.compile('([0-9]+)')):
    return [int(text) if text.isdigit() else text.lower()
            for text in re.split(_nsre, s)]   

for group_name in env_groups:
    print("#### %s\n" % group_name[len(env_group_prefix):])
    hosts = data[group_name]['hosts'].sort(key=natural_sort_key)
    for host in data[group_name]['hosts']:
        host_ip = data['_meta']['hostvars'][host]['ansible_host']
        print("- [%s](http://%s:3013/v2/top) %s" % (host, host_ip, host_ip))
    print("\n")

