#!/usr/bin/env python3

#TODO: need to implement sha384 check, current run against previous run, if diff, make alert happen

import sys
import json
import argparse
import subprocess
from os import path
from datetime import datetime

SHA_SUM = '/usr/bin/sha384sum'
VERSION_ALREADY_FOUND_EXIT = 100 #return code when joplin version has already occurred

def parse_arguments():
	p = argparse.ArgumentParser(description='Detect joplin server Dockerfile changes and store for future detection')
	p.add_argument('--docker-file', required=True, type=str, help='joplin server Dockerfile file path')
	p.add_argument('--joplin-ver', required=True, type=str, help='joplin release version')
	p.add_argument('--json-file', required=True, type=str, help='json meta file path')
	return p.parse_args()

def sha384sum(file_path):
	try:
		proc = subprocess.Popen([SHA_SUM, file_path], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
		retcode = proc.wait()
		if retcode == 0:
			stderr = proc.stderr.read()
			if len(stderr) > 0:
				return False, ""
			stdout = proc.stdout.read()
			return True, stdout.split()[0].decode('utf8')
	except Exception as e:
		pass
	return False, ""

def meta_json_read(file_path):
	obj = None
	with open(file_path, 'r') as fo:
		obj = json.load(fo)
	return obj

def meta_json_write(file_path, obj):
	with open(file_path, 'w') as fo:
		json.dump(obj, fo, indent='\t')

def meta_json_initialize(file_path):
	meta_json_write(file_path, {})

def main():
	args = parse_arguments()
	print(dir(args))
	if not path.isfile(args.docker_file):
		print("joplin server Dockerfile file path: %s doesn't exist" % args.docker_file)

	if not path.isfile(args.json_file):
		meta_json_initialize(args.json_file)

	worked, sha384 = sha384sum(args.docker_file)
	if not worked:
		print("Unable to compute sha checksum for: %s" % fp)

	dt = datetime.now().strftime('%Y%m%d_%H%M%S')
	json_obj = meta_json_read(args.json_file)
	if args.joplin_ver in json_obj:
		print("joplin version: %s has already been processed... return code will be %d" % (args.joplin_ver, VERSION_ALREADY_FOUND_EXIT))
		return VERSION_ALREADY_FOUND_EXIT
	else:
		json_obj[args.joplin_ver] = [dt, sha384]
		meta_json_write(args.json_file, json_obj)
	return 0

if __name__ == "__main__":
	sys.exit(main())
