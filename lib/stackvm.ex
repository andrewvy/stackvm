defmodule StackVM do
  def execute() do
    instructions = {
        :iconst, 5,
        :iconst, 2,
        :iadd,
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
