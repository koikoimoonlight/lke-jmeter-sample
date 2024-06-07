#!/usr/bin/env bash

working_dir="`pwd`"

# Get namesapce variable
tenant=`awk '{print $NF}' "$working_dir/tenant_export"`

jmx_dir=$1

if [ ! -d "$jmx_dir" ];
then
    echo "Test script dir was not found"
    echo "Kindly check and input the correct file path"
    exit
fi

test_name="$(basename "$jmx")"

# Get Master pod details

master_pod=`kubectl get po -n $tenant | grep jmeter-master | awk '{print $1}'`

kubectl cp "$jmx" -n $tenant "$master_pod:/$test_name"

# Starting Jmeter load test
kubectl exec -ti -n "$tenant" "$master_pod" -- /bin/bash /load_test "/${jmx_dir}.jmx"
kubectl exec -ti -n "$tenant" "$master_pod" -- /bin/gzip /out.jtl
kubectl cp -n $tenant $master_pod:/out.jtl.gz out.jtl.gz
kubectl exec -ti -n "$tenant" "$master_pod" -- rm -f /out.jtl.gz