defmodule StackVM do
  def execute() do
    instructions = {
      :loadstring, 'Hello world!',
      :printstring,
      :halt
    }

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
