defmodule AdventOfCode2024.Day13 do
  @behaviour AdventOfCode.Day

  def process_line(line, regex) do
    Regex.run(regex, line, capture: :all_but_first)
    |> Enum.map(&String.to_integer/1)
    |> List.to_tuple()
  end

  def preprocess(input, boost) do
    input
    |> String.split("\n\n", trim: true)
    |> Enum.map(fn task ->
      [buttonA, buttonB, prize] = String.split(task, "\n", trim: true)

      buttonA = process_line(buttonA, ~r/Button A: X\+([0-9]+), Y\+([0-9]+)/)
      buttonB = process_line(buttonB, ~r/Button B: X\+([0-9]+), Y\+([0-9]+)/)
      {prizeX, prizeY} = process_line(prize, ~r/Prize: X=([0-9]+), Y=([0-9]+)/)

      {buttonA, buttonB, {prizeX + boost, prizeY + boost}}
    end)
  end

  def solve(input, boost) do
    preprocess(input, boost)
    |> Enum.map(fn {{a, c}, {b, d}, {x, y}} ->
      # a * A + b * B = x
      # c * A + d * B = y
      #             A = (x - bB) / a
      #             A = (y - dB) / c
      #  (x - bB) / a = (y - dB) / c
      #     c(x - bB) = a(y - dB)
      #      cx - cbB = ay - adB
      #     adB - cbB = ay - cx
      #    B(ad - cb) = ay - cx
      #             B = (aY - cx) / (ad - cb)
      goal_b = (a * y - c * x) / (a * d - b * c)
      goal_a = (x - b * goal_b) / a

      if goal_a == Float.floor(goal_a) and goal_b == Float.floor(goal_b) and goal_a >= 0 and
           goal_b >= 0 do
        round(3 * goal_a + goal_b)
      else
        0
      end
    end)
    |> Enum.sum()
  end

  @impl AdventOfCode.Day
  def part1(input) do
    solve(input, 0)
  end

  @impl AdventOfCode.Day
  def part2(input) do
    solve(input, 10_000_000_000_000)
  end
end
