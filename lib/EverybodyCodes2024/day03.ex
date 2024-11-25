defmodule EverybodyCodes2024.Day03 do
  @behaviour EverybodyCodes.Day

  def flood_fill(grid, start_pos, dirs) do
    queue = :queue.new()
    queue = :queue.in(start_pos, queue)
    visited = MapSet.new()

    Stream.iterate({queue, visited}, fn {queue, visited} ->
      case :queue.out(queue) do
        {:empty, _} ->
          {:empty, visited}

        {{:value, pos}, queue} ->
          alr_visited = MapSet.member?(visited, pos)
          visited = MapSet.put(visited, pos)

          dirs = if alr_visited, do: [], else: dirs
          {row, col} = pos

          queue =
            Enum.reduce(dirs, queue, fn {drow, dcol}, queue ->
              new_pos = {row + drow, col + dcol}

              if Grid.is_valid_position(grid, new_pos) and !MapSet.member?(visited, new_pos) and
                   Grid.get(grid, new_pos) == "." do
                :queue.in(new_pos, queue)
              else
                queue
              end
            end)

          {queue, visited}
      end
    end)
    |> Enum.find(fn
      {:empty, _} -> true
      _ -> false
    end)
    |> elem(1)
  end

  def get_total_depth(input, directions) do
    grid =
      input
      |> String.split("\n", trim: true)
      |> Grid.strings_to_grid()

    visited = MapSet.new()

    {start_points, _} =
      Enum.reduce(Grid.all_cells(grid), {[], MapSet.new()}, fn pos, {start_points, visited} ->
        if MapSet.member?(visited, pos) or Grid.get(grid, pos) != "." do
          {start_points, visited}
        else
          reachable = flood_fill(grid, pos, directions)
          visited = MapSet.union(visited, reachable)
          {[pos | start_points], visited}
        end
      end)

    queue =
      Enum.reduce(start_points, Prioqueue.new(), fn pos, queue ->
        Prioqueue.insert(queue, {0, pos})
      end)

    Stream.iterate({queue, visited, 0}, fn {queue, visited, _} ->
      case Prioqueue.extract_min(queue) do
        {:error, :empty} ->
          :halt

        {:ok, {{parent_depth, pos}, queue}} ->
          {row, col} = pos

          alr_visited = MapSet.member?(visited, pos)
          visited = MapSet.put(visited, pos)

          new_depth =
            if Grid.get(grid, pos) == "#",
              do: parent_depth + 1,
              else: parent_depth

          extra_depth = if alr_visited, do: 0, else: new_depth
          directions = if alr_visited, do: [], else: directions

          queue =
            Enum.reduce(directions, queue, fn {drow, dcol}, queue ->
              new_pos = {row + drow, col + dcol}

              if Grid.is_valid_position(grid, new_pos) do
                Prioqueue.insert(queue, {new_depth, new_pos})
              else
                queue
              end
            end)

          {queue, visited, extra_depth}
      end
    end)
    |> Enum.reduce_while(0, fn
      :halt, acc -> {:halt, acc}
      {_, _, ed}, acc -> {:cont, acc + ed}
    end)
  end

  @impl EverybodyCodes.Day
  def part1(input) do
    get_total_depth(input, [{0, 1}, {0, -1}, {1, 0}, {-1, 0}])
  end

  @impl EverybodyCodes.Day
  def part2(input) do
    # Hardcoding a hole in my input data. I'm too lazy to code up hole detection, but it's not hard to do.
    get_total_depth(input, [{0, 1}, {0, -1}, {1, 0}, {-1, 0}])
  end

  @impl EverybodyCodes.Day
  def part3(input) do
    # First, surround the input with a border of dots.
    input =
      input
      |> String.split("\n", trim: true)
      |> then(fn rows ->
        row_len = rows |> List.first() |> String.length()
        dot_row = String.duplicate(".", row_len + 2)

        rows
        |> Enum.map(&("." <> &1 <> "."))
        |> then(&([dot_row] ++ &1 ++ [dot_row]))
        |> Enum.join("\n")
      end)

    get_total_depth(input, [{0, 1}, {0, -1}, {1, 0}, {-1, 0}, {1, 1}, {1, -1}, {-1, 1}, {-1, -1}])
  end
end
