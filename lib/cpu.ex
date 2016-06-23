defmodule StackFrame do
  defstruct stack: []
end

defmodule CPU do
  defstruct instruction_list: [], callstack: [], ip: 0, csp: 0
end

defmodule VM do
  def get_ins(cpu) do
    if cpu.ip < tuple_size(cpu.instruction_list) do
      elem(cpu.instruction_list, cpu.ip)
    else
      nil
    end
  end

  def inc_ip(cpu, inc_ip) do
    %CPU{ cpu | ip: cpu.ip + inc_ip}
  end

  def execute(%CPU{} = cpu) do
    _execute(
      get_ins(cpu), inc_ip(cpu, 1)
    )
  end

  defp _execute(nil, cpu), do: cpu
  defp _execute(:halt, _cpu), do: :halted

  defp _execute(:print, cpu) do
    stackframe = Enum.at(cpu.callstack, cpu.csp)
    [ int | _rest_of_stack ] = stackframe.stack
    IO.inspect(int)

    _execute(
      get_ins(cpu), inc_ip(cpu, 1)
    )
  end

  defp _execute(:iconst, cpu) do
    int = get_ins(cpu)
    stackframe = Enum.at(cpu.callstack, cpu.csp)
    cpu = %CPU{ cpu |
      ip: cpu.ip + 1,
      callstack: List.replace_at(
          cpu.callstack,
          cpu.csp,
          %StackFrame{ stackframe | stack: stackframe.stack ++ [int] }
      )
    }

    _execute(
      get_ins(cpu), inc_ip(cpu, 1)
    )
  end

  defp _execute(:pop, cpu) do
    stackframe = Enum.at(cpu.callstack, cpu.csp)
    [ _int | rest_of_stack ] = stackframe.stack
    cpu = %CPU{ cpu |
      callstack: List.replace_at(
        cpu.callstack,
        cpu.csp,
        %StackFrame{ stackframe | stack: rest_of_stack }
      )
    }

    _execute(
      get_ins(cpu), inc_ip(cpu, 1)
    )
  end

  defp _execute(:iadd, cpu) do
    stackframe = Enum.at(cpu.callstack, cpu.csp)
    [a | [b | rest_of_stack]] = stackframe.stack
    cpu = %CPU{ cpu | callstack: List.replace_at(cpu.callstack, cpu.csp, %StackFrame{ stackframe | stack: [a + b | rest_of_stack] })}

    _execute(
      get_ins(cpu), inc_ip(cpu, 1)
    )
  end

  defp _execute(:jump, cpu) do
    jump_ins = get_ins(cpu)
    cpu = %CPU{ cpu |
      ip: jump_ins,
    }

    _execute(
      get_ins(cpu), inc_ip(cpu, 1)
    )
  end
end
