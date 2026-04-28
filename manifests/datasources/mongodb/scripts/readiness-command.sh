#!/bin/bash
mongosh \
    --authenticationDatabase "admin" \
    --username "${MONGO_APP_USERNAME}" \
    --password "${MONGO_APP_PASSWORD}" \
    --eval "db.runCommand({ ping:1 }).ok" \
    --quiet
