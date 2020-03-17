# GitOps Demo

A small GitOps demo you can run on your laptop.

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

1. Clone [99-gitops-demo](https://github.com/pittar-gitops/99-gitops-demo) and switch to the `99-gitops-demo` directory.
2. Create the Argo CD *Projects*.  These projects will hold the different Argo CD *Applications*.
    * `oc apply -f projects`
    * This will create Argo CD *projects* for the *demo app*, *cluster configuration*, and *ci/cd tools*.
3. Create the **config** application.
    * `oc apply -f applications/demo-config.yaml`
    * In the Argo CD UI, you will notice a new application appear and begins the *sync* process.
    * This will create:
        * Three new projects/namespaces: `cicd`, `demo-dev`, `demo-test`
        * Qutoas and Limits in the `demo-app` and `demo-test` projects.
        * Roles and role bindings to allow Jenkins (in the `cicd` project) to have *admin* access to the `demo-dev` and `demo-test` projects in order to deploy new container images.
4. Create the **demo-cicd** application.
    * `oc apply -f applications/demo-cicd.yaml`
    * In the Argo CD UI, you will notice a new application appear and begins the *sync* process on this application.
    * This will create:
        * A new Jenkins instance in the `cicd` project.  It will take a minute or two for the Jenkins pod to fully start and become ready to run builds.
5. Create the **demo-builds** application.
    * `oc apply -f applications/demo-builds.yaml`
    * In the Argo CD UI, you will notice a new application appear and begins the *sync* process on this application.
    * This will create:
        * A Jenkins Pipeline build, as well as a *binary source-to-image* build config in the `cicd` project.
        * A new `ImageStream` that will track the container images Jenkins will build.
6. Create the **demo-app-dev** and **demo-app-test** applications.
    * `oc apply -f applications/demo-app-dev.yaml`
    * `oc apply -f applications/demo-app-test.yaml`
    * This will setup the `DeploymentConfig`, `Service`, and `Route`in each environment.
    * It will also apply the appropriate *Kustomizations* to each environment.  For example, each environment needs to use a different container image tag and have a different `Route` url.
7. Done!  Your environment is now setup.  It's also completely reproducible!

Now, if you delete your CodeReady Containers instance and follow the instructions above, you will have your environment back exactly how it should be.  This is the real power of GitOps!

## Explore

Take a moment to explore what was created, either with the OpenShift UI or the `oc` cli tool.  

Take a look at what now exists in the `cicd` project (you should see Jenkins, an `ImageStream`, and two `BuildConfig`s).

In the `demo-dev` and `demo-test` projects you will see the application is setup, but not yet running.  If you explore the `DeploymentConfig` in each project you will see they each are using a different `tag` (`:dev` for the DEV project, `:test` for the TEST project).  If you check *Project Access* you will also notice the *Jenkins* service account has `admin` access to these projects.

## Build and Deploy

* From the `cicd` project in the OpenShift UI, click on **Builds** item from the left navigation panel.
* Click on the `petclinic-jenkins-pipeline` link.
* From `Action` drop down list at the top-right of the screen, select **Start Build**.
* Alternatively, you can start the build with `oc`: `oc start-build petclinic-jenkins-pipeline -n cicd`

This triggeres a Jenkins pipeline build. This will follow the steps in the `Jenkinsfile` located in the root of the associated git repository.  You can view this file here:
[Jenkinsfile](https://github.com/pittar/spring-petclinic/blob/master/Jenkinsfile)

You can follow along with the build in the OpenShift UI, or you can follow the logs in Jenkins.

Once the build is complete, it will *tag* the container image with *dev* and *test* and rollout these changes to the appropriate projects.

You can then see your running dev and test apps!
