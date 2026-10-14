// last_verified: 2026-10-14 · Jenkins shared library scaffold
// Shared utility classes for the library.

package com.example.jenkinslib

class DockerUtils {
    static String parseImageRef(String imageRef) {
        def parts = imageRef.split(':')
        if (parts.size() == 2) {
            return [registry: parts[0].split('/')[0], image: parts[0].split('/')[1], tag: parts[1]]
        }
        return null
    }

    static String buildImageName(String registry, String image, String tag) {
        return "${registry}/${image}:${tag}"
    }

    static String buildLatestRef(String registry, String image) {
        return "${registry}/${image}:latest"
    }
}

class K8sUtils {
    static String buildSetImageCommand(String deployment, String container, String imageRef, String namespace) {
        return "kubectl set image deployment/${deployment} ${container}=${imageRef} --namespace=${namespace}"
    }

    static String buildRolloutCommand(String deployment, String namespace, String timeout) {
        return "kubectl rollout status deployment/${deployment} --namespace=${namespace} --timeout=${timeout}"
    }
}

class GitUtils {
    static String getShortSha() {
        return sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
    }

    static String getBranchName() {
        return sh(script: 'git rev-parse --abbrev-ref HEAD', returnStdout: true).trim()
    }
}