defmodule AdventOfCode2024.Day05 do
  @behaviour AdventOfCode.Day

  def preprocess(input) do
    [rules, updates] = String.split(input, "\n\n", trim: true)

    rules_set =
      Enum.reduce(String.split(rules, "\n", trim: true), MapSet.new(), fn rule, acc ->
        [a, b] =
          String.split(rule, "|")
          |> Enum.map(&String.to_integer/1)

        MapSet.put(acc, {a, b})
      end)

    updates =
      updates
      |> String.split("\n", trim: true)
      |> Enum.map(fn update ->
        String.split(update, ",")
        |> Enum.map(&String.to_integer/1)
      end)

    {rules_set, updates}
  end

  def update_broken(numbers, rules_set) do
    Enum.any?(
      for {n1, i} <- Enum.with_index(numbers),
          {n2, j} <- Enum.with_index(numbers),
          i < j do
        MapSet.member?(rules_set, {n2, n1})
      end
    )
  end

  @impl AdventOfCode.Day
  def part1(input) do
    {rules_set, updates} = preprocess(input)

    updates
    |> Enum.filter(fn numbers -> not update_broken(numbers, rules_set) end)
    |> Enum.map(fn numbers -> Enum.at(numbers, round((Enum.count(numbers) - 1) / 2)) end)
    |> Enum.sum()
  end

  def fix_update(update, rules_set) do
    Enum.reduce(update, [], fn number, acc ->
        idx =
          acc
          |> Enum.with_index()
          |> Enum.filter(fn {n, _} -> MapSet.member?(rules_set, {n, number}) end)
          |> Enum.map(fn {_, i} -> i end)
          |> Enum.max(fn -> -1 end)

        List.insert_at(acc, idx + 1, number)
    end)
  end

  @impl AdventOfCode.Day
  def part2(input) do
    {rules_set, updates} = preprocess(input)

    updates
    |> Enum.filter(fn numbers -> update_broken(numbers, rules_set) end)
    |> Enum.map(fn update -> fix_update(update, rules_set) end)
    |> Enum.map(fn numbers -> Enum.at(numbers, round((Enum.count(numbers) - 1) / 2)) end)
    |> Enum.sum()
  end
end
