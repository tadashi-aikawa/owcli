#!/usr/bin/env bats

APP="testapp"

OWCLI="pipenv run python owcli/main.py"
TEST_CMD="pipenv run python ${APP}/main.py"

teardown() {
  rm -rf ${APP} actual
}

assert_exists() {
  [[ $(ls "$1") ]]
}

assert_not_exists() {
  [[ ! $(ls "$1") ]]
}

assert_out() {
  local expected="$1"
  local actual="$2"

  diff -aur tests/expected/${expected} <(echo "${actual}")
}

# Only for this test
prepare() {
  $OWCLI init ${APP}
  mv ${APP} tmpapp
  mv tmpapp/${APP} .
  rm -rf tmpapp
}

#--------------------------
# owcli usage
#--------------------------

@test "Usage" {
  $OWCLI -h
}


#--------------------------
# owcli init
#--------------------------

@test "Init with no args" {
  run $OWCLI init
  [ "$status" -eq 0 ]

  assert_not_exists ${APP}
}

@test "Init with help args" {
  run $OWCLI init --help
  [ "$status" -eq 0 ]

  assert_not_exists ${APP}
}

@test "Init with invalid args" {
  run $OWCLI init --invalid args
  [ "$status" -eq 1 ]

  assert_not_exists ${APP}
}

@test "Init" {
  $OWCLI init ${APP}

  assert_exists ${APP}
}

#--------------------------
# Root
#--------------------------
@test "Root" {
  prepare

  run $TEST_CMD
  assert_out root "$output"
}

@test "Root help" {
  prepare

  run $TEST_CMD -h
  assert_out root_help "$output"
}
