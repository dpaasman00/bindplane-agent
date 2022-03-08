#!/bin/sh
# Copyright  observIQ, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -e
BASEDIR="$(dirname "$(realpath "$0")")"
PROJECT_BASE="$BASEDIR/../.."

[ -f go-msi.exe ] || curl -f -L -o go-msi.exe https://github.com/observIQ/go-msi/releases/download/v2.1.0/go-msi.exe
[ -f ./cinc-auditor.msi ] || curl -f -L -o cinc-auditor.msi http://downloads.cinc.sh/files/stable/cinc-auditor/4.17.7/windows/2012r2/cinc-auditor-4.17.7-1-x64.msi

[ -f ./wix-binaries.zip ] || curl -f -L -o wix-binaries.zip https://github.com/wixtoolset/wix3/releases/download/wix3112rtm/wix311-binaries.zip

mkdir -p wix
[ -d wix/sdk ] || unzip -o wix-binaries.zip -d wix

$PROJECT_BASE/buildscripts/download-dependencies.sh

cp "$PROJECT_BASE/config/example.yaml" "./config.yaml"