#!/usr/bin/env bash
set -euo pipefail
: "${JIRA_BASE_URL:?}"
: "${JIRA_PROJECT_KEY:?}"
: "${JIRA_EMAIL:?}"
: "${JIRA_API_TOKEN:?}"

SUMMARY="${1:-Deploy completed}"
DESCRIPTION="${2:-Created by GitHub Actions (free-tier lab)}"

read -r -d '' PAYLOAD <<'JSON'
{
  "fields": {
    "project": {"key": "REPLACE_ME"},
    "summary": "REPLACE_SUMMARY",
    "description": "REPLACE_DESCRIPTION",
    "issuetype": {"name": "Task"}
  }
}
JSON

PAYLOAD="${PAYLOAD/REPLACE_ME/${JIRA_PROJECT_KEY}}"
PAYLOAD="${PAYLOAD/REPLACE_SUMMARY/${SUMMARY}}"
PAYLOAD="${PAYLOAD/REPLACE_DESCRIPTION/${DESCRIPTION}}"

curl -sS -X POST -H "Content-Type: application/json" \
  -u "${JIRA_EMAIL}:${JIRA_API_TOKEN}" \
  --data "${PAYLOAD}" \
  "${JIRA_BASE_URL}/rest/api/3/issue"
