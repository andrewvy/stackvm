defmodule StackVM do
  def execute() do
    instructions = {
        :iconst, 2,
        :iconst, 2,
        :iadd,
        :iconst, 4,
        :is_eq,
        :branch_if_true, 11,
        :halt,
        :call, 16, 0,
        :print,
        :halt,
        :iconst, 10,
        :iconst, 10,
        :iadd,
        :return
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
