defmodule ExContract do
  @moduledoc """
  This is Elixir library application that adds support for design by contract. For intro to DbC
  methodology see [DbC](https://en.wikipedia.org/wiki/Design_by_contract).
  """

  alias Macro.Env
  alias ExContract.CompileState
  alias ExContract.ConditionMsg
  alias ExContract.Assert

  @default_state CompileState.new

  @type t_ast :: tuple | list(any) | any

  #
  # Private Functions
  #

  @spec agent_name(env :: Env.t) :: atom
  defp agent_name(%Env{module: module} = _env) do
    Module.concat(__MODULE__, module)
  end

  # Transforms a list of pre-conditions to ast that is to be inserted into client code.
  @spec requires_ast(cond_msg :: ConditionMsg.t) :: t_ast
  defp requires_ast(%ConditionMsg{condition: condition, msg: msg} = _cond_msg) do
    condition_txt = Macro.to_string(condition)
    ast =
      quote do
        Assert.requires(unquote(condition), unquote(condition_txt), __ENV__, unquote(msg))
      end
    #IO.puts("requires_ast=#{Macro.to_string(ast)}")
    ast
  end

  # Transforms a list of post-conditions to ast that is to be inserted into client code.
  @spec ensures_ast(cond_msg :: ConditionMsg.t) :: t_ast
  defp ensures_ast(%ConditionMsg{condition: condition, msg: msg} = _cond_msg) do
    condition_txt = Macro.to_string(condition)
    ast =
      quote do
        Assert.ensures(unquote(condition), unquote(condition_txt), __ENV__, unquote(msg))
      end
    #IO.puts("ensures_ast=#{Macro.to_string(ast)}")
    ast
  end

  @spec check_ast(condition :: t_ast, msg :: String.t) :: t_ast
  defp check_ast(condition, msg) do
    condition_txt = Macro.to_string(condition)
    ast =
      quote do
        Assert.check(unquote(condition), unquote(condition_txt), __ENV__, unquote(msg))
      end
    #IO.puts("check_ast=#{Macro.to_string(ast)}")
    ast
  end

  @spec get_and_reset_compile_state(env :: Env.t) :: CompileState.t
  defp get_and_reset_compile_state(%Env{} = env) do
    Agent.get_and_update(agent_name(env), fn %CompileState{} = s -> {s, @default_state} end)
  end

  @spec build_body_with_contracts_ast(requires :: list(ConditionMsg.t),
    body_ast :: t_ast, ensures :: list(ConditionMsg.t)) :: t_ast
  defp build_body_with_contracts_ast(requires, body_ast, ensures) do
    pre_expr =
      requires
      |> Enum.map(&requires_ast/1)

    post_expr =
      ensures
      |> Enum.map(&ensures_ast/1)

    result =
      case {Enum.empty?(pre_expr), Enum.empty?(post_expr)} do
        {true, true} -> body_ast
        {true, false} ->
          quote do
            var!(result) = unquote(body_ast)
            unquote_splicing(post_expr)
            var!(result)
          end
        {false, true} ->
          quote do
            unquote_splicing(pre_expr)
            unquote(body_ast)
          end
        {false, false} ->
          quote do
            unquote_splicing(pre_expr)
            var!(result) = unquote(body_ast)
            unquote_splicing(post_expr)
            var!(result)
          end
      end

    #IO.puts("result=#{inspect result}")
    result
  end

  @spec def_imp(public? :: boolean, definition :: t_ast, body :: t_ast, env :: Env.t) :: t_ast
  defp def_imp(public?, definition, body, env) do
    %CompileState{requires: requires, ensures: ensures} = get_and_reset_compile_state(env)

    body_with_contracts_ast = build_body_with_contracts_ast(requires, body, ensures)

    ast =
      if public? do
        quote do
          Kernel.def(unquote(definition)) do
            unquote(body_with_contracts_ast)
          end
        end
      else
        quote do
          Kernel.defp(unquote(definition)) do
            unquote(body_with_contracts_ast)
          end
        end
      end

    #IO.puts("#{Macro.to_string(ast)}")
    ast
  end

  @spec def_implicit_try_imp(list) :: t_ast
  def def_implicit_try_imp([do: body, after: rest]) do
    quote do
      try do
        unquote(body)
      after
        unquote(rest)
      end
    end
  end
  def def_implicit_try_imp([do: body, rescue: rest]) do
    quote do
      try do
        unquote(body)
      rescue
        unquote(rest)
      end
    end
  end
  def def_implicit_try_imp([do: body, catch: rest]) do
    quote do
      try do
        unquote(body)
      catch
        unquote(rest)
      end
    end
  end

  #
  # Macros
  #

  defmacro __using__(_options) do
    {:ok, _pid} = Agent.start_link(fn -> @default_state end, name: agent_name(__CALLER__))

    ast =
      quote do
        import Kernel, except: [def: 2, defp: 2]
        import unquote(__MODULE__)
        alias ExContract.Contract.Assert
        @before_compile unquote(__MODULE__)
      end
    #IO.puts("#{Macro.to_string(ast)}")
    ast
  end

  defmacro __before_compile__(%Env{} = env) do
    :ok = Agent.stop(agent_name(env))
  end

  defmacro requires(condition) do
    Agent.update(agent_name(__CALLER__),
      fn %CompileState{} = s -> CompileState.add_require(s, condition) end)
  end

  defmacro requires(condition, msg) do
    Agent.update(agent_name(__CALLER__),
      fn %CompileState{} = s -> CompileState.add_require(s, condition, msg) end)
  end

  defmacro ensures(condition) do
    Agent.update(agent_name(__CALLER__),
      fn %CompileState{} = s -> CompileState.add_ensure(s, condition) end)
  end

  defmacro ensures(condition, msg) do
    Agent.update(agent_name(__CALLER__),
      fn %CompileState{} = s -> CompileState.add_ensure(s, condition, msg) end)
  end

  defmacro check(condition, msg) do
    check_ast(condition, msg)
  end

  defmacro check(condition) do
    check_ast(condition, "")
  end

  defmacro fail(msg) do
    ast =
      quote do
        Assert.fail(__ENV__, unquote(msg))
      end
    #IO.puts("fail_ast=#{Macro.to_string(ast)}")
    ast
  end

  @doc """
  This macro replaces Kernel.def macro and adds support for DbC. When there are no pre or post
  conditions that were specified, the macro generates the same code as the Kernel module. When pre
  conditions are specified, this macro insert the portion that adds the checks as the first
  statements that are executed. When postcoditions are specified the macro wraps the body of the
  function and stores the result into `result` variable that is avialable for examination in the
  definition of ensures. If any of assertions are false, an exception is raised.
  """
  defmacro def(definition, do: body) do
    def_imp(true, definition, body, __CALLER__)
  end

  @doc """
  This macros handles function definitions that contain implicit `try` block that is followed by
  `rescue`, `after`, or `catch`. Example:
  ```
  def without_even_trying do
    raise "oops"
  after
    IO.puts "cleaning up!"
  end
  ```
  In this case the macro receives AST for body of this form:
  ```
  [do: {...}, rescue: [...]]
  ```
  """
  defmacro def(definition, body) do
    body_ast = def_implicit_try_imp(body)
    def_imp(true, definition, body_ast, __CALLER__)
  end

  @doc """
  The same as def macro except supports `requires` and `ensures` for private functions.
  """
  defmacro defp(definition, do: body) do
    def_imp(false, definition, body, __CALLER__)
  end
  @doc """
  The same as def macro except supports `requires` and `ensures` for private functions with implicit
  try block.
  """
  defmacro defp(definition, body) do
    body_ast = def_implicit_try_imp(body)
    def_imp(false, definition, body_ast, __CALLER__)
  end

end
