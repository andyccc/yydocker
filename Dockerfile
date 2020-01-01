FROM livingobjects/jre8


# 在宿主机内部使用sed调整docker容器文件内容
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories
#RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories
RUN apk add --update-cache bash

#采用国内阿里云的源，文件内容为：
#https://mirrors.aliyun.com/alpine/v3.6/main/ https://mirrors.aliyun.com/alpine/v3.6/community/

#如果采用中国科技大学的源，文件内容为：
#https://mirrors.ustc.edu.cn/alpine/v3.6/main/ https://mirrors.ustc.edu.cn/alpine/v3.6/community/

# ---not shown here--- 解决中文乱码 https://blog.carlwang.top/article/12

# Install language pack
RUN apk --no-cache add ca-certificates wget && \
    wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub && \
    wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.25-r0/glibc-2.25-r0.apk && \
    wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.25-r0/glibc-bin-2.25-r0.apk && \
    wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.25-r0/glibc-i18n-2.25-r0.apk && \
    apk add glibc-bin-2.25-r0.apk glibc-i18n-2.25-r0.apk glibc-2.25-r0.apk

# Iterate through all locale and install it
# Note that locale -a is not available in alpine linux, use `/usr/glibc-compat/bin/locale -a` instead
COPY ./locale.md /locale.md
RUN cat locale.md | xargs -i /usr/glibc-compat/bin/localedef -i {} -f UTF-8 {}.UTF-8

# Set the lang, you can also specify it as as environment variable through docker-compose.yml
ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8

# --- not show here---


# 这个镜像 'FROM adoptopenjdk/openjdk8' 直接含 jps、jstack等工具


# 安装openjdk8 添加 jps、jstack、jmap的支持
RUN apk add openjdk8
# 添加arthas 支持
RUN wget https://alibaba.github.io/arthas/arthas-boot.jar
# 调用：java -jar /arthas-boot.jar

#RUN echo "export JAVA_HOME=/usr/lib/jvm/java-1.8-openjdk" >> /etc/profile
#RUN echo "export CLASSPATH=.:$JAVA_HOME/jre/lib/rt.jar:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar"  >> /etc/profile
#RUN echo "export PATH=$PATH:$JAVA_HOME/bin"  >> /etc/profile

# 暂时没想到其他方式，先这么用着
RUN ln -s /usr/lib/jvm/java-1.8-openjdk/bin/jps /usr/bin/jps
RUN ln -s /usr/lib/jvm/java-1.8-openjdk/bin/jstack /usr/bin/jstack
RUN ln -s /usr/lib/jvm/java-1.8-openjdk/bin/jmap /usr/bin/jmap
RUN ln -s /usr/lib/jvm/java-1.8-openjdk/bin/jstat /usr/bin/jstat


VOLUME /tmp
WORKDIR /app

EXPOSE 6010

ENTRYPOINT ["sh", "start.sh"]
