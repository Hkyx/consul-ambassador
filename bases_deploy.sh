#!/bin/bash

TODO=$1
CLUSTER_NAME="ARGOfficeProtectPOC"

get_creds(){
    CLUSTERNAME=$1
    az aks get-credentials --resource-group ${CLUSTERNAME} --name ${CLUSTERNAME} --admin --overwrite-existing
}
# hanbdler to update helm repo
update_repo(){
    FLAG=$1
    if [ -z "$var" ]
    then
        helm repo update
    else
        helm repo update $FLAG
    fi

}

# Use taint to disable basic deployment on windows and focus services deployments to linux nodes
disable_windows(){
    for i in $(kubectl get nodes -A | grep window |awk '{print $1;}')
        do
            kubectl taint nodes $i key=globalwin:NoSchedule
    done
}

# Consul:
consul(){
    TODO=$1
    if [ ${TODO} == "install" ]
    then
        kubectl create namespace consul
        helm repo add hashicorp "https://helm.releases.hashicorp.com"
        update_repo
        helm install consul hashicorp/consul -f values/consul/dev.yml #--version=0.22.0
    elif [ ${TODO} == "delete" ]
    then
        helm delete consul
    else
        echo "take a param as install or delete"
    fi
    # connecto to ui kubectl port-forward service/consul-server 8501:8501 && https://localhost:8501/ui/dev/nodes
}

ambassador(){

#    TODO=$1
 #   if [ ${TODO} == "install" ]
  #  then
        # ambassador use it's own cli called Edgectl:
        #    HOMEBIN="~/bin"
        #    curl -fLO https://metriton.datawire.io/downloads/linux/edgectl
        #    chmod a+x edgectl
        #    if [ ! -d ${HOMEBIN} ]
        #    then
        #        mkdir ${HOMEBIN}
        #    fi
        #    mv edgectl ~/bin
        # now we can deploy ambassador to k8s
        #kubectl create namespace ambassador
        #        helm install ambassador datawire/ambassador -f values/ambassador/dev.yml #-n ambassador

TODO=$1
if [ ${TODO} == "install" ]
then
    kubectl apply -f values/ambassador/AKS-config/1-aes-crds.yml && \
        kubectl wait --for condition=established --timeout=90s crd -lproduct=aes && \
        kubectl apply -f values/ambassador/AKS-config/2-aes.yml && \
        kubectl -n default wait --for condition=available --timeout=90s deploy -l product=aes
        kubectl apply -f values/ambassador/AKS-config/3-user.yml
   #     kubectl apply -f values/ambassador/AKS-config/4-prometheus-crd.yml && \
  #      kubectl wait --for condition=established  --timeout=90s crd -lproduct=aes-prometheus && \
 #       kubectl apply -f values/ambassador/AKS-config/5-prometheus.yml
        kubectl apply -f values/ambassador/ambassador-consul-connector.yaml
        kubectl apply -f values/ambassador/consul_as_resolver.yml
        kubectl apply -f values/ambassador/host-op-svc.yml
        kubectl apply -f values/ambassador/test-app/myapp.yml
        kubectl apply -f values/ambassador/test-app/myapp-mapping.yml

elif [ ${TODO} == "delete" ]
then
        kubectl delete -f values/ambassador/AKS-config/1-aes-crds.yml && \
        kubectl delete -f values/ambassador/AKS-config/2-aes.yml && \
        kubectl delete -f values/ambassador/AKS-config/3-user.yml
#       kubectl delete -f values/ambassador/AKS-config/4-prometheus-crd.yml && \
#        kubectl delete -f values/ambassador/AKS-config/5-prometheus.yml
        kubectl delete -f values/ambassador/ambassador-consul-connector.yaml
        kubectl delete -f values/ambassador/consul_as_resolver.yml
        kubectl delete -f values/ambassador/host-op-svc.yml


else
    echo "take a param as install or delete"
fi

}

upload_certificates() {
    TLS_NAME=$1
    TLS_PATH="values/certs/${TLS_NAME}"
    kubectl create secret tls ${TLS_NAME} --key ${TLS_PATH}/tls.key --cert ${TLS_PATH}/tls.crt -n ambassador
}


zipkin(){
    #need to restart (deploy?) ambassador after that command
    kubectl apply -f values/zipkin/zipkin-in-memory.yml

}

fluent_bit(){
    kubectl create namespace "fluent-bit"
    helm repo add fluent "https://fluent.github.io/helm-charts"
    update_repo
    helm install "fluent-bit" "fluent/fluent-bit" -f "values/fluent-bit/values.yaml" --namespace="fluent-bit"
}
#get_creds ${CLUSTER_NAME}
#disable_windows
#upload_certificates svcopcom
consul $TODO
sleep 30
ambassador $TODO


echo "#################"
echo "# "all\'s done" #"
echo "#################"
