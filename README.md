# GitOps Demo

A small GitOps demo you can run on your laptop.

## What's Included

* Argo CD - Both the Operator and an Argo CD server
* CI/CD tools - Only Jenkins for the demo
* Jenkins pipeline and *source-to-image* binary build to create a container image.
* Demo App (Spring Petclinic)
* Quotas, Limits, NetworkPolicies... oh my!

## Prerequisites

* [CodeReady Containers 1.6+](https://developers.redhat.com/products/codeready-containers/overview) - It's free!  Sign up for a free Red Hat account to download and install CodeReady Containers on your local machine.
* [oc command line tool](https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/) or `kubectl`

Since you will be running full fledged OpenShift 4 cluster, as well as Argo CD, Jenkins, Maven builds, container image builds, and two application environments, this demo does need a decent amount of resources.  This is the CodeReady Containers configuration that I have tested this demo on locally:

```
$ crc config view
- cpus                                  : 4
- memory                                : 12288
- nameserver                            : 
- pull-secret-file                      : /Users/pitta/Utils/crc/pull-secret.txt
- vm-driver                             : hyperkit
- warn-check-bundle-cached              : true
```

If you need to increase the number of cpu cores or memory your CodeReady Containers instance uses, run the commands:
```
$ crc config set cpus 4
$ crc config set memory 12288
```

Of course, if you have more CPU or Memory, you can bump those numbers up accordingly.  Please note the **cpu** number is *hyper-threded cores*.  For example, a 4-core Intil i7 would have 8 hyper-threaded cores.  In this scenario, giving CodeReady Containers *4 cpus* would allocate it half of the CPU resources of your computer.

## 1: Clone the Demo Repository

Clone this repository and change to the `99-gitops-demo` directory.

```
$ git clone https://github.com/pittar-gitops/99-gitops-demo.git
$ cd 99-gitops-demo
```

## 2: Install Argo CD

1. Login using the `oc` cli tool as a cluster admin (you can use the `kubeadmin` username and password supplied when you start CodeReady Containers).  The login command printed when CodeReady Containers starts should look something like:\
`oc login -u kubeadmin -p db9Dr-J2csc-8oP78-9sbmf https://api.crc.testing:6443`\
Of coure, your password will be different.
2. Run `./setup.sh` to install Argo CD on your cluster.
    * If you are using Windows, you can simply copy/paste the `oc` commands and run them from DOS, Powershell, or another terminal such as Cygwin or Linux Subsystems for Windows.
    * If you want to use `kubectl` instead, first create the `argocd` project, then manually run the `oc` commands using `kubectl` instead.
3. Be sure to note the Argo CD password printed when the script completes.  The default Argo CD password is the name of the main Argo CD pod.
4. Login to the Argo CD console:
    * Run `oc get route argocd-server -n argocd` to get the URL for your server.
    * Open the URL in a browser tab and login with user `admin` and the password printed in the terminal after the opertor finishes installing.
4. Login to the OpenShift console.
    * Run `crc console` to open the OpenShift console in a new browser tab.
    * Login to OpenShift using the `kubeadmin` username and password printed in the terminal when it started.

## 3: Install Demo

1. Create the Argo CD *Projects*.  These projects will hold the different Argo CD *Applications*.
    * `oc apply -f projects`
    * This will create Argo CD *projects* for the *demo app*, *cluster configuration*, and *ci/cd tools*.
2. Create the **config** application.
    * `oc apply -f applications/demo-config.yaml`
    * In the Argo CD UI, you will notice a new application appear and begins the *sync* process.
    * This will create:
        * Three new projects/namespaces: `cicd`, `demo-dev`, `demo-test`
        * Qutoas and Limits in the `demo-app` and `demo-test` projects.
        * Roles and role bindings to allow Jenkins (in the `cicd` project) to have *admin* access to the `demo-dev` and `demo-test` projects in order to deploy new container images.
3. Create the **demo-cicd** application.
    * `oc apply -f applications/demo-cicd.yaml`
    * In the Argo CD UI, you will notice a new application appear and begins the *sync* process on this application.
    * This will create:
        * A new Jenkins instance in the `cicd` project.  It will take a minute or two for the Jenkins pod to fully start and become ready to run builds.
4. Create the **demo-builds** application.
    * `oc apply -f applications/demo-builds.yaml`
    * In the Argo CD UI, you will notice a new application appear and begins the *sync* process on this application.
    * This will create:
        * A Jenkins Pipeline build, as well as a *binary source-to-image* build config in the `cicd` project.
        * A new `ImageStream` that will track the container images Jenkins will build.
5. Create the **demo-app-dev** and **demo-app-test** applications.
    * `oc apply -f applications/demo-app-dev.yaml`
    * `oc apply -f applications/demo-app-test.yaml`
    * This will setup the `DeploymentConfig`, `Service`, and `Route`in each environment.
    * It will also apply the appropriate *Kustomizations* to each environment.  For example, each environment needs to use a different container image tag and have a different `Route` url.
6. Done!  Your environment is now setup.  It's also completely reproducible!

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

You should be able to access your Jenkins instance at [https://jenkins-cicd.apps-crc.testing/](https://jenkins-cicd.apps-crc.testing/).  Login using your kubeadmin username and password.  This is integrated with OpenShift OAuth.

This triggeres a Jenkins pipeline build. This will follow the steps in the `Jenkinsfile` located in the root of the associated git repository.  You can view this file here:
[Jenkinsfile](https://github.com/pittar/spring-petclinic/blob/master/Jenkinsfile)

You can follow along with the build in the OpenShift UI, or you can follow the logs in Jenkins.

Once the build is complete, it will *tag* the container image with *dev* and *test* and rollout these changes to the appropriate projects.

You can then see your running dev and test apps!  They will be accessible at:
* DEV: [http://petclinic-dev.apps-crc.testing/](http://petclinic-dev.apps-crc.testing/)
* TEST: [http://petclinic-test.apps-crc.testing/](http://petclinic-test.apps-crc.testing/)

## Conclusion

Although this is a simple demo, it gives you a sense of how GitOps can fit into a well balanced CI/CD diet!
