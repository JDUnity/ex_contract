defmodule ExContract.RequiresException do
  @moduledoc """
  Custom exception raised by `ExContract.requires/1` macro.
  """

  use ExContract.BaseContractException

  @spec new(condition_txt :: String.t, env :: any, msg :: String.t) :: t
  def new(condition_txt, env, msg) do
    %__MODULE__{message:
    "Pre-condition [#{condition_txt}] violated. Invalid implementation of caller to function \
[#{function_desc(env.function)}] #{msg}"}
  end

end
