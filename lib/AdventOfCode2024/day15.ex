defmodule AdventOfCode2024.Day15 do
  @behaviour AdventOfCode.Day

  def get_movement("^") do
    {-1, 0}
  end

  def get_movement("v") do
    {1, 0}
  end

  def get_movement("<") do
    {0, -1}
  end

  def get_movement(">") do
    {0, 1}
  end

  @impl AdventOfCode.Day
  def part1(input) do
    [map, moves] = String.split(input, "\n\n", trim: true)
    grid = String.split(map, "\n", trim: true) |> Grid.strings_to_grid()

    moves = String.replace(moves, "\n", "") |> String.split("", trim: true)

    robot_pos = Grid.all_cells(grid) |> Enum.find(fn pos -> Grid.get(grid, pos) == "@" end)

    {grid, _} =
      Enum.reduce(moves, {grid, robot_pos}, fn move, {grid, robot_pos = {row, col}} ->
        {drow, dcol} = get_movement(move)

        {state, end_pos, pushing} =
          Stream.iterate({:thinking, robot_pos, false}, fn {_, robot_pos = {row, col}, pushing} ->
            new_pos = {row + drow, col + dcol}

            symbol = Grid.get(grid, new_pos)

            case symbol do
              "#" -> {:blocked, robot_pos, false}
              "." -> {:empty, new_pos, pushing}
              "O" -> {:thinking, new_pos, true}
            end
          end)
          |> Enum.find(fn {state, _, _} -> state != :thinking end)

        new_robot_pos = {row + drow, col + dcol}

        case {state, pushing} do
          {:blocked, _} ->
            {grid, robot_pos}

          {:empty, false} ->
            {
              Grid.set(grid, new_robot_pos, "@") |> Grid.set(robot_pos, "."),
              new_robot_pos
            }

          {:empty, true} ->
            {
              Grid.set(grid, new_robot_pos, "@")
              |> Grid.set(end_pos, "O")
              |> Grid.set(robot_pos, "."),
              new_robot_pos
            }
        end
      end)

    Enum.reduce(0..(Grid.num_rows(grid) - 1), 0, fn row, acc ->
      Enum.reduce(0..(Grid.num_cols(grid) - 1), acc, fn col, acc ->
        if Grid.get(grid, {row, col}) == "O" do
          acc + 100 * row + col
        else
          acc
        end
      end)
    end)
  end

  @impl AdventOfCode.Day
  def part2(input) do
    [map, moves] = String.split(input, "\n\n", trim: true)
    moves = String.replace(moves, "\n", "") |> String.split("", trim: true)

    grid =
      map
      |> String.split("\n", trim: true)
      |> Enum.map(fn line ->
        line
        |> String.replace(".", "..")
        |> String.replace("@", "@.")
        |> String.replace("#", "##")
        |> String.replace("O", "[]")
      end)
      |> Grid.strings_to_grid()

    robot_pos = Grid.all_cells(grid) |> Enum.find(fn pos -> Grid.get(grid, pos) == "@" end)

    {grid, _} =
      Enum.reduce(moves, {grid, robot_pos}, fn move, {grid, robot_pos = {row, col}} ->
        if Grid.get(grid, robot_pos) != "@" do
          raise "Robot is not in the correct position"
        end

        {drow, dcol} = get_movement(move)

        {status, clump} =
          Stream.iterate({:queue.from_list([robot_pos]), MapSet.new()}, fn {queue, clump} ->
            {v, queue} = :queue.out(queue)

            case v do
              :empty ->
                {:halt, clump}

              {:value, pos = {row, col}} ->
                if MapSet.member?(clump, pos) do
                  {queue, clump}
                else
                  symbol = Grid.get(grid, pos)

                  case {symbol, drow, dcol} do
                    {"#", _, _} ->
                      {:blocked, clump}

                    {".", _, _} ->
                      {queue, clump}

                    {"@", _, _} ->
                      {:queue.in({row + drow, col + dcol}, queue), MapSet.put(clump, pos)}

                    {"[", 0, -1} ->
                      {:queue.in({row, col - 1}, queue),
                       MapSet.put(clump, pos) |> MapSet.put({row, col + 1})}

                    {"[", 0, 1} ->
                      {:queue.in({row, col + 2}, queue),
                       MapSet.put(clump, pos) |> MapSet.put({row, col + 1})}

                    {"]", 0, -1} ->
                      {:queue.in({row, col - 2}, queue),
                       MapSet.put(clump, {row, col - 1}) |> MapSet.put({row, col})}

                    {"]", 0, 1} ->
                      {:queue.in({row, col + 1}, queue),
                       MapSet.put(clump, {row, col - 1}) |> MapSet.put({row, col})}

                    {"[", _, _} ->
                      {:queue.in({row + drow, col}, :queue.in({row + drow, col + 1}, queue)),
                       MapSet.put(clump, pos) |> MapSet.put({row, col + 1})}

                    {"]", _, _} ->
                      {:queue.in({row + drow, col}, :queue.in({row + drow, col - 1}, queue)),
                       MapSet.put(clump, {row, col - 1}) |> MapSet.put({row, col})}
                  end
                end
            end
          end)
          |> Enum.find(fn {v, _} -> v == :blocked or v == :halt end)

        if status == :blocked do
          {grid, robot_pos}
        else
          values = Enum.map(clump, fn pos -> {pos, Grid.get(grid, pos)} end)
          grid = Enum.reduce(clump, grid, fn pos, grid -> Grid.set(grid, pos, ".") end)

          {Enum.reduce(values, grid, fn {{row, col}, value}, grid ->
             Grid.set(grid, {row + drow, col + dcol}, value)
           end), {row + drow, col + dcol}}
        end
      end)

    Enum.reduce(0..(Grid.num_rows(grid) - 1), 0, fn row, acc ->
      Enum.reduce(0..(Grid.num_cols(grid) - 1), acc, fn col, acc ->
        if Grid.get(grid, {row, col}) == "[" do
          acc + 100 * row + col
        else
          acc
        end
      end)
    end)
  end
end
