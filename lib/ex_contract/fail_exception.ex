defmodule ExContract.FailException do
  @moduledoc """
  Custom exception raised by `ExContract.fail/1` macro.
  """

  use ExContract.BaseContractException

  @spec new(env :: any, msg :: String.t()) :: t
  def new(env, msg) do
    %__MODULE__{message: message(env, msg)}
  end

  defp message(env, msg) do
    "Fail condition executed. " <>
    "Invalid assumption in function [#{function_desc(env.function)}] #{msg}"
  end
end
