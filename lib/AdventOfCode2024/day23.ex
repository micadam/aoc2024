defmodule AdventOfCode2024.Day23 do
  @behaviour AdventOfCode.Day

  @impl AdventOfCode.Day
  def part1(input) do
    connections =
      input
      |> String.split("\n", trim: true)
      |> Enum.map(&String.split(&1, "-", trim: true))
      |> Enum.reduce(%{}, fn [from, to], acc ->
        Map.update(acc, from, MapSet.new([to]), &MapSet.put(&1, to))
        |> Map.update(to, MapSet.new([from]), &MapSet.put(&1, from))
      end)

    for a <- Map.keys(connections),
        b <- Map.keys(connections),
        c <- Map.keys(connections),
        a < b,
        b < c,
        String.starts_with?(a, "t") or String.starts_with?(b, "t") or String.starts_with?(c, "t") do
      MapSet.member?(Map.get(connections, a), b) and
        MapSet.member?(Map.get(connections, b), c) and
        MapSet.member?(Map.get(connections, c), a)
    end
    |> Enum.count(& &1)
  end

  def bron_kerbosch(r, p, x, graph) do
    if Enum.empty?(p) and Enum.empty?(x) do
      [r]
    else
      Enum.reduce(p, {[], p, MapSet.new()}, fn v, {ans, p, x} ->
        neighbors = Map.get(graph, v, MapSet.new())

        {bron_kerbosch(
           MapSet.put(r, v),
           MapSet.intersection(p, neighbors),
           MapSet.intersection(x, neighbors),
           graph
         ) ++ ans, MapSet.delete(p, v), MapSet.put(x, v)}
      end) |> elem(0)
    end
  end

  @impl AdventOfCode.Day
  def part2(input) do
    connections =
      input
      |> String.split("\n", trim: true)
      |> Enum.map(&String.split(&1, "-", trim: true))
      |> Enum.reduce(%{}, fn [from, to], acc ->
        Map.update(acc, from, MapSet.new([to]), &MapSet.put(&1, to))
        |> Map.update(to, MapSet.new([from]), &MapSet.put(&1, from))
      end)

    bron_kerbosch(
      MapSet.new(),
      connections |> Map.keys() |> MapSet.new(),
      MapSet.new(),
      connections
    )
    |> Enum.max_by(&MapSet.size/1)
    |> MapSet.to_list()
    |> Enum.sort()
    |> Enum.join(",")
  end
end
