#!/bin/bash
# ==============================================================================
# Smoke Tests
# Purpose: E2E validation of deployed web application
# ==============================================================================

set -euo pipefail

# Validate required parameters
: "${VM_IP:?VM_IP not set}"

readonly URL="http://$VM_IP"
EXIT_CODE=0

echo "🧪 === SMOKE TESTS E2E ==="
echo "Target: $URL"
echo ""

# ==============================================================================
# Test 1: HTTP Status 200
# ==============================================================================
echo "Test 1: Verify HTTP 200..."
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$URL")

if [ "$HTTP_STATUS" = "200" ]; then
  echo "✅ HTTP 200 OK"
else
  echo "❌ HTTP $HTTP_STATUS - Expected 200"
  EXIT_CODE=1
fi

# ==============================================================================
# Test 2: Nginx Header
# ==============================================================================
echo "Test 2: Verify Nginx header..."
if curl -sI "$URL" | grep -i "nginx"; then
  echo "✅ Nginx header present"
else
  echo "❌ Nginx header not found"
  EXIT_CODE=1
fi

# ==============================================================================
# Test 3: Content Check
# ==============================================================================
echo "Test 3: Verify content..."
if curl -s "$URL" | grep -i "Deployed with Terraform"; then
  echo "✅ Content correct"
else
  echo "❌ Content not found"
  EXIT_CODE=1
fi

# ==============================================================================
# Summary
# ==============================================================================
echo ""
if [ $EXIT_CODE -eq 0 ]; then
  echo "✅ === ALL SMOKE TESTS PASSED ==="
else
  echo "❌ === SOME TESTS FAILED ==="
fi

exit $EXIT_CODE
