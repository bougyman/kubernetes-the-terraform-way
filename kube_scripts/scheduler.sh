#!/bin/bash
kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=ssl/ca.pem \
    --embed-certs=true \
    --server=https://127.0.0.1:6443 \
    --kubeconfig=kube_configs/kube-scheduler.kubeconfig

kubectl config set-credentials system:kube-scheduler \
    --client-certificate=ssl/kube-scheduler.pem \
    --client-key=ssl/kube-scheduler-key.pem \
    --embed-certs=true \
    --kubeconfig=kube_configs/kube-scheduler.kubeconfig

kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=system:kube-scheduler \
    --kubeconfig=kube_configs/kube-scheduler.kubeconfig

kubectl config use-context default --kubeconfig=kube_configs/kube-scheduler.kubeconfig

