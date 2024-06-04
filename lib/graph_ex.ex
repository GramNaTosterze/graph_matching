defmodule Graph.Ex do
  @moduledoc """
  This module provides some extention functions for libgraph module.
  """

  @doc """
  Returns true if there is edge between two vertices in the graph. Otherwise false.

  ## Example
    iex> g = Graph.new |> Graph.add_vertices([:a,:b,:c,:d,:e]) |> Graph.add_edges([{:a,:b}, {:a,:c}, {:b,:d}, {:c,:e}, {:d,:e}])
    iex> g |> Graph.Ex.has_edge?(:a, :c)
    true

  """
  @spec has_edge?(Graph.t, Graph.vertex, Graph.vertex) :: boolean
  def has_edge?(graph, v1, v2), do: Graph.edges(graph, v1,v2) |> Enum.any?

  @doc """
  Performs Contraction of v1 and v2, deleting all v2 edges and moving them to v1.

  ## Example
    iex> g = Graph.new |> Graph.add_vertices([:a,:b,:c,:d,:e]) |> Graph.add_edges([{:a,:b}, {:a,:c}, {:b,:d}, {:c,:e}, {:d,:e}])
    iex> g |> Graph.Ex.contract_vertex(:d, :e)
  """
  @spec contract_vertex(Graph.t, Graph.vertex, Graph.vertex) :: Graph.t
  def contract_vertex(graph, v1, v2) do
    v2_edges = Graph.edges(graph, v2) -- Graph.edges(graph,v1,v2)
    new_edges = for edge <- v2_edges do
      if edge.v1 == v2 do
        %Graph.Edge{edge|v1: v1}
      else
        %Graph.Edge{edge|v2: v1}
      end
    end

    graph
    |> Graph.delete_vertex(v2)
    |> Graph.add_edges(new_edges)

  end


  # for quick testing
  def test_graph, do: g_b()

  def g_a, do: Graph.new(type: :undirected) |> Graph.add_vertices([1,2,3,4,5,6]) |> Graph.add_edges([{1,2}, {1,3}, {2,3}, {2,4}, {2,5}, {2,6}])
  def g_b, do: Graph.new(type: :undirected) |> Graph.add_vertices([1,2,3,4,5,6]) |> Graph.add_edges([{1,2}, {1,3}, {2,3}, {2,4}, {3,5}, {4,5}, {4,6}])
  def g_c, do: Graph.new(type: :undirected) |> Graph.add_vertices([1,2,3,4,5]) |> Graph.add_edges([{1,2}, {1,3}, {2,3}, {2,4}, {3,5}, {4,5}])

end
