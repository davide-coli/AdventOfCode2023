defmodule DayTen do
  defp get_symbol(graph, {x, y}) do
    graph |> Enum.at(y) |> Enum.at(x)
  end

  defp right_connected_coords?(coord_a, coord_b, graph) do
    a = get_symbol(graph, coord_a)
    b = get_symbol(graph, coord_b)
    a != ?. and a != ?| and a != ?7 and a != ?J and (b == ?- or b == ?J or b == ?7)
  end

  defp bottom_connected_symbol?(coord_a, coord_b, graph) do
    a = get_symbol(graph, coord_a)
    b = get_symbol(graph, coord_b)
    a != ?. and a != ?- and a != ?L and a != ?J and (b == ?| or b == ?J or b == ?L)
  end

  defp are_coonnected(src, dst, graph) do
    size = length(graph)
    {x_src, y_src} = src

    case dst do
      {x, _} when x < 0 or x >= size -> false
      {_, y} when y < 0 or y >= size -> false
      {x, y} when x == x_src and y == y_src - 1 -> bottom_connected_symbol?(dst, src, graph)
      {x, y} when x == x_src and y == y_src + 1 -> bottom_connected_symbol?(src, dst, graph)
      {x, y} when x == x_src + 1 and y == y_src -> right_connected_coords?(src, dst, graph)
      {x, y} when x == x_src - 1 and y == y_src -> right_connected_coords?(dst, src, graph)
      _ -> false
    end
  end

  defp get_connections(graph, {x, y}) do
    [{x - 1, y}, {x + 1, y}, {x, y - 1}, {x, y + 1}]
    |> Enum.filter(&are_coonnected({x, y}, &1, graph))
  end

  defp deduce_S(graph) do
    y_s = Enum.find_index(graph, &Enum.member?(&1, ?S))
    x_s = Enum.at(graph, y_s) |> Enum.find_index(fn x -> x == ?S end)

    replace_S = fn new_char ->
      Enum.with_index(graph)
      |> Enum.map(fn {line, idx} ->
        if idx != y_s do
          line
        else
          line |> Enum.map(fn char -> if char == ?S, do: new_char, else: char end)
        end
      end)
    end

    correct_char =
      [?|, ?-, ?F, ?J, ?7, ?L]
      |> Enum.find(fn s ->
        replace_S.(s) |> get_connections({x_s, y_s}) |> (fn conns -> length(conns) == 2 end).()
      end)

    {{x_s, y_s}, correct_char, replace_S.(correct_char)}
  end

  defp graph_to_map(graph) do
    n_rows = length(graph)
    n_columns = Enum.at(graph, 0) |> length()

    0..(n_rows - 1)
    |> Enum.flat_map(fn row_idx ->
      0..(n_columns - 1) |> Enum.map(fn col_idx -> {col_idx, row_idx} end)
    end)
    |> Enum.map(fn coord -> {coord, get_connections(graph, coord)} end)
    |> Map.new()
  end

  defp next_step(previous, current, graph_map) do
    Map.get(graph_map, current) |> Enum.filter(fn x -> x !== previous end) |> Enum.at(0)
  end

  defp find_loop(graph_map, start) do
    find_loop(graph_map, start, nil, start, [])
  end

  defp find_loop(_, start, pv, start, path) when is_tuple(pv) do
    path
  end

  defp find_loop(_, _, _, nil, _) do
    :not_loop
  end

  defp find_loop(graph_map, initial_pos, prev_pos, current_pos, path) do
    next_pos = next_step(prev_pos, current_pos, graph_map)
    find_loop(graph_map, initial_pos, current_pos, next_pos, path ++ [current_pos])
  end

  defp row_segment_intersects?({x_row, y_row}, segm_coords) do
    case segm_coords do
      {{x_0, _}, {x_1, _}} when x_0 != x_row + 1 or x_1 != x_row + 1 -> false
      {{_, y_0}, {_, y_1}} when y_0 == y_row and y_1 == y_row + 1 -> true
      {{_, y_0}, {_, y_1}} when y_0 == y_row + 1 and y_1 == y_row -> true
      _ -> false
    end
  end

  defp find_internals(graph, loop) do
    n_columns = Enum.count(graph)
    n_rows = Enum.at(graph, 0) |> Enum.count()
    n_loop = Enum.count(loop)

    loop_segments =
      0..(n_loop - 1)
      |> Enum.map(fn idx ->
        {Enum.at(loop, idx), Enum.at(loop, rem(idx + 1, n_loop))}
      end)

    all_internals =
      0..(n_rows - 1)
      |> Enum.flat_map(fn row_idx ->
        -1..n_columns
        |> Enum.reduce({0, []}, fn col_idx, acc ->
          {n_crosses, internal_points} = acc
          is_crossing = Enum.any?(loop_segments, &row_segment_intersects?({col_idx, row_idx}, &1))

          case {is_crossing, n_crosses} do
            {false, n} when rem(n, 2) == 0 ->
              {n_crosses, internal_points}

            {false, _} ->
              {n_crosses, internal_points ++ [{col_idx + 1, row_idx}]}

            {true, n} when rem(n, 2) == 0 ->
              {n_crosses + 1, internal_points ++ [{col_idx + 1, row_idx}]}

            {true, _} ->
              {n_crosses + 1, internal_points}
          end
        end)
        |> elem(1)
      end)

    all_internals -- loop
  end

  def one_star(text) do
    {coords_s, _, graph} =
      String.split(text, "\n") |> Enum.map(&String.to_charlist/1) |> deduce_S()

    graph_map = graph_to_map(graph)
    loop_length = find_loop(graph_map, coords_s) |> length()
    div(loop_length, 2)
  end

  def two_stars(text) do
    {coords_s, _, graph} =
      String.split(text, "\n") |> Enum.map(&String.to_charlist/1) |> deduce_S()

    graph_map = graph_to_map(graph)
    loop = find_loop(graph_map, coords_s)

    find_internals(graph, loop) |> length()
  end
end

text = File.read!("./inputs/dayten.txt") |> String.trim()

IO.puts("""
One star: #{DayTen.one_star(text)}
Two stars: #{DayTen.two_stars(text)}
""")
