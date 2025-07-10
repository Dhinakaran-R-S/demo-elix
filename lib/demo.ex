defmodule LongText do
  require Logger
  def long do
  IO.puts("Reading the file...")
  Logger.info("Started to read the file")
  path = "lib/long.txt"
  case File.read(path) do
  {:ok, content} ->
  words =
  content
  |> String.downcase()
  |> String.split(~r{[^a-zA-Z0-9]+}, trim: true)
  word_map = Enum.reduce(words, %{}, fn word, acc ->
  Map.update(acc, word, 1, &(&1 + 1))
  end)
  word_map |> Map.keys() |> Enum.sort() |> Enum.each(fn word ->
  IO.puts("#{word} => #{Map.get(word_map,word)}")
  end)
  {:error, reason} ->
  IO.puts("Error reading file: #{reason}")
  end
  end
  end
