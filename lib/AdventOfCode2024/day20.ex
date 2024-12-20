defmodule AdventOfCode2024.Day20 do
  @behaviour AdventOfCode.Day

  def get_cost_map_no_cheat(grid) do
    end_pos = Grid.all_cells(grid) |> Enum.find(fn pos -> Grid.get(grid, pos) == "E" end)

    q = :queue.from_list([end_pos])

    Stream.iterate({:cont, {q, MapSet.new(), %{end_pos => 0}}}, fn {_, {q, visited, costs}} ->
      v = :queue.out(q)

      case v do
        {:empty, _} ->
          {:done, costs}

        {{:value, pos = {row, col}}, q} ->
          if MapSet.member?(visited, pos) do
            {:cont, {q, visited, costs}}
          else
            visited = MapSet.put(visited, pos)
            moves = [{0, 1}, {1, 0}, {0, -1}, {-1, 0}]

            cost = Map.get(costs, pos)

            {q, costs} =
              moves
              |> Enum.reduce({q, costs}, fn dir = {drow, dcol}, {q, costs} ->
                npos = {row + drow, col + dcol}
                dcost = 1

                if Grid.is_valid_position(grid, npos) and Grid.get(grid, npos) != "#" and
                     not Map.has_key?(costs, npos) do
                  {:queue.in(npos, q), Map.put(costs, npos, cost + dcost)}
                else
                  {q, costs}
                end
              end)

            {:cont, {q, visited, costs}}
          end
      end
    end)
    |> Enum.find(fn {signal, _} -> signal == :done end)
    |> elem(1)
  end

  def generate_cheat_moves(max_length) do
    for drow <- -max_length..max_length,
        dcol <- -max_length..max_length,
        abs(drow) + abs(dcol) <= max_length,
        abs(drow) + abs(dcol) > 0 do
      {drow, dcol}
    end
  end

  def find_good_cheats(input, max_cheat) do
    grid = String.split(input, "\n", trim: true) |> Grid.strings_to_grid()

    costs_to_end = get_cost_map_no_cheat(grid)

    start_pos = Grid.all_cells(grid) |> Enum.find(fn pos -> Grid.get(grid, pos) == "S" end)
    normal_cost = Map.get(costs_to_end, start_pos)

    end_pos = Grid.all_cells(grid) |> Enum.find(fn pos -> Grid.get(grid, pos) == "E" end)

    q = :queue.from_list([{0, start_pos}])

    Stream.iterate({:cont, {q, MapSet.new(), []}}, fn {_, {q, visited, costs}} ->
      v = :queue.out(q)

      case v do
        {:empty, _} ->
          {:error, :empty}

        {{:value, {_, ^end_pos}}, _} ->
          {:found, costs |> Enum.count(&(normal_cost - &1 >= 100))}

        {{:value, {cost, pos = {row, col}}}, q} ->
          if MapSet.member?(visited, pos) do
            {:cont, {q, visited, costs}}
          else
            visited = MapSet.put(visited, pos)
            moves = generate_cheat_moves(max_cheat)

            {pq, costs} =
              moves
              |> Enum.reduce({q, costs}, fn dir = {drow, dcol}, {q, costs} ->
                npos = {row + drow, col + dcol}
                dcost = dir |> Tuple.to_list() |> Enum.map(&abs/1) |> Enum.sum()
                cheated = dcost > 1

                cost_to_end = Map.get(costs_to_end, npos)

                if not Grid.is_valid_position(grid, npos) or Grid.get(grid, npos) == "#" or
                     MapSet.member?(visited, npos) do
                  {q, costs}
                else
                  if cheated do
                    cheated_cost = cost_to_end + cost + dcost

                    if cheated_cost < normal_cost do
                      {q, [cheated_cost | costs]}
                    else
                      {q, costs}
                    end
                  else
                    {:queue.in({cost + dcost, npos}, q), costs}
                  end
                end
              end)

            {:cont, {pq, visited, costs}}
          end
      end
    end)
    |> Enum.find(fn {signal, _} -> signal == :found end)
    |> elem(1)
  end

  @impl AdventOfCode.Day
  def part1(input) do
    find_good_cheats(input, 2)
  end

  @impl AdventOfCode.Day
  def part2(input) do
    find_good_cheats(input, 20)
  end
end
