#!/usr/bin/env bats

OWCLI="pipenv run python owcli/main.py"

teardown() {
  rm -rf test_result
}

assert_exists() {
  [[ $(ls "$1") ]]
}

assert_not_exists() {
  [[ ! $(ls "$1") ]]
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

  assert_not_exists test_result
}

@test "Init with help args" {
  run $OWCLI init --help
  [ "$status" -eq 0 ]

  assert_not_exists test_result
}

@test "Init with invalid args" {
  run $OWCLI init --invalid args
  [ "$status" -eq 1 ]

  assert_not_exists test_result
}

@test "Init" {
  $OWCLI init test_result

  assert_exists test_result
}

