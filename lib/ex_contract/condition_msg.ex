defmodule ExContract.ConditionMsg do
  @moduledoc """
  This module is not meant to be used directly by client code. This module holds data related to
  contract condition and optional message that is reported when such condition fails.
  """

  @typedoc """
  Defines fields that store `ExContract` compile state.
  * `:condition` - tuple representing an AST of Elixir conditon statement that is to return boolean.
  * `:msg` - an optional message that is to be retported when the `:condition` turns out to be
  `false`.
  """
  @type t :: %__MODULE__{condition: tuple, msg: String.t()}
  defstruct [:condition, :msg]

  @doc """
  Create an instance of `CondMsg` given provided `condition`. Sets msg to `nil`.
  """
  @spec new(condition :: tuple) :: __MODULE__.t()
  def new(condition) do
    %__MODULE__{condition: condition, msg: ""}
  end

  @doc """
  Create an instance of `ExContract.ConditionMsg` given provided `condition` and `msg`.
  """
  @spec new(condition :: tuple, msg :: String.t()) :: __MODULE__.t()
  def new(condition, msg) do
    %__MODULE__{condition: condition, msg: msg}
  end
end
