#!/bin/bash

retry() {
    local n=0
    until [ "$n" -ge 3 ]; do
        "$@" && break
        n=$((n + 1))
        echo "Retrying... ($n/3)"
        sleep 10
    done
}
