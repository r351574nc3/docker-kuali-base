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
    --header "Cookie: atgPlatoStop=1; s_nr=1403896436303; s_cc=true; oraclelicense=accept-securebackup-cookie; gpw_e24=http%3A%2F%2Fwww.oracle.com%2Ftechnetwork/java/javase%2Fdownloads%2Fjdk7-downloads-1880260.html; s_sq=%5B%5BB%5D%5D" \
     -O /tmp/jdk-7u65-linux-x64.rpm http://download.oracle.com/otn-pub/java/jdk/7u65-b17/jdk-7u65-linux-x64.rpm

RUN yum install -y /tmp/jdk-7u65-linux-x64.rpm

RUN rm -f /tmp/jdk*

RUN wget --no-verbose -O /tmp/apache-maven-$MAVEN_VERSION.tar.gz \
    http://archive.apache.org/dist/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz

# Verify Download
RUN echo "87e5cc81bc4ab9b83986b3e77e6b3095  /tmp/apache-maven-$MAVEN_VERSION.tar.gz" | \
    md5sum -c

RUN tar -xzf /tmp/apache-maven-$MAVEN_VERSION.tar.gz 
RUN mv apache-maven-$MAVEN_VERSION /usr/local
RUN ln -s /usr/local/apache-maven-$MAVEN_VERSION /usr/local/apache-maven
RUN ln -s /usr/local/apache-maven/bin/* /usr/local/bin

RUN rm -f /tmp/apache*

ENV MAVEN_OPTS -Xmx2g -XX:MaxPermSize=256m 

RUN svn export https://svn.kuali.org/repos/rice/tags/rice-2.4.2/db

WORKDIR db/impex/master

RUN cp /files/my.cnf /etc

RUN pwd && /usr/bin/mysqld_safe & mvn clean install -Pdb,mysql -Dimpex.dba.password=NONE 

RUN rm -rf /db 
