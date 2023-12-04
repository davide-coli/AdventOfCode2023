defmodule RegexResult do
  defstruct value: "", start: 0, size: 0, line_id: 0
end

defmodule DayThree do
  defp add_value_to_regex_result(regex_results, line, line_id) do
    regex_results
    |> Enum.map(fn {start, size} ->
      %RegexResult{
        value: String.slice(line, start..(start + size - 1)),
        start: start,
        size: size,
        line_id: line_id
      }
    end)
  end

  defp get_regex_results(line, line_id, regex) do
    Regex.scan(regex, line, return: :index)
    |> Enum.flat_map(&add_value_to_regex_result(&1, line, line_id))
  end

  defp get_all_symbols_from_text(text, regex) do
    text
    |> String.split("\n")
    |> Enum.with_index()
    |> Enum.flat_map(fn {line, idx} -> get_regex_results(line, idx, regex) end)
  end

  defp number_and_symbol_touch?(number_res, symbol_res) do
    %{start: number_start, size: number_size, line_id: number_line_id} = number_res

    case symbol_res do
      %{line_id: symbol_line_id}
      when symbol_line_id in (number_line_id - 1)..(number_line_id + 1) ->
        symbol_res.start >= number_start - 1 and symbol_res.start <= number_start + number_size

      _ ->
        false
    end
  end

  def one_star(text) do
    numbers = get_all_symbols_from_text(text, ~r/\d+/)
    symbols = get_all_symbols_from_text(text, ~r/[^\d\s.]/)

    numbers
    |> Enum.filter(fn number_res ->
      Enum.any?(symbols, &number_and_symbol_touch?(number_res, &1))
    end)
    |> Enum.map(fn %{value: value} -> value end)
    |> Enum.map(&String.to_integer/1)
    |> Enum.sum()
  end

  def two_star(text) do
    numbers = get_all_symbols_from_text(text, ~r/\d+/)
    symbols = get_all_symbols_from_text(text, ~r/[*]/)

    symbols
    |> Enum.map(fn symbol_res ->
      numbers |> Enum.filter(&number_and_symbol_touch?(&1, symbol_res))
    end)
    |> Enum.filter(fn arr -> length(arr) == 2 end)
    |> Enum.map(fn [a, b] -> String.to_integer(a.value) * String.to_integer(b.value) end)
    |> Enum.sum()
  end
end

one_star =
  File.read!("./inputs/daythree.txt")
  |> DayThree.one_star()

IO.puts("One star result: #{one_star}")

two_star =
  File.read!("./inputs/daythree.txt")
  |> DayThree.two_star()

IO.puts("Two star result: #{two_star}")
