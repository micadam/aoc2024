defmodule EverybodyCodes2024.Day02 do
  @behaviour EverybodyCodes.Day

  @impl EverybodyCodes.Day
  def part1(input) do
    [possible_words, text] = input |> String.split("\n", trim: true)

    possible_words =
      possible_words
      |> String.slice(6..-1//1)
      |> String.split(",", trim: true)

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
    [possible_words | texts] = input |> String.split("\n", trim: true)

    possible_words =
      possible_words
      |> String.slice(6..-1//1)
      |> String.split(",", trim: true)

    possible_words = Enum.concat(possible_words, Enum.map(possible_words, fn possible_word -> [String.reverse(possible_word)] end) |> List.flatten())

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
    end) |> Enum.sum()
  end

  @impl EverybodyCodes.Day
  def part3(_input) do
    "Not implemented"
  end
end
