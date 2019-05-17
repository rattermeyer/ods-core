#!/usr/bin/env bash

echo "whoami : $(whoami)"
set -e

if [ "${1:0:1}" != '-' ]; then
  exec "$@"
fi

# Parse Docker env vars to customize SonarQube
#
# e.g. Setting the env var sonar.jdbc.username=foo
#
# will cause SonarQube to be invoked with -Dsonar.jdbc.username=foo

declare -a sq_opts

while IFS='=' read -r envvar_key envvar_value
do
    if [[ "$envvar_key" =~ sonar.* ]] || [[ "$envvar_key" =~ ldap.* ]]; then
        sq_opts+=("-D${envvar_key}=${envvar_value}")
    fi
done < <(env)

# Update sonar.properties for crowd plugin
echo "sonar.security.realm=Crowd" >> conf/sonar.properties
echo "crowd.url=$SONARQUBE_CROWD_URL" >> conf/sonar.properties
echo "crowd.application=$SONARQUBE_CROWD_APP" >> conf/sonar.properties
echo "crowd.password=$SONARQUBE_CROWD_PWD" >> conf/sonar.properties
echo "sonar.security.localUsers=admin" >> conf/sonar.properties

# Copy plugins into volume
mkdir -p $SONARQUBE_HOME/extensions/plugins
for FILENAME in /opt/configuration/sonarqube/plugins/*; do
  plugin=$(basename $FILENAME)
  cp $FILENAME $SONARQUBE_HOME/extensions/plugins/$plugin
done

exec java -jar lib/sonar-application-$SONAR_VERSION.jar \
  -Dsonar.log.console=true \
  -Dsonar.jdbc.username="$SONARQUBE_JDBC_USERNAME" \
  -Dsonar.jdbc.password="$SONARQUBE_JDBC_PASSWORD" \
  -Dsonar.jdbc.url="$SONARQUBE_JDBC_URL" \
  -Dsonar.web.javaAdditionalOpts="$SONARQUBE_WEB_JVM_OPTS -Djava.security.egd=file:/dev/./urandom" \
  "${sq_opts[@]}" \
  "$@"
