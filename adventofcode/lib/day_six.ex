defmodule RaceInfo do
  defstruct time: 0, space: 0
end

defmodule DaySix do
  defp string_to_integer_list(string, one_star) do
    numbers = string |> String.split()

    if one_star do
      numbers |> Enum.map(&String.to_integer/1)
    else
      numbers |> Enum.join() |> String.to_integer() |> (fn x -> [x] end).()
    end
  end

  defp get_limits(%RaceInfo{time: time, space: space}) do
    delta = :math.sqrt(time ** 2 - 4 * space)

    range =
      {:math.ceil((time - delta) / 2) |> trunc(), :math.floor((time + delta) / 2) |> trunc()}

    case range do
      {a, b} when a * (time - a) == space and b * (time - b) == space -> b - a - 1
      {a, b} when a * (time - a) == space or b * (time - b) == space -> b - a
      {a, b} -> b - a + 1
    end
  end

  defp parse_text(text, one_star) do
    times =
      Regex.run(~r/Time:\s*(\d+(\s*\d+)+)/, text)
      |> Enum.at(1)
      |> string_to_integer_list(one_star)

    distances =
      Regex.run(~r/Distance:\s*(\d+(\s*\d+)+)/, text)
      |> Enum.at(1)
      |> string_to_integer_list(one_star)

    if length(times) != length(distances) do
      raise "Error different number of times and distances"
    end

    Enum.zip(times, distances) |> Enum.map(fn {t, x} -> %RaceInfo{time: t, space: x} end)
  end

  def solve(text, one_star) do
    races = parse_text(text, one_star)
    races |> Enum.map(&get_limits/1) |> Enum.reduce(1, fn cv, acc -> cv * acc end)
  end
end

one_star = File.read!("./inputs/daysix.txt") |> DaySix.solve(true)
two_stars = File.read!("./inputs/daysix.txt") |> DaySix.solve(false)

IO.puts("""
One star: #{one_star}
Two stars: #{two_stars}
""")
