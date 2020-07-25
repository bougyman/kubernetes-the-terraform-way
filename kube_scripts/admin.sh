#!/bin/bash
kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=ssl/ca.pem \
    --embed-certs=true \
    --server=https://127.0.0.1:6443 \
    --kubeconfig=kube_configs/admin.kubeconfig

kubectl config set-credentials admin \
    --client-certificate=ssl/admin.pem \
    --client-key=ssl/admin-key.pem \
    --embed-certs=true \
    --kubeconfig=kube_configs/admin.kubeconfig

kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=admin \
    --kubeconfig=kube_configs/admin.kubeconfig

kubectl config use-context default --kubeconfig=kube_configs/admin.kubeconfig
