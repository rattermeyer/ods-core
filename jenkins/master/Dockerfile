FROM registry.access.redhat.com/openshift3/jenkins-2-rhel7

ARG APP_DNS=192.168.99.100.nip.io
ARG ENABLING_DNS=192.168.56.31.nip.io

USER root
RUN yum -y install openssl gnutls-utils

# fetch certificates and store them in tmp directory
RUN echo ${APP_DNS} && \
    gnutls-cli --insecure --print-cert ${APP_DNS} </dev/null| sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > /etc/pki/ca-trust/source/anchors/oc_app.crt && \
    gnutls-cli --insecure --print-cert ${ENABLING_DNS} </dev/null| sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' >> /etc/pki/ca-trust/source/anchors/oc_enabling.crt && \
    update-ca-trust

COPY plugins.txt /opt/openshift/configuration/plugins.txt
COPY kube-slave-common.sh /usr/local/bin/kube-slave-common.sh
RUN /usr/local/bin/install-plugins.sh /opt/openshift/configuration/plugins.txt && \
    rm -r /opt/openshift/configuration/jobs/OpenShift* && \
    touch /var/lib/jenkins/configured
COPY configuration/ /opt/openshift/configuration/
ENV JENKINS_JAVA_OVERRIDES="-Dhudson.tasks.MailSender.SEND_TO_UNKNOWN_USERS=true -Dhudson.tasks.MailSender.SEND_TO_USERS_WITHOUT_READ=true"
USER jenkins
