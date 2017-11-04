# ExContracts

This is an Elixir library that adds support for design by contract. See [DbC](https://en.wikipedia.org/wiki/Design_by_contract) for introductory description.

## Theory

At the heart of Design by Contract is the idea that we choose to engage in economic activity because
of mutual benefits that we derive when interacting with each other. Relevant to this notion is the relationship between a client and a supplier. We can view each Elixir module or function as either
supplying a service or being a client of a module or function that supplies a service. A contract
defines obligations and establishing benefits when interactions between modules and functions take
place. This is similar, in many ways, to a business contract. As an example, a contract for a
cellular service can be established between you and a cellular provider. Under this contract, terms
clearly define obligations and benefits of each party. A cellular provider gets a benefit of your
money but must provide you with a cellular service. On the other hand, you get a benefit of a
service but must provide money in exchange. A contract clearly spells out benefits and obligations.
To put it in another way, a pre-condition, a condition that must be true, or is required to be true
before you can obtain a service, is the promise of money that you must pay for the service. The post-condition, the benefit that you get, or a condition that needs to be ensured by the supplier,
is the service that you obtain when you make a phone call.

Design by contract benefits not just an object oriented language but also a functional one
including Elixir. After all, some functions are partial and we need to know what is expected from
us before calling them. More formally, we need to know what is a pre-condition that we need to
satisfy before making a call. With the help of this library, one can clearly define such an
requirement using `ExContract.requires/1` macro. When we see that `ExContract.requires/1` condition
failed, a bug can quickly be identified as being in the calling code. In summary, a function can
only be called if pre-condition is satisfied; all bets are off if this is not the case.
Pre-condition i.e. `ExContract.requires/1` macro provides a benefit to the person implementing a
function. It makes the code simpler to implement as some possibilities are eliminated by `ExContract.requires/1`. The implementation must only concern itself with the possibilities that are
still open as defined by pre-condition.

After calling an Elixir function, we need to know what is guaranteed by a function we just called.
This defines a benefit to the calling code. More formally we want to know what is guaranteed or
ensured by a function we just called. In this library, `ExContract.ensures/1` macro expresses the
benefit we obtain from calling a function. If for some reason, there is a failure of the
`ExContract.ensures/1` macro, we know the implementation of the function is incorrect as the code
does not live to its expectation. When this is the case, we can focus our effort on fixing the
function that promised but did not deliver.

`ExContract.check/1` macro allows us to clearly define assumptions about our code that we believe to
be true at certain point of function execution. Were such assumption turn out to be incorrect, as
manifested by failure of `ExContract.check/1` macro, we should go back and correct the code that was
written claiming these assumptions were true.

`ExContract.fail/1` macro is useful when it is our understanding that certain portion of code
should never be executed or reached. If this proves not to be the case, we should re-examine the
code and make necessary corrections.

To summarize, contracts allow us to fail fast as recommended by Elixir and Erlang experts. We can
clearly express what is required before calling a function and what benefit we obtain. Finally,
failures of different types of contracts clearly give indication of which part of the code has bugs.
This makes the exercise of correcting them simpler. Testing, including, property based testing and
design by contract are trying to address our inability to implement formal proof for code
correctness. Pre-conditions and post-conditions are useful even in functions with no side effects,
as they limit input domains and output ranges making code easier to develop and reason about.

## Accomplished Design Goals
1. Allow for multiple requires and ensures clauses.
2. Allow optional message parameters to be specified for ensures, requires, and check conditions.
3. For a failed contract, print the code representation of the condition that failed.
4. Do not modify AST (Abstract Syntax Tree) when no contract is specified or when certain contract
type is not present. For example, result variable is not created when there is no post-condition
`ExContract.requires/1`.
5. Allow contract `ExContract.requires/1` and `ExContract.ensures/1` for private functions as there is
no reason to limit contracts to only public ones.
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

## Future Improvements
1. Report individual values of the expression that led to failure just like in `ExUnit`.

## Usage

The package is available in Hex and can be added as dependency into mix.exs file:

```elixir
def deps do
  [
    {:ex_contract, "~> 0.1.1"}
  ]
end
```

Run mix deps.get followed by deps.compile. Every module where contracts are to be specified needs to
have `use` statement:

```elixir
defmodule SomeModule do
  use ExContract

  ...
end
```

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
When condition provided to `ExContract.requires/1` macro turns out to be false, the macro raises
`ExContract.RequiresException`. The exception contains code representation of the condition that
failed followed by generic message related to type of contract that failed. The message embeds the
second parameter if such was specified in macro call.

Example of `ExContract.requires/1` macro failure:

```elixir
(ExContract.RequiresException) Pre-condition [x < y] violated. Invalid implementation of caller to function [test_requires/2] called with x=6 and y=5
    (ex_contract) lib/ex_contract/assert.ex:16: ExContract.Assert.requires/4
    (ex_contract) test/lib/ex_contract_test.ex:30: ExContractTest.test_requires/2
```
## Post-conditions: ensures

The library allows to define multiple ensures conditions that can have optional message parameters.
A return value of a function can be checked via a pre-defined `result` variable that is available in
the ensures condition.  The first parameter specifies a condition that we expect to be true when
function exits.

Example:

```elixir
  ensures result == x * y
  @spec test_ensures(x :: integer, y :: integer) :: integer | no_return
  def test_ensures(x, y) do
    x * y
  end
```

When condition provided to `ExContract.ensures/1` macro turns out to be false, the macro raises
`ExContract.EnsuresException`. The exception contains code representation of the condition that
failed followed by generic message related to type of contract that failed. The message embeds the
second parameter if such was specified in macro call.

Example of `ExContract.ensures/1` macro failure:

```elixir
(ExContract.EnsuresException) Post-condition [result == x * y] violated. Invalid implementation of function [test_ensures/2]
    (ex_contract) lib/ex_contract/assert.ex:22: ExContract.Assert.ensures/4
    (ex_contract) test/lib/ex_contract_test.ex:129: ExContractTest.test_ensures/2
```

## Check-condition: check

This macro can appear multiple times inside of function body. First parameter to `ExContract.check/1`
macro specifies a condition that we expect to be true at certain point of function execution.

Example:

```elixir
  @spec test_check(x :: integer) :: integer | no_return
  def test_check(x) do
    r = x * x
    check r > x or r == 1
    r
  end
```
When condition provided to `ExContract.check/1` macro turns out to be false, the macro raises
`ExContract.CheckException`. The exception contains code representation of the condition that failed
followed by generic message related to type of contract that failed. The message embeds the second
parameter if such was specified in macro call.

## Fail-condition: fail

`ExContract.fail/1` macro can appear multiple times inside of function body. It raises
`ExContract.FailException` when path of the code that we did not expect to execute is taken. The
only parameter to the macro is a message that should describe a reason for a failure.

Example:

```elixir
  @spec test_fail(x :: integer) :: integer | no_return
  def test_fail(x) do
    fail "This callback should never have been executed"
  end
```

## Installation

Package [is available in Hex](https://hex.pm/docs/publish) and can be installed
by adding `ex_contract` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_contract, "~> 0.1.1"}
  ]
end
```

Documentation generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Docs can
be found at [https://hexdocs.pm/ex_contract](https://hexdocs.pm/ex_contract).

# Credits

AST generation based on idea in [Elixir Contracts](https://github.com/epsanchezma/elixir-contracts)