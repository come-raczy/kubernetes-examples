#!/bin/env bash

echo "installing the ingress-nginx controller..."
helm upgrade --install ingress-nginx ingress-nginx \
  --repo https://kubernetes.github.io/ingress-nginx \
  --namespace ingress-nginx --create-namespace
echo
echo "   ===>" accessing localhos
curl localhost
echo
echo "   ===>" waiting for the ingress-nginx controller to be ready
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=120s
echo
echo "   ===>" showing the ingress-nginx controller service
kubectl get service ingress-nginx-controller --namespace=ingress-nginx
echo
echo "   ===>" accessing localhos
curl localhost
echo
echo "   ===>" adding some services to the ingress-nginx controller
kubectl create deployment demo --image=httpd --port=80
kubectl expose deployment demo
echo
echo "   ===>" creating an ingress resource mapping the demo service to localhost
kubectl create ingress demo --class=nginx --rule="localhost/*=demo:80"
echo
echo "   ===> waiting for ingress demo to be ready (can take a up to 60s)"
sleep 2
while [[ -z $(kubectl get ingress demo -o jsonpath="{.status.loadBalancer.ingress}" 2> /dev/null) ]]; do
    echo "        still waiting..."
    sleep 1
done
echo
echo "   ===>" accessing localhost:
curl localhost
OTHER_HOST=$(grep '^127\.0\.0\.1' /etc/hosts | tr $'\t' ' ' | cut -d ' ' -f2 | head -n 1)
if [ -n "$OTHER_HOST" ]; then
  echo
  echo "   ===>" creating an ingress resource mapping the demo service to "$OTHER_HOST"
  kubectl create ingress demo1 --class=nginx --rule="$OTHER_HOST/*=demo:80"
  echo
  echo "   ===>" waiting for ingress demo1 to be ready
  sleep 2
  while [[ -z $(kubectl get ingress demo1 -o jsonpath="{.status.loadBalancer.ingress}" 2> /dev/null) ]]; do
      echo "        still waiting..."
      sleep 1
  done
  echo
  echo "   ===>" accessing "$OTHER_HOST":
  curl "$OTHER_HOST"
fi
echo
echo "   ===>" showing the ingress resources
kubectl get ingress --all-namespaces
echo
echo "   ===>" cleaning up
kubectl delete ingress demo1
kubectl delete ingress demo
kubectl delete service demo
kubectl delete deployment demo
