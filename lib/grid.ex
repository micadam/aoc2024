defmodule Grid do
  def strings_to_grid(texts) do
    texts
    |> Enum.map(fn text -> String.graphemes(text) end)
    |> Enum.map(&:array.from_list/1)
    |> :array.from_list()
  end

  def strings_to_integer_grid(texts) do
    texts
    |> Enum.map(fn row ->
      row
      |> String.graphemes()
      |> Enum.map(&String.to_integer/1)
      |> :array.from_list()
    end)
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

  def get_neighbours(grid, {row, col}) do
    rows = num_rows(grid)
    cols = num_cols(grid)

    [{0, 1}, {1, 0}, {0, -1}, {-1, 0}]
    |> Enum.map(fn {drow, dcol} -> {row + drow, col + dcol} end)
    |> Enum.filter(fn {nrow, ncol} ->
      nrow >= 0 and nrow < rows and ncol >= 0 and ncol < cols
    end)
  end
end
