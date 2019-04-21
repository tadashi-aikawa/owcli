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
  assert_out none "$output"
}

@test "Root help" {
  prepare
  run $TEST_CMD -h
  assert_out help "$output"
}

#--------------------------
# cmd1 (Command only)
#--------------------------
@test "cmd1" {
  prepare
  run $TEST_CMD cmd1
  assert_out cmd1/none "$output"
}

@test "cmd1 help" {
  prepare
  run $TEST_CMD cmd1 -h
  assert_out cmd1/help "$output"
}

@test "cmd1 full command" {
  prepare
  run $TEST_CMD cmd1 tokyo -t station -vv

  assert_out cmd1/full "$output"
}

#--------------------------
# cmd2
#--------------------------
@test "cmd2" {
  prepare
  run $TEST_CMD cmd2
  assert_out cmd2/none "$output"
}

@test "cmd2 help" {
  prepare
  run $TEST_CMD cmd2 --help
  assert_out cmd2/help "$output"
}

#--------------------------
# cmd2 -> subcmd1
#--------------------------
@test "cmd2 -> subcmd1" {
  prepare
  run $TEST_CMD cmd2 subcmd1
  assert_out cmd2/subcmd1/none "$output"
}

@test "cmd2 -> subcmd1 help" {
  prepare
  run $TEST_CMD cmd2 subcmd1 --help
  assert_out cmd2/subcmd1/help "$output"
}

@test "cmd2 -> subcmd1 full" {
  prepare
  run $TEST_CMD cmd2 subcmd1 name1 name2 -f
  assert_out cmd2/subcmd1/full "$output"
}

#--------------------------
# cmd2 -> subcmd2
#--------------------------
@test "cmd2 -> subcmd2" {
  prepare
  run $TEST_CMD cmd2 subcmd2
  assert_out cmd2/subcmd2/none "$output"
}

@test "cmd2 -> subcmd2 help" {
  prepare
  run $TEST_CMD cmd2 subcmd2 --help
  assert_out cmd2/subcmd2/help "$output"
}

@test "cmd2 -> subcmd2 full" {
  prepare
  run $TEST_CMD cmd2 subcmd2 action2 --target target1 target2 -v
  assert_out cmd2/subcmd2/full "$output"
}
