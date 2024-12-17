defmodule AdventOfCode2024.Day17 do
  @behaviour AdventOfCode.Day

  def combo_operand(operand, _) when 0 <= operand and operand <= 3 do
    operand
  end

  def combo_operand(operand, {a, b, c}) when 4 <= operand and operand <= 6 do
    Map.get(%{4 => a, 5 => b, 6 => c}, operand)
  end

  def combo_operand(operand, _) do
    raise "Invalid operand #{operand}"
  end

  def divpow_operator(numerator, exponent) do
    div(numerator, floor(:math.pow(2, exponent)))
  end

  def step(ptr, abc, ops) do
  end

  def run_program(a, b, c, ops) do
    Stream.iterate({:cont, {0, {a, b, c}, []}}, fn
      {:cont, {ptr, _, outs}} when ptr >= length(ops) ->
        {:halt, outs}

      {:cont, {ptr, {a, b, c}, outs}} ->
        {code, op} = {Enum.at(ops, ptr), Enum.at(ops, ptr + 1)}

        new_ptr =
          case {code, op} do
            {3, _} when a == 0 -> ptr + 2
            {3, _} -> op
            _ -> ptr + 2
          end

        new_outs =
          case {code, op} do
            {5, op} ->
              [rem(combo_operand(op, {a, b, c}), 8) | outs]

            _ ->
              outs
          end

        new_abc =
          case {code, op} do
            # adv
            {0, op} ->
              {divpow_operator(a, combo_operand(op, {a, b, c})), b, c}

            # bxl
            {1, op} ->
              {a, Bitwise.bxor(b, op), c}

            # bst
            {2, op} ->
              {a, rem(combo_operand(op, {a, b, c}), 8), c}

            # jnz
            {3, _} ->
              {a, b, c}

            # bxc
            {4, _} ->
              {a, Bitwise.bxor(b, c), c}

            # out
            {5, _} ->
              {a, b, c}

            # bdv
            {6, op} ->
              {a, divpow_operator(a, combo_operand(op, {a, b, c})), c}

            # cdv
            {7, op} ->
              {a, b, divpow_operator(a, combo_operand(op, {a, b, c}))}
          end

        {:cont, {new_ptr, new_abc, new_outs}}
    end)
    |> Enum.find(fn {signal, _} -> signal == :halt end)
    |> elem(1)
    |> Enum.reverse()
  end

  @impl AdventOfCode.Day
  def part1(input) do
    [a, b, c | ops] =
      Regex.scan(~r/\d+/, input) |> List.flatten() |> Enum.map(&String.to_integer/1)

    run_program(a, b, c, ops)
    |> Enum.join(",")
  end

  @impl AdventOfCode.Day
  def part2(input) do
    [_, b, c | ops] =
      Regex.scan(~r/\d+/, input) |> List.flatten() |> Enum.map(&String.to_integer/1)

    # (for my input) each loop of the program is only dependent on the last 10 bits of A.
    # So let's create a map of each unique 10-bit value of A to the output of the program.
    # Then we can stitch together the digits to produce the expected 16-digit number (the program itself)
    transformations =
      0..1023
      |> Enum.map(fn i -> {i, run_program(i, b, c, ops)} end)
      |> Enum.map(fn {i, outs} ->
        {inspect(i, base: :binary) |> String.replace("0b", "") |> String.pad_leading(10, "0"),
         Enum.at(outs, 0)}
      end)
      |> Enum.reduce(%{}, fn {i, out}, acc ->
        Map.update(acc, out, MapSet.new([i]), &MapSet.put(&1, i))
      end)

    [first_op | rest] = ops

    # Here are some facts that are true for my input (I don't know how true they are in general):
    # - The program runs in loops where each operation is executed exactly once,
    #   and then goes back to the beginning (until A is 0)
    # - The only relevant value at the start of each loop is A, since B and C are derived from A immediately
    # - After each loop, A is shifted to the right by 3 bits
    # - The value on the output is B
    # So, at each step we check the value of B (`op`) depending on the last 10 bits of A (from `transformations`),
    # and then we shift A to the right by 3 bits.
    # We do this in binary for convenience, since each output is dependent on the last 10 bits of A.
    Enum.with_index(rest)
    |> Enum.reduce(Map.get(transformations, first_op) |> MapSet.to_list(), fn {op, i}, acc ->
      str_len_after_this_step = 10 + (i + 1) * 3
      bits_filled = str_len_after_this_step |> min(48)
      num_leading_zeros = str_len_after_this_step - bits_filled

      candidates =
        Map.get(transformations, op)
        |> Enum.filter(fn i ->
          if num_leading_zeros == 0 do
            true
          else
            Enum.all?(String.slice(i, 0..(num_leading_zeros - 1)) |> String.graphemes(), fn c ->
              c == "0"
            end)
          end
        end)

      # The first 7 bits of the previous output have to match the last 7 bits of the new output
      # The new accumulator is all the candidates that satisfy this condition, combined with
      # each sequence in the old accumulator.
      Enum.reduce(acc, [], fn old_seq, new_acc ->
        Enum.reduce(candidates, new_acc, fn candidate, new_acc ->
          if String.slice(candidate, 3..9) == String.slice(old_seq, 0..6) do
            [String.slice(candidate, 0..2) <> old_seq | new_acc]
          else
            new_acc
          end
        end)
      end)
    end)
    |> Enum.map(fn i -> String.to_integer(i, 2) end)
    |> Enum.min()
  end
end
