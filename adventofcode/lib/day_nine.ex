defmodule BinomialCoefficient do
  defp choose(n, k) when is_integer(n) and is_integer(k) and n >= 0 and k >= 0 and n >= k do
    if k == 0, do: 1, else: choose(n, k, 1, 1)
  end

  defp choose(n, k, k, acc), do: div(acc * (n - k + 1), k)
  defp choose(n, k, i, acc), do: choose(n, k, i + 1, div(acc * (n - i + 1), i))

  def get_coefficients(n) do
    get_sign = fn idx -> if rem(idx + n, 2) == 0, do: 1, else: -1 end
    0..n |> Enum.map(fn idx -> choose(n, idx) * get_sign.(idx) end)
  end
end

defmodule DayNine do
  @binomials 0..22 |> Enum.map(&BinomialCoefficient.get_coefficients/1)

  defp scalar_product(a, b) when length(a) == length(b) do
    Enum.zip(a, b) |> Enum.map(fn {x, y} -> x * y end) |> Enum.sum()
  end

  defp convolute_array(arr, n_floor) do
    binomial = Enum.at(@binomials, n_floor)

    0..(length(arr) - n_floor - 1)
    |> Enum.map(fn idx -> scalar_product(binomial, Enum.slice(arr, idx, n_floor + 1)) end)
  end

  defp find_n_floors(arr) do
    find_n_floors(arr, 0)
  end

  defp find_n_floors(arr, count) do
    case convolute_array(arr, count) |> Enum.uniq() do
      [] -> :error
      [value] -> {count, value}
      _ -> find_n_floors(arr, count + 1)
    end
  end

  defp estimate_next_element(arr) do
    {n_floors, alpha} = find_n_floors(arr)
    generators = Enum.take(arr, -n_floors)
    binomials = Enum.at(@binomials, n_floors) |> Enum.reverse() |> tl() |> Enum.reverse()
    alpha - scalar_product(generators, binomials)
  end

  defp parse_integer_list(line) do
    String.split(line) |> Enum.map(&String.to_integer/1)
  end

  def solve(text, one_star) do
    histories =
      String.split(text, "\n")
      |> Enum.map(&parse_integer_list/1)
      |> Enum.filter(fn arr -> Enum.count(arr) > 0 end)

    if one_star do
      histories |> Enum.map(&estimate_next_element/1) |> Enum.sum()
    else
      histories |> Enum.map(&Enum.reverse/1) |> Enum.map(&estimate_next_element/1) |> Enum.sum()
    end
  end
end

text = File.read!("./inputs/daynine.txt")

IO.puts("""
One star: #{DayNine.solve(text, true)}
Two stars: #{DayNine.solve(text, false)}
""")
