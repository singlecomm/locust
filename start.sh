#!/usr/bin/env bash

LOCUST_INSTANCE_TYPE=${LOCUST_INSTANCE_TYPE:-standalone}
LOCUST_TEST_HOST=${LOCUST_TEST_HOST:-localhost}
LOCUST_REQUESTS=${LOCUST_REQUESTS:-100}
LOCUST_CONCURRENT_CLIENTS=${LOCUST_CONCURRENT_CLIENTS:-1}
LOCUST_REQUEST_RATE=${LOCUST_REQUEST_RATE:-1}

# Stop on the first error
set -e;

function onExit {
    if [ "$?" != "0" ]; then
        echo "Stress tests failed!";
        exit 1
    else
        echo "Stress tests passed!";
        exit 0
    fi
}

# Call onExit when the script exits
trap onExit EXIT;

if [ "${LOCUST_INSTANCE_TYPE}" = "slave" ] && [ "${LOCUST_MASTER_HOST}" != "" ]; then
	locust -f ${LOCUST_TESTS} \
	  --${LOCUST_INSTANCE_TYPE} \
	  --master-host=${LOCUST_MASTER_HOST} \
	  --host=${LOCUST_TEST_HOST} \
	  -n${LOCUST_REQUESTS} \
	  -c${LOCUST_CONCURRENT_CLIENTS} \
	  -r${LOCUST_REQUEST_RATE} \
	  ${LOCUST_ADDITIONAL_OPTIONS}	
elif [ "${LOCUST_INSTANCE_TYPE}" = "slave" ] && [ "${LOCUST_MASTER_HOST}" = "" ]; then
	echo "Please provide a LOCUST_MASTER_HOST variable for Locust slaves"
elif [ "${LOCUST_INSTANCE_TYPE}" = "master" ] || ["${LOCUST_INSTANCE_TYPE}" = "standalone" ]; then
	locust -f ${LOCUST_TESTS} \
	  --${LOCUST_INSTANCE_TYPE} \
	  --host=${LOCUST_TEST_HOST} \
	  -n${LOCUST_REQUESTS} \
	  -c${LOCUST_CONCURRENT_CLIENTS} \
	  -r${LOCUST_REQUEST_RATE} \
	  ${LOCUST_ADDITIONAL_OPTIONS}
else
    echo "Please provide a LOCUST_INSTANCE_TYPE variable for Locust slaves"
fi
