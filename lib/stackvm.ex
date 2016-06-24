defmodule StackVM do
  def execute() do
    instructions = {
      :iconst,
      100,
      :iconst,
      108,
      :iconst,
      114,
      :iconst,
      111,
      :iconst,
      119,

      :iconst,
      32,

      :iconst,
      111,
      :iconst,
      108,
      :iconst,
      108,
      :iconst,
      101,
      :iconst,
      72,

      :print,
      :pop,
      :print,
      :pop,
      :print,
      :pop,
      :print,
      :pop,
      :print,
      :pop,
      :print,
      :pop,
      :print,
      :pop,
      :print,
      :pop,
      :print,
      :pop,
      :print,
      :pop,
      :print,
      :pop,
      :print,
      :halt
    }

    cpu = %CPU{
      instruction_list: instructions,
      callstack: [%StackFrame{}],
      ip: 0,
      csp: 0
    }

    VM.execute(cpu)
  end
end
