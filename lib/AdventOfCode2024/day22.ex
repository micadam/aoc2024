defmodule AdventOfCode2024.Day22 do
  @behaviour AdventOfCode.Day

  def get_secret_number(number) do
    number
    |> then(fn number -> rem(Bitwise.bxor(number * 64, number), 16_777_216) end)
    |> then(fn number -> rem(Bitwise.bxor(div(number, 32), number), 16_777_216) end)
    |> then(fn number -> rem(Bitwise.bxor(number * 2048, number), 16_777_216) end)
  end

  @impl AdventOfCode.Day
  def part1(input) do
    numbers = input |> String.split("\n", trim: true) |> Enum.map(&String.to_integer/1)

    Enum.map(numbers, fn number ->
      Enum.reduce(1..2000, number, fn _, acc ->
        get_secret_number(acc)
      end)
    end)
    |> Enum.sum()
  end

  def generate_selling_map(initial_secret_number) do
    # Iterate getting 2000 secret numbers and store each intermediate result
    secret_numbers =
      Enum.reduce(1..2000, [initial_secret_number], fn _, numbers = [number | _] ->
        [
          get_secret_number(number)
          | numbers
        ]
      end)
      |> Enum.reverse()
      |> Enum.map(fn number -> rem(number, 10) end)

    diffs = secret_numbers |> Enum.chunk_every(2, 1, :discard) |> Enum.map(fn [a, b] -> b - a end)

    Enum.zip(
      Enum.drop(secret_numbers, 4),
      Enum.chunk_every(diffs, 4, 1, :discard)
    )
    |> Enum.reduce(%{}, fn {secret_number, diffs}, acc ->
      Map.update(acc, diffs |> List.to_tuple(), secret_number, fn existing -> existing end)
    end)
  end

  @impl AdventOfCode.Day
  def part2(input) do
    numbers = input |> String.split("\n", trim: true) |> Enum.map(&String.to_integer/1)

    selling_maps = Enum.map(numbers, &generate_selling_map/1)
    all_keys = selling_maps |> Enum.flat_map(&Map.keys/1) |> Enum.uniq()

    all_keys
    |> Enum.map(fn key -> Enum.map(selling_maps, &Map.get(&1, key, 0)) end)
    |> Enum.map(&Enum.sum/1)
    |> Enum.max()
  end
end
