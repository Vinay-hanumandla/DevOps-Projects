# last_verified: 2026-10-14 · Jenkins shared library scaffold
# Docker test harness for testing Jenkins shared library steps
# Uses Jenkins Pipeline Unit Testing framework (https://github.com/jenkinsci/JenkinsPipelineUnit)

FROM jenkins/inbound-agent:latest-jdk17

USER root

# Install dependencies for testing
RUN apt-get update && apt-get install -y \
    groovy \
    git \
    curl \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Install Jenkins Pipeline Unit
ARG PIPELINE_UNIT_VERSION=2.8
RUN curl -L -o /tmp/JenkinsPipelineUnit.zip \
    "https://github.com/jenkinsci/JenkinsPipelineUnit/releases/download/${PIPELINE_UNIT_VERSION}/JenkinsPipelineUnit-${PIPELINE_UNIT_VERSION}.zip" \
    && unzip /tmp/JenkinsPipelineUnit.zip -d /opt/jenkins-pipeline-unit \
    && rm /tmp/JenkinsPipelineUnit.zip

# Set up Groovy classpath
ENV GROOVY_CLASSPATH=/opt/jenkins-pipeline-unit/lib/*

# Copy test files
COPY tests/ /workspace/tests/
COPY vars/ /workspace/vars/
COPY src/ /workspace/src/

WORKDIR /workspace

# Default command runs all tests
CMD ["groovy", "-cp", "/opt/jenkins-pipeline-unit/lib/*:/workspace/src", "/workspace/tests/runAllTests.groovy"]