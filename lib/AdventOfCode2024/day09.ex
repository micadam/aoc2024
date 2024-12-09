defmodule AdventOfCode2024.Day09 do
  @behaviour AdventOfCode.Day

  @impl AdventOfCode.Day
  def part1(input) do
    numbers =
      input
      |> String.trim()
      |> String.split("", trim: true)
      |> Enum.map(&String.to_integer/1)
      |> Enum.with_index()
      |> Enum.reduce([], fn {number, idx}, acc ->
        if rem(idx, 2) == 0 do
          acc ++ [{number, round(idx / 2)}]
        else
          acc ++ [{number, :blank}]
        end
      end)

    Enum.reduce_while(0..1_000_000, {0, Enum.count(numbers) - 1, 0, 0, 0, false}, fn _,
                                                                                     {left_ptr,
                                                                                      right_ptr,
                                                                                      mult, sum,
                                                                                      right_used,
                                                                                      blank} ->
      if left_ptr >= Enum.count(numbers) or left_ptr > right_ptr do
        {:halt, sum}
      else
        if not blank do
          {size, number} = Enum.at(numbers, left_ptr)
          size = if left_ptr < right_ptr, do: size, else: size - right_used

          sum =
            sum +
              (mult..(mult + size - 1)
               |> Enum.map(fn i -> i * number end)
               |> Enum.sum())

          {:cont, {left_ptr + 1, right_ptr, mult + size, sum, right_used, true}}
        else
          {blank_space, :blank} = Enum.at(numbers, left_ptr)

          {sum, right_ptr, right_used} =
            Enum.reduce_while(
              0..1_000_000_000,
              {sum, right_ptr, right_used, blank_space, mult},
              fn
                _, {sum, right_ptr, right_used, 0, _} ->
                  {:halt, {sum, right_ptr, right_used}}

                _, {sum, right_ptr, right_used, blank_space, mult} ->
                  {size, number} = Enum.at(numbers, right_ptr)

                  if number == :blank do
                    {:cont, {sum, right_ptr - 1, right_used, blank_space, mult}}
                  else
                    to_use = min(blank_space, size - right_used)

                    sum =
                      sum +
                        (mult..(mult + to_use - 1)
                         |> Enum.map(fn i -> i * number end)
                         |> Enum.sum())

                    right_ptr = if to_use + right_used == size, do: right_ptr - 1, else: right_ptr
                    right_used = if to_use + right_used == size, do: 0, else: right_used + to_use

                    {:cont, {sum, right_ptr, right_used, blank_space - to_use, mult + to_use}}
                  end
              end
            )

          {:cont, {left_ptr + 1, right_ptr, mult + blank_space, sum, right_used, false}}
        end
      end
    end)
  end

  def interleave([a], []), do: [a]
  def interleave([a | rest_a], [b | rest_b]), do: [a, b | interleave(rest_a, rest_b)]

  @impl AdventOfCode.Day
  def part2(input) do
    numbers =
      input
      |> String.trim()
      |> String.split("", trim: true)
      |> Enum.map(&String.to_integer/1)
      |> Enum.with_index()
      |> Enum.reduce([], fn {number, idx}, acc ->
        if rem(idx, 2) == 0 do
          acc ++ [{number, round(idx / 2), idx}]
        else
          acc ++ [{number, :blank, idx}]
        end
      end)

    %{block: blocks, blank: blanks} =
      numbers
      |> Enum.group_by(fn {_, id, _} -> if id == :blank, do: :blank, else: :block end, fn
        {size, :blank, idx} ->
          {size, [], idx}

        block ->
          block
      end)

    blanks = :array.from_list(blanks)

    {blanks, blocks} =
      blocks
      |> Enum.reverse()
      |> Enum.reduce({blanks, []}, fn block = {size, _, idx}, {blanks, blocks} ->
        blank_idx =
          Enum.find_index(:array.to_list(blanks), fn {blank_size, _, blank_idx} ->
            blank_size >= size and blank_idx < idx
          end)

        if blank_idx != nil do
          {old_blank_size, old_blank_blocks, old_blank_idx} = :array.get(blank_idx, blanks)
          new_blank = {old_blank_size - size, [block | old_blank_blocks], old_blank_idx}
          {:array.set(blank_idx, new_blank, blanks), [{size, :blank, idx} | blocks]}
        else
          {blanks, [block | blocks]}
        end
      end)

    # IO.inspect(blanks)
    # IO.inspect(blocks)

    blanks =
      :array.to_list(blanks)
      |> Enum.map(fn {size, blocks, idx} ->
        {:blank, size, Enum.reverse(blocks), idx}
      end)

    all_blocks = interleave(blocks, blanks)

    {sum, _} =
      Enum.reduce(all_blocks, {0, 0}, fn
        {:blank, size, blocks, _}, {sum, mult} ->
          total_size = size + (blocks |> Enum.map(fn {size, _, _} -> size end) |> Enum.sum())

          {sum, _} =
            Enum.reduce(blocks, {sum, mult}, fn {size, id, _}, {sum, mult} ->
              {
                sum + round((mult + mult + size - 1) * size / 2) * id,
                mult + size
              }
            end)

          {sum, mult + total_size}

        {size, :blank, _}, {sum, mult} ->
          {sum, mult + size}

        {size, id, _}, {sum, mult} ->
          {sum + round((mult + mult + size - 1) * size / 2) * id, mult + size}
      end)

    sum
  end
end
