# Function VNS (x, kmax, tmax );
#  1: repeat
#  2:    k ← 1;
#  3:    repeat
#  4:       x' ←Shake(x, k) /* Shaking */;
#  5:       x'' ← FirstImprovement(x' ) /* Local search */;
#  6:       x ←NeighbourhoodChange(x, x'', k) /* Change neighbourhood */;
#  7:    until k = k_max ;
#  8:    t ←CpuTime()
#  9: until t > t_max ;

#############################################################################

# Variable Neighbourhood Descent (VND):
# determine initial candidate solution s
# i := 1
# Repeat:
# | choose a most improving neighbour s0 of s in Ni
# | If g(s0
# ) < g(s): | s := s0
# | i := 1
# | Else:
# | i := i + 1
# Until i > k

############################### - AUXILIARY FUNCTIONS - ##############################################

##############################################################
#
#   edge_weight(x1, y1, x2, y2) -> float
#  
#   given the coordinates of two points, returns
#   the euclidean distance between them.
# 
##############################################################

function edge_weight(node_a, node_b)
  x1 = node_a[1]
  y1 = node_a[2]
  x2 = node_b[1]
  y2 = node_b[2]
  x1_x2 = (x1 - x2)^2
  y1_y2 = (y1 - y2)^2
  return sqrt(x1_x2 + y1_y2)
end

##############################################################
#
#   parse_file(file_name) -> GRAPH
#  
#   given a file, parse_file reads the file and set
#   the graph data structure.
# 
##############################################################

function parse_file(file_name)

  # initializing the data structure
  GRAPH = Dict()

  # getting the file content 
  file = open(file_name)
  file_content = readstring(file)
  close(file)

  # parsing the content
  splited_file = split(file_content, r"COST_LIMIT : |EDGE_WEIGHT_TYPE :|EDGE_WEIGHT_TYPE:|NODE_COORD_SECTION|NODE_SCORE_SECTION|DEPOT_SECTION")

  # getting the maximum cost for the route
  max_cost = split(splited_file[2])
  max_cost_int = parse(Int64, max_cost[1])
  push!(GRAPH, (0 => max_cost_int))

  # getting the nodes coordinates
  raw_graph_coords = split(splited_file[4], "\n")
  for item in raw_graph_coords
    if item != ""
      node_coords = split(item, " ")
      node_to_int = parse(Int64, node_coords[1])
      coord_x_int = parse(Float64, node_coords[2])
      coord_y_int = parse(Float64, node_coords[3])
      push!(GRAPH, (node_to_int => [coord_x_int, coord_y_int]))
    end
  end

  # getting the nodes weights
  raw_graph_weights = split(splited_file[5], "\n")
  for item in raw_graph_weights
    if item != ""
      node_weights = split(item, " ")
      node_to_int = parse(Int64, node_weights[1])
      weight_to_int = parse(Float64, node_weights[2])
      push!(GRAPH[node_to_int], weight_to_int)
    end
  end

  FULL_GRAPH = Dict()

  push!(FULL_GRAPH, (0 => Int64[]))

  for i in 1:length(GRAPH)-1
    if i != 0
      push!(FULL_GRAPH[0], GRAPH[i][3])
    end
  end

  for (key, value) in GRAPH
    if key != 0
      push!(FULL_GRAPH, (key => Float64[]))
      for i in 1:length(GRAPH)-1 
        if key != i
            push!(FULL_GRAPH[key], edge_weight(GRAPH[key], GRAPH[i]))
        else 
            push!(FULL_GRAPH[key], 999999.9999999999)
        end
      end
    end
  end

  push!(FULL_GRAPH, length(FULL_GRAPH) => GRAPH[0])

  return FULL_GRAPH
end


##############################################################
#
#   route_weight(route, graph) -> float
#  
#   given a route, returns the total weight of it.
# 
##############################################################

function route_weight(route, graph)
  total_weight = 0.0
  node_a = 0
  node_b = 0
  for i in 1:length(route)
    if i != length(route)
      node_a = route[i]
      node_b = route[i+1]
    end
    total_weight += graph[node_a][node_b]
    # println(total_weight)
    # println(graph[node_a][node_b])
  end
  return total_weight
end

##############################################################
#
#   route_nodes_weight(route) -> float
#  
#   given a route, returns the total weight of it.
# 
##############################################################

function route_nodes_weight(route, graph)
  # total_weight = 0.0
  # node_a = route[1]
  # node_b = route[2]
  # for i in lenght(route)
  #   total_weight += graph[node_a][node_b]
  #   node_a = node_b
  #   node_b = route[i+1]
  # end
  # return total_weight
end


function initial_solution(graph)

  aux_graph = deepcopy(graph)

  solution = [1]
  println(solution)

  minimum_index = 1
  current_node = 1

  for i in 2:length(graph)-2
    minimum_index = indmin(aux_graph[current_node])
    println(minimum_index)
    if minimum_index in solution
      while minimum_index in solution
          aux_graph[current_node][minimum_index] = 999999.9999999999
          minimum_index = indmin(aux_graph[current_node])
      end
    end
    push!(solution, minimum_index)
    current_node = minimum_index
  end
  push!(solution, 1)
  println(solution)


  println("FIRST METHOD")
  initial_solution_weight = route_weight(solution, graph)
  println(initial_solution_weight)

  ########################################################################

  aux_graph = deepcopy(graph)

  solution = [1]
  println(solution)
  

  println(aux_graph[0])

  for i in 2:length(graph)-2
    current_best = indmax(aux_graph[0])
    push!(solution, indmax(aux_graph[0]))
    aux_graph[0][current_best] = -1
  end

  println(aux_graph[0])
  println(graph[0])

  push!(solution, 1)
  println(solution)

  println("SECOND METHOD")
  initial_solution_weight = route_weight(solution, graph)
  println(initial_solution_weight)


  return solution
end



# function two_opt()
    
# end


############################### - MAIN - #############################################################

function main()

  # arguments from terminal
  file_name = ARGS[1]
  seed = parse(Int64, ARGS[2])
  println("\nFile name: $file_name")
  println("Seed: $seed\n")

  # initializing graph data structure
  GRAPH = parse_file(file_name)

  # printing the graph data structure

  println("MAXIMUM COST OF THE OPTIMAL ROUTE: $(GRAPH[length(GRAPH)-1])\n")
  println("NODES WEIGHT: $(GRAPH[0])\n")

  for j in 0:length(GRAPH)-1
    if (j != 0) && (j != length(GRAPH)-1)
      # println("$key\t =>\t $value")
      for i in 1:length(GRAPH[j])
        println("WEIGHT OF EDGE ($j -> $i): $(GRAPH[j][i])")
      end
    end
  end

  println("\n")

  initial_solution(GRAPH)

  println(GRAPH[0])

  # sol = random_solution(seed, length(GRAPH)-1, GRAPH)
  # println("initial solution: $sol")

  # sol_weight = route_nodes_weight(sol, GRAPH)
  # println("initial solution value: $sol_weight")

end

main()
















