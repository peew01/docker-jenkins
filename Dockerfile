FROM jenkins/jenkins:lts

USER root

# Install docker binary
ENV DOCKER_BUCKET download.docker.com
ENV DOCKER_VERSION 17.06.2-ce

RUN curl -fSL "https://${DOCKER_BUCKET}/linux/static/stable/x86_64/docker-${DOCKER_VERSION}.tgz" -o /tmp/docker-ce.tgz \
        && tar -xvzf /tmp/docker-ce.tgz --directory="/usr/local/bin" --strip-components=1 docker/docker \
	&& rm /tmp/docker-ce.tgz

# Install docker-compose
RUN curl -L https://github.com/docker/compose/releases/download/1.21.2/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose \
    && chmod +x /usr/local/bin/docker-compose

# Install plugins
RUN /usr/local/bin/install-plugins.sh \
  authentication-tokens \
  credentials-binding \
  docker-commons \
  docker-workflow:1.14 \
  icon-shim \
  xvnc \
  gerrit-trigger \
  git \
  ldap \
  matrix-auth \
  workflow-aggregator

# Add groovy setup config
COPY init.groovy.d/ /usr/share/jenkins/ref/init.groovy.d/

# Add Jenkins URL and system admin e-mail config file
COPY jenkins.model.JenkinsLocationConfiguration.xml /usr/local/etc/jenkins.model.JenkinsLocationConfiguration.xml

USER jenkins
# Generate jenkins ssh key.
COPY generate_key.sh /usr/local/bin/generate_key.sh

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
