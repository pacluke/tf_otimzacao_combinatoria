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

  return GRAPH
end

##############################################################
#
#   edge_weight(x1, y1, x2, y2) -> float
#  
#   given the coordinates of two points, returns
#   the euclidean distance between them.
# 
##############################################################

function edge_weight(x1, y1, x2, y2)
  x1_x2 = (x1 - x2)^2
  y1_y2 = (y1 - y2)^2
  return sqrt(x1_x2 + y1_y2)
end

##############################################################
#
#   route_weight(route, graph) -> float
#  
#   given a route, returns the total weight of it.
# 
##############################################################

function route_weight(route, graph)
  previous_node = graph[route[1]]
  total_weight = 0.0
  for node in route
    current_node = graph[node]
    total_weight += edge_weight(previous_node[1], previous_node[2], current_node[1], current_node[2])
    previous_node = graph[node]
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
  total_weight = 0.0
  for node in route
    total_weight += graph[node][3]
  end
  return total_weight
end


function random_solution(seed, num_of_nodes, graph)
  srand(seed)
  solution = unique(rand(2:num_of_nodes, num_of_nodes-1))
  push!(solution, 1)
  solution = append!([1], solution)
  solution_weight = route_weight(solution, graph)

  println(solution)
  println(solution_weight)
  println(graph[0])

  while graph[0] < solution_weight
    solution = deleteat!(solution, length(solution) - 1)
    solution_weight = route_weight(solution, graph)
    println(solution)
    println(solution_weight)
  end
  
  return solution
end

function two_opt()
    
end


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
  println("MAXIMUM ROUTE COST =>\t $(GRAPH[0])\n")
  for (key, value) in GRAPH
    if key != 0
      println("$key\t =>\t $value")
    end
  end

  sol = random_solution(seed, length(GRAPH)-1, GRAPH)
  println("initial solution: $sol")

  sol_weight = route_nodes_weight(sol, GRAPH)
  println("initial solution value: $sol_weight")

end

main()

















