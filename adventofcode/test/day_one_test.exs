defmodule DayOneTest do
  use ExUnit.Case
  doctest DayOne

  @example1 """
  1abc2
  pqr3stu8vwx
  a1b2c3d4e5f
  treb7uchet
  """

  @example2 """
  two1nine
  eightwothree
  abcone2threexyz
  xtwone3four
  4nineeightseven2
  zoneight234
  7pqrstsixteen
  """

  test "One Star" do
    assert DayOne.one_star_solver(@example1) == 142
  end

  test "Two Star" do
    assert DayOne.two_star_solver(@example2) == 281
  end
end
