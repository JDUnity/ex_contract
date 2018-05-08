defmodule ExContract.EnsuresException do
  @moduledoc """
  Custom exception raised by `ExContract.ensures/1` macro.
  """

  use ExContract.BaseContractException

  @spec new(condition_txt :: String.t(), env :: any, msg :: String.t()) :: t
  def new(condition_txt, env, msg) do
    %__MODULE__{message: message(condition_txt, env, msg)}
  end

  defp message(condition_txt, env, msg) do
    "Post-condition [#{inspect(condition_txt)}] violated. " <>
    "Invalid implementation of function \ [#{function_desc(env.function)}] #{msg}"
  end
end
