#!/bin/bash
kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=ssl/ca.pem \
    --embed-certs=true \
    --server=https://127.0.0.1:6443 \
    --kubeconfig=kube_configs/kube-controller-manager.kubeconfig

kubectl config set-credentials system:kube-controller-manager \
    --client-certificate=ssl/kube-controller-manager.pem \
    --client-key=ssl/kube-controller-manager-key.pem \
    --embed-certs=true \
    --kubeconfig=kube_configs/kube-controller-manager.kubeconfig

kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=system:kube-controller-manager \
    --kubeconfig=kube_configs/kube-controller-manager.kubeconfig

kubectl config use-context default --kubeconfig=kube_configs/kube-controller-manager.kubeconfig
