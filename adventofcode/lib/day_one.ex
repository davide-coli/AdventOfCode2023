defmodule DayOne do
  @numbers ["zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine"]

  @normal_regex ~r/#{Enum.join(@numbers, "|")}|\d/
  @inverted_regex ~r/#{@numbers |> Enum.map(fn x -> String.reverse(x) end) |> Enum.join("|")}|\d/

  def numeric_string_to_value(str) do
    case Enum.find_index(@numbers, fn x -> x == str || String.reverse(x) == str end) do
      nil -> String.to_integer(str)
      idx -> idx
    end
  end

  def find_value_from_regex(regex, string) do
    case Regex.run(regex, string) do
      [value] -> value
      _ -> "0"
    end
  end

  def string_to_value(str, first_regex, second_regex) do
    digits =
      [
        find_value_from_regex(first_regex, str),
        find_value_from_regex(second_regex, String.reverse(str))
      ]
      |> Enum.map(&numeric_string_to_value/1)

    case digits do
      [nil, _] -> 0
      [_, nil] -> 0
      [a, b] -> 10 * a + b
      _ -> 0
    end
  end

  def string_to_value_test(str) do
    string_to_value(str, @normal_regex, @inverted_regex)
  end

  def one_star_solver(complete_string) do
    complete_string
    |> String.split("\n")
    |> Enum.map(fn x -> string_to_value(x, ~r/\d/, ~r/\d/) end)
    |> Enum.sum()
  end

  def two_star_solver(complete_string) do
    complete_string
    |> String.split("\n")
    |> Enum.map(fn x -> string_to_value(x, @normal_regex, @inverted_regex) end)
    |> Enum.sum()
  end
end

one_star =
  File.read!("./inputs/dayone.txt")
  |> DayOne.one_star_solver()

IO.puts("One star result: #{one_star}")

two_star =
  File.read!("./inputs/dayone.txt")
  |> DayOne.two_star_solver()

IO.puts("Two star result: #{two_star}")
