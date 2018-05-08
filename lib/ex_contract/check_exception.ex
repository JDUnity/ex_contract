defmodule ExContract.CheckException do
  @moduledoc """
  Custom exception raised by `ExContract.check/1` macro.
  """

  use ExContract.BaseContractException

  @spec new(condition_txt :: String.t(), env :: any, msg :: String.t()) :: t
  def new(condition_txt, env, msg) do
    %__MODULE__{message: message(condition_txt, env, msg)}
  end

  defp message(condition_txt, env, msg) do
    "Check condition [#{inspect(condition_txt)}] violated. " <>
    "Invalid assumption in function \ [#{function_desc(env.function)}] #{msg}"
  end
end
