defmodule ExContract.Assert do
  @moduledoc """
  This is implementation module used by `ExContract.Contract` for making calls that check for
  requires, ensures, check, and fail conditions.
  """

  alias ExContract.{RequiresException, EnsuresException, CheckException, FailException}

  #
  # Public Functions
  #

  @spec requires(condition :: boolean, condition_txt :: String.t, env :: any, msg :: String.t) ::
    nil | no_return
  def requires(condition, condition_txt, env, msg) do
    unless condition, do: raise RequiresException.new(condition_txt, env, msg)
  end

  @spec ensures(condition :: boolean, condition_txt :: String.t, env :: any, msg :: String.t) ::
    nil | no_return
  def ensures(condition, condition_txt, env, msg) do
    unless condition, do: raise EnsuresException.new(condition_txt, env, msg)
  end

  @spec check(condition :: boolean, condition_txt :: String.t, env :: any, msg :: String.t) ::
  nil | no_return
  def check(condition, condition_txt, env, msg) do
    unless condition, do: raise CheckException.new(condition_txt, env, msg)
  end

  @spec fail(env :: any, msg :: String.t) :: nil | no_return
  def fail(env, msg) do
    raise FailException.new(env, msg)
  end

end
