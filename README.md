# ExContracts

This is Elixir library that adds support for design by contract. See [DbC](https://en.wikipedia.org/wiki/Design_by_contract) for introductory description.

Design by contract brings benefits not just to object oriented languages but also to a functional
ones. After all, some functions are partial and we need to know what is expected from us before
calling such functions. More formally, we need to know what is a pre-condition that we need to
satisfy before making a call. Using this library, one can clearly define such an requirement with
`requires` macro. When we see that `requires` condition failed, a bug can quickly be identified
as being in the calling code. In summary, a function can only be called if pre-condition is
satisfied; all bets are off if this is not the case. Pre-condition i.e. `requires` macro
provides a benefit to the person implementing it. It makes the code simpler to implement
as some possibilities are eliminated by `requires`. The implementation must only concern
itself with the possibilities that are still open as defined by pre-condition.

After calling an Elixir function, we need to know what is guaranteed by the function we just called.
This defines a benefit to the calling code. More formally we want to know what is guaranteed or
ensured by a function we just called. In this library, `ensures` macro expresses the benefit we
obtain from calling a function. If for some reason, there is a failure of the `ensures` macro, we
know the implementation of the function is incorrect as the code does not live to its expectation.
When this is the case, we can focus our effort on fixing the function that promised but did not
deliver.

The `check` macro allows us to clearly define assumptions about our code that we believe to be true
at certain point of function execution. Were such assumption turn out to be incorrect, as manifested
by failure of the `check` macro, we should go back and correct the code that was written claiming
these assumptions were true.

The `fail` macro is useful when it is our understanding that certain portion of code should never be
executed or reached. If this proves not to be the case, we should re-examine the code and and make
necessary corrections.

To summarize, contracts allow us to fail fast as recommended by Elixir and Erlang experts. We can
clearly express what is required before calling a function and what benefit we obtain. Finally,
failures of different types of contracts clearly give indication of which part of the code has bugs
making the exercise of correcting them simpler.

# Accomplished Design Goals
1. Allow for multiple requires and ensures clauses.
2. Allow optional message parameters to be specified for ensures, requires, and check conditions.
3. For a failed contract, print the code representation of the condition that failed.
4. Do not modify AST (Abstract Syntax Tree) when no contract is specified or when certain contract
type is not present. For example, result variable is not created when there is no post-condition
`requires`.
5. Allow contract `requires` and `ensures` for private functions as there is no reason to limit
contracts to only public ones.
6. Handle function definitions that contain implicit `try` block that is followed by `rescue`,
`after`, or `catch`. Example:

```elixir
  requires x < y, "Called with x=#{inspect x} and y=#{inspect y}"
  requires x > 5
  @spec test_requires(x :: integer, y :: integer) :: integer | no_return
  def test_requires(x, y) do
    x * y
  after
    IO.puts("Cleanup")
  end
```

# Future Improvements
1. Report individual values of the expression that led to failure just like in `ExUnit`.

# Usage

## Pre-conditions: requires
Multiple requires contract clauses with optional message parameter can be defined. The first
parameter specifies a condition that we expect to be true upon call to a function.

Example:

```elixir
  requires x < y, "called with x=#{inspect x} and y=#{inspect y}"
  requires x > 5
  @spec test_requires(x :: integer, y :: integer) :: integer | no_return
  def test_requires(x, y) do
    x * y
  end
```
When condition provided to `ExContract.requires` macro turns out to be false, the macro raises
`ExContract.RequiresException`. The exception contains code representation of the condition that
failed followed by generic message related to type of contract that failed. The message embeds the
second parameter if such was specified in macro call.

Example of `requires` macro failure:

```elixir
(ExContract.RequiresException) Pre-condition [x < y] violated. Invalid implementation of caller to function [test_requires/2] called with x=6 and y=5
    (ex_contract) lib/ex_contract/assert.ex:16: ExContract.Assert.requires/4
    (ex_contract) test/lib/ex_contract_test.ex:30: ExContractTest.test_requires/2
```
## Post-conditions: ensures

The library allows to define multiple ensures conditions that can have optional message parameters.
A return value of a function can be checked via a pre-defined `result` variable that is available in
the ensures condition.  The first
parameter specifies a condition that we expect to be true when function exits.

Example:

```elixir
  ensures result == x * y
  @spec test_ensures(x :: integer, y :: integer) :: integer | no_return
  def test_ensures(x, y) do
    x * y
  end
```

When condition provided to `ExContract.ensures` macro turns out to be false, the macro raises
`ExContract.EnsuresException`. The exception contains code representation of the condition that
failed followed by generic message related to type of contract that failed. The message embeds the
second parameter if such was specified in macro call.

Example of `ensures` macro failure:

```elixir
(ExContract.EnsuresException) Post-condition [result == x * y] violated. Invalid implementation of function [test_ensures/2]
    (ex_contract) lib/ex_contract/assert.ex:22: ExContract.Assert.ensures/4
    (ex_contract) test/lib/ex_contract_test.ex:129: ExContractTest.test_ensures/2
```

## Check-condition: check

This macro can appear multiple times inside of function body. First
parameter to `check` macro specifies a condition that we expect to be true at certain point of function execution.

Example:

```elixir
  @spec test_check(x :: integer) :: integer | no_return
  def test_check(x) do
    r = x * x
    check r > x or r == 1
    r
  end
```
When condition provided to ExContract.check macro turns out to be false, the macro raises ExContract.CheckException. The exception contains code representation of the condition that failed followed by generic message related to type of contract that failed. The message embeds the second parameter if such was specified in macro call.

## Fail-condition: fail

This macro can appear multiple times inside of function body. It raises `ExContract.FailException` when path of the code that we did not expect to execute is taken. The only parameter to the macro is a message that should describe a reason for a failure.

Example:

```elixir
  @spec test_fail(x :: integer) :: integer | no_return
  def test_fail(x) do
    fail "This callback should never have been executed"
  end
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `ex_contract` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_contract, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/ex_contract](https://hexdocs.pm/ex_contract).

# Credits

AST generation based on idea in [Contracts](https://github.com/epsanchezma/elixir-contracts)