#!/bin/sh

set -e

conf_path_param=""
if [ -n "${EBK_CONF_PATH}" ]; then
  conf_path_param="--conf-path=${EBK_CONF_PATH}"
fi

# Create initial admin user from env (only when all required vars are set)
if [ -n "${EBK_INIT_ADMIN_USERNAME}" ] && [ -n "${EBK_INIT_ADMIN_PASSWORD}" ] && [ -n "${EBK_INIT_ADMIN_EMAIL}" ]; then
  _nick="${EBK_INIT_ADMIN_NICKNAME:-${EBK_INIT_ADMIN_USERNAME}}"
  _currency="${EBK_INIT_ADMIN_DEFAULT_CURRENCY:-USD}"
  # Start server briefly so DB is created
  /ezbookkeeping/ezbookkeeping server run ${conf_path_param} &
  _pid=$!
  sleep 5
  # Add user (ignore error if user already exists)
  /ezbookkeeping/ezbookkeeping userdata user-add \
    --username "${EBK_INIT_ADMIN_USERNAME}" \
    --email "${EBK_INIT_ADMIN_EMAIL}" \
    --nickname "${_nick}" \
    --password "${EBK_INIT_ADMIN_PASSWORD}" \
    --default-currency "${_currency}" \
    2>/dev/null || true
  kill ${_pid} 2>/dev/null || true
  wait ${_pid} 2>/dev/null || true
fi

if [ $# -gt 0 ]; then
  exec "$@"
else
  exec /ezbookkeeping/ezbookkeeping server run ${conf_path_param}
fi
