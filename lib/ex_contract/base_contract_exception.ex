defmodule ExContract.BaseContractException do
  @moduledoc """
  Base module for contract exceptions that provides common implementation and data representation.
  """

  defmacro __using__(_opts) do
    quote do
      @type t :: %__MODULE__{message: String.t()}
      defexception message: nil

      @spec function_desc({func_name :: atom, arity :: non_neg_integer}) :: String.t()
      defp function_desc({func_name, arity}) do
        "#{func_name}/#{arity}"
      end
    end
  end
end
