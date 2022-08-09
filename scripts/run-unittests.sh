#!/bin/bash

set -o pipefail
set -e

xcodebuild -scheme 'NYPLCardCreator' -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPad mini (6th generation)' test | if command -v xcpretty; then xcpretty; else cat; fi
