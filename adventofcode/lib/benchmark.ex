texts =
  [
    "dayone.txt",
    "daytwo.txt",
    "daythree.txt",
    "dayfour.txt",
    "dayfive.txt",
    "daysix.txt",
    "dayseven.txt",
    "dayeight.txt",
    "daynine.txt",
    "dayten.txt"
  ]
  |> Enum.map(fn fname -> "./inputs/#{fname}" end)
  |> Enum.map(fn file -> File.read!(file) end)

Benchee.run(
  %{
    "day_one" => fn -> DayOne.two_star_solver(Enum.at(texts, 0)) end,
    "day_two" => fn -> DayTwo.two_star_solver(Enum.at(texts, 1)) end,
    "day_three" => fn -> DayThree.two_star(Enum.at(texts, 2)) end,
    "day_four" => fn -> DayFour.two_stars(Enum.at(texts, 3)) end,
    "day_five" => fn -> DayFive.solve(Enum.at(texts, 4), false) end,
    "day_six" => fn -> DaySix.solve(Enum.at(texts, 5), false) end,
    "day_seven" => fn -> DaySeven.two_stars(Enum.at(texts, 6)) end,
    "day_eight" => fn -> DayEight.two_stars(Enum.at(texts, 7)) end,
    "day_nine" => fn -> DayNine.solve(Enum.at(texts, 8), false) end,
    "day_ten" => fn -> DayTen.two_stars(Enum.at(texts, 9)) end
  },
  parallel: 4,
  time: 20,
  warmup: 15
)
