#!/usr/bin/env bash
working_dir=`pwd`

if ! hash kubectl 2>/dev/null
then
    echo "'kubectl' was not found in PATH"
    echo "Kindly ensure that you can acces an existing kubernetes cluster via kubectl"
    exit
fi

kubectl version --short
echo "Current list of namespaces on the kubernetes cluster:"
echo
kubectl get namespaces | grep -v NAME | awk '{print $1}'
echo
tenant="jmeter"
echo
kubectl get namespace $tenant > /dev/null 2>&1

if [ $? -eq 0 ]
then
  echo "Namespace $tenant already exists, please select a unique name"
  echo "Current list of namespaces on the kubernetes cluster"
  sleep 2

 kubectl get namespaces | grep -v NAME | awk '{print $1}'
  exit 1
fi

echo
echo "Creating Namespace: $tenant"
kubectl create namespace $tenant
echo "Namspace $tenant has been created"
echo
echo "Creating Jmeter slave nodes"
nodes=`kubectl get no | egrep -v "master|NAME" | wc -l`
echo
echo "Number of worker nodes on this cluster is " $nodes
kubectl create -n $tenant -f $working_dir/jmeter_slaves_deploy.yaml
kubectl create -n $tenant -f $working_dir/jmeter_slaves_svc.yaml
echo "Creating Jmeter Master"
kubectl create -n $tenant -f $working_dir/jmeter_master_configmap.yaml
kubectl create -n $tenant -f $working_dir/jmeter_master_deploy.yaml
echo "Printout Of the $tenant Objects"
echo
kubectl get -n $tenant all
echo namespace = $tenant > $working_dir/tenant_export