defmodule StackVM do
  def execute() do
    instructions = {
        :iconst, 5,
        :iconst, 2,
        :call, 9, 2,
        :print,
        :halt,
        # func(a, b) -> a + b + 5
        :iadd,
        :iconst, 5,
        :iadd,
        :return,
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
