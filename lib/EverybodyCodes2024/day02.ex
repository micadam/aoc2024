defmodule EverybodyCodes2024.Day02 do
  @behaviour EverybodyCodes.Day

  def get_inputs(input) do
    [possible_words | text] = input |> String.split("\n", trim: true)

    possible_words =
      possible_words
      |> String.slice(6..-1//1)
      |> String.split(",", trim: true)

    {possible_words, text}
  end

  @impl EverybodyCodes.Day
  def part1(input) do
    {possible_words, [text]} = get_inputs(input)

    # Iterate over possible starting positions in text
    Enum.map(0..String.length(text), fn start_pos ->
      possible_words
      |> Enum.map(fn word ->
        String.slice(text, start_pos..(start_pos + String.length(word) - 1)//1) == word
      end)
      |> Enum.count(& &1)
    end)
    |> Enum.sum()
  end

  @impl EverybodyCodes.Day
  def part2(input) do
    {possible_words, texts} = get_inputs(input)

    possible_words =
      Enum.concat(
        possible_words,
        Enum.map(possible_words, fn possible_word -> [String.reverse(possible_word)] end)
        |> List.flatten()
      )

    Enum.map(texts, fn text ->
      # Iterate over possible starting positions in text
      Enum.map(0..String.length(text), fn start_pos ->
        possible_words
        |> Enum.filter(fn word ->
          String.slice(text, start_pos..(start_pos + String.length(word) - 1)//1) == word
        end)
        |> Enum.map(fn word -> start_pos..(start_pos + String.length(word) - 1)//1 end)
        |> Enum.map(fn range -> Enum.to_list(range) end)
      end)
      |> List.flatten()
      |> Enum.uniq()
      |> Enum.count()
    end)
    |> Enum.sum()
  end

  def get_matching_tiles(grid, word, {row, col}, {drow, dcol}) do
    rows = :array.size(grid)
    cols = :array.size(:array.get(0, grid))

    grid_cells =
      Enum.map(0..(String.length(word) - 1), fn i ->
        {
          row + i * drow,
          rem(col + i * dcol + cols, cols)
        }
      end)

    valid =
      Enum.all?(grid_cells, fn {row, _} ->
        row >= 0 and row < rows
      end)

    if not valid do
      []
    else
      grid_text =
        grid_cells
        |> Enum.map(fn {row, col} -> :array.get(col, :array.get(row, grid)) end)
        |> Enum.join()

      if grid_text == word do
        grid_cells
      else
        []
      end
    end
  end

  @impl EverybodyCodes.Day
  def part3(input) do
    {possible_words, texts} = get_inputs(input)

    text_grid = Grid.strings_to_grid(texts)

    for row <- 0..(:array.size(text_grid) - 1),
        col <- 0..(:array.size(:array.get(0, text_grid)) - 1),
        direction <- [{1, 0}, {0, 1}, {-1, 0}, {0, -1}],
        word <- possible_words do
      get_matching_tiles(text_grid, word, {row, col}, direction)
    end
    |> List.flatten()
    |> Enum.uniq()
    |> Enum.count()
  end
end
