defmodule Card do
  defstruct id: 0,
            winning: [],
            played: [],
            quantity: 1
end

defmodule DayFour do
  @game_regex ~r/Card\s+(\d+): ([0-9 ]+) \| ([0-9 ]+)/

  defp number_string_to_arr(string) do
    string
    |> String.split()
    |> Enum.map(&String.to_integer/1)
    |> MapSet.new()
  end

  defp game_parser(line) do
    case Regex.run(@game_regex, line) do
      [_, id, winning, played] ->
        %Card{
          id: String.to_integer(id),
          winning: number_string_to_arr(winning),
          played: number_string_to_arr(played)
        }

      _ ->
        nil
    end
  end

  def one_star(text) do
    text
    |> String.split("\n")
    |> Enum.map(&game_parser/1)
    |> Enum.filter(fn x -> !is_nil(x) end)
    |> Enum.map(fn %{winning: w, played: p} -> MapSet.intersection(w, p) |> MapSet.size() end)
    |> Enum.map(fn
      0 -> 0
      x -> 2 ** (x - 1)
    end)
    |> Enum.sum()
  end

  def two_stars(text) do
    text
    |> String.split("\n")
    |> Enum.map(&game_parser/1)
    |> Enum.filter(&(!is_nil(&1)))
    |> Enum.reduce({[], 0}, fn cv, {cumulative_sums, result} ->
      temp =
        cumulative_sums
        |> Enum.filter(fn %{:idx => idx} -> idx > 0 end)
        |> Enum.map(&Map.get(&1, :quantity))
        |> Enum.sum()

      n_cards = temp + 1

      new_sums =
        cumulative_sums
        |> Enum.map(fn
          %{:idx => idx, :quantity => quantity} -> %{:idx => idx - 1, :quantity => quantity}
        end)

      n_winning_cards = MapSet.intersection(cv.winning, cv.played) |> MapSet.size()

      {new_sums ++ [%{:idx => n_winning_cards, :quantity => n_cards}], result + n_cards}
    end)
    |> elem(1)
  end
end

one_star =
  File.read!("./inputs/dayfour.txt")
  |> DayFour.one_star()

IO.puts("One star: #{one_star}")

two_star =
  File.read!("./inputs/dayfour.txt")
  |> DayFour.two_stars()

IO.puts("Two star: #{two_star}")
