#install cert-manager and generate certificates
kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.5.3/cert-manager.crds.yaml
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm install \
  cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.12.4 \
  # --set installCRDs=true

# Generate a new CA key and certificate
openssl genrsa -out ca.key 4096
openssl req -new -x509 -sha256 -days 365 -key ca.key -out ca.crt

# Base64 encode the CA key and certificate
ca_crt_base64=$(cat ca.crt | base64 -w 0)
ca_key_base64=$(cat ca.key | base64 -w 0)

# Create the nginx-secret.yaml file
cat <<EOF > nginx-secret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: nginx1-ca-secret
  namespace: cert-manager
type: Opaque
data:
  tls.crt: $ca_crt_base64
  tls.key: $ca_key_base64
EOF
echo "nginx-secret.yaml created with base64-encoded ca.crt and ca.key values."
kubectl create -f nginx-secret.yaml

# Add ClusterIsuuer
cat <<EOF > nginx-clusterissuer.yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: nginx1-clusterissuer
spec:
  ca:
    secretName: nginx1-ca-secret
EOF

echo "nginx-clusterissuer.yaml created."

kubectl create -f nginx-clusterissuer.yaml

# Create the Certificate resource
cat <<EOF > nginx-certificate.yaml
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: nginx1-cert
  namespace: istio-system
spec:
  secretName: nginx1-tls-secret
  issuerRef:
    name: nginx1-clusterissuer
    kind: ClusterIssuer
  dnsNames:
    - sslistio.nginxtls.local
EOF

kubectl apply -f nginx-certificate.yaml
echo "nginx-certificate.yaml created."

cat <<EOF | kubectl apply -f -
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: mygateway
spec:
  selector:
    istio: ingressgateway # use istio default ingress gateway
  servers:
  - port:
      number: 443
      name: https
      protocol: HTTPS
    tls:
      mode: SIMPLE
      credentialName: nginx1/nginx1-tls-secret # must be the same as secret
    hosts:
    - httpbin.example.com
EOF

apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: nginx1-ingress
  namespace: istio-system
  annotations:
    kubernetes.io/ingress.class: istio
spec:
  rules:
  - host: "nginx1.clcreative.home"
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: nginx-service
            port:
              number: 80 
  tls:
  - hosts:
    - nginx1.clcreative.home
    secretName: nginx1-tls-secret
