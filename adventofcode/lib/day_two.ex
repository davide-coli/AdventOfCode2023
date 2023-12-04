defmodule DayTwo do
  @max_blue 14
  @max_red 12
  @max_green 13

  def extract_id(line) do
    {id, _} =
      line
      |> String.split()
      |> Enum.at(1)
      |> Integer.parse()

    id
  end

  def get_game_quantity(string) do
    string
    |> String.split(",")
    |> Enum.map(&String.trim/1)
    |> Enum.reduce({0, 0, 0}, fn cv, accumulator ->
      {blue, red, green} = accumulator

      case Integer.parse(cv) do
        {value, " blue"} -> {value, red, green}
        {value, " red"} -> {blue, value, green}
        {value, " green"} -> {blue, red, value}
        _ -> {blue, red, green}
      end
    end)
  end

  def get_games(line) do
    case String.split(line, ":") do
      [_, rest] -> String.split(rest, ";")
      _ -> []
    end
    |> Enum.map(&get_game_quantity/1)
  end

  def is_existent_game(line) do
    line
    |> get_games()
    |> Enum.all?(fn {blue, red, green} ->
      blue <= @max_blue and red <= @max_red and green <= @max_green
    end)
  end

  def get_power_game(line) do
    {b, g, r} =
      line
      |> get_games()
      |> Enum.reduce({0, 0, 0}, fn cv, acc ->
        {oldb, oldr, oldg} = acc
        {newb, newr, newg} = cv
        {max(oldb, newb), max(oldr, newr), max(oldg, newg)}
      end)

    b * g * r
  end

  def one_star_solver(string) do
    string
    |> String.split("\n")
    |> Enum.filter(fn line -> String.length(String.trim(line)) > 0 end)
    |> Enum.map(fn line ->
      if is_existent_game(line) do
        extract_id(line)
      else
        0
      end
    end)
    |> Enum.sum()
  end

  def two_star_solver(string) do
    string
    |> String.split("\n")
    |> Enum.filter(fn line -> String.length(String.trim(line)) > 0 end)
    |> Enum.map(&get_power_game/1)
    |> Enum.sum()
  end
end

one_star =
  File.read!("./inputs/daytwo.txt")
  |> DayTwo.one_star_solver()

IO.puts("One star solution: #{one_star}")

two_star =
  File.read!("./inputs/daytwo.txt")
  |> DayTwo.two_star_solver()

IO.puts("Two star solution: #{two_star}")
