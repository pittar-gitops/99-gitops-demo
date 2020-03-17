# GitOps Demo

A small GitOps demo you can run on your own cluster.

## What's Included

* Argo CD
* CI/CD tools - Only Jenkins for the demo
* Demo App (Spring Petclinic)

## Prerequisites

* [CodeReady Containers 1.6+](https://developers.redhat.com/products/codeready-containers/overview) - It's free!  Sign up for a free Red Hat account to download and install CodeReady Containers.
* [oc command line tool](https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/) or `kubectl`

## Setup

1. Clone [00-gitups-setup](https://github.com/pittar-gitops/99-gitops-demo) and run `setup.sh` to install Argo CD on your cluster.
    * If you are using Windows, you can simply copy/paste the `oc` commands and run them from DOS, Powershell, or another terminal such as Cygwin or Linux Subsystems for Windows.
    * If you want to use `kubectl` instead, run `setup-kubectl.sh`.
2. Login using the `oc` cli tool as a cluster admin (you can use the `kubeadmin` user and password supplied when you start CodeReady Containers).
3. Run `./setup.sh` to install the Argo CD operator and instantiate an instance of Argo CD.
4. Be sure to note the Argo CD password printed when the script completes.  The default Argo CD password is the name of the main Argo CD pod.