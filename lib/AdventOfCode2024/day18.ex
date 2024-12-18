defmodule AdventOfCode2024.Day18 do
  @behaviour AdventOfCode.Day

  def in_bounds?({x, y}) do
    x >= 0 and x <= 70 and y >= 0 and y <= 70
  end

  def path_length(obstacles) do
    q = :queue.from_list([{{0, 0}, 0}])

    Stream.iterate({:cont, {q, MapSet.new()}}, fn {_, {q, visited}} ->
      v = :queue.out(q)

      case v do
        {:empty, _} ->
          {:error, :error}

        {{:value, {pos = {row, col}, t}}, q} ->
          if MapSet.member?(visited, pos) do
            {:cont, {q, visited}}
          else
            visited = MapSet.put(visited, pos)

            if pos == {70, 70} do
              {:done, t}
            else
              q =
                Enum.reduce(
                  [{0, 1}, {1, 0}, {0, -1}, {-1, 0}],
                  q,
                  fn {drow, dcol}, q ->
                    npos = {row + drow, col + dcol}

                    if in_bounds?(npos) and not MapSet.member?(visited, npos) and
                         not MapSet.member?(obstacles, npos) do
                      :queue.in({npos, t + 1}, q)
                    else
                      q
                    end
                  end
                )

              {:cont, {q, visited}}
            end
          end
      end
    end)
    |> Enum.find(fn {signal, _} -> signal == :done or signal == :error end)
    |> then(fn {signal, t} ->
      if signal == :done do
        t
      else
        :error
      end
    end)
  end

  @impl AdventOfCode.Day
  def part1(input) do
    obstacles =
      input
      |> String.split("\n", trim: true)
      |> Enum.map(fn line ->
        String.split(line, ",", trim: true) |> Enum.map(&String.to_integer/1)
      end)
      |> Enum.map(&List.to_tuple/1)

    obstacles = obstacles |> Enum.take(1024) |> Enum.into(MapSet.new())

    path_length(obstacles)
  end

  @impl AdventOfCode.Day
  def part2(input) do
    obstacles =
      input
      |> String.split("\n", trim: true)
      |> Enum.map(fn line ->
        String.split(line, ",", trim: true) |> Enum.map(&String.to_integer/1)
      end)
      |> Enum.map(&List.to_tuple/1)

    Stream.iterate({1025, :ok}, fn {i, _} ->
      obstacles = obstacles |> Enum.take(i) |> Enum.into(MapSet.new())

      {i + 1, path_length(obstacles)}
    end)
    |> Enum.find(fn {_, signal} -> signal == :error  end)
    |> elem(0)
    |> then(&Enum.at(obstacles, &1 - 2))
    |> then(fn i -> "#{elem(i, 0)},#{elem(i, 1)}" end)
  end
end
