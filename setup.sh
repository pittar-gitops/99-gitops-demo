#!/bin/bash

LANG=C

echo ""
echo "Installing Argo CD Operator."

echo "Create the Argo CD project."
oc adm new-project argocd
oc project argocd

echo "Create Subscription and OperatorGroup."
oc create -f manifests/argocd/argocd-operatorgroup.yaml -n argocd
oc create -f manifests/argocd/argocd-subscription.yaml -n argocd

sleep 15

echo "There should be some CRDs."
oc get crd | grep argo

echo "Waiting for Argo CD operator to start."
sleep 5

while oc get deployment/argocd-operator -n argocd | grep "0/1" >> /dev/null;
do
    echo "Waiting..."
    sleep 3
done
echo "Argo CD Operator ready!"

echo "Create an instance of Argo CD."
oc create -f manifests/argocd/argocd.yaml -n argocd

echo "Waiting for Argo CD to start."
sleep 15

until oc get deployment/argocd-server -n argocd | grep "1/1" >> /dev/null;
do
    echo "Waiting..."
    sleep 3
done
echo "Argo CD ready!"

# Grant Argo CD cluster admin, so it can manage security contexts.
oc adm policy add-cluster-role-to-user cluster-admin -z argocd-application-controller -n argocd

echo ""
echo "Printing default admin password:"
oc -n argocd get pod -l "app.kubernetes.io/name=argocd-server" -o jsonpath='{.items[*].metadata.name}'
echo ""
echo ""
