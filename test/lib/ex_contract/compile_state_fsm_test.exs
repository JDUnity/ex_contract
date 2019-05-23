defmodule ExContract.CompileStateFsmTest do
  @moduledoc false

  use ExUnit.Case

  alias ExContract.CompileStateFsm, as: FSM

  setup do
    {:ok, fsm: start_fsm()}
  end

  test "starts in :no_contracts_pending state", %{fsm: fsm} do
    assert FSM.current_state(fsm) == :no_contracts_pending
  end

  describe ":no_contracts_pending state" do
    test "function_def event", %{fsm: fsm} do
      FSM.function_def(fsm, function_def(:foo))
      assert FSM.current_state(fsm) == :no_contracts_pending
    end

    test "requires_def event", %{fsm: fsm} do
      FSM.requires_def(fsm, :requires)
      assert FSM.current_state(fsm) == :contracts_pending
      assert FSM.pending_requires(fsm) == [:requires]
    end

    test "ensures_def event", %{fsm: fsm} do
      FSM.ensures_def(fsm, :ensures)
      assert FSM.current_state(fsm) == :contracts_pending
      assert FSM.pending_ensures(fsm) == [:ensures]
    end

    test "pending_requires", %{fsm: fsm} do
      assert FSM.pending_requires(fsm) == []
    end

    test "pending_ensures", %{fsm: fsm} do
      assert FSM.pending_ensures(fsm) == []
    end
  end

  describe ":contracts_pending state" do
    setup %{fsm: fsm} do
      set_state(fsm, :contracts_pending)
      {:ok, fsm: fsm}
    end

    test "function_def event", %{fsm: fsm} do
      FSM.function_def(fsm, function_def(:foo))
      assert FSM.current_state(fsm) == :contracts_apply
      assert FSM.pending_requires(fsm) == []
      assert FSM.pending_ensures(fsm) == []
    end

    test "requires_def event", %{fsm: fsm} do
      FSM.requires_def(fsm, :requires)
      assert FSM.current_state(fsm) == :contracts_pending
      assert FSM.pending_requires(fsm) == [:requires]
    end

    test "ensures_def event", %{fsm: fsm} do
      FSM.ensures_def(fsm, :ensures)
      assert FSM.current_state(fsm) == :contracts_pending
      assert FSM.pending_ensures(fsm) == [:ensures]
    end
  end

  describe ":contracts_apply state" do
    setup %{fsm: fsm} do
      set_state(fsm, :contracts_apply)
      {:ok, fsm: fsm}
    end

    test "function_def event", %{fsm: fsm} do
      FSM.function_def(fsm, function_def(:foo))
      assert FSM.current_state(fsm) == :no_contracts_pending
    end

    test "requires_def event", %{fsm: fsm} do
      FSM.requires_def(fsm, :requires)
      assert FSM.current_state(fsm) == :contracts_pending
      assert FSM.pending_requires(fsm) == [:requires]
    end

    test "ensures_def event", %{fsm: fsm} do
      FSM.ensures_def(fsm, :ensures)
      assert FSM.current_state(fsm) == :contracts_pending
      assert FSM.pending_ensures(fsm) == [:ensures]
    end
  end

  describe "functions with multiple clauses" do
    setup %{fsm: fsm} do
      FSM.requires_def(fsm, :requires1)
      FSM.requires_def(fsm, :requires2)
      FSM.ensures_def(fsm, :ensures1)
      FSM.ensures_def(fsm, :ensures2)

      {:ok, fsm: fsm}
    end

    test "contracts apply to all clauses of functions with same name and arity", %{fsm: fsm} do
      assert FSM.current_state(fsm) == :contracts_pending
      assert FSM.pending_requires(fsm) == [:requires1, :requires2]
      assert FSM.pending_ensures(fsm) == [:ensures1, :ensures2]

      FSM.function_def(fsm, function_def(:fn1, [:x, :y]))
      assert FSM.current_state(fsm) == :contracts_apply
      assert FSM.pending_requires(fsm) == [:requires1, :requires2]
      assert FSM.pending_ensures(fsm) == [:ensures1, :ensures2]

      FSM.function_def(fsm, function_def(:fn1, [:a, :b]))
      assert FSM.current_state(fsm) == :contracts_apply
      assert FSM.pending_requires(fsm) == [:requires1, :requires2]
      assert FSM.pending_ensures(fsm) == [:ensures1, :ensures2]

      FSM.function_def(fsm, function_def(:fn2, [:x, :y]))
      assert FSM.current_state(fsm) == :no_contracts_pending
      assert FSM.pending_requires(fsm) == []
      assert FSM.pending_ensures(fsm) == []
    end

    test "contracts cannot be defined in between clauses of functions", %{fsm: fsm} do
      assert FSM.current_state(fsm) == :contracts_pending
      assert FSM.pending_requires(fsm) == [:requires1, :requires2]
      assert FSM.pending_ensures(fsm) == [:ensures1, :ensures2]

      FSM.function_def(fsm, function_def(:fn1, [:x, :y]))
      assert FSM.current_state(fsm) == :contracts_apply
      assert FSM.pending_requires(fsm) == [:requires1, :requires2]
      assert FSM.pending_ensures(fsm) == [:ensures1, :ensures2]

      FSM.requires_def(fsm, :requires_in_between)
      FSM.ensures_def(fsm, :ensures_in_between)
      assert FSM.current_state(fsm) == :contracts_pending
      assert FSM.pending_requires(fsm) == [:requires_in_between]
      assert FSM.pending_ensures(fsm) == [:ensures_in_between]

      assert_raise CompileError, fn ->
        FSM.function_def(fsm, function_def(:fn1, [:a, :b]))
      end

      assert FSM.current_state(fsm) == :no_contracts_pending
    end
  end

  defp start_fsm(module \\ __MODULE__) do
    {:ok, fsm} = FSM.start_link(module)
    fsm
  end

  defp set_state(fsm, state) do
    :gen_statem.cast(fsm, {:set_state, state})
  end

  defp function_def(name, args \\ [:x, :y]) do
    {name, [line: 11], Enum.map(args, &{&1, [line: 11], nil})}
  end
end
