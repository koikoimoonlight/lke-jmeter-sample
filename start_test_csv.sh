#!/usr/bin/env bash

working_dir=$(pwd)

# Get namesapce variable
tenant=$(awk '{print $NF}' "$working_dir"/tenant_export)

jmx_dir=$1

if [ ! -d "$jmx_dir" ];
then
    echo "Test script dir was not found"
    echo "Kindly check and input the correct file path"
    exit
fi

# Get Master pod details
printf "Copy %s to master\n" "${jmx_dir}.jmx"
master_pod=$(kubectl get po -n "$tenant" | grep jmeter-master | awk '{print $1}')
kubectl cp "${jmx_dir}/${jmx_dir}.jmx" -n "$tenant" "$master_pod":/

# Get slaves
printf "Get number of slaves\n"
slave_pods=($(kubectl get po -n "$tenant" | grep jmeter-slave | awk '{print $1}'))

# for array iteration
slavesnum=${#slave_pods[@]}

# for split command suffix and seq generator
slavedigits="${#slavesnum}"
printf "Number of slaves is %s\n" "${slavesnum}"

# Split and upload csv files
for csvfilefull in "${jmx_dir}"/*.csv

  do

  csvfile="${csvfilefull##*/}"

  printf "Processing %s file..\n" "$csvfile"

  split --suffix-length="${slavedigits}" --additional-suffix=.csv -d --number="l/${slavesnum}" "${jmx_dir}/${csvfile}" "$jmx_dir"/

  j=0
  for i in $(seq -f "%0${slavedigits}g" 0 $((slavesnum-1)))
  do
    printf "Copy %s to %s on %s\n" "${i}.csv" "${csvfile}" "${slave_pods[j]}"
    kubectl -n "$tenant" cp "${jmx_dir}/${i}.csv" "${slave_pods[j]}":/
    kubectl -n "$tenant" exec "${slave_pods[j]}" -- mv -v /"${i}.csv" /"${csvfile}"
    rm -v "${jmx_dir}/${i}.csv"

    let j=j+1
  done

done

## Starting Jmeter load test
kubectl exec -ti -n "$tenant" "$master_pod" -- /bin/bash /load_test "/${jmx_dir}.jmx"
kubectl exec -ti -n "$tenant" "$master_pod" -- /bin/gzip /out.jtl
kubectl cp -n $tenant $master_pod:/out.jtl.gz out.jtl.gz
kubectl exec -ti -n "$tenant" "$master_pod" -- rm -f /out.jtl.gz