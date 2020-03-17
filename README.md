# GitOps Demo

A small GitOps demo you can run on your own cluster.

## What's Included

* Argo CD
* CI/CD tools - Only Jenkins for the demo
* Demo App (Spring Petclinic)

## Prerequisites

* [CodeReady Containers 1.6+](https://developers.redhat.com/products/codeready-containers/overview) - It's free!  Sign up for a free Red Hat account to download and install CodeReady Containers.
* [oc command line tool](https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/) or `kubectl`

## 1: Install Argo CD

1. Login using the `oc` cli tool as a cluster admin (you can use the `kubeadmin` username and password supplied when you start CodeReady Containers).
2. Clone [00-gitups-setup](https://github.com/pittar-gitops/99-gitops-demo) and run `setup.sh` to install Argo CD on your cluster.
    * If you are using Windows, you can simply copy/paste the `oc` commands and run them from DOS, Powershell, or another terminal such as Cygwin or Linux Subsystems for Windows.
    * If you want to use `kubectl` instead, first create the `argocd` project, then manually run the `oc` commands using `kubectl` instead.
3. Be sure to note the Argo CD password printed when the script completes.  The default Argo CD password is the name of the main Argo CD pod.
4. Login to the Argo CD console:
    * Run `oc get route argocd-server -n argocd` to get the URL for your server.
    * Open the URL in a browser tab and login with user `admin` and the password printed in the terminal after the opertor finishes installing.
4. Login to the OpenShift console.
    * Run `crc console` to open the OpenShift console in a new browser tab.
    * Login to OpenShift using the `kubeadmin` username and password printed in the terminal when it started.

## 2: Install Demo

1. Clone [00-gitups-setup](https://github.com/pittar-gitops/99-gitops-demo) and switch to the `00-gitops-setup` directory.
2. Create the Argo CD *Projects*.  These projects will hold the different Argo CD *Applications*.
    * `oc apply -f projects`
    * This will create Argo CD *projects* for the *demo app*, *cluster configuration*, and *ci/cd tools*.
3. Create the **config** application.
    * `oc apply -f applications/demo-config.yaml`
    * In the Argo CD UI, you will notice a new application appear and begin the *sync* process.
    * This will create:
        * Three new projects/namespaces: `cicd`, `demo-dev`, `demok-test`
        * Qutoas and Limits in the `demo-app` and `demo-test` projects.
        * Roles and role bindings to allow Jenkins (in the `cicd` project) to have *admin* access to the `demo-dev` and `demo-test` projects in order to deploy new container images.
4. Create the **demo-cicd** application.
    * `oc apply -f applications/demo-cicd.yaml`
    * In the Argo CD UI, you will notice a new application appear and begin the *sync* process.
    * This will create:
        * A new Jenkins instance in the `cicd` project.  It will take a minute or two for the Jenkins pod to fully start and become ready to run builds.
5. Create the **demo-builds** application.
    * `oc apply -f applications/demo-builds.yaml`
    * In the Argo CD UI, you will notice a new application appear and begin the *sync* process.
    * This will create:
        * A Jenkins Pipeline build, as well as a *binary source-to-image* build config in the `cicd` project.
        * A new `ImageStream` that will track the container images Jenkins will build.
6. Create the **demo-app-dev** and **demo-app-test** applications.
    * `oc apply -f applications/demo-builds.yaml`
    * `oc apply -f applications/demo-builds.yaml`