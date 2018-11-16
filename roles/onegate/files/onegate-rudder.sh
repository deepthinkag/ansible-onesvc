#! /usr/bin/env bash

get_one_svc_info() {
    JSON=$(timeout 10 onegate service show --json)
    if [ $? != 0 ]; then
        echo "failed to connect to onegate"
        exit 1
    fi
    export JSON
}


read_one_svcname() {
    SVCNAME=$(echo "${JSON}" | jq -r ".SERVICE.name")
    if [ $? != 0 ]; then
        echo "failed to find service name"
        exit 1
    fi
    
    export SVCNAME
}


store_property_json() {
echo "{ 
  \"properties\": [
    { \"ONE_svcname\" : \"$SVCNAME\"  } ]
}" > /var/rudder/local/properties.d/ONEgate.json

}


test -d /var/rudder/local/properties.d || mkdir -p /var/rudder/local/properties.d


if get_one_svc_info ; then
    read_one_svcname
    store_property_json
else
    exit 1
fi
