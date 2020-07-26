#!/bin/bash
cd ssl
export INSTANCES EXTERNAL_IPS INTERNAL_IPS
external_ips=( $EXTERNAL_IPS )
internal_ips=( $INTERNAL_IPS )
instances=( $INSTANCES )
for i in ${!instances[@]}
do
	instance=${instances[$i]}
	EXTERNAL_IP=${external_ips[$i]}
	INTERNAL_IP=${internal_ips[$i]}
	cat > ${instance}-csr.json <<EOF
{
  "CN": "system:node:${instance}",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "US",
      "L": "Fort Worth",
      "O": "system:nodes",
      "OU": "Kubernetes The Hard Way",
      "ST": "Texas"
    }
  ]
}
EOF

	cfssl gencert \
	  -ca=ca.pem \
	  -ca-key=ca-key.pem \
	  -config=ca-config.json \
	  -hostname=${instance},${EXTERNAL_IP},${INTERNAL_IP} \
	  -profile=kubernetes \
	  ${instance}-csr.json | cfssljson -bare ${instance}
done
