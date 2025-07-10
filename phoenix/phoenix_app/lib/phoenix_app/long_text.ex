defmodule PhoenixApp.LongText do
  def count_words do
    path = Path.join(:code.priv_dir(:phoenix_app), "static/long.txt")

    with {:ok, content} <- File.read(path) do
      words =
        content
        |> String.downcase()
        |> String.split(~r{[^a-zA-Z0-9]+}, trim: true)

      Enum.reduce(words, %{}, fn word, acc ->
        Map.update(acc, word, 1, &(&1 + 1))
      end)
    else
      _ -> %{}
    end
  end
end
