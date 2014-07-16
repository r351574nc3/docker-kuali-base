FROM fedora:latest

MAINTAINER Leo Przybylski https://github.com/r351574nc3/

# Environment variables
ENV MAVEN_VERSION 3.2.2
ENV TOMCAT_VERSION 7.0.54
ENV OJDBC_VERSION 12.1.0.1

ADD files /files

RUN yum -y update --skip-broken -x iputils,systemd 
RUN yum -y install bc community-mysql community-mysql-server git subversion which wget systemd unzip; yum clean all

RUN mysql_install_db  --user=mysql; cat /var/log/mysqld.log

RUN wget  --no-check-certificate --no-verbose --no-cookies \
    --header "Cookie: atgPlatoStop=1; s_nr=1403896436303; s_cc=true; oraclelicense=accept-securebackup-cookie; gpw_e24=http%3A%2F%2Fwww.oracle.com%2Ftechnetwork%2Fjava%2Fjavase%2Fdownloads%2Fjdk8-downloads-2133151.html; s_sq=%5B%5BB%5D%5D" \
     -O /tmp/jdk-8u5-linux-x64.rpm http://download.oracle.com/otn-pub/java/jdk/8u5-b13/jdk-8u5-linux-x64.rpm

RUN yum install -y /tmp/jdk-8u5-linux-x64.rpm

RUN rm -f /tmp/jdk*

RUN wget --no-verbose -O /tmp/apache-maven-3.2.2.tar.gz \
    http://archive.apache.org/dist/maven/maven-3/3.2.2/binaries/apache-maven-3.2.2-bin.tar.gz

# Verify Download
RUN echo "87e5cc81bc4ab9b83986b3e77e6b3095  /tmp/apache-maven-3.2.2.tar.gz" | \
    md5sum -c

RUN tar -xzf /tmp/apache-maven-3.2.2.tar.gz 
RUN mv apache-maven-3.2.2 /usr/local
RUN ln -s /usr/local/apache-maven-3.2.2 /usr/local/apache-maven
RUN ln -s /usr/local/apache-maven/bin/* /usr/local/bin

RUN rm -f /tmp/apache*

ENV MAVEN_OPTS -Xmx2g -XX:MaxPermSize=256m 

RUN svn export https://svn.kuali.org/repos/rice/trunk/db

WORKDIR db/impex/master

RUN cp /files/my.cnf /etc

RUN /usr/bin/mysqld_safe & mvn clean install -Pdb,mysql -Dimpex.dba.password=NONE 
