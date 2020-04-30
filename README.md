# jenkins-slave

jenkins 运行在k8s中，日常job工作在slave中运行，涉及到 java 、nodejs 编译、docker image 打包，deploy 到k8s 中，所以将需要的依赖打包在一起。 

### 内置环境：
```
python2.7
python3
docker
java 1.8.0
maven 3.6.3
node 11.10.0
kubectl 1.17.2
```
### 编译镜像
```
add kubectl 
slave.jar 通过部署在k8s中的jenkins master 节点地址下载
kubectl get svc -n jenkins 查看 CLUSTER-IP和PORT
wget CLUSTER-IP:PORT/slave.jar
docker build  -t registry.cn-zhangjiakou.aliyuncs.com/cryptape/jenkins-slave:v3 .
```
### 获取已编译镜像
```
docker pull  registry.cn-zhangjiakou.aliyuncs.com/cryptape/jenkins-slave:v3
```


 