defmodule MaximumGraphMatchingTest do
  use ExUnit.Case
  doctest Graph.Ex
  doctest Graph.Matching

  test "Graph.Matching.maximum_matching" do
    g = Graph.Ex.test_graph
    assert g|>Graph.Matching.maximum == [
      %Graph.Edge{v1: 1, v2: 2, weight: 1, label: nil},
      %Graph.Edge{v1: 3, v2: 5, weight: 1, label: nil},
      %Graph.Edge{v1: 4, v2: 6, weight: 1, label: nil}
    ]
  end

end
