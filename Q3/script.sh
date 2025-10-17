#!/bin/bash
echo "========================================================================================"
echo "Creating cluster"
echo "========================================================================================"
kind create cluster
echo

echo "========================================================================================"
echo "Testing cluster connectivity"
echo "========================================================================================"
kubectl cluster-info
echo
echo "========================================================================================"
echo "Creating deployments"
echo "========================================================================================"
kubectl create deploy redis-running --image=redis:latest
kubectl create deploy redis-failed --image=redis:unknown
kubectl wait --for=condition=available --timeout=300s deployment/redis-running

echo
echo "========================================================================================"
echo "Finding pods in a none running state and also returning which nodes are hosting them"
echo "========================================================================================"
kubectl get po -A  --field-selector=status.phase!=Running -o custom-columns="NAMESPACE:.metadata.namespace,NAME:.metadata.name,NODE:.spec.nodeName,STATUS:.status.phase"

echo "Finding events for failing pods"

kubectl get po -A --field-selector=status.phase!=Running -o custom-columns="NAMESPACE:.metadata.namespace,NAME:.metadata.name" --no-headers |
while read ns name; do
  echo "Events for $name in $ns"
  kubectl get events -n "$ns" --field-selector involvedObject.name="$name" --sort-by=.lastTimestamp
  echo
done
echo

echo "========================================================================================"
echo "Finding events for affected nodes"
echo "========================================================================================"

kubectl get po -A --field-selector=status.phase!=Running -o custom-columns="NODE:.spec.nodeName" --no-headers | sort | uniq |
while read node; do
  echo "Events for $node"
  kubectl get events --field-selector involvedObject.kind=Node,involvedObject.name=$node --sort-by=.lastTimestamp
  echo
done
echo

echo "========================================================================================"
echo "Finding logs for affected pods"
echo "========================================================================================"

kubectl get po -A --field-selector=status.phase!=Running -o custom-columns="NAMESPACE:.metadata.namespace,NAME:.metadata.name" --no-headers |
while read ns name; do
  echo "Logs for $name in $ns"
  kubectl logs -n "$ns" $name --tail=100
  echo
done