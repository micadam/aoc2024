defmodule Grid do
  def strings_to_grid(texts) do
    texts
    |> Enum.map(fn text -> String.graphemes(text) end)
    |> Enum.map(&:array.from_list/1)
    |> :array.from_list()
  end

  def is_valid_position(grid, {row, col}) do
    rows = :array.size(grid)
    cols = :array.size(:array.get(0, grid))

    row >= 0 and row < rows and col >= 0 and col < cols
  end

  def num_rows(grid) do
    :array.size(grid)
  end

  def num_cols(grid) do
    :array.size(:array.get(0, grid))
  end

  def get(grid, {row, col}) do
    :array.get(col, :array.get(row, grid))
  end

  def set(grid, {row, col}, value) do
    :array.set(row, :array.set(col, value, :array.get(row, grid)), grid)
  end

  def all_cells(grid) do
    rows = num_rows(grid)
    cols = num_cols(grid)

    for row <- 0..(rows - 1), col <- 0..(cols - 1), do: {row, col}
  end
end
