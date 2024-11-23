defmodule EverybodyCodes2024.Day01 do
  @behaviour EverybodyCodes.Day

  defp score_monster(monster) do
    case monster do
      "A" -> 0
      "B" -> 1
      "C" -> 3
      "D" -> 5
      _ -> 0
    end
  end

  @impl EverybodyCodes.Day
  def part1(input) do
    input
    |> String.split("", trim: true)
    |> Enum.map(&score_monster/1)
    |> Enum.sum()
  end

  @impl EverybodyCodes.Day
  def part2(input) do
    input
    |> String.split("", trim: true)
    |> Enum.chunk_every(2)
    |> Enum.map(fn [x, y] ->
      case {x, y} do
        {a, "x"} -> score_monster(a)
        {"x", b} -> score_monster(b)
        {a, b} -> score_monster(a) + score_monster(b) + 2
      end
    end)
    |> Enum.sum()
  end

  @impl EverybodyCodes.Day
  def part3(input) do
    input
    |> String.split("", trim: true)
    |> Enum.chunk_every(3)
    |> Enum.map(fn [x, y, z] ->
      case {x, y, z} do
        {a, "x", "x"} -> score_monster(a)
        {"x", b, "x"} -> score_monster(b)
        {"x", "x", c} -> score_monster(c)
        {a, b, "x"} -> score_monster(a) + score_monster(b) + 2
        {a, "x", c} -> score_monster(a) + score_monster(c) + 2
        {"x", b, c} -> score_monster(b) + score_monster(c) + 2
        {a, b, c} -> score_monster(a) + score_monster(b) + score_monster(c) + 6
      end
    end)
    |> Enum.sum()
  end
end
