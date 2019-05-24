defmodule ExContractTest do
  @moduledoc false
  use ExContract

  alias ExContract.{RequiresException, EnsuresException, CheckException, FailException}

  import ExUnit.Assertions

  #
  # No Contract Tests
  #

  @spec test_function_without_contracts(x :: integer, y :: integer) :: integer
  def test_function_without_contracts(x, y) do
    x + y
  end

  @spec test_function_without_contracts_p(x :: integer, y :: integer) :: integer
  defp test_function_without_contracts_p(x, y) do
    x + y
  end

  #
  # Requires Tests
  #

  requires(x < y, "Called with x=#{inspect(x)} and y=#{inspect(y)}")
  requires(x > 5)
  @spec test_requires(x :: integer, y :: integer) :: integer | no_return
  def test_requires(x, y) do
    x * y
  end

  requires(x < y, "Called with x=#{inspect(x)} and y=#{inspect(y)}")
  requires(x > 5)
  @spec test_requires_p(x :: integer, y :: integer) :: integer | no_return
  defp test_requires_p(x, y) do
    x * y
  end

  #
  # Requires Tests (Implicit Try Block)
  #

  requires(x < y, "Called with x=#{inspect(x)} and y=#{inspect(y)}")
  requires(x > 5)

  @spec test_requires_with_implicit_after(x :: integer, y :: integer, fail? :: boolean) ::
          integer | no_return
  def test_requires_with_implicit_after(x, y, fail?) do
    if fail? do
      raise "Oop told to fail and so it did"
    end

    x * y
  after
    x
  end

  requires(x < y, "Called with x=#{inspect(x)} and y=#{inspect(y)}")
  requires(x > 5)

  @spec test_requires_with_implicit_after_p(x :: integer, y :: integer, fail? :: boolean) ::
          integer | no_return
  defp test_requires_with_implicit_after_p(x, y, fail?) do
    if fail? do
      raise "Oop told to fail and so it did"
    end

    x * y
  after
    x
  end

  requires(x < y, "Called with x=#{inspect(x)} and y=#{inspect(y)}")
  requires(x > 5)

  @spec test_requires_with_implicit_rescue(x :: integer, y :: integer, fail? :: boolean) ::
          integer | no_return
  def test_requires_with_implicit_rescue(x, y, fail?) do
    if fail? do
      raise "Oop told to fail and so it did"
    end

    x * y
  rescue
    _ -> x
  end

  requires(x < y, "Called with x=#{inspect(x)} and y=#{inspect(y)}")
  requires(x > 5)

  @spec test_requires_with_implicit_rescue_p(x :: integer, y :: integer, fail? :: boolean) ::
          integer | no_return
  defp test_requires_with_implicit_rescue_p(x, y, fail?) do
    if fail? do
      raise "Oop told to fail and so it did"
    end

    x * y
  rescue
    _ -> x
  end

  requires(x < y, "Called with x=#{inspect(x)} and y=#{inspect(y)}")
  requires(x > 5)

  @spec test_requires_with_implicit_catch(x :: integer, y :: integer, fail? :: boolean) ::
          integer | no_return
  def test_requires_with_implicit_catch(x, y, fail?) do
    if fail? do
      throw(y)
    end

    x * y
  catch
    y -> y
  end

  requires(x < y, "Called with x=#{inspect(x)} and y=#{inspect(y)}")
  requires(x > 5)

  @spec test_requires_with_implicit_catch_p(x :: integer, y :: integer, fail? :: boolean) ::
          integer | no_return
  defp test_requires_with_implicit_catch_p(x, y, fail?) do
    if fail? do
      throw(y)
    end

    x * y
  catch
    y -> y
  end

  #
  # Ensures Tests
  #

  ensures(result == x * y)
  @spec test_ensures(x :: integer, y :: integer) :: integer | no_return
  def test_ensures(x, y) do
    x * y
  end

  ensures(result == x * y)
  @spec test_ensures_p(x :: integer, y :: integer) :: integer | no_return
  defp test_ensures_p(x, y) do
    x * y
  end

  ensures(result > x * y * 2)
  @spec test_ensures_failure(x :: integer, y :: integer) :: integer | no_return
  def test_ensures_failure(x, y) do
    x * y
  end

  ensures(result > x * y * 2)
  @spec test_ensures_failure_p(x :: integer, y :: integer) :: integer | no_return
  defp test_ensures_failure_p(x, y) do
    x * y
  end

  #
  # Ensures Tests (Implicit Try)
  #

  # Try After Block

  ensures(result == x * y)

  @spec test_ensures_with_implicit_after(x :: integer, y :: integer, fail? :: boolean) ::
          integer | no_return
  def test_ensures_with_implicit_after(x, y, fail?) do
    if fail?, do: raise("Oop told to fail and so it did")
    x * y
  after
    x
  end

  ensures(result == x * y)

  @spec test_ensures_with_implicit_after_p(x :: integer, y :: integer, fail? :: boolean) ::
          integer | no_return
  defp test_ensures_with_implicit_after_p(x, y, fail?) do
    if fail?, do: raise("Oop told to fail and so it did")
    x * y
  after
    x
  end

  ensures(result > x * y * 2)

  @spec test_ensures_failure_with_implicit_after(x :: integer, y :: integer) ::
          integer | no_return
  def test_ensures_failure_with_implicit_after(x, y) do
    x * y
  after
    x
  end

  ensures(result > x * y * 2)

  @spec test_ensures_failure_with_implicit_after_p(x :: integer, y :: integer) ::
          integer | no_return
  defp test_ensures_failure_with_implicit_after_p(x, y) do
    x * y
  after
    x
  end

  # Try Rescue Block

  ensures(result == x * y)

  @spec test_ensures_with_implicit_rescue(x :: integer, y :: integer, fail? :: boolean) ::
          integer | no_return
  def test_ensures_with_implicit_rescue(x, y, fail?) do
    if fail?, do: raise("Oop told to fail and so it did")
    x
  rescue
    _ -> x * y
  end

  ensures(result == x * y)

  @spec test_ensures_with_implicit_rescue_p(x :: integer, y :: integer, fail? :: boolean) ::
          integer | no_return
  defp test_ensures_with_implicit_rescue_p(x, y, fail?) do
    if fail?, do: raise("Oop told to fail and so it did")
    x
  rescue
    _ -> x * y
  end

  ensures(result > x * y * 2)

  @spec test_ensures_failure_with_implicit_rescue(x :: integer, y :: integer, fail? :: boolean) ::
          integer | no_return
  def test_ensures_failure_with_implicit_rescue(x, y, fail?) do
    if fail?, do: raise("Oop told to fail and so it did")
    x * y * 2
  rescue
    _ -> x
  end

  ensures(result > x * y * 2)

  @spec test_ensures_failure_with_implicit_rescue_p(x :: integer, y :: integer, fail? :: boolean) ::
          integer | no_return
  defp test_ensures_failure_with_implicit_rescue_p(x, y, fail?) do
    if fail?, do: raise("Oop told to fail and so it did")
    x * y * 2
  rescue
    _ -> x
  end

  #
  # Requires and Ensures Tests
  #

  requires(x > 0, "Called with x=#{x}")
  requires(y > 0, "Called with y=#{y}")
  ensures(result == x * y)
  @spec test_requires_and_ensures(x :: integer, y :: integer) :: integer | no_return
  def test_requires_and_ensures(x, y) do
    x * y
  end

  requires(x > 0, "Called with x=#{x}")
  requires(y > 0, "Called with y=#{y}")
  ensures(result == x * y)
  @spec test_requires_and_ensures_p(x :: integer, y :: integer) :: integer | no_return
  defp test_requires_and_ensures_p(x, y) do
    x * y
  end

  requires(x > 0, "Called with x=#{x}")
  requires(y > 0, "Called with y=#{y}")
  ensures(result > x * y * 2)
  @spec test_requires_and_ensures_failure(x :: integer, y :: integer) :: integer | no_return
  def test_requires_and_ensures_failure(x, y) do
    x * y
  end

  requires(x > 0, "Called with x=#{x}")
  requires(y > 0, "Called with y=#{y}")
  ensures(result > x * y * 2)
  @spec test_requires_and_ensures_failure_p(x :: integer, y :: integer) :: integer | no_return
  defp test_requires_and_ensures_failure_p(x, y) do
    x * y
  end

  requires(x > 0 or x == -1, "Called with x=#{x}")
  requires(y > 0 or x == -1, "Called with y=#{y}")
  ensures(result == x * y or result == -1)
  @spec test_requires_and_ensures_multiple_clauses(x :: pos_integer | -1, y :: pos_integer | -1) ::
          pos_integer | no_return
  defp test_requires_and_ensures_multiple_clauses(-1 = x, -1 = y), do: -1

  # Uncommenting the following line results in compile error since it is not allowed to define
  # contracts in between different clauses of functions with the same name and arity.
  # requires(x == 0)

  defp test_requires_and_ensures_multiple_clauses(x, y), do: x * y

  #
  # Check Tests
  #

  @spec test_check(x :: integer) :: integer | no_return
  def test_check(x) do
    r = x * x
    check r > x or r == 1
    r
  end

  #
  # Fail Tests
  #

  @spec test_fail(x :: integer, fail? :: boolean) :: integer | no_return
  def test_fail(x, fail?) do
    if fail? do
      fail("Told to fail and so it did")
    end

    x
  end

  #
  # Public Functions (Test Runners)
  #

  @spec run_no_contracts_tests :: nil | no_return
  def run_no_contracts_tests do
    assert test_function_without_contracts(4, 5) == 9
    assert test_function_without_contracts_p(4, 5) == 9
  end

  @spec run_requires_tests() :: nil | no_return
  def run_requires_tests do
    assert test_requires(6, 10) == 60
    assert test_requires_p(6, 10) == 60

    assert_raise(RequiresException, fn -> test_requires(1, 2) end)
    assert_raise(RequiresException, fn -> test_requires(6, 5) end)
    assert_raise(RequiresException, fn -> test_requires_p(1, 2) end)
    assert_raise(RequiresException, fn -> test_requires_p(6, 5) end)
  end

  @spec run_requires_with_implicit_try_tests :: nil | no_return
  def run_requires_with_implicit_try_tests do
    assert test_requires_with_implicit_after(6, 7, false) == 42
    assert test_requires_with_implicit_after_p(6, 7, false) == 42

    assert test_requires_with_implicit_rescue(6, 7, false) == 42
    assert test_requires_with_implicit_rescue_p(6, 7, false) == 42
    assert test_requires_with_implicit_rescue(6, 7, true) == 6
    assert test_requires_with_implicit_rescue_p(6, 7, true) == 6

    assert_raise(RequiresException, fn -> test_requires_with_implicit_after(3, 4, true) end)
    assert_raise(RequiresException, fn -> test_requires_with_implicit_after_p(3, 4, true) end)
    assert_raise(RequiresException, fn -> test_requires_with_implicit_after(0, 5, false) end)
    assert_raise(RequiresException, fn -> test_requires_with_implicit_after_p(0, 5, false) end)

    assert_raise(RequiresException, fn -> test_requires_with_implicit_rescue(3, 4, true) end)
    assert_raise(RequiresException, fn -> test_requires_with_implicit_rescue_p(3, 4, true) end)
    assert_raise(RequiresException, fn -> test_requires_with_implicit_rescue(0, 5, false) end)
    assert_raise(RequiresException, fn -> test_requires_with_implicit_rescue_p(0, 5, false) end)

    assert test_requires_with_implicit_catch(6, 7, false) == 42
    assert test_requires_with_implicit_catch_p(6, 7, false) == 42
    assert test_requires_with_implicit_catch(6, 7, true) == 7
    assert test_requires_with_implicit_catch_p(6, 7, true) == 7

    assert_raise(RequiresException, fn -> test_requires_with_implicit_catch(3, 4, true) end)
    assert_raise(RequiresException, fn -> test_requires_with_implicit_catch_p(3, 4, true) end)
    assert_raise(RequiresException, fn -> test_requires_with_implicit_catch(0, 5, false) end)
    assert_raise(RequiresException, fn -> test_requires_with_implicit_catch_p(0, 5, false) end)
  end

  @spec run_ensures_tests() :: nil | no_return
  def run_ensures_tests do
    assert test_ensures(6, 10) == 60
    assert test_ensures_p(6, 10) == 60

    assert_raise(EnsuresException, fn -> test_ensures_failure(5, 10) end)
    assert_raise(EnsuresException, fn -> test_ensures_failure_p(5, 10) end)
  end

  @spec run_ensures_with_implicit_try_tests :: nil | no_return
  def run_ensures_with_implicit_try_tests do
    assert test_ensures_with_implicit_after(6, 10, false) == 60
    assert test_ensures_with_implicit_after_p(6, 10, false) == 60

    assert_raise(RuntimeError, fn -> test_ensures_with_implicit_after(6, 10, true) end)
    assert_raise(RuntimeError, fn -> test_ensures_with_implicit_after_p(6, 10, true) end)
    assert_raise(EnsuresException, fn -> test_ensures_failure_with_implicit_after(5, 10) end)
    assert_raise(EnsuresException, fn -> test_ensures_failure_with_implicit_after_p(5, 10) end)

    assert_raise(EnsuresException, fn -> test_ensures_with_implicit_rescue(6, 10, false) == 60 end)

    assert_raise(EnsuresException, fn ->
      test_ensures_with_implicit_rescue_p(6, 10, false) == 60
    end)

    assert test_ensures_with_implicit_rescue(6, 10, true) == 60
    assert test_ensures_with_implicit_rescue_p(6, 10, true) == 60

    assert_raise(EnsuresException, fn -> test_ensures_with_implicit_rescue(6, 10, false) end)
    assert_raise(EnsuresException, fn -> test_ensures_with_implicit_rescue_p(6, 10, false) end)

    assert_raise(EnsuresException, fn ->
      test_ensures_failure_with_implicit_rescue(5, 10, true)
    end)

    assert_raise(EnsuresException, fn ->
      test_ensures_failure_with_implicit_rescue_p(5, 10, true)
    end)
  end

  @spec run_requires_and_ensures_tests() :: nil | no_return
  def run_requires_and_ensures_tests do
    assert test_requires_and_ensures(6, 10) == 60
    assert test_requires_and_ensures_p(6, 10) == 60
    assert_raise(RequiresException, fn -> test_requires_and_ensures(0, 10) end)
    assert_raise(RequiresException, fn -> test_requires_and_ensures_p(0, 10) end)

    assert_raise(EnsuresException, fn -> test_requires_and_ensures_failure(5, 10) end)
    assert_raise(EnsuresException, fn -> test_requires_and_ensures_failure_p(5, 10) end)
    assert_raise(RequiresException, fn -> test_requires_and_ensures_failure(0, 10) end)
    assert_raise(RequiresException, fn -> test_requires_and_ensures_failure_p(0, 10) end)

    assert test_requires_and_ensures_multiple_clauses(-1, -1) == -1
    assert test_requires_and_ensures_multiple_clauses(6, 10) == 60
    assert_raise RequiresException, fn -> test_requires_and_ensures_multiple_clauses(0, 10) end
  end

  @spec run_check_tests() :: nil | no_return
  def run_check_tests do
    assert test_check(2) == 4
    assert_raise(CheckException, fn -> test_check(0) end)
  end

  @spec run_fail_tests() :: nil | no_return
  def run_fail_tests do
    assert test_fail(2, false) == 2
    assert_raise(FailException, fn -> test_fail(2, true) end)
  end
end
