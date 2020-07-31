
TODO=$1
if [ ${TODO} == "install" ]
then
    kubectl apply -f 1-aes-crds.yml && \
        kubectl wait --for condition=established --timeout=90s crd -lproduct=aes && \
        kubectl apply -f 2-aes.yml && \
        kubectl -n default wait --for condition=available --timeout=90s deploy -lproduct=aes
        kubectl apply -f 3-user.yml
        kubectl apply -f 4-prometheus-crd.yml && \
        kubectl wait --for condition=established  --timeout=90s crd -lproduct=aes-prometheus && \
        kubectl apply -f 5-prometheus.yml

elif [ ${TODO} == "delete" ]
then
kubectl delete -f 1-aes-crds.yml && \
kubectl delete -f 2-aes.yml && \
kubectl delete -f 3-user.yml
kubectl delete -f 4-prometheus-crd.yml && \
kubectl delete -f 5-prometheus.yml

else
    echo "take a param as install or delete"
fi
