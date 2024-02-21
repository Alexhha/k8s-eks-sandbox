## CKA/CKS: EKS Sandbox

I wrote it for personal use during preparation to CKA/CKS certifications. It allows you quickly setup EKS cluster with specific version and parameters. Supports 2 OS on worker nodes: `Amazon Linux2` and `Ubuntu` in both architectures `x86_64` and `arm64`.

### Prerequisites
You just need clone the repository, cd to `terraform/eks`directory and update AWS profile name in the following files: `provider.tf` and `templates/kube.config`
```
// provider.tf
provider "aws" {
    region  = var.region
    profile = "default" <== Replace with your own profile
}
```
```yaml
// templates/kube.config
- name: aws
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1beta1
      command: aws
      args:
        - "eks"
        - "get-token"
        - "--cluster-name"
        - "${eks_name}"
      env:
        - name: AWS_PROFILE
          value: "default" <== Replace with your own profile
        - name: AWS_DEFAULT_REGION
          value: "${eks_region}"
```
That's it. You are ready to go.

### Create EKS
It's pretty simple. Just run the following commands
```bash
$ terraform init
$ terraform apply
```
In 10-15 minutes you will get EKS cluster. All required information will be printed in the output
```
Apply complete! Resources: 22 added, 0 changed, 0 destroyed.

Outputs:

a0 = "-----------------------------------------------------------------"
eks_cluster_arn = "arn:aws:eks:eu-central-1:1234567890:cluster/eks-sandbox-0d3e6104"
eks_cluster_endpoint = "https://13A712BCAC53B752D6F6AA5710B9F820.gr7.eu-central-1.eks.amazonaws.com"
eks_cluster_id = "eks-sandbox-0d3e6104"
f0 = "-----------------------------------------------------------------"
node_group_id_amd64 = "eks-sandbox-0d3e6104:linux-amd64-al2-0d3e6104"
node_group_id_arm64 = "eks-sandbox-0d3e6104:linux-arm64-al2-0d3e6104"
node_group_id_win64 = "N/A"
node_group_instance = {
  "i-0760eba7ae7ca6ff3" = "3.xxx.yyy.zzz"
}
p0 = "-----------------------------------------------------------------"
```
Terraform generates kubeconfig `eks-sandbox.kubeconfig`. You can use it with kubectl to work with the cluster
```bash
$ export KUBECONFIG=terraform/eks/eks-sandbox.kubeconfig
$ kubectl get nodes
NAME                                            STATUS   ROLES    AGE   VERSION
ip-172-31-1-112.eu-central-1.compute.internal   Ready    <none>   12m   v1.28.5-eks-5e0fdde

$ kubectl get ns
NAME              STATUS   AGE
default           Active   7m45s
kube-node-lease   Active   7m45s
kube-public       Active   7m45s
kube-system       Active   7m45s

$ kubectl get pod -n kube-system
NAME                                  READY   STATUS    RESTARTS   AGE
aws-node-mxrh6                        2/2     Running   0          2m56s
coredns-648485486-58nph               1/1     Running   0          6m30s
coredns-648485486-7svsb               1/1     Running   0          6m30s
ebs-csi-controller-54786c59bc-7nngk   6/6     Running   0          2m52s
ebs-csi-controller-54786c59bc-gjp5b   6/6     Running   0          2m52s
ebs-csi-node-q49wb                    3/3     Running   0          2m52s
kube-proxy-6zq7l                      1/1     Running   0          4m2s
```
Run simple workload
```bash
$ kubectl run hello-world --image=nginx
pod/hello-world created

$ kubectl get pods
NAME          READY   STATUS    RESTARTS   AGE
hello-world   1/1     Running   0          7s

$ kubectl expose --name=nginx-svc pod/hello-world --port=80 --target-port=80 --type=LoadBalancer
service/nginx-svc exposed

$ kubectl describe svc nginx-svc
Name:                     nginx-svc
Namespace:                default
Labels:                   run=hello-world
Annotations:              <none>
Selector:                 run=hello-world
Type:                     LoadBalancer
IP Family Policy:         SingleStack
IP Families:              IPv4
IP:                       192.168.128.239
IPs:                      192.168.128.239
LoadBalancer Ingress:     acbd730bba1c239a47e6b4f04e04cab6-123456789.us-east-1.elb.amazonaws.com
Port:                     <unset>  80/TCP
TargetPort:               80/TCP
NodePort:                 <unset>  32116/TCP
Endpoints:                172.31.15.158:80
Session Affinity:         None
External Traffic Policy:  Cluster
Events:
  Type    Reason                Age   From                Message
  ----    ------                ----  ----                -------
  Normal  EnsuringLoadBalancer  54s   service-controller  Ensuring load balancer
  Normal  EnsuredLoadBalancer   52s   service-controller  Ensured load balancer

$ curl -i -I acbd730bba1c239a47e6b4f04e04cab6-123456789.us-east-1.elb.amazonaws.com
HTTP/1.1 200 OK
Server: nginx/1.25.4
Date: Wed, 21 Feb 2024 20:42:27 GMT
Content-Type: text/html
Content-Length: 615
Last-Modified: Wed, 14 Feb 2024 16:03:00 GMT
Connection: keep-alive
ETag: "65cce434-267"
Accept-Ranges: bytes

$ kubectl exec hello-world -- sh -c 'echo "Hello from EKS Sandbox" > /usr/share/nginx/html/index.html'
$ curl acbd730bba1c239a47e6b4f04e04cab6-123456789.us-east-1.elb.amazonaws.com
Hello from EKS Sandbox
```
Don't forget to explicitly delete `nginx-svc` service as it creates AWS ELB.
```bash
$ kubectl delete svc nginx-svc
service "nginx-svc" deleted
```

### Examples
Use `Ubuntu` on worker nodes instead of `Amazon Linux 2`. If you want to play with AppArmor
```bash
$ terraform apply -var eks_node_group_distro=ubuntu
```
Enable remote ssh access on worker nodes. You have to update ssh public key `files/k8s-eks-sandbox.pub` file before you enable remote access.
```bash
$ terraform apply -var remote_access_enabled=true
```
Use `ON_DEMAND` EC2 instances instead of `SPOT`
```bash
$ terraform apply -var capacity_type=ON_DEMAND
```
Enable `arm64` node group in addition to `amd64`
```bash
$ terraform apply -var arm64_enabled=true
```
Run `arm64` node group only
```bash
$ terraform apply -var arm64_enabled=true -var amd64_enabled=false

$ kubectl get nodes
NAME                                             STATUS   ROLES    AGE   VERSION
ip-172-31-12-120.eu-central-1.compute.internal   Ready    <none>   18m   v1.28.5-eks-5e0fdde

$ kubectl get node ip-172-31-12-120.eu-central-1.compute.internal -o json | jq -r '.metadata.labels."kubernetes.io/arch"'
arm64

$ kubectl run nginx-armd64 --image=arm64v8/nginx
pod/nginx-armd64 created

$ kubectl get pod
NAME           READY   STATUS    RESTARTS   AGE
nginx-armd64   1/1     Running   0          12s
```
Run k8s v1.29
```bash
$ terraform apply -var k8s_version=1.29
```
