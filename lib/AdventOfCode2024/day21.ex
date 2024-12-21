defmodule AdventOfCode2024.Day21 do
  @behaviour AdventOfCode.Day

  def big_keypad() do
    %{
      {0, 0} => "7",
      {0, 1} => "8",
      {0, 2} => "9",
      {1, 0} => "4",
      {1, 1} => "5",
      {1, 2} => "6",
      {2, 0} => "1",
      {2, 1} => "2",
      {2, 2} => "3",
      {3, 1} => "0",
      {3, 2} => "A"
    }
  end

  def small_keypad() do
    %{
      {0, 1} => :up,
      {0, 2} => "A",
      {1, 0} => :left,
      {1, 1} => :down,
      {1, 2} => :right
    }
  end

  use Memoize

  defmemo get_path(from_key, to_key, big_keypad) do
    keypad = if big_keypad, do: big_keypad(), else: small_keypad()
    keypad_inverse = Enum.into(keypad, %{}, fn {k, v} -> {v, k} end)
    {row, col} = Map.get(keypad_inverse, from_key)
    {nrow, ncol} = Map.get(keypad_inverse, to_key)

    {drow, dcol} = {nrow - row, ncol - col}
    up_moves = if drow < 0, do: List.duplicate(:up, -drow), else: []
    down_moves = if drow > 0, do: List.duplicate(:down, drow), else: []
    left_moves = if dcol < 0, do: List.duplicate(:left, -dcol), else: []
    right_moves = if dcol > 0, do: List.duplicate(:right, dcol), else: []

    dead_zone = if big_keypad, do: {3, 0}, else: {0, 0}

    cond do
      # Only one possible sequence due to straight line
      drow == 0 or dcol == 0 ->
        down_moves ++ right_moves ++ up_moves ++ left_moves ++ ["A"]

      # Only one possible sequence due to dead zone (move rows first)
      {row, col + dcol} == dead_zone ->
        up_moves ++ down_moves ++ left_moves ++ right_moves ++ ["A"]

      # Only one possible sequence due to dead zone (move cols first)
      {row + drow, col} == dead_zone ->
        left_moves ++ right_moves ++ up_moves ++ down_moves ++ ["A"]

      # left is better than up/down is better than right
      # (for some reason, based on some experiments)
      true ->
        left_moves ++ up_moves ++ down_moves ++ right_moves ++ ["A"]
    end
  end

  defmemo(get_path_len(_, _, false, 0), do: 1)

  defmemo get_path_len(from_key, to_key, big_keypad, num_keypads) do
    path = get_path(from_key, to_key, big_keypad)

    new_num_keypads = if big_keypad, do: num_keypads, else: num_keypads - 1

    Enum.chunk_every(["A" | path], 2, 1, :discard)
    |> Enum.map(fn [start_key, end_key] ->
      get_path_len(start_key, end_key, false, new_num_keypads)
    end)
    |> Enum.sum()
  end

  def solve(code, num_keypads) do
    (Enum.chunk_every(["A" | code], 2, 1, :discard)
     |> Enum.map(fn [start_key, end_key] ->
       get_path_len(start_key, end_key, true, num_keypads)
     end)
     |> Enum.sum()) * (Enum.drop(code, -1) |> Enum.join() |> String.to_integer())
  end

  @impl AdventOfCode.Day
  def part1(input) do
    codes = String.split(input, "\n", trim: true) |> Enum.map(&String.split(&1, "", trim: true))

    codes
    |> Enum.map(&solve(&1, 2))
    |> Enum.sum()
  end

  @impl AdventOfCode.Day
  def part2(input) do
    codes = String.split(input, "\n", trim: true) |> Enum.map(&String.split(&1, "", trim: true))

    codes
    |> Enum.map(&solve(&1, 25))
    |> Enum.sum()
  end
end
