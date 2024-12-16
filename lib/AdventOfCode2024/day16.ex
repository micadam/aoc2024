defmodule AdventOfCode2024.Day16 do
  @behaviour AdventOfCode.Day

  @impl AdventOfCode.Day
  def part1(input) do
    grid = input |> String.split("\n", trim: true) |> Grid.strings_to_grid()

    start_pos = Grid.all_cells(grid) |> Enum.find(fn pos -> Grid.get(grid, pos) == "S" end)
    end_pos = Grid.all_cells(grid) |> Enum.find(fn pos -> Grid.get(grid, pos) == "E" end)

    pq = Prioqueue.new([{0, start_pos, {0, 1}}])

    Stream.iterate({pq, MapSet.new()}, fn {pq, visited} ->
      v = Prioqueue.extract_min(pq)

      case v do
        {:error, :empty} ->
          {:error, 1_234_567}

        {:ok, {{cost, ^end_pos, _}, _}} ->
          {:found, cost}

        {:ok, {{cost, pos = {row, col}, dir = {drow, dcol}}, pq}} ->
          visited = MapSet.put(visited, {pos, dir})

          {pq, visited} =
            [
              {{row + drow, col + dcol}, {drow, dcol}, 1},
              {{row, col}, {dcol, -drow}, 1000},
              {{row, col}, {-dcol, drow}, 1000}
            ]
            |> Enum.reduce({pq, visited}, fn {new_pos, new_dir, new_cost}, {pq, visited} ->
              if Grid.is_valid_position(grid, new_pos) and Grid.get(grid, new_pos) != "#" and
                   not MapSet.member?(visited, {new_pos, new_dir}) do
                {Prioqueue.insert(pq, {cost + new_cost, new_pos, new_dir}),
                 MapSet.put(visited, {new_pos, new_dir})}
              else
                {pq, visited}
              end
            end)

          {pq, visited}
      end
    end)
    |> Enum.find(fn {signal, _} -> signal == :found end)
    |> elem(1)
  end

  @impl AdventOfCode.Day
  def part2(input) do
    grid = input |> String.split("\n", trim: true) |> Grid.strings_to_grid()

    start_pos = Grid.all_cells(grid) |> Enum.find(fn pos -> Grid.get(grid, pos) == "S" end)
    end_pos = Grid.all_cells(grid) |> Enum.find(fn pos -> Grid.get(grid, pos) == "E" end)

    Stream.iterate(
      {Prioqueue.new([{0, start_pos, {0, 1}}]), MapSet.new(), %{start_pos: 0}, %{}},
      fn {pq, visited, dist, prev} ->
        v = Prioqueue.extract_min(pq)

        case v do
          {:error, :empty} ->
            {:done, visited, dist, prev}

          {:ok, {{_, ^end_pos, _}, pq}} ->
            {pq, visited, dist, prev}

          {:ok, {{cost, pos = {row, col}, dir = {drow, dcol}}, pq}} ->
            if MapSet.member?(visited, {pos, dir}) do
              {pq, visited, dist, prev}
            else
              visited = MapSet.put(visited, {pos, dir})

              [
                {{row + drow, col + dcol}, {drow, dcol}, cost + 1},
                {{row, col}, {dcol, -drow}, cost + 1000},
                {{row, col}, {-dcol, drow}, cost + 1000}
              ]
              |> Enum.reduce({pq, visited, dist, prev}, fn {new_pos, new_dir, new_cost},
                                                           {pq, visited, dist, prev} ->
                new_dir = if new_pos != end_pos, do: new_dir, else: :fake_dir
                old_cost = Map.get(dist, {new_pos, new_dir}, 1_234_567)

                if Grid.is_valid_position(grid, new_pos) and Grid.get(grid, new_pos) != "#" and
                     not MapSet.member?(visited, {new_pos, new_dir}) do
                  new_prev =
                    if new_cost < old_cost,
                      do: Map.put(prev, {new_pos, new_dir}, MapSet.new([{pos, dir}])),
                      else:
                        if(new_cost == old_cost,
                          do:
                            Map.update(
                              prev,
                              {new_pos, new_dir},
                              MapSet.new([{pos, dir}]),
                              &MapSet.put(&1, {pos, dir})
                            ),
                          else: prev
                        )

                  {
                    Prioqueue.insert(pq, {new_cost, new_pos, new_dir}),
                    visited,
                    Map.update(dist, {new_pos, new_dir}, new_cost, &min(&1, new_cost)),
                    new_prev
                  }
                else
                  {pq, visited, dist, prev}
                end
              end)
            end
        end
      end
    )
    |> Enum.find(fn {signal, _, _, _} -> signal == :done end)
    |> elem(3)
    |> then(fn prev ->
      Stream.iterate({:queue.from_list([{end_pos, :fake_dir}]), MapSet.new()}, fn {q, visited} ->
        case :queue.out(q) do
          {:empty, _} ->
            {:done, visited}

          {{:value, v = {pos, dir}}, q} ->
            {Enum.reduce(Map.get(prev, {pos, dir}, MapSet.new()), q, fn v = {pos, _}, q ->
               :queue.in(v, q)
             end), MapSet.put(visited, pos)}
        end
      end)
      |> Enum.find(fn {signal, _} -> signal == :done end)
      |> elem(1)
      |> MapSet.size()
    end)
  end
end
