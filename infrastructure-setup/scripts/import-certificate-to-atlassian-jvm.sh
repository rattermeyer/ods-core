#!/usr/bin/env bash
# Import certificate to JVM
export PATH=$PATH:/usr/local/bin/

BASE_DIR=${OPENDEVSTACK_DIR:-"/ods"}
cwd=${pwd}

if [ "$HOSTNAME" != "atlassian" ] ; then
	echo "This script has to be executed on the atlassian VM"
	exit
fi

JRE_PATH="/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.201.b09-2.el7_6.x86_64"

${JRE_PATH}/jre/bin/keytool -delete -alias openshift -keystore ${JRE_PATH}/jre/lib/security/cacerts -storepass changeit
${JRE_PATH}/jre/bin/keytool -delete -alias oc_router -keystore ${JRE_PATH}/jre/lib/security/cacerts -storepass changeit
${JRE_PATH}/jre/bin/keytool -delete -alias oc_registry -keystore ${JRE_PATH}/jre/lib/security/cacerts -storepass changeit

openssl s_client -connect 192.168.56.101:8443 -showcerts < /dev/null 2>/dev/null| sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > ${BASE_DIR}/openshift.crt
yes yes | ${JRE_PATH}/jre/bin/keytool -import -alias openshift -keystore ${JRE_PATH}/jre/lib/security/cacerts -storepass changeit -file ${BASE_DIR}/openshift.crt
yes yes | ${JRE_PATH}/jre/bin/keytool -import -alias oc_router -keystore ${JRE_PATH}/jre/lib/security/cacerts -storepass changeit -file ${BASE_DIR}/certs/router.crt
yes yes | ${JRE_PATH}/jre/bin/keytool -import -alias oc_registry -keystore ${JRE_PATH}/jre/lib/security/cacerts -storepass changeit -file ${BASE_DIR}/certs/registry.crt
