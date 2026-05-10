#!/bin/bash

# MongoDB Readiness Check Script
# Designed for Kubernetes readiness probes
# Returns 0 when MongoDB replica set member is ready to accept connections

set -euo pipefail

# Configuration
DB_HOST="${MONGODB_HOST:-127.0.0.1}"
MONGODB_PORT="${MONGODB_PORT:-27017}"
MONGO_USER="${MONGO_INITDB_ROOT_USERNAME:-}"
MONGO_PASS="${MONGO_INITDB_ROOT_PASSWORD:-}"

# Logging function
log() {
    echo "[READINESS] $1" >&2
}

# Check if MongoDB is ready
check_mongodb_readiness() {
    local auth_string=""
    local use_auth="$1"
    
    # Build connection string based on auth requirement
    if [ "$use_auth" = "true" ] && [ -n "${MONGO_USER}" ] && [ -n "${MONGO_PASS}" ]; then
        auth_string="${MONGO_USER}:${MONGO_PASS}@"
    fi
    
    local connection_string="mongodb://${auth_string}${DB_HOST}:${MONGODB_PORT}/admin"
    if [ "$use_auth" = "true" ] && [ -n "${MONGO_USER}" ]; then
        connection_string="${connection_string}?authSource=admin"
    fi
    
    # Execute readiness check with timeout
    local result
    result=$(mongosh "${connection_string}" --quiet --eval '
        try {
            // First check basic connectivity
            const ping = db.adminCommand({ ping: 1 });
            if (!ping.ok) {
                print("PING_FAILED");
                quit(1);
            }
            
            // Get replica set status
            const hello = db.hello();
            
            // Check if replica set is configured
            if (!hello.setName) {
                // No replica set configured yet
                print("NO_REPLSET");
                quit(1);
            }
            
            // Check member state
            if (hello.isWritablePrimary === true) {
                print("PRIMARY");
                quit(0);
            } else if (hello.secondary === true) {
                print("SECONDARY");
                quit(0);
            } else if (hello.arbiterOnly === true) {
                print("ARBITER");
                quit(0);
            } else {
                // Member is in transition state (STARTUP, RECOVERING, etc.)
                const state = hello.myState || "UNKNOWN";
                print("TRANSITIONING:" + state);
                quit(1);
            }
        } catch(e) {
            if (e.code === 13 || e.codeName === "Unauthorized") {
                print("AUTH_REQUIRED");
                quit(2);
            } else if (e.code === 94 || e.codeName === "NotYetInitialized") {
                print("NOT_INITIALIZED");
                quit(1);
            } else {
                print("ERROR:" + e.code + ":" + e.message);
                quit(1);
            }
        }
    ' 2>/dev/null || echo "FAILED:$?")
    
    echo "$result"
    
    # Determine exit code based on result
    case "$result" in
        PRIMARY|SECONDARY|ARBITER)
            return 0
            ;;
        AUTH_REQUIRED)
            return 2
            ;;
        *)
            return 1
            ;;
    esac
}

# Main readiness check logic
main() {
    log "Checking MongoDB readiness on ${DB_HOST}:${MONGODB_PORT}"

    # Try with auth first when credentials are available — avoids a redundant
    # no-auth mongosh invocation that would exceed the probe timeout.
    if [ -n "${MONGO_USER}" ] && [ -n "${MONGO_PASS}" ]; then
        result=$(check_mongodb_readiness "true")
        exit_code=$?

        if [ $exit_code -eq 0 ]; then
            log "MongoDB is ready (with auth): $result"
            exit 0
        else
            log "MongoDB not ready (with auth): $result"
            exit 1
        fi
    fi

    # No credentials available — fall back to unauthenticated check
    result=$(check_mongodb_readiness "false")
    exit_code=$?

    if [ $exit_code -eq 0 ]; then
        log "MongoDB is ready (no auth): $result"
        exit 0
    else
        log "MongoDB not ready: $result"
        exit 1
    fi
}

# Execute main function
main
