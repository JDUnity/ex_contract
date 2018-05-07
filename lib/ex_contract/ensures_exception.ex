defmodule ExContract.EnsuresException do
  @moduledoc """
  Custom exception raised by `ExContract.ensures/1` macro.
  """

  use ExContract.BaseContractException

  @spec new(condition_txt :: String.t(), env :: any, msg :: String.t()) :: t
  def new(condition_txt, env, msg) do
    %__MODULE__{
      message: "Post-condition [#{condition_txt}] violated. Invalid implementation of function \
[#{function_desc(env.function)}] #{msg}"
    }
  end
end
