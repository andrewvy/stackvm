defmodule StackVM do
  def execute() do
    instructions = {
      :iconst, 0,
      :iconst, 5,
      :is_eq,
      :branch_if_true, 19,

      :pop,
      :pop,
      :loadstring, 'Hello world!',
      :printstring,
      :pop,
      :iconst, 1,
      :iadd,
      :jump, 2,
      :halt,

      :halt,
    }

    # for (var i = 0; i < 5; i++) {
    #   print('Hello world!')
    # }

    cpu = %CPU{
      constant_pool: %ConstantPool{},
      instruction_list: instructions,
      callstack: [%StackFrame{}],
      ip: 0,
      csp: 0
    }

    VM.execute(cpu)
  end
end
