# Luceo-K8s

Personal learnings with Kubernetes.

## Useful Resources
* [OpenShift's Intro to k8s](http://kubernetesbyexample.com/)
* [Official Documentation](https://kubernetes.io/docs/home/)
* [Official tutorial](https://kubernetes.io/docs/tutorials/kubernetes-basics/)

# Getting Started

You will need a [Google Cloud Platform](https://cloud.google.com/) account.
Check out the [free trial](https://console.cloud.google.com/freetrial).

Perform the following steps:

1. [Google Cloud SDK](#google-cloud-sdk-setup)
2. [Terraform](#terraform-setup)
3. [Kubectl](#kubectl-setup)

## Google Cloud SDK Setup

[Download and follow the instructions](https://cloud.google.com/sdk/downloads).
The `gcloud` CLI is included.

## Terraform Setup

[Install Terraform](https://www.terraform.io/downloads.html) and create a
[JSON authentication file](https://www.terraform.io/docs/providers/google/index.html#authentication-json-file) for your GCP project.

### Create authentication file

Update the variable `gcp_credentials_file` found in
`terraform/variables/variables.tfvars` with the file path of the JSON
authentication file you generated above. A recommended path would be
`~/.gcp/<gcp-project-name>.json`.

### Create project

Create a project in GCP.

Update the variable `project` in `terraform/variables/variables.tfvars` with
the project name you have created.

### Create k8s cluster name

Pick a name for your k8s cluster and update the variable `k8s_cluster_name` in
`terraform/variables/variables.tfvars`.

### Create secrets

Create a file called `secrets.tfvars` in the `terraform/variables/` directory.
Provide values for the following secrets:

```
k8s_username = ""
k8s_password = ""
```

### Initialise Terraform

In the `terraform` directory of this project, run:

```
$ terraform init
```

### Run Terraform

From the same directory, create a Terraform
[plan](https://www.terraform.io/docs/commands/plan.html):

```
$ terraform plan -var-file=variables/variables.tfvars -var-file=variables/secrets.tfvars -out=plan
```

To [apply](https://www.terraform.io/docs/commands/apply.html) the Terraform
plan you have just created:

```
$ terraform apply "plan"
```

This should create a
[Google Kubernetes Engine (GKE)](https://cloud.google.com/kubernetes-engine/)
cluster.

## Kubectl Setup

Install `kubectl` via the Google Cloud SDK:

```
$ gcloud components install kubectl
```

** NB. Make sure your GKE cluster exists from the previous step. **

Modify the `gcloud` (GCP CLI) default cluster. This means you can omit having to
provide `--cluster CLUSTER-NAME` from `gcloud` commands.

```
$ gcloud config set container/cluster <cluster-name>
```

Now fetch the cluster credentials for `kubectl`.

```
$ gcloud container clusters get-credentials <cluster-name>
```

The credentials will be stored in the file `~/.kube/config`.

Check that `kubectl` can access your cluster.

```
$ kubectl cluster-info

Kubernetes master is running at https://<ip>
GLBCDefaultBackend is running at https://<ip>/api/v1/namespaces/kube-system/services/default-http-backend/proxy
Heapster is running at https://<ip>/api/v1/namespaces/kube-system/services/heapster/proxy
KubeDNS is running at https://<ip>/api/v1/namespaces/kube-system/services/kube-dns/proxy
kubernetes-dashboard is running at https://<ip>/api/v1/namespaces/kube-system/services/kubernetes-dashboard/proxy

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.
```

# Kubernetes

## Namespaces

[Namespaces](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/) are virtual clusters within a physical cluster.

They are intended for teams with many (dozens) of users or when users are spread
across multiple teams/projects.

Essentially, namespaces provide a scope for names. Resource names inside a
namespace must be unique, but not across namespaces.

In a new, empty cluster you can view the available namespaces:

```
$ kubectl get namespaces
NAME          STATUS    AGE
default       Active    19h
kube-public   Active    19h
kube-system   Active    19h
```

Kubernetes starts with three initial namespaces:

* `default` - the default namespace
* `kube-system` - the namespace for objects created by the k8s system
* `kube-public` - this is created automatically and is readable by all users,
including unauthenticated ones. It is mostly reserved for cluster usage, in case
that some resources should be visible and publicly readable throughout the
cluster. The public aspect is convention, not a requirement.

### Viewing Resources within a namespace

To list all resources across all namespaces:

```
$ kubectl get --all-namespaces all
NAMESPACE     NAME                           DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
kube-system   deploy/event-exporter-v0.1.7   1         1         1            1           19h
kube-system   deploy/heapster-v1.4.3         1         1         1            1           19h
kube-system   deploy/kube-dns                1         1         1            1           19h
kube-system   deploy/kube-dns-autoscaler     1         1         1            1           19h
kube-system   deploy/kubernetes-dashboard    1         1         1            1           19h
kube-system   deploy/l7-default-backend      1         1         1            1           19h

NAMESPACE     NAME                                 DESIRED   CURRENT   READY     AGE
kube-system   rs/event-exporter-v0.1.7-958884745   1         1         1         19h
kube-system   rs/heapster-v1.4.3-3647254599        0         0         0         19h
kube-system   rs/heapster-v1.4.3-3927789093        1         1         1         19h
kube-system   rs/heapster-v1.4.3-449571852         0         0         0         19h
kube-system   rs/kube-dns-3092422022               1         1         1         19h
kube-system   rs/kube-dns-autoscaler-97162954      1         1         1         19h
kube-system   rs/kubernetes-dashboard-1914926742   1         1         1         19h
kube-system   rs/l7-default-backend-1798834265     1         1         1         19h

NAMESPACE     NAME                           DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
kube-system   deploy/event-exporter-v0.1.7   1         1         1            1           19h
kube-system   deploy/heapster-v1.4.3         1         1         1            1           19h
kube-system   deploy/kube-dns                1         1         1            1           19h
kube-system   deploy/kube-dns-autoscaler     1         1         1            1           19h
kube-system   deploy/kubernetes-dashboard    1         1         1            1           19h
kube-system   deploy/l7-default-backend      1         1         1            1           19h

NAMESPACE     NAME                                                     READY     STATUS    RESTARTS   AGE
kube-system   po/event-exporter-v0.1.7-958884745-c705g                 2/2       Running   0          19h
kube-system   po/fluentd-gcp-v2.0.9-9fs96                              2/2       Running   0          19h
kube-system   po/heapster-v1.4.3-3927789093-m42gg                      3/3       Running   0          19h
kube-system   po/kube-dns-3092422022-tpsng                             3/3       Running   0          19h
kube-system   po/kube-dns-autoscaler-97162954-t2hlz                    1/1       Running   0          19h
kube-system   po/kube-proxy-gke-luceo-k8s-default-pool-1ab79163-zs91   1/1       Running   0          19h
kube-system   po/kubernetes-dashboard-1914926742-dzxcl                 1/1       Running   0          19h
kube-system   po/l7-default-backend-1798834265-j4x39                   1/1       Running   0          19h
```

Here we can see the default services(??) that exist in an initial k8s cluster.
All the resources belong to the `kube-system` namespace and none exist for the
`default` and `kube-public` namespaces.

To target a specific namespace, simply include the flag `--namespace`. Let's
confirm that the `default` indeed has no resources:

```
$ kubectl get all --namespace=default
No resources found.
```

## Services

TODO

https://kubernetes.io/docs/concepts/services-networking/service/

`my-svc.my-namespace.svc.cluster.local`


## Labels

TODO

Labels are used to organise k8s objects.

## DNS

TODO

https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/
