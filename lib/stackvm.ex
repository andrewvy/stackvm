defmodule StackVM do
  defmodule CPU do
    defstruct stack: [], ip: 0
  end

  def execute() do
    code = {
        :push, 5,
        :label, :increment_and_inspect,
        :push, 2,
        :add,
        :inspect
    }

    execute(code)
  end

  def execute(code) do
    Agent.start_link(fn -> %{original_code: code} end, name: __MODULE__)
    _execute(instruction(0), %CPU{stack: [], ip: 0})
  end

  defp original_code do
    Agent.get(__MODULE__, fn(state) -> state.original_code end)
  end

  defp instruction(ip) do
    Agent.get(__MODULE__, fn(state) ->
      if ip < tuple_size(state.original_code) do
        elem(state.original_code, ip)
      else
        nil
      end
    end)
  end

  defp _execute(nil, cpu), do: cpu

  defp _execute(:push, cpu) do
    value = instruction(cpu.ip + 1)

    _execute(
      instruction(cpu.ip + 2),
      %CPU{ cpu | stack: [value | cpu.stack], ip: cpu.ip + 2}
    )
  end

  defp _execute(:add, %CPU{ stack: [a | [b | rest_of_stack]]} = cpu) do
    _execute(
      instruction(cpu.ip + 1),
      %CPU{ cpu | stack: [a + b | rest_of_stack], ip: cpu.ip + 1}
    )
  end

  defp _execute(:multiply, %CPU{ stack: [a | [b | rest_of_stack]]} = cpu) do
    _execute(
      instruction(cpu.ip + 1),
      %CPU{ cpu | stack: [a * b | rest_of_stack], ip: cpu.ip + 1}
    )
  end

  defp _execute(:return, cpu), do: %CPU{cpu | ip: cpu.ip + 1}

  defp _execute(:label, cpu) do
    _execute(
      instruction(cpu.ip + 2),
      %CPU{cpu | ip: cpu.ip + 2}
    )
  end

  defp _execute(:halt, _cpu), do: :halted

  defp _execute(:inspect, cpu) do
    _execute(
      instruction(cpu.ip + 1),
      %CPU{cpu | ip: cpu.ip + 1}
    )
  end

  defp _execute(:call, %CPU{ stack: [label | stack] } = cpu) do
    {instruction, new_ip} = subroutine(label)
    new_cpu = _execute(instruction, %CPU{ cpu | stack: stack, ip: new_ip})

    _execute(
      instruction(cpu.ip + 1),
      %CPU{new_cpu | ip: cpu.ip + 1}
    )
  end

  defp subroutine(label) do
    _subroutine(instruction(0), label, 0)
  end

  defp _subroutine(nil, label, ip), do: { :halt, ip }
  defp _subroutine(:label, label, ip), do: { instruction(ip + 1), ip + 1}
  defp _subroutine(_, label, ip), do: _subroutine(instruction(ip + 1), label, ip + 1)
end
