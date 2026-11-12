#!/usr/bin/env bash

# Run directly with Bash; no installed Ruby or test framework is required.
shopt -s extglob
rvm_scripts_path="$(cd "${BASH_SOURCE[0]%/*}/../scripts" && pwd)"
rvm_path="${rvm_scripts_path%/scripts}"
source "$rvm_scripts_path/functions/logging"
source "$rvm_scripts_path/functions/support"
source "$rvm_scripts_path/functions/utility"
source "$rvm_scripts_path/functions/env"
__rvm_setup_utils_functions_common
set -e

fixture="$(mktemp -d)"
trap 'rm -rf "$fixture"' EXIT
mkdir -p "$fixture"/{rvm/{bin,scripts,rubies/ruby-test/bin},gems/bin,old-rvm/{bin,scripts},usr/bin,bin,custom/bin}
for installation in rvm old-rvm
do
  printf '#!/bin/sh\nexit 0\n' > "$fixture/$installation/bin/rvm"
  chmod +x "$fixture/$installation/bin/rvm"
  cp "$fixture/$installation/bin/rvm" "$fixture/$installation/scripts/rvm"
done
for directory in usr/bin bin custom/bin
do
  ln -s "$fixture/rvm/bin/rvm" "$fixture/$directory/rvm"
done

check_cleanup()
(
  rvm_path="$fixture/rvm"
  rvm_gems_path="$fixture/gems"
  rvm_bin_path="$1"
  PATH="$fixture/rvm/bin:$fixture/rvm/rubies/ruby-test/bin:$fixture/gems/bin:$fixture/usr/bin:$fixture/old-rvm/bin:$fixture/bin:$fixture/custom/bin:/usr/bin:/bin"
  expected="$fixture/usr/bin:$fixture/bin:$fixture/custom/bin:/usr/bin:/bin"
  __rvm_remove_rvm_from_path
  if [[ "$PATH" != "$expected" ]]
  then
    printf 'FAIL (rvm_bin_path=%s)\nexpected: %s\nactual:   %s\n' "$rvm_bin_path" "$expected" "$PATH" >&2
    exit 1
  fi
  command -v ls >/dev/null || exit 1
  command -v mkdir >/dev/null || exit 1
  __rvm_remove_rvm_from_path
  [[ "$PATH" == "$expected" ]] || exit 1
  printf 'PASS cleanup with rvm_bin_path=%s\n' "$rvm_bin_path"
)

status=0
for directory in "$fixture/rvm/bin" /usr/bin /bin "$fixture/custom/bin"
do
  check_cleanup "$directory" || status=1
done
exit "$status"
