defmodule ExContract.CompileState do
  @moduledoc """
  Holds compilation state for JdContracts storing each condition and optional message in
  corresponding requires or ensures lists.
  """

  alias ExContract.ConditionMsg

  @spec append(items :: list(ConditionMsg.t), item :: ConditionMsg.t) :: list(ConditionMsg.t)
  defp append(items, item) do
    List.insert_at(items, Enum.count(items), item)
  end

  @typedoc """
  Defines fields that store `JdContracts` compile state.
  * `:requires` - list of `ExContract.ConditionMsg` that define a single method pre-conditions.
  * `:ensures` - list of `ExContract.ConditionMsg` that define a single method post-conditions.
  """
  @type t :: %__MODULE__{requires: list(ConditionMsg.t), ensures: list(ConditionMsg.t)}
  defstruct [requires: [], ensures: []]

  @doc """
  Returns an empty state where both `:requires` and `:ensures` list are empty.
  """
  @spec new :: __MODULE__.t
  def new, do: %__MODULE__{requires: [], ensures: []}

  @doc """
  Adds a require condition of type `ExContract.ConditionMsg` to the `requires` list. The condition
  is associated with `nil` message.
  """
  @spec add_require(state :: __MODULE__.t, condition :: tuple) :: __MODULE__.t
  def add_require(%__MODULE__{requires: requires} = state, condition) do
    %{state | requires: append(requires, ConditionMsg.new(condition))}
  end

  @doc """
  Adds a require condition of type `ExContract.ConditionMsg` to the `requires` list. The condition
  is associated with provided message.
  """
  @spec add_require(state :: __MODULE__.t, condition :: tuple, msg :: String.t) :: __MODULE__.t
  def add_require(%__MODULE__{requires: requires} = state, condition, msg) do
    %{state | requires: append(requires, ConditionMsg.new(condition, msg))}
  end

  @doc """
  Adds a ensures condition of type `ExContract.ConditionMsg` to the `ensures` list. The condition
  is associated with `nil` message.
  """
  @spec add_ensure(state :: __MODULE__.t, condition :: tuple) :: __MODULE__.t
  def add_ensure(%__MODULE__{ensures: ensures} = state, condition) do
    %{state | ensures: append(ensures, ConditionMsg.new(condition))}
  end

  @doc """
  Adds a ensures condition of type `ExContract.ConditionMsg` to the `ensures` list. The condition
  is associated with `nil` message.
  """
  @spec add_ensure(state :: __MODULE__.t, condition :: tuple, msg :: String.t) :: __MODULE__.t
  def add_ensure(%__MODULE__{ensures: ensures} = state, condition, msg) do
    %{state | ensures: append(ensures, ConditionMsg.new(condition, msg))}
  end

end
