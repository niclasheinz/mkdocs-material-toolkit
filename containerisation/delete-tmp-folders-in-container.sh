#!/bin/bash
# =============================================================================
# Script Name:      delete-tmp-folders-in-container.sh
# Description:      This script identifies the MkDocs container, lists the
#                   contents of the /tmp directory inside it determines the
#                   latest /tmp/mkdocs* folder, and removes all older
#                   /tmp/mkdocs* folders to clean up temporary files while
#                   preserving the most recent folder.
# Author:           Niclas Heinz
# Created Date:     16.01.2025
# Last Modified:    16.01.2025
# Version:          1.0
# License:          MIT
#
# Copyright (c) 2025 Niclas Heinz
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
# IN THE SOFTWARE.
# =============================================================================

# Detect the MkDocs Material container
container_id=$(docker ps -a --filter "ancestor=squidfunk/mkdocs-material" --format "{{.ID}}")

if [ -z "$container_id" ]; then
  echo "No Material for MkDocs container found."
  exit 1
fi

# List the contents of /tmp in the container
echo "Contents of /tmp in container $container_id:"
docker exec "$container_id" ls -l /tmp

# Find the latest /tmp/mkdocs* folder using sh
latest_folder=$(docker exec "$container_id" sh -c 'ls -dt /tmp/mkdocs* 2>/dev/null | head -n 1')

if [ -z "$latest_folder" ]; then
  echo "No /tmp/mkdocs* folders found."
  exit 0
fi

echo "Latest folder is: $latest_folder"

# Remove all other /tmp/mkdocs* folders using sh
docker exec "$container_id" sh -c "ls -d /tmp/mkdocs* 2>/dev/null | grep -v '$latest_folder' | xargs rm -rf"

echo "Clean-up completed. Remaining contents of /tmp:"
docker exec "$container_id" ls -l /tmp
