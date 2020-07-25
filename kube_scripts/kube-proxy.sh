#!/bin/bash
export KUBERNETES_PUBLIC_ADDRESS
kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=ssl/ca.pem \
    --embed-certs=true \
    --server=https://${KUBERNETES_PUBLIC_ADDRESS}:6443 \
    --kubeconfig=kube_configs/kube-proxy.kubeconfig

kubectl config set-credentials system:kube-proxy \
    --client-certificate=sssl/kube-proxy.pem \
    --client-key=ssl/kube-proxy-key.pem \
    --embed-certs=true \
    --kubeconfig=kube_configs/kube-proxy.kubeconfig

kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=system:kube-proxy \
    --kubeconfig=kube_configs/kube-proxy.kubeconfig

kubectl config use-context default --kubeconfig=kube_configs/kube-proxy.kubeconfig
