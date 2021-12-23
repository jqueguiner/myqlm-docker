#!/usr/bin/env bash
set -eu

#test -x /usr/local/bin/extract_workspace.sh && /usr/local/bin/extract_workspace.sh

jupyter lab --ip=0.0.0.0 --port=8080 --no-browser --allow-root \
  --LabApp.token='' \
  --LabApp.custom_display_url=${JOB_URL_SCHEME}${JOB_ID}-8080.${JOB_HOST} \
  --LabApp.allow_remote_access=True \
  --LabApp.allow_origin='*' \
  --LabApp.disable_check_xsrf=True
