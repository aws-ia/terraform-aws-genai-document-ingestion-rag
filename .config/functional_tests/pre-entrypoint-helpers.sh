#!/bin/bash
## NOTE: this script runs at the start of functional test
## use this to load any configuration before the functional test 
## TIPS: avoid modifying the .project_automation/functional_test/entrypoint.sh
## migrate any customization you did on entrypoint.sh to this helper script
echo "Executing Pre-Entrypoint Helpers"

#********** Project Path *************
PROJECT_PATH=${BASE_PATH}/project
PROJECT_TYPE_PATH=${BASE_PATH}/projecttype
cd ${PROJECT_PATH}

export AWS_DEFAULT_REGION=us-east-1

/usr/local/bin/dockerd \
	--host=unix:///var/run/docker.sock \
	--host=tcp://127.0.0.1:2375 \
	--storage-driver=overlay2 &>/var/log/docker.log &

tries=0
d_timeout=10
until docker info >/dev/null 2>&1
do
	if [ "$tries" -gt "$d_timeout" ]; then
                cat /var/log/docker.log
		echo 'Timed out trying to connect to internal docker host.' >&2
		exit 1
	fi
        tries=$(( $tries + 1 ))
	sleep 1
done