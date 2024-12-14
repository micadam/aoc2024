defmodule AdventOfCode2024.Day14 do
  @behaviour AdventOfCode.Day

  @impl AdventOfCode.Day
  def part1(input) do
    xx = 101
    yy = 103

    mid_x = div(xx, 2)
    mid_y = div(yy, 2)

    robots =
      input
      |> String.split("\n", trim: true)
      |> Enum.map(fn line ->
        Regex.scan(~r/-?\d+/, line)
        |> List.flatten()
        |> Enum.map(&String.to_integer/1)
        |> List.to_tuple()
      end)

    Enum.reduce(1..100, robots, fn _, robots ->
      Enum.map(robots, fn {x, y, vx, vy} ->
        {rem(x + vx + xx, xx), rem(y + vy + yy, yy), vx, vy}
      end)
    end)
    |> Enum.group_by(fn
      {x, y, _, _} when x == mid_x or y == mid_y -> :mid
      {x, y, _, _} when x < mid_x and y < mid_y -> :top_left
      {x, y, _, _} when x < mid_x and y > mid_y -> :bottom_left
      {x, y, _, _} when x > mid_x and y < mid_y -> :top_right
      {x, y, _, _} when x > mid_x and y > mid_y -> :bottom_right
    end)
    |> Enum.filter(fn {label, _} -> label != :mid end)
    |> Enum.reduce(1, fn {_, robots}, acc ->
      acc * Enum.count(robots)
    end)
  end

  @impl AdventOfCode.Day
  def part2(input) do
    xx = 101
    yy = 103

    mid_x = div(xx, 2)
    mid_y = div(yy, 2)

    robots =
      input
      |> String.split("\n", trim: true)
      |> Enum.map(fn line ->
        Regex.scan(~r/-?\d+/, line)
        |> List.flatten()
        |> Enum.map(&String.to_integer/1)
        |> List.to_tuple()
      end)

    Stream.iterate({0, robots}, fn {i, robots} ->
      {i + 1,
       Enum.map(robots, fn {x, y, vx, vy} ->
         {rem(x + vx + xx, xx), rem(y + vy + yy, yy), vx, vy}
       end)}
    end)
    |> Stream.map(fn {i, robots} ->
      counts =
        Enum.map(robots, fn {x, y, _, _} -> {x, y} end)
        |> Enum.frequencies()

        {i,
          for y <- 0..(yy - 1) do
          for x <- 0..(xx - 1) do
            if (c = Map.get(counts, {x, y}, 0)) == 0 do
              " "
            else
              c
            end
          end
          |> Enum.join()
        end
        |> Enum.join("\n")}
    end)
    |> Enum.find(fn {_, drawing} ->
      # (I only know the christmas tree drawing will contain this because I scolled all the step outputs for a long time)
      String.contains?(drawing, "1111111111111111111111111111111")
    end)
    |> elem(0)
  end
end
