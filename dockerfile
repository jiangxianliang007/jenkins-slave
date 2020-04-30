FROM ubuntu:18.04

ENV TIMEZONE=Asia/Shanghai \
    LANG=zh_CN.UTF-8 

RUN rm /bin/sh && ln -s /bin/bash /bin/sh

RUN echo "${TIMEZONE}" > /etc/timezone \
    && echo "$LANG UTF-8" > /etc/locale.gen \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get -y install --no-install-recommends \
       apt-utils \
       dialog \
       curl wget \
       openssh-server \
       bzip2 \
       jq \
       unzip \
       zip \ 
       gnupg2 \
       git \
       docker \
       python2.7 \
       python3 \
       python3-pip \
       libcurl4-openssl-dev \
       locales \
       build-essential \
       ca-certificates \
       apt-transport-https \
       software-properties-common \
    && update-locale LANG=$LANG \ 
    && locale-gen $LANG \
    && DEBIAN_FRONTEND=noninteractive dpkg-reconfigure locales \
    && ln -sf /usr/share/zoneinfo/${TIMEZONE} /etc/localtime \ 
    && mkdir -p /home/jenkins/.jenkins \ 
    && mkdir -p /home/jenkins/agent \ 
    && mkdir -p /usr/share/jenkins \ 
    && mkdir -p /root/.kube 

RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - \
    && echo "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable" > /etc/apt/sources.list.d/docker-stable.list \
    && apt-get update \ 
    && apt-get install -y --no-install-recommends docker-ce \
    && apt-get clean \
    && apt-get autoclean \
    && rm -rf /var/lib/apt/lists/*

ENV JDK_VERSION jdk-8u251-linux-x64
RUN mkdir /usr/local/java
ADD https://code.aliyun.com/kar/oracle-jdk/raw/3c932f02aa11e79dc39e4a68f5b0483ec1d32abe/${JDK_VERSION}.tar.gz /usr/local/java/
RUN cd /usr/local/java \
    && tar zxvf ${JDK_VERSION}.tar.gz \
    && rm -rf ${JDK_VERSION}.tar.gz
ENV JAVA_HOME /usr/local/java/jdk1.8.0_251
ENV JRE_HOME $JAVA_HOME/jre
ENV CLASSPATH $JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar:$JRE_HOME/lib:$CLASSPATH
#ENV PATH $JAVA_HOME/bin:$PATH

ENV MAVEN_VERSION 3.6.3
ADD https://downloads.apache.org/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz /usr/local/
RUN cd /usr/local \
    && tar zxvf apache-maven-${MAVEN_VERSION}-bin.tar.gz \
    && rm -rf apache-maven-${MAVEN_VERSION}-bin.tar.gz 
ENV MAVEN_HOME /usr/local/apache-maven-${MAVEN_VERSION}
#ENV PATH $MAVEN_HOME/bin:$PATH

ENV NVM_DIR /usr/local/nvm
ENV NODE_VERSION 11.10.0

WORKDIR $NVM_DIR

RUN curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.35.2/install.sh | bash \
    && . $NVM_DIR/nvm.sh \
    && nvm install $NODE_VERSION \
    && npm install yarn -g
ENV NODE_PATH $NVM_DIR/versions/node/v$NODE_VERSION/lib/node_modules
ENV PATH     $JAVA_HOME/bin:$PATH:$MAVEN_HOME/bin:$PATH:$NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

COPY kubectl /usr/bin/kubectl 
COPY jenkins-slave /usr/bin/jenkins-slave 
COPY slave.jar /usr/share/jenkins
RUN chmod +x /usr/bin/jenkins-slave \
    && chmod +x /usr/bin/kubectl

USER root

WORKDIR /home/jenkins

ENTRYPOINT "jenkins-slave"

