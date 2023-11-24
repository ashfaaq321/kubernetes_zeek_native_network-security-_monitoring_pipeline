#!/bin/bash

# Check what changes would be made
kubectl get configmap kube-proxy -n kube-system -o yaml | \
sed -e "s/strictARP: false/strictARP: true/" | \
kubectl diff -f - -n kube-system
    
# Actually apply the changes (returns nonzero returncode on errors only)
kubectl get configmap kube-proxy -n kube-system -o yaml | \
sed -e "s/strictARP: false/strictARP: true/" | \
kubectl apply -f - -n kube-system

# Install MetalLB
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.11/config/manifests/metallb-native.yaml

# Create MetalLB configuration files
cat <<EOF > pool.yaml
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: first-pool
  namespace: metallb-system
spec:
  addresses:
  - 192.168.121.3-192.168.121.253
EOF

cat <<EOF > l2.yaml
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: homelab-l2
  namespace: metallb-system
spec:
  ipAddressPools:
  - first-pool
EOF

kubectl create -f pool.yaml
kubectl create -f l2.yaml

# Install Istio
kubectl get crd gateways.gateway.networking.k8s.io &> /dev/null || \
  { kubectl kustomize "github.com/kubernetes-sigs/gateway-api/config/crd?ref=v0.8.0-rc1" | kubectl apply -f -; }

curl -L https://istio.io/downloadIstio | ISTIO_VERSION=1.19.0 TARGET_ARCH=x86_64 sh -
cd istio-1.19.0
export PATH=$PWD/bin:$PATH
istioctl install --set profile=demo
kubectl label namespace default istio-injection=enabled

# Deploy Nginx
cat <<EOF > nginx.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
        - name: nginx
          image: nginx:latest
          ports:
            - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  selector:
    app: nginx
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
  type: LoadBalancer
EOF
kubectl create -f nginx.yaml

#To check logs of istiod
kubectl logs -n istio-system -l  istiod-86b84db666-prmcj

# PLugins for CA
#!/bin/bash

# Generate the CA certificate and key
openssl genpkey -algorithm RSA -out ca-key.pem
openssl req -x509 -new -nodes -key ca-key.pem -sha256 -days 1825 -out ca-cert.pem -subj "/CN=MyCA"

# Generate the server certificate and key
openssl genpkey -algorithm RSA -out server-key.pem
openssl req -new -key server-key.pem -out server.csr -subj "/CN=myserver"

# Sign the server certificate with the CA
openssl x509 -req -in server.csr -CA ca-cert.pem -CAkey ca-key.pem -CAcreateserial -out server-cert.pem -days 825

# Create cert-chain.pem by concatenating server-cert.pem and ca-cert.pem
cat server-cert.pem ca-cert.pem > cert-chain.pem

# Create root-cert.pem by copying ca-cert.pem
cp ca-cert.pem root-cert.pem

# Create the istio-system namespace
kubectl create namespace istio-system

# Create the secret with the generated PEM files in the istio-system namespace
kubectl create secret generic cacerts -n istio-system \
      --from-file=ca-cert.pem \
      --from-file=ca-key.pem \
      --from-file=root-cert.pem \
      --from-file=cert-chain.pem

# Install Istio
istioctl install --set profile=demo

# Get the Istio CA root certificate
kubectl get configmap istio-ca-root-cert -n istio-system -o yaml



echo "Setup completed!"


# Cleanup

kubectl delete deployment nginx-deployment
kubectl delete service nginx-service
