defmodule ExUnit.CaseTemplate do
  @moduledoc """
  Defines a module template to be used throughout your test suite.

  This is useful when there are a set of setup callbacks or a set
  of functions that should be shared between test modules.

  Once a case template is used, the regular functionality in
  `ExUnit.Case` plus the functionality defined in the template
  will become available.

  ## Example

      defmodule MyCase do
        use ExUnit.CaseTemplate

        setup do
          IO.puts("This will run before each test that uses this case")
        end
      end

      defmodule MyTest do
        use MyCase, async: true

        test "truth" do
          assert true
        end
      end

  """

  @doc false
  defmacro __using__(_) do
    quote do
      use ExUnit.Callbacks

      import ExUnit.Assertions
      import unquote(__MODULE__)

      defmacro __using__(opts) do
        unquote(__MODULE__).__proxy__(__MODULE__, opts)
      end

      defoverridable __using__: 1
    end
  end

  @doc false
  def __proxy__(module, opts) do
    quote do
      use ExUnit.Case, unquote(opts)

      setup_all context do
        unquote(module).__ex_unit__(:setup_all, context)
      end

      setup context do
        unquote(module).__ex_unit__(:setup, context)
      end
    end
  end

  @doc """
  Allows a developer to customize the using block
  when the case template is used.

  ## Example

      defmodule MyCase do
        use ExUnit.CaseTemplate

        using do
          quote do
            # This code is injected into every case that calls "use MyCase"
            alias MyApp.FunModule
          end
        end
      end

  """
  defmacro using(var \\ quote(do: _), do: block) do
    quote do
      defmacro __using__(unquote(var) = opts) do
        parent = unquote(__MODULE__).__proxy__(__MODULE__, opts)
        result = unquote(block)
        {:__block__, [], [parent, result]}
      end
    end
  end
end
