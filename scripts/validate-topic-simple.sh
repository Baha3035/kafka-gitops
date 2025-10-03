#!/bin/bash
# Simple topic validation - checks only critical issues

TOPIC_FILE=$1
ERRORS=0

echo "Validating: $TOPIC_FILE"

# 1. Check replicas <= 3 (broker count)
REPLICAS=$(grep "replicas:" "$TOPIC_FILE" | awk '{print $2}')
if [ "$REPLICAS" -gt 3 ]; then
    echo "❌ Replicas ($REPLICAS) cannot exceed broker count (3)"
    ERRORS=$((ERRORS + 1))
fi

# 2. Check partitions is reasonable (1-12)
PARTITIONS=$(grep "partitions:" "$TOPIC_FILE" | awk '{print $2}')
if [ "$PARTITIONS" -lt 1 ] || [ "$PARTITIONS" -gt 12 ]; then
    echo "❌ Partitions must be between 1-12, got: $PARTITIONS"
    ERRORS=$((ERRORS + 1))
fi

# 3. Check has required label
if ! grep -q "strimzi.io/cluster:" "$TOPIC_FILE"; then
    echo "❌ Missing required label: strimzi.io/cluster"
    ERRORS=$((ERRORS + 1))
fi

if [ $ERRORS -eq 0 ]; then
    echo "✅ Validation passed"
    exit 0
else
    echo "❌ Validation failed with $ERRORS error(s)"
    exit 1
fi