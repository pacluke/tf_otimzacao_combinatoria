
# DATA STRUCTUTE
struct Point
    x :: Number
    y :: Number
end

struct Node
    value :: Number
    weight :: Number
    coordinate :: Point
end

struct Graph
    edges :: Array{Array{Number}}
    nodes :: Array{Node}
end

struct Instance
    max_route_cost :: Number
    graph :: Graph
end

##############################################################
#
#   edge_weight(node_a, node_b) -> float
#  
#   given two nodes, returns
#   the euclidean distance between them.
# 
##############################################################

function edge_weight(node_a, node_b)
    x1 = node_a.coordinate.x
    y1 = node_a.coordinate.y
    x2 = node_b.coordinate.x
    y2 = node_b.coordinate.y
    x1_x2 = (x1 - x2)^2
    y1_y2 = (y1 - y2)^2
    return sqrt(x1_x2 + y1_y2)
end

##############################################################
#
#   parse_file(file_name) -> Instance
#  
#   given a file, parse_file reads the file and set
#   the instance data structure.
# 
##############################################################

function parse_file(file_name)

    max_cost_int = 0
    nodes = []
    weights = []
    adjacency_matrix = []


    # getting the file content 
    file = open(file_name)
    file_content = readstring(file)
    close(file)

    # parsing the content
    splited_file = split(file_content, r"COST_LIMIT : |EDGE_WEIGHT_TYPE :|EDGE_WEIGHT_TYPE:|NODE_COORD_SECTION|NODE_SCORE_SECTION|DEPOT_SECTION")

    # getting the maximum cost for the route
    max_cost = split(splited_file[2])
    max_cost_int = parse(Int64, max_cost[1])

    # getting the nodes weights
    raw_graph_weights = split(splited_file[5], "\n")
    for item in raw_graph_weights
        if item != ""
            node_weights = split(item, " ")
            node_to_int = parse(Int64, node_weights[1])
            weight_to_int = parse(Float64, node_weights[2])
            push!(weights, weight_to_int)
        end
    end

    # getting the nodes coordinates
    raw_graph_coords = split(splited_file[4], "\n")
    node_counter = 0
    for item in raw_graph_coords
        if item != ""
            node_counter += 1
            node_coords = split(item, " ")
            node_to_int = parse(Int64, node_coords[1])
            coord_x_int = parse(Float64, node_coords[2])
            coord_y_int = parse(Float64, node_coords[3])
            push!(nodes, Node(node_to_int, weights[node_counter], Point(coord_x_int, coord_y_int)))
        end
    end

    for node_a in nodes
        line_matrix = []
        for node_b in nodes
            push!(line_matrix, edge_weight(node_a, node_b))
        end
        push!(adjacency_matrix, line_matrix)
    end

    full_graph = Graph(adjacency_matrix, nodes)
    full_instance = Instance(max_cost_int, full_graph)

    return full_instance
end


function print_instance(instance)

    print("\n\n")

    for item in instance.graph.nodes
        println("Node: $(item.value) => Info: (x: $(item.coordinate.x), y: $(item.coordinate.x)), Weight: $(item.weight)\n")
    end

    line = 0
    for i in 0:length(instance.graph.edges)
        if i == 0
            for k in 1:length(instance.graph.edges)
                print("\t$k")
            end    
        else
            for j in 0:length(instance.graph.edges)
                if j == 0
                    line += 1
                    print(line)
                else
                    print("\t$(ceil(instance.graph.edges[i][j]))")
                end
            end
        end
        print("\n")
    end

    # print("\n")
    # print("\n")

    # for i in -8:-5
    #     println(abs(i))
    # end

    # print("\n")
    # print("\n")

    print("\n\n")
end


function respects_maximum_weight(instance, route)

    total_weight = 0
    maximum_weight = instance.max_route_cost
    edge_weight = instance.graph.edges

    node_a = 0
    node_b = 0

    for i in 1:length(route)
        if i != length(route)
            node_a = route[i]
            node_b = route[i+1]
        end
        total_weight += edge_weight[node_a][node_b]
    end

    if total_weight <= maximum_weight
        println(total_weight)
        return true
    end

    return false
