FROM centos:centos6
MAINTAINER nattapon

RUN yum -y update && yum -y upgrade
RUN yum install -y chkconfig
RUN yum install -y httpd php openssh openssh-server openssh-clients sudo passwd

RUN useradd userb
RUN echo centos | passwd --stdin usera 
#RUN passwd -f -u deploy
RUN useradd deploy
RUN echo deploy | passwd --stdin deploy
RUN mkdir -p /home/deploy/.ssh; chown deploy /home/deploy/.ssh;chmod 700 /home/deploy/.ssh
ADD ./authorized_keys /home/deploy/.ssh/authorized_keys
RUN chown deploy /home/deploy/.ssh/authorized_keys;chmod 600 /home/deploy/.ssh/authorized_keys

RUN echo "deploy ALL=(ALL) ALL" >> /etc/sudoers.d/deploy

#ADD ./sshd_config /etc/ssh/sshd_config
RUN sed -ri "s/^UsePAM yes/#UsePAM yes/" /etc/ssh/sshd_config
RUN sed -ri "s/^#UsePAM no/UsePAM no/" /etc/ssh/sshd_config
RUN sed -ri "s/^#PubkeyAuthentication yes/PubkeyAuthentication yes/" /etc/ssh/sshd_config
RUN /etc/init.d/sshd start; /etc/init.d/sshd stop

EXPOSE 80 22

ENTRYPOINT /etc/init.d/httpd start && /etc/init.d/sshd start && /bin/bash
