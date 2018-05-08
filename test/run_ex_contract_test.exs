defmodule RunExContractTest do
  use ExUnit.Case
  @moduledoc false

  alias ExContractTest

  test "ExContractTest.run_no_contracts_tests()" do
    ExContractTest.run_no_contracts_tests()
  end

  test "ExContractTest.run_requires_tests()" do
    ExContractTest.run_requires_tests()
  end

  test "ExContractTest.run_requires_with_implicit_try_tests()" do
    ExContractTest.run_requires_with_implicit_try_tests()
  end

  test "ExContractTest.run_ensures_tests()" do
    ExContractTest.run_ensures_tests()
  end

  test "ExContractTest.run_ensures_with_implicit_try_tests()" do
    ExContractTest.run_ensures_with_implicit_try_tests()
  end

  test "ExContractTest.run_requires_and_ensures_tests()" do
    ExContractTest.run_requires_and_ensures_tests()
  end

  test "ExContractTest.run_check_tests()" do
    ExContractTest.run_check_tests()
  end

  test "ExContractTest.run_fail_tests()" do
    ExContractTest.run_fail_tests()
  end
end