end

function route_value(instance, route)

    nodes = deepcopy(instance.graph.nodes)
    total_value = 0

    for i in 1:length(route)
        total_value += nodes[route[i]].weight
    end
    return total_value

end


function initial_solution_one(instance)

    aux_inst = deepcopy(instance.graph.edges)

    solution = [1]

    minimum_index = 1
    current_node = 1

    for i in 2:length(aux_inst)
        minimum_index = indmin(aux_inst[current_node])
        # println(minimum_index)
        if minimum_index in solution
            while minimum_index in solution
                aux_inst[current_node][minimum_index] = 999999.9999999999
                minimum_index = indmin(aux_inst[current_node])
            end
        end
        push!(solution, minimum_index)
        current_node = minimum_index
    end
    push!(solution, 1)

    println("\n\nFIRST METHOD")
    initial_solution_weight = respects_maximum_weight(instance, solution)
    println("Solution: $solution => situation: $initial_solution_weight")

  ########################################################################

  return solution
end

function initial_solution_two(instance)

    aux_graph = deepcopy(instance.graph.nodes)

    solution = [1]
    weights = []

    # println(solution)

    for i in 1:length(aux_graph)
        push!(weights, aux_graph[i].weight)
    end

    for i in 2:length(weights)
        current_best = indmax(weights)
        push!(solution, indmax(weights))
        weights[current_best] = -1
    end

    push!(solution, 1)

    println("\n\nSECOND METHOD")
    initial_solution_weight = respects_maximum_weight(instance, solution)
    println("Solution: $solution => situation: $initial_solution_weight")

    return solution
end


function two_opt_swap(route, node_a, node_b)
    new_route = []
    for i in 1:node_a-1
        push!(new_route, route[i])
    end
    for i in -node_b:-node_a 
        push!(new_route, route[abs(i)])
    end
    for i in node_b+1:length(route)
        push!(new_route, route[i])
    end
    return new_route
end



# function shake(instance, route)
#     new_route = []
#     return new_route
# end

# function insert_node(instance, route)
#     new_route = []
#     return new_route
# end

# function remove_node(instance, route)
#     new_route = []
#     return new_route    
# end

# function random_neighbour(instance, route, neighborhood)

#     graph = deepcopy(instance.graph)
#     neighbour = []

#     return neighbour

# end

# function local_search(solution)
# end

# function shake()
# end

# function VND(instance, initial_solution, max_neighborhoods)

#     best_solution = initial_solution
#     k = 1

#     while k <= max_neighborhoods
#         best_neighbour = local_search(best_solution)

#         if (route_value(instance, best_neighbour)) < (route_value(instance, best_solution))
#             best_solution = best_neighbour
#             k = 1
#         else
#             k += 1
#         end 
#     end
#     return best_solution
# end


# function VNS(instance, initial_solution, max_neighborhoods, max_iterations)

#     for i in 1:max_iterations
#         k = 1
#         while k <= max_neighborhoods
#             x1 = random_neighbour()
#             x2 = VND()
#             if (route_value(instance, x2)) < (route_value(instance, x1))
#                 initial_solution = x2
#                 k = 1
#             else
#                 k += 1
#             end
#         end
#     end
# end







srand(1)

inst = parse_file(ARGS[1])

# print_instance(inst)

# while !respects_maximum_weight(inst, route)
#     deleteat!(route, length(route)-1)
# end



route_1 = reverse(initial_solution_one(inst))
while !respects_maximum_weight(inst, route_1)
    deleteat!(route_1, length(route_1)-1)
end

route_2 = reverse(initial_solution_two(inst))
while !respects_maximum_weight(inst, route_2)
    deleteat!(route_2, length(route_2)-1)
end

println("\n\n")
println("Route 01: $(length(route_1)) => situation: $(respects_maximum_weight(inst, route_1)) and value: $(route_value(inst, route_1))")
println("\n\n")
println("Route 02: $(length(route_2)) => situation: $(respects_maximum_weight(inst, route_2)) and value: $(route_value(inst, route_2))")
println("\n\n")


