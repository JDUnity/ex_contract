defmodule ExContract.CheckException do
  @moduledoc """
  Custom exception raised by `ExContract.check/1` macro.
  """

  use ExContract.BaseContractException

  @spec new(condition_txt :: String.t, env :: any, msg :: String.t) :: t
  def new(condition_txt, env, msg) do
    %__MODULE__{message:
    "Check condition [#{condition_txt}] violated. Invalid assumption in function \
[#{function_desc(env.function)}] #{msg}"}
  end

end
