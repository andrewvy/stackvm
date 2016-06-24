defmodule VM do
  def get_ins(cpu) do
    if cpu.ip < tuple_size(cpu.instruction_list) do
      elem(cpu.instruction_list, cpu.ip)
    else
      nil
    end
  end

  def inc_ip(cpu, inc_ip), do: %CPU{ cpu | ip: cpu.ip + inc_ip}

  def pop(stackframe), do: [a | _stack] = stackframe.stack; a

  def lookup(cpu, :string, reference), do: Map.get(cpu.constant_pool.strings, reference)

  def execute(%CPU{} = cpu), do: _execute(get_ins(cpu), inc_ip(cpu, 1))

  defp _execute(nil, cpu), do: cpu
  defp _execute(:halt, cpu), do: { :halted, cpu }

  defp _execute(:print, cpu) do
    stackframe = Enum.at(cpu.callstack, 0)
    char = case stackframe.stack do
      [] -> 10
      [ int | _rest_of_stack ] -> int
    end

    IO.write :stdio, [char]

    _execute(get_ins(cpu), inc_ip(cpu, 1))
  end

  defp _execute(:printstring, cpu) do
    stackframe = Enum.at(cpu.callstack, 0)
    case stackframe.stack do
      [] -> _execute(get_ins(cpu), inc_ip(cpu, 1))
      [ string_ref | _rest_of_stack ] ->
        string = lookup(cpu, :string, string_ref)
        IO.write :stdio, string.value
        _execute(get_ins(cpu), inc_ip(cpu, 1))
    end
  end

  defp _execute(:loadstring, cpu) do
    value = get_ins(cpu)
    stackframe = Enum.at(cpu.callstack, 0)
    string_ref = cpu.constant_pool.strings_ref
    string = %StringDefinition{ value: value }
    strings = Map.put(cpu.constant_pool.strings, string_ref, string)

    constant_pool = %ConstantPool{cpu.constant_pool |
      strings: strings,
      strings_ref: string_ref + 1
    }

    cpu = %CPU{ cpu |
      ip: cpu.ip + 1,
      constant_pool: constant_pool,
      callstack: List.replace_at(
          cpu.callstack,
          0,
          %StackFrame{ stackframe | stack: [string_ref | stackframe.stack] }
      )
    }

    _execute(get_ins(cpu), inc_ip(cpu, 1))
  end

  defp _execute(:iconst, cpu) do
    int = get_ins(cpu)
    stackframe = Enum.at(cpu.callstack, 0)
    cpu = %CPU{ cpu |
      ip: cpu.ip + 1,
      callstack: List.replace_at(
          cpu.callstack,
          0,
          %StackFrame{ stackframe | stack: [int | stackframe.stack] }
      )
    }

    _execute(get_ins(cpu), inc_ip(cpu, 1))
  end

  defp _execute(:pop, cpu) do
    stackframe = Enum.at(cpu.callstack, 0)

    rest_of_stack = case stackframe.stack do
      [] -> []
      [ _int | rest_of_stack ] -> rest_of_stack
    end

    cpu = %CPU{ cpu |
      callstack: List.replace_at(
        cpu.callstack,
        0,
        %StackFrame{ stackframe | stack: rest_of_stack }
      )
    }

    _execute(get_ins(cpu), inc_ip(cpu, 1))
  end

  defp _execute(:iadd, cpu) do
    stackframe = Enum.at(cpu.callstack, 0)
    [a | [b | rest_of_stack]] = stackframe.stack
    cpu = %CPU{ cpu | callstack: List.replace_at(cpu.callstack, 0, %StackFrame{ stackframe | stack: [a + b | rest_of_stack] })}

    _execute(
      get_ins(cpu), inc_ip(cpu, 1)
    )
  end

  defp _execute(:jump, cpu) do
    jump_ins = get_ins(cpu)
    cpu = %CPU{ cpu |
      ip: jump_ins,
    }

    _execute(get_ins(cpu), inc_ip(cpu, 1))
  end

  defp _execute(:is_eq, cpu) do
    stackframe = Enum.at(cpu.callstack, 0)
    [a | [b | rest_of_stack]] = stackframe.stack

    is_equal = case a == b do
      true -> 1
      false -> 0
    end

    cpu = %CPU{ cpu | callstack: List.replace_at(cpu.callstack, 0, %StackFrame{ stackframe | stack: [ is_equal | rest_of_stack ] })}

    _execute(get_ins(cpu), inc_ip(cpu, 1))
  end

  defp _execute(:branch_if_true, cpu) do
    jump_ins = get_ins(cpu)
    stackframe = Enum.at(cpu.callstack, 0)
    [a | _rest_of_stack] = stackframe.stack

    if a == 1 do
      cpu = %CPU{ cpu |
        ip: jump_ins,
      }
    else
      cpu = %CPU{ cpu |
        ip: cpu.ip + 1,
      }
    end

    _execute(get_ins(cpu), inc_ip(cpu, 1))
  end

  defp _execute(:call, cpu) do
    call_address = get_ins(cpu)
    argcount = get_ins(inc_ip(cpu, 1))
    [current_stackframe | stackframes] = cpu.callstack

    { current_stack, stack } =
      Enum.reduce(1..argcount, {current_stackframe.stack, []}, fn (_, {stack, acc}) ->
        { new_stack, new_acc } = case stack do
          [] -> { stack, acc }
          [a | new_stack] -> { new_stack, [ a | acc ] }
        end

        { new_stack, new_acc }
      end)

    current_stackframe = %StackFrame{ current_stackframe | stack: current_stack }

    new_stackframe = %StackFrame{ return_address: cpu.ip + 2, stack: stack }
    cpu = %CPU{ cpu | csp: 0, ip: call_address, callstack: [new_stackframe | [current_stackframe | stackframes]] }

    _execute(get_ins(cpu), inc_ip(cpu, 1))
  end

  defp _execute(:return, cpu) do
    [last_stackframe | [current_stackframe | stackframes]] = cpu.callstack
    [return_value | _] = last_stackframe.stack

    current_stackframe = %StackFrame{ current_stackframe |
      stack: [return_value | current_stackframe.stack]
    }

    cpu = %CPU{ cpu |
      ip: last_stackframe.return_address,
      csp: 0,
      callstack: [current_stackframe | stackframes]
    }

    _execute(get_ins(cpu), inc_ip(cpu, 1))
  end
end
