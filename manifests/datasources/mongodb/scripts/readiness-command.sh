#!/bin/bash
mongosh \
    --authenticationDatabase "admin" \
    --username "${MONGO_APP_USERNAME}" \
    --password "${MONGO_APP_PASSWORD}" \
    --eval "db.adminCommand('ping').ok" \
    --quiet
