defmodule CardBet do
  defstruct hand: "", bet: 0
end

defmodule DaySeven do
  @card_score ["2", "3", "4", "5", "6", "7", "8", "9", "T", "J", "Q", "K", "A"]
              |> Enum.with_index()
              |> Map.new()

  @card_score_joker ["J", "2", "3", "4", "5", "6", "7", "8", "9", "T", "Q", "K", "A"]
                    |> Enum.with_index()
                    |> Map.new()

  @hand_score [:high, :pair, :double_pair, :three, :full, :four, :five]
              |> Enum.with_index()
              |> Map.new()

  defp card_by_card_compare(hand1, hand2) do
    Enum.zip(String.graphemes(hand1), String.graphemes(hand2))
    |> Enum.find(fn {card1, card2} -> card1 != card2 end)
    |> (fn
          {card1, card2} -> Map.get(@card_score, card1) < Map.get(@card_score, card2)
          _ -> true
        end).()
  end

  defp card_by_card_compare_joker(hand1, hand2) do
    Enum.zip(String.graphemes(hand1), String.graphemes(hand2))
    |> Enum.find(fn {card1, card2} -> card1 != card2 end)
    |> (fn
          {card1, card2} -> Map.get(@card_score_joker, card1) < Map.get(@card_score_joker, card2)
          _ -> true
        end).()
  end

  defp hand_frequency_to_score(hand_frequency) do
    case hand_frequency do
      [5] -> :five
      [4, 1] -> :four
      [3, 2] -> :full
      [3, 1, 1] -> :three
      [2, 2, 1] -> :double_pair
      [2, 1, 1, 1] -> :pair
      [1, 1, 1, 1, 1] -> :high
      _ -> raise "Error!"
    end
  end

  defp get_hand_score(hand) do
    String.graphemes(hand)
    |> Enum.frequencies()
    |> Enum.map(fn {_, freq} -> freq end)
    |> Enum.sort(:desc)
    |> hand_frequency_to_score()
  end

  def get_hand_score_joker(hand) do
    hand_arr = String.graphemes(hand)
    n_jokers = Enum.count(hand_arr, fn x -> x == "J" end)

    hand_score =
      Enum.filter(hand_arr, fn x -> x != "J" end)
      |> Enum.frequencies()
      |> Enum.map(fn {_, freq} -> freq end)
      |> Enum.sort(:desc)
      |> (fn
            [head | rest] -> [head + n_jokers | rest]
            [] -> [5]
          end).()

    hand_frequency_to_score(hand_score)
  end

  defp parse_hand_line(line) do
    case String.split(line) do
      [hand, bet_string] -> %CardBet{hand: hand, bet: String.to_integer(bet_string)}
      _ -> raise "Impossible parsing at line \"#{line}\""
    end
  end

  def compare_hand_score(hand1, hand2, hand_score_fn, compare_fn) do
    hand_score_1 = hand_score_fn.(hand1)
    hand_score_2 = hand_score_fn.(hand2)

    if hand_score_1 == hand_score_2 do
      compare_fn.(hand1, hand2)
    else
      Map.get(@hand_score, hand_score_1) < Map.get(@hand_score, hand_score_2)
    end
  end

  def one_star(text) do
    String.split(text, "\n")
    |> Enum.filter(fn line -> String.length(line) > 0 end)
    |> Enum.map(&parse_hand_line/1)
    |> Enum.sort(fn %CardBet{hand: hand1}, %CardBet{hand: hand2} ->
      compare_hand_score(hand1, hand2, &get_hand_score/1, &card_by_card_compare/2)
    end)
    |> Enum.map(fn x -> x.bet end)
    |> Enum.with_index()
    |> Enum.map(fn {bet, idx} -> bet * (idx + 1) end)
    |> Enum.sum()
  end

  def two_stars(text) do
    String.split(text, "\n")
    |> Enum.filter(fn line -> String.length(line) > 0 end)
    |> Enum.map(&parse_hand_line/1)
    |> Enum.sort(fn %CardBet{hand: hand1}, %CardBet{hand: hand2} ->
      compare_hand_score(hand1, hand2, &get_hand_score_joker/1, &card_by_card_compare_joker/2)
    end)
    |> Enum.map(fn x -> x.bet end)
    |> Enum.with_index()
    |> Enum.map(fn {bet, idx} -> bet * (idx + 1) end)
    |> Enum.sum()
  end
end

text = File.read!("./inputs/dayseven.txt")

IO.puts("""
One star: #{DaySeven.one_star(text)}
Two stars: #{DaySeven.two_stars(text)}
""")
