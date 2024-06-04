defmodule MaximumGraphMatchingTest do
  use ExUnit.Case
  doctest Graph.Ex
  doctest Graph.Matching

  test "Graph.Matching.maximum_matching Graph a" do
    g = Graph.Ex.g_a
    assert g|>Graph.Matching.maximum == [
      %Graph.Edge{v1: 1, v2: 3, weight: 1, label: nil},
      %Graph.Edge{v1: 2, v2: 6, weight: 1, label: nil}
    ] || [
      %Graph.Edge{v1: 1, v2: 3, weight: 1, label: nil},
      %Graph.Edge{v1: 2, v2: 5, weight: 1, label: nil}
    ] || [
      %Graph.Edge{v1: 1, v2: 3, weight: 1, label: nil},
      %Graph.Edge{v1: 2, v2: 4, weight: 1, label: nil}
    ]
  end

  test "Graph.Matching.maximum_matching Graph b" do
    g = Graph.Ex.g_b
    assert g|>Graph.Matching.maximum == [
      %Graph.Edge{v1: 1, v2: 2, weight: 1, label: nil},
      %Graph.Edge{v1: 3, v2: 5, weight: 1, label: nil},
      %Graph.Edge{v1: 4, v2: 6, weight: 1, label: nil}
    ]
  end

  test "Graph.Matching.maximum_matching Graph c" do
    g = Graph.Ex.g_c
    assert g|>Graph.Matching.maximum |> length == 2
  end

end
