## Getting Started

There are certain dependencies between the steps, so
it's important to follow these steps in this order to
install your configured Ambassador Edge Stack.


## Install the Ambassador Edge Stack

Connect to your cluster and then run the following commands:

  kubectl apply -f 1-aes-crds.yml && \
  kubectl wait --for condition=established --timeout=90s crd -lproduct=aes && \
  kubectl apply -f 2-aes.yml && \
  kubectl -n ambassador wait --for condition=available --timeout=90s deploy -lproduct=aes


## Install Your Custom Resources

Now run the following commands to configure your Ambassador deployment with your custom manifests
generated from your configuration:

  kubectl apply -f 3-user.yml


## Installing Prometheus

When using Prometheus for collecting metrics from your application, you will need to verify that
the Kubernetes version you are running is version 1.16+ or greater.  To determine this, run:

  kubectl version

and confirm that the "serverVersion" is at least "Major:1, Minor:16+"

To install Prometheus, run:

  kubectl apply -f 4-prometheus-crd.yml && \
  kubectl wait --for condition=established  --timeout=90s crd -lproduct=aes-prometheus && \
  kubectl apply -f 5-prometheus.yml


