defmodule Graph.Matching do
  #use Graph
  @moduledoc """
  This module provides some algorithms related to matchings in graphs, most notably an
  implementation of Edmond's blossom algorithm, which computes maximum matchings for graphs.

  VERY EXPERIMENTAL and probably not working in a long run! Made to learn elixir

  Based on paper written by Amy Shoemaker and Sagar Vare
  https://stanford.edu/~rezab/classes/cme323/S16/projects_reports/shoemaker_vare.pdf
  """

  @doc """
  Minimal Maximal Matching 2-Aproximation algorythm

  All it does is return a random maximal matching.
  """
  @spec minimal_maximal_matching(Graph.t) :: [Graph.Edge.t]
  def minimal_maximal_matching(graph), do: maximal(graph)

  @doc """
  Gready algorytm to give a random maximal matching
  """
  @spec maximal(Graph.t) :: [Graph.Edge.t]
  def maximal(graph) do

    Enum.reduce(Graph.edges(graph), Graph.new(type: :undirected), fn e, match ->
      if e.v1 not in Graph.vertices(match) and e.v2 not in Graph.vertices(match) and e.v1 != e.v2 do
        match |> Graph.add_edge(e)
      else
        match
      end
    end)
    |> Graph.edges
  end

  @doc """
  Computes a maximum matching of the given graph using Edmond's blossom algorithm
  """
  @spec maximum(Graph.t, Graph.t) :: [Graph.Edge.t]
  def maximum(graph, matching \\ Graph.new(type: :undirected)) do
    case finding_aug_path(graph, matching) do
    [] -> matching |> Graph.edges
    path ->
      matching = Enum.reduce(0..(length(path) - 3) |> Enum.filter(&(rem(&1, 2) == 0)), matching, fn i, matching ->

        matching
        |> Graph.add_edge(Enum.at(path,i), Enum.at(path,i + 1))
        |> Graph.delete_edge(Enum.at(path,i + 1), Enum.at(path,i + 2))
      end)
      matching |> Graph.add_edge(Enum.at(path, -2), Enum.at(path, -1))
      maximum(graph, matching)
    end
  end

  @spec dist_to_root(Graph.t, Graph.vertex, Graph.vertex) :: integer
  defp dist_to_root(graph, point, root) do
    case Graph.get_shortest_path(graph, point, root) do
      nil -> 0
      path -> length(path)-1
    end
  end


  @doc """
  Loops through exposed vertices, adding pairs of
  unmatched-matched edges to the corresponding tree in order to build alternating paths.
  """
  @spec finding_aug_path(Graph.t, Graph.t, [Graph.vertex]) :: [Graph.vertex]
  def finding_aug_path(graph, matching, blossom_stack \\ []) do
    unmarked_edges = Graph.edges(graph) -- Graph.edges(matching)
    #unmarked_nodes = Graph.vertices(graph)

    exp_vertex = Graph.vertices(graph) -- Graph.vertices(matching)

    # build the singleton forest
    forest = Enum.reduce(exp_vertex, %{}, fn v, forest ->
      tree = Graph.new(type: :undirected) |> Graph.add_vertex(v)

      # link each root to its tree
      Map.put(forest, v, tree)
    end)


    Enum.reduce(forest, {[], forest}, fn {v,_}, {acc, forest} ->
      root_of_v = Enum.find_value(Map.to_list(forest), fn {root, tree} ->
        if Graph.has_vertex?(tree, v) do
          root
        else
          false
        end
      end)

      edges_v = Graph.edges(graph, v)
      Enum.reduce_while(edges_v, {acc, forest}, fn e, {acc, forest} ->
        if e in unmarked_edges do
          w = if e.v1 != v, do: e.v1, else: e.v2
          {w_in_forest, root_of_w} = Enum.find_value(Map.to_list(forest), {false, nil}, fn {root, tree} ->
            if Graph.has_vertex?(tree, w) do
              {true, root}
            else
              false
            end
          end)

          cond do
            !w_in_forest -> # Add to Forest
              forest =  Map.put(forest, root_of_v, Graph.add_edge(forest[root_of_v], v, w))
              edge_w = Graph.edges(matching, w) |> Enum.at(0)
              forest =  Map.put(forest, root_of_v, Graph.add_edge(forest[root_of_v], edge_w.v1, edge_w.v2))
              {:cont, {acc, forest}}

            dist_to_root(forest[root_of_w], w, root_of_w) |> rem(2) == 0 ->
              if root_of_w != root_of_v do # Return Aug Path
                path_in_v = case Graph.get_shortest_path(forest[root_of_v], root_of_v, v) do
                  nil -> [v]
                  path -> path
                end
                path_in_w = case Graph.get_shortest_path(forest[root_of_w], w, root_of_w)  do
                  nil -> [w]
                  path -> path
                end
                {:halt, {path_in_v ++ path_in_w, forest}}
              else # Blossom Recursion
                blossom = Graph.get_shortest_path(forest[root_of_w], v, w)

                {contracted_g, contracted_m} = Enum.reduce(blossom, fn v, {contracted_g, contracted_m} ->
                  if v != w do
                    contracted_g = Graph.Ex.contract_vertex(contracted_g, w, v)
                    contracted_m = if Graph.has_vertex?(contracted_m, v) do
                      [edge_rm|_] = Graph.edges(v) # should be one
                      Graph.delete_vertices(contracted_m, [edge_rm.v1, edge_rm.v2])
                    else
                      contracted_m
                    end
                    {contracted_g, contracted_m}
                  end
                end)

                blossom = blossom ++ [v]

                blossom_stack = blossom_stack ++ [w]
                # recurse
                aug_path = finding_aug_path(contracted_g, contracted_m, blossom_stack)

                [v_b|_] = blossom_stack

                if v_b in aug_path do
                  base = Enum.find_value(blossom, fn node ->
                    if not Graph.Ex.has_edge?(matching, node, blossom[rem(node + 1, length(blossom))]) do
                      node
                    else
                      false
                    end
                  end)
                  lifted_blossom = if Graph.Ex.has_edge?(graph, base, hd(aug_path)) do
                    [base | Enum.drop_while(blossom, &(&1 != base))]
                  else
                    Enum.reduce_while(1..(length(blossom) - 2), [], fn i, acc ->
                      if Graph.Ex.has_edge?(graph, Enum.at(blossom, i), hd(aug_path)) do
                        {:halt, Enum.slice(blossom, i, length(blossom) - i) ++ Enum.slice(blossom, 0, i), forest}
                      else
                        {:cont, {acc, forest}}
                      end
                    end)
                  end
                  {:halt, lifted_blossom ++ tl(aug_path), forest}
                else
                  {:halt, {aug_path, forest}}
                end
              end

            true ->
              {:cont, {acc, forest}}
          end
        else
          {:cont, {acc, forest}}
        end
      end)
    end) |> elem(0)
  end


end
