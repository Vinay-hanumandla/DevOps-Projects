// last_verified: 2026-10-19
package com.example.jenkinslib

class Utils implements Serializable {
    def static sanitize(String input) {
        return input?.trim()?.replaceAll("\\s+", "-")?.toLowerCase()
    }
}
