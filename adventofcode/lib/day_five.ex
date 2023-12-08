defmodule PositionRange do
  defstruct start: 0, size: 0
end

defmodule ResourceRange do
  defstruct source: 0, dest: 0, size: 0
end

defmodule TextParse do
  defstruct seeds: [], resources: []
end

defmodule DayFive do
  @seed_regex ~r/seeds:\s*(\d+(\s+\d+)*)/
  @resource_regex ~r/map:\s*((\d+\s+\d+\s+\d+\s*)+)/

  defp get_seed_ranges([]) do
    []
  end

  defp get_seed_ranges([_]) do
    []
  end

  defp get_seed_ranges([a, b | rest]) do
    [%PositionRange{start: a, size: b}] ++ get_seed_ranges(rest)
  end

  defp parse_resource_line(line) do
    case String.split(line) |> Enum.map(&String.to_integer/1) do
      [a, b, c] -> %ResourceRange{dest: a, source: b, size: c}
      _ -> raise "Three integers expected"
    end
  end

  defp parse_seeds(text, one_star) do
    input_list = Regex.run(@seed_regex, text)

    seeds =
      input_list |> Enum.at(1) |> String.split() |> Enum.map(&String.to_integer/1)

    if one_star do
      seeds |> Enum.map(fn x -> %PositionRange{start: x, size: 1} end)
    else
      get_seed_ranges(seeds)
    end
  end

  defp parse_resources(text) do
    Regex.scan(@resource_regex, text)
    |> Enum.map(&Enum.at(&1, 1))
    |> Enum.map(fn block ->
      block
      |> String.split("\n")
      |> Enum.filter(&(String.length(&1) > 0))
      |> Enum.map(&parse_resource_line/1)
    end)
  end

  defp safe_min([], _) do
    nil
  end

  defp safe_min(arr, fun) do
    Enum.min_by(arr, fun)
  end

  def map_source_range_to_dest(source_range, mappings) do
    map_source_range_to_dest(source_range, mappings, [])
  end

  defp map_source_range_to_dest(%PositionRange{size: size}, _, acc) when size <= 0 do
    acc
  end

  defp map_source_range_to_dest(%PositionRange{start: start, size: size}, mappings, acc) do
    start_mapping =
      mappings
      |> Enum.find(fn resource ->
        start >= resource.source and start < resource.source + resource.size
      end)

    if not is_nil(start_mapping) do
      new_start = start_mapping.dest + start - start_mapping.source
      new_size = min(start_mapping.source + start_mapping.size - start, size)

      map_source_range_to_dest(
        %PositionRange{start: start_mapping.source + start_mapping.size, size: size - new_size},
        mappings,
        [%PositionRange{start: new_start, size: new_size}] ++ acc
      )
    else
      end_mapping =
        mappings
        |> Enum.filter(fn resource ->
          resource.source < start + size and resource.source > start
        end)
        |> safe_min(fn resource -> resource.source end)

      case end_mapping do
        nil ->
          map_source_range_to_dest(
            %PositionRange{},
            mappings,
            [%PositionRange{start: start, size: size}] ++ acc
          )

        _ ->
          map_source_range_to_dest(
            %PositionRange{start: end_mapping.source, size: start + size - end_mapping.source},
            mappings,
            [%PositionRange{start: start, size: end_mapping.source - start}] ++ acc
          )
      end
    end
  end

  def parse_text(text, one_star) do
    %TextParse{
      seeds: parse_seeds(text, one_star),
      resources: parse_resources(text)
    }
  end

  def solve(text, one_star) do
    %{seeds: seeds, resources: resources} = parse_text(text, one_star)

    resources
    |> Enum.reduce(seeds, fn cv, acc ->
      acc |> Enum.flat_map(&map_source_range_to_dest(&1, cv))
    end)
    |> Enum.map(fn x -> x.start end)
    |> Enum.min()
  end
end

text = File.read!("./inputs/dayfive.txt")

IO.puts("""
One star: #{DayFive.solve(text, true)}
Two stars: #{DayFive.solve(text, false)}
""")
