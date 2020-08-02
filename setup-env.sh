#!/bin/sh

set -e -u

# Only run as superuser
if [ "$(id -u)" != "0" ]; then
  echo "This script must be run as root" 1>&2
  exit 1
fi

# add core packages
cat packages/core-packages | xargs pkg install -y

# add GhostBSD source code (pending)

# add GhostBSD ports (pending)

# Configure poudriere (pending)

# Configure nginx (pending)

# Configure vm-bhyve (pending)
