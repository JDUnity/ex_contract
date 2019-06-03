defmodule ExContract.CompileStateFsm do
  @moduledoc """
  Finite State Machine (FSM) holding compile-time state for modules that use `ExContract`.

  The states recognized by this FSM are:

    * `:no_contracts_pending` - initial state before any function or contract definitions have been
          encountered
    * `:contracts_pending` - one or more `requires` or `ensures` has been encountered and will be
          applied to the next function definition
    * `:contracts_apply` - a function definition has been encountered in the `:contracts_pending`
          state and the function should be wrapped with the pending contracts
  """

  @type server_ref :: pid | atom
  @type state :: :no_contracts_pending | :contracts_pending | :contracts_apply
  @type function_def :: {name :: atom, list, parameters :: list | nil}
  @type requires_def :: tuple
  @type ensures_def :: tuple

  @doc """
  Returns the name that is used to register the CompileStateFsm process for the given module.
  """
  @spec name(module) :: module
  def name(module), do: Module.concat(module, CompileStateFsm)

  @doc """
  Starts a new FSM process for the given module, and registers it with the name provided by
  calling `name(module)`.
  """
  @spec start_link(module) :: {:ok, pid} | {:error, reason :: term}
  def start_link(module) when is_atom(module),
    do: :gen_statem.start_link({:local, name(module)}, __MODULE__.Server, module, [])

  @doc "Stop the FSM process."
  @spec stop(server_ref) :: :ok
  def stop(fsm), do: :gen_statem.stop(fsm)

  @doc """
  Returns the PID of the FSM process for the given module, or `nil` if there is no such process.
  """
  @spec for_module(module) :: pid | nil
  def for_module(module) when is_atom(module) do
    Process.whereis(name(module))
  end

  @doc """
  Returns the current state of the FSM as an atom.
  """
  @spec current_state(server_ref) :: state
  def current_state(fsm), do: :gen_statem.call(fsm, :get_state)

  @doc """
  Sends a `function_def` event to the FSM.

  Raises a `CompileError` if the FSM is in an error state.
  """
  @spec function_def(server_ref, function_def) :: :ok | no_return
  def function_def(fsm, definition) do
    case :gen_statem.call(fsm, {:function_def, definition}) do
      :ok -> :ok
      {:error, reason} -> raise CompileError, description: reason
    end
  end

  @doc """
  Sends a `requires_def` event to the FSM.
  """
  @spec requires_def(server_ref, requires_def) :: :ok
  def requires_def(fsm, definition) do
    :gen_statem.cast(fsm, {:requires_def, definition})
  end

  @doc """
  Sends a `ensures_def` event to the FSM.
  """
  @spec ensures_def(server_ref, ensures_def) :: :ok
  def ensures_def(fsm, definition) do
    :gen_statem.cast(fsm, {:ensures_def, definition})
  end

  @doc """
  Returns a list containing all pending `requires` definitions.
  """
  @spec pending_requires(server_ref) :: list(requires_def)
  def pending_requires(fsm) do
    :gen_statem.call(fsm, :pending_requires)
  end

  @doc """
  Returns a list containing all pending `ensures` definitions.
  """
  @spec pending_ensures(server_ref) :: list(ensures_def)
  def pending_ensures(fsm) do
    :gen_statem.call(fsm, :pending_ensures)
  end

  defmodule Server do
    @moduledoc false
    @behaviour :gen_statem

    defstruct module: nil, last_function_def: nil, requires_defs: [], ensures_defs: []

    @impl :gen_statem
    def callback_mode, do: :handle_event_function

    @impl :gen_statem
    def init(module) when is_atom(module),
      do: {:ok, :no_contracts_pending, %__MODULE__{module: module}}

    @impl :gen_statem
    def handle_event({:call, from}, :get_state, state, data) do
      {:keep_state, data, [{:reply, from, state}]}
    end

    def handle_event({:call, from}, {:function_def, definition}, :no_contracts_pending, data) do
      {:keep_state, record_function_def(data, definition), {:reply, from, :ok}}
    end

    def handle_event({:call, from}, {:function_def, definition}, :contracts_pending, data) do
      if function_id(definition) == data.last_function_def do
        error =
          {:error,
           "cannot define contracts in between clauses of functions with the same name" <>
             " and arity (number of arguments)"}

        {:next_state, :no_contracts_pending, clear_pending_contracts(data), {:reply, from, error}}
      else
        {:next_state, :contracts_apply, record_function_def(data, definition),
         {:reply, from, :ok}}
      end
    end

    def handle_event({:call, from}, {:function_def, definition}, :contracts_apply, data) do
      if function_id(definition) == data.last_function_def do
        {:keep_state, data, {:reply, from, :ok}}
      else
        new_data =
          data
          |> record_function_def(definition)
          |> clear_pending_contracts()

        {:next_state, :no_contracts_pending, new_data, {:reply, from, :ok}}
      end
    end

    def handle_event(:cast, {:requires_def, definition}, state, data)
        when state in [:no_contracts_pending, :contracts_pending] do
      new_data = update_in(data.requires_defs, &[definition | &1])
      {:next_state, :contracts_pending, new_data}
    end

    def handle_event(:cast, {:requires_def, definition}, :contracts_apply, data) do
      data = clear_pending_contracts(data)
      new_data = put_in(data.requires_defs, [definition])
      {:next_state, :contracts_pending, new_data}
    end

    def handle_event(:cast, {:ensures_def, definition}, state, data)
        when state in [:no_contracts_pending, :contracts_pending] do
      new_data = update_in(data.ensures_defs, &[definition | &1])
      {:next_state, :contracts_pending, new_data}
    end

    def handle_event(:cast, {:ensures_def, definition}, :contracts_apply, data) do
      data = clear_pending_contracts(data)
      new_data = put_in(data.ensures_defs, [definition])
      {:next_state, :contracts_pending, new_data}
    end

    def handle_event({:call, from}, :pending_requires, :no_contracts_pending, data) do
      {:keep_state, data, {:reply, from, []}}
    end

    def handle_event({:call, from}, :pending_requires, _state, data) do
      {:keep_state, data, {:reply, from, Enum.reverse(data.requires_defs)}}
    end

    def handle_event({:call, from}, :pending_ensures, :no_contracts_pending, data) do
      {:keep_state, data, {:reply, from, []}}
    end

    def handle_event({:call, from}, :pending_ensures, _state, data) do
      {:keep_state, data, {:reply, from, Enum.reverse(data.ensures_defs)}}
    end

    # NOTE: this clause is used only for testing purposes
    def handle_event(:cast, {:set_state, new_state}, _state, data) do
      {:next_state, new_state, data}
    end

    defp function_id({name, _, nil}), do: {name, 0}
    defp function_id({name, _, params}) when is_list(params), do: {name, length(params)}

    defp record_function_def(data, definition) do
      %{data | last_function_def: function_id(definition)}
    end

    defp clear_pending_contracts(data) do
      %{data | requires_defs: [], ensures_defs: []}
    end
  end
end
