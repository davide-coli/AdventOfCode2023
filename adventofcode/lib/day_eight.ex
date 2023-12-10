defmodule ExtendedEuclideanAlgorithm do
  defp interpolation_step({gcd, x, y}, {0, _, _}) do
    {gcd, x, y}
  end

  defp interpolation_step({r0, x0, y0}, {r1, x1, y1}) do
    q = div(r0, r1)

    interpolation_step(
      {r1, x1, y1},
      {r0 - q * r1, x0 - q * x1, y0 - q * y1}
    )
  end

  def extended_gcd(a, b) when a < b do
    {gcd, x, y} = extended_gcd(b, a)
    {gcd, y, x}
  end

  def extended_gcd(a, b) do
    interpolation_step({a, 1, 0}, {b, 0, 1})
  end

  defp gcd(a, b) do
    extended_gcd(a, b) |> elem(0)
  end

  defp lcm_pair(a, b) do
    div(a * b, gcd(a, b))
  end

  def lcm([]) do
    :error
  end

  def lcm([value]) do
    value
  end

  def lcm([a, b | rest]) do
    lcm([lcm_pair(a, b)] ++ rest)
  end
end

defmodule ChineseRemainderTheorem do
  defp pair_crt({a, m}, {b, n}) do
    {gcd, u, _} = ExtendedEuclideanAlgorithm.extended_gcd(m, n)

    if rem(a - b, gcd) != 0 do
      :error
    else
      lambda = div(a - b, gcd)
      lcm = div(m * n, gcd)
      x = a - m * lambda * u
      Integer.mod(x, lcm)
    end
  end

  def crt([]) do
    :error
  end

  def crt([{r, value}]) do
    Integer.mod(r, value)
  end

  def crt([{r0, value0}, {r1, value1} | rest]) do
    sigma = pair_crt({r0, value0}, {r1, value1})

    case sigma do
      :error ->
        :error

      _ ->
        lcm = ExtendedEuclideanAlgorithm.lcm([value0, value1])
        crt([{sigma, lcm}] ++ rest)
    end
  end
end

defmodule CycleStruct do
  defstruct non_repeating: 0, cycle_size: 0, target: 0
end

defmodule NodeTrack do
  defstruct idx: 0, node: ""
end

defmodule Day8 do
  @regex_instructions ~r/^[RL]+/
  @regex_moves ~r/([A-Z0-9]{3}) = \(([A-Z0-9]{3}), ([A-Z0-9]{3})\)/

  defp parse_instructions(text) do
    Regex.run(@regex_instructions, text)
    |> Enum.at(0)
    |> String.to_charlist()
    |> Enum.map(fn char ->
      case char do
        ?R -> :right
        ?L -> :left
        _ -> :error
      end
    end)
  end

  defp parse_graph(text) do
    Regex.scan(@regex_moves, text)
    |> Enum.map(fn [_, node, left, right] -> {node, %{:left => left, :right => right}} end)
    |> Map.new()
  end

  defp find_n_moves_one_star(instructions, graph) do
    find_n_moves_one_star(instructions, graph, "AAA", 0)
  end

  defp find_n_moves_one_star(_, _, "ZZZ", count) do
    count
  end

  defp find_n_moves_one_star(instructions, graph, start, count) do
    {nmoves, new_position} =
      Enum.reduce_while(
        instructions,
        {0, start},
        fn move, {movecounter, pos} ->
          if pos === "ZZZ" do
            {:halt, {movecounter, pos}}
          else
            {:cont, {movecounter + 1, Map.get(graph, pos) |> Map.get(move)}}
          end
        end
      )

    find_n_moves_one_star(instructions, graph, new_position, count + nmoves)
  end

  def one_star(text) do
    instructions = parse_instructions(text)
    graph = parse_graph(text)

    find_n_moves_one_star(instructions, graph)
  end

  defp get_cycle_struct(graph, instructions, start) do
    n_instructions = Enum.count(instructions)
    maximum_cycle_size = n_instructions * Enum.count(graph) + 1

    cycle_tracking =
      0..maximum_cycle_size
      |> Enum.reduce_while(
        {false, %NodeTrack{idx: 0, node: start}, [], MapSet.new()},
        fn idx, {_, node, path, visited} ->
          if MapSet.member?(visited, node) do
            {:halt, {true, node, path}}
          else
            move = instructions |> Enum.at(rem(idx, n_instructions))
            new_node = Map.get(graph, node.node) |> Map.get(move)
            node_track = %NodeTrack{idx: rem(node.idx + 1, n_instructions), node: new_node}
            {:cont, {false, node_track, path ++ [node], MapSet.put(visited, node)}}
          end
        end
      )

    if elem(cycle_tracking, 0) do
      {_, wedge_node, path} = cycle_tracking

      wedge_node_idx =
        Enum.find_index(path, fn %NodeTrack{idx: idx, node: node} ->
          idx == wedge_node.idx and node == wedge_node.node
        end)

      %CycleStruct{
        non_repeating: wedge_node_idx,
        cycle_size: length(path) - wedge_node_idx,
        target:
          path
          |> Enum.take(wedge_node_idx - length(path))
          |> Enum.map(fn x -> x.node end)
          |> Enum.with_index()
          |> Enum.filter(fn {node, _} -> String.ends_with?(node, "Z") end)
          |> Enum.map(fn {_, idx} -> idx + 1 end)
      }
    else
      :error
    end
  end

  defp cartesian_product([]) do
    [[]]
  end

  defp cartesian_product([array | rest]) do
    for element <- array, rest_product <- cartesian_product(rest), do: [element | rest_product]
  end

  defp compute_cycle_info(cycles) do
    total_cycle_size =
      cycles |> Enum.map(&Map.get(&1, :cycle_size)) |> ExtendedEuclideanAlgorithm.lcm()

    max_non_repeating = cycles |> Enum.map(&Map.get(&1, :non_repeating)) |> Enum.max()

    crts =
      cycles
      |> Enum.map(fn
        %CycleStruct{non_repeating: nr, cycle_size: cs, target: targets} ->
          targets |> Enum.map(fn target -> {rem(nr + target - 1, cs), cs} end)
      end)
      |> cartesian_product()

    {total_cycle_size, max_non_repeating - 1, crts}
  end

  def two_stars(text) do
    graph = parse_graph(text)
    instructions = parse_instructions(text)

    start_points =
      graph
      |> Enum.map(fn {nodename, _} -> nodename end)
      |> Enum.filter(fn nodename -> String.ends_with?(nodename, "A") end)

    {total_cycle_size, cycle_offset, targets} =
      Enum.map(start_points, fn x -> get_cycle_struct(graph, instructions, x) end)
      |> compute_cycle_info()

    targets
    |> Enum.map(&ChineseRemainderTheorem.crt/1)
    |> Enum.filter(fn x -> x != :error end)
    |> Enum.map(fn x ->
      if x <= cycle_offset do
        x + total_cycle_size
      else
        x
      end
    end)
    |> Enum.min(fn -> :error end)
  end
end

text = File.read!("./inputs/dayeight.txt")

one_star = Day8.one_star(text)
two_stars = Day8.two_stars(text)

IO.puts("""
One star: #{one_star}
Two stars: #{two_stars}
""")
