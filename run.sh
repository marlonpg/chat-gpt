#!/bin/bash

export JAVA_HOME="C:/Users/gamba/.jdks/corretto-25.0.1"
export PATH="$JAVA_HOME/bin:$PATH"

echo "Starting Daily Devotional Bot..."
echo "JAVA_HOME: $JAVA_HOME"
echo "All logs will be displayed below:"
echo "================================"
echo ""

./mvnw spring-boot:run 2>&1
