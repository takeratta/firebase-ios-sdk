# Copyright 2018 Google
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

# Within Travis, runs the given command if the current project has changes
# worth building.
#
# Examines the following Travis-supplied environment variables:
#   - TRAVIS_PULL_REQUEST - the PR number or false for full build
#   - TRAVIS_COMMIT_RANGE - the range of commits under test; empty on a new
#     branch
#
# Also examines the following configured environment variables that should be
# specified in an env: block
#   - PROJECT - Firebase or Firestore
#   - METHOD - xcodebuild or cmake

function check_changes() {
  if git diff --name-only "$TRAVIS_COMMIT_RANGE" | grep -Eq "$1"; then
    run=true
  fi
}

run=false

# To force Travis to do a full run, change the "false" to "{PR number}" like
# if [[ "$TRAVIS_PULL_REQUEST" == "904" ]]; then
if [[ "$TRAVIS_PULL_REQUEST" == "false" ]]; then
  # Full builds should run everything
  run=true

elif [[ -z "$TRAVIS_COMMIT_RANGE" ]]; then
  # First builds on a branch should also run everything
  run=true

else
  case "$PROJECT-$METHOD" in
    Firebase-pod-lib-lint) # Combines Firebase-* and InAppMessaging*
      check_changes '^(Firebase/Auth|Firebase/Core|Firebase/Database|Firebase/DynamicLinks|'\
'Firebase/Messaging|Firebase/Storage|GoogleUtilities|Interop|Example|'\
'FirebaseAnalyticsIntop.podspec|FirebaseAuth.podspec|FirebaseAuthInterop.podspec|'\
'FirebaseCore.podspec|FirebaseDatabase.podspec|FirebaseDynamicLinks.podspec|'\
'FirebaseMessaging.podspec|FirebaseStorage.podspec|'\
'FirebaseStorage.podspec|Firebase/InAppMessagingDisplay|InAppMessagingDisplay|'\
'InAppMessaging|Firebase/InAppMessaging|'\
'FirebaseInAppMessaging.podspec|FirebaseInAppMessagingDisplay.podspec|'\
'Firebase/InstanceID|FirebaseInstanceID.podspec)'
      ;;

    Firebase-*)
      check_changes '^(Firebase/Auth|Firebase/Core|Firebase/Database|Firebase/DynamicLinks|'\
'Firebase/Messaging|Firebase/Storage|GoogleUtilities|Interop|Example|'\
'FirebaseAnalyticsIntop.podspec|FirebaseAuth.podspec|FirebaseAuthInterop.podspec|'\
'FirebaseCore.podspec|FirebaseDatabase.podspec|FirebaseDynamicLinks.podspec|'\
'FirebaseMessaging.podspec|FirebaseStorage.podspec|'\
'FirebaseStorage.podspec|Firebase/InstanceID|FirebaseInstanceID.podspec)'
      ;;

    Functions-*)
      check_changes '^(Firebase/Core|Functions|GoogleUtilities|FirebaseFunctions.podspec)'
      ;;

    InAppMessaging-*)
      check_changes '^(Firebase/InAppMessagingDisplay|InAppMessagingDisplay|InAppMessaging|'\
'Firebase/InAppMessaging)'
      ;;

    Firestore-xcodebuild|Firestore-pod-lib-lint)
      check_changes '^(Firestore|FirebaseFirestore.podspec|FirebaseFirestoreSwift.podspec|'\
'GoogleUtilities)'
      ;;

    Firestore-cmake)
      check_changes '^(Firestore/(core|third_party)|cmake|GoogleUtilities)'
      ;;

    GoogleDataTransport-*)
      check_changes '^(GoogleDataTransport|GoogleDataTransport.podspec)'
      ;;

    GoogleDataTransportCCTSupport-*)
      check_changes '^(GoogleDataTransportCCTSupport|GoogleDataTransportCCTSupport.podspec|GoogleDataTransport|GoogleDataTransport.podspec)'
      ;;

    *)
      echo "Unknown project-method combo" 1>&2
      echo "  PROJECT=$PROJECT" 1>&2
      echo "  METHOD=$METHOD" 1>&2
      exit 1
      ;;
  esac
fi

# Always rebuild if Travis configuration and/or build scripts changed.
check_changes '^.travis.yml'
check_changes '^Gemfile.lock'
check_changes '^scripts/(build|if_changed|install_prereqs).sh'

if [[ "$run" == true ]]; then
  "$@"
else
  echo "skipped $*"
fi

