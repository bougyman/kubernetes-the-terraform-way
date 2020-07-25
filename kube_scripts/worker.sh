#!/bin/bash
export instance KUBERNETES_PUBLIC_ADDRESS
kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=ssl/ca.pem \
    --embed-certs=true \
    --server=https://${KUBERNETES_PUBLIC_ADDRESS}:6443 \
    --kubeconfig=kube_configs/${instance}.kubeconfig

kubectl config set-credentials system:node:${instance} \
    --client-certificate=ssl/${instance}.pem \
    --client-key=ssl/${instance}-key.pem \
    --embed-certs=true \
    --kubeconfig=kube_configs/${instance}.kubeconfig

kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=system:node:${instance} \
    --kubeconfig=kube_configs/${instance}.kubeconfig

kubectl config use-context default --kubeconfig=kube_configs/${instance}.kubeconfig
