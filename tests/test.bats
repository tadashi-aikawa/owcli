#!/usr/bin/env bats
APP="testapp"

OWCLI="python owcli/main.py"
TEST_CMD="python ${APP}/main.py"

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
  $OWCLI init ${APP} --python $(pipenv run python -V | cut -d' ' -f2)
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
  [ "$status" -eq 1 ]

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
  $OWCLI init ${APP} --python x.y

  assert_exists ${APP}
}

#--------------------------
# Root
#--------------------------
@test "Root" {
  prepare
  run $TEST_CMD
  [ "$status" -eq 1 ]
  assert_out none "$output"
}

@test "Root help" {
  prepare
  run $TEST_CMD -h
  [ "$status" -eq 0 ]
  assert_out help "$output"
}

#--------------------------
# cmd1 (Command only)
#--------------------------
@test "cmd1" {
  prepare
  run $TEST_CMD cmd1
  [ "$status" -eq 1 ]
  assert_out cmd1/none "$output"
}

@test "cmd1 help" {
  prepare
  run $TEST_CMD cmd1 -h
  [ "$status" -eq 0 ]
  assert_out cmd1/help "$output"
}

@test "cmd1 full command" {
  prepare
  run $TEST_CMD cmd1 tokyo -t station -vv
  [ "$status" -eq 0 ]
  assert_out cmd1/full "$output"
}

#--------------------------
# cmd2
#--------------------------
@test "cmd2" {
  prepare
  run $TEST_CMD cmd2
  [ "$status" -eq 1 ]
  assert_out cmd2/none "$output"
}

@test "cmd2 help" {
  prepare
  run $TEST_CMD cmd2 --help
  [ "$status" -eq 0 ]
  assert_out cmd2/help "$output"
}

#--------------------------
# cmd2 -> subcmd1
#--------------------------
@test "cmd2 -> subcmd1" {
  prepare
  run $TEST_CMD cmd2 subcmd1
  [ "$status" -eq 1 ]
  assert_out cmd2/subcmd1/none "$output"
}

@test "cmd2 -> subcmd1 help" {
  prepare
  run $TEST_CMD cmd2 subcmd1 --help
  [ "$status" -eq 0 ]
  assert_out cmd2/subcmd1/help "$output"
}

@test "cmd2 -> subcmd1 full" {
  prepare
  run $TEST_CMD cmd2 subcmd1 name1 name2 -f
  [ "$status" -eq 0 ]
  assert_out cmd2/subcmd1/full "$output"
}

#--------------------------
# cmd2 -> subcmd2
#--------------------------
@test "cmd2 -> subcmd2" {
  prepare
  run $TEST_CMD cmd2 subcmd2
  [ "$status" -eq 1 ]
  assert_out cmd2/subcmd2/none "$output"
}

@test "cmd2 -> subcmd2 help" {
  prepare
  run $TEST_CMD cmd2 subcmd2 --help
  [ "$status" -eq 0 ]
  assert_out cmd2/subcmd2/help "$output"
}

@test "cmd2 -> subcmd2 full" {
  prepare
  run $TEST_CMD cmd2 subcmd2 action2 --target target1 --target target2 -v
  [ "$status" -eq 0 ]
  assert_out cmd2/subcmd2/full "$output"
}

#--------------------------
# cmd2 -> subcmd3
#--------------------------
@test "cmd2 -> subcmd3" {
  prepare
  run $TEST_CMD cmd2 subcmd3
  [ "$status" -eq 0 ]
  assert_out cmd2/subcmd3/none "$output"
}

@test "cmd2 -> subcmd3 help" {
  prepare
  run $TEST_CMD cmd2 subcmd3 --help
  [ "$status" -eq 0 ]
  assert_out cmd2/subcmd3/help "$output"
}

#--------------------------
# cmd3
#--------------------------
@test "cmd3" {
  prepare
  run $TEST_CMD cmd3
  [ "$status" -eq 0 ]
  assert_out cmd3/none "$output"
}

@test "cmd3 help" {
  prepare
  run $TEST_CMD cmd3 --help
  [ "$status" -eq 0 ]
  assert_out cmd3/help "$output"
}

# Import error
@test "cmd3 import error" {
  prepare
  echo "import hogehoge" >> ${APP}/commands/cmd3/main.py
  run $TEST_CMD cmd3
  [ "$status" -eq 1 ]
  assert_out cmd3/error "$(echo "$output" | tail -1)"
}
