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

# Get the Oracle XE
RUN rm -f /tmp/*.zip
RUN wget  --no-check-certificate --no-verbose --no-cookies \
    --header "Cookie: ARU_LANG=US; atgPlatoStop=1; s_nr=1403896436303; s_cc=true; oraclelicense=accept-sqldev-cookie; gpw_e24=http%3A%2F%2Fwww.oracle.com%2Ftechnetwork%2Fdatabase%2Fdatabase-technologies%2Fexpress-edition%2Fdownloads%2Findex.html; s_sq=oracleforums%3D%2526pid%253Dforums%25253Aen-us%25253A%25252Fthread%25252F2611952%2526pidt%253D1%2526oid%253Dhttp%25253A%25252F%25252Fwww.oracle.com%25252Ftechnetwork%25252Fdatabase%25252Ffeatures%25252Fjdbc%25252Fjdbc-drivers-12c-download-1958347.html%2526ot%253DA; ORASSO_AUTH_HINT=v1.0~20140716185438; OHS-edelivery.oracle.com-80=25DC03BF04E80FF0A5DD05FB18344BAA8C666AD7112F0DA2167E637A0D241136EFC303D05AE2303663976AF79BF8FACBA7A566C4A455917D55BB14A1D9956E68C29097F31B1D7C888F3A5F5712A91F4DFD625A4DCC3383ED99C6E6C0A818FA5CDB1D453CD1245B66D2EEB77E9620CFFC339BDD9C08D32408F7CCEC6CA29CEDFF6E319EE5EC83EAB6141514E3C0B4CE40AD78021280E284434F1AF231CC8C1F14535BFE941E6D076CFC097FBB3ACC600370E2073B1AC3777E09BA244C95D0E6DA2FEB8893EF611D4EAC08B777398ABC345B71023325EF5A5C70CACBFE162303617804162302A3C8DEA74130ED5FEF805D1E60992049700479~" \
     -O /tmp/oracle-xe-11.2.0-1.0.x86_64.rpm.zip  http://download.oracle.com/otn/linux/oracle11g/xe/oracle-xe-11.2.0-1.0.x86_64.rpm.zip 


RUN unzip /tmp/oracle-xe-11.2.0-1.0.x86_64.rpm.zip -d /tmp
RUN yum -y install /tmp/Disk1/oracle-xe-11.2.0-1.0.x86_64.rpm

RUN rm -f /tmp/*.zip
RUN rm -rf /tmp/Disk1

# Get the Oracle driver
RUN wget  --no-check-certificate --no-verbose --no-cookies \
    --header "Cookie: ARU_LANG=US; atgPlatoStop=1; s_nr=1403896436303; s_cc=true; oraclelicense=accept-classes12_10203-cookie; gpw_e24=http%3A%2F%2Fwww.oracle.com%2Ftechnetwork%2Fdatabase%2Ffeatures%2Fjdbc%2Fjdbc-drivers-12c-download-1958347.html; s_sq=oracleforums%3D%2526pid%253Dforums%25253Aen-us%25253A%25252Fthread%25252F2611952%2526pidt%253D1%2526oid%253Dhttp%25253A%25252F%25252Fwww.oracle.com%25252Ftechnetwork%25252Fdatabase%25252Ffeatures%25252Fjdbc%25252Fjdbc-drivers-12c-download-1958347.html%2526ot%253DA; ORASSO_AUTH_HINT=v1.0~20140714133443; OHS-edelivery.oracle.com-80=4F6BE8279E891DD2DBABA7EB45299A1B3AB03E3F2644D793868F9DDF060E33B48AFBA411B58EAD8516431CE5B5BF5BD96B2224246A361704E5675DD8D3F74C778BA5AD22AFE3333F62D51238D596EB5904BF43A04385C53A9EB3191548E43793B85CCCF321BD77399AD7F3E745B1EC37DD245A2D8F344C8F959AC353E8C2145773E542CEC0B38294658EFC93EDA35727A1D9502BA3F4256C1CF55E2DD2A13DA3DF6480D1F2B6906C03BFE98A7703B8C8AEACB2133B0201FC8E68203562D1A23C3218E23E4BE99DD64E8D85AC20364DBA0CD62EBDDA3718A6332BDCB837370B01B6E2784A451269636BF96777620DAB9295B37B6E1D123710~" \
     -O /tmp/ojdbc7.jar http://download.oracle.com/otn/utilities_drivers/jdbc/121010/ojdbc7.jar

#RUN source /u01/app/oracle/product/11.2.0/xe/bin/oracle_env.sh \
#   && usermod root -G root,dba &&
RUN su - oracle /files/runasoracle.sh

RUN mvn install:install-file -DgroupId=com.oracle -DartifactId=ojdbc7 -Dversion=$OJDBC_VERSION -Dpackaging=jar -Dfile=/tmp/ojdbc7.jar

RUN svn export https://svn.kuali.org/repos/rice/trunk/db

WORKDIR db/impex/master

RUN cp /files/my.cnf /etc

RUN /usr/bin/mysqld_safe & mvn clean install -Pdb,mysql -Dimpex.dba.password=NONE 
