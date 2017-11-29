include("./structures.jl")

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
        # println(total_weight)
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

  ########################################################################
    while !respects_maximum_weight(inst, solution)
        deleteat!(solution, length(solution)-1)
    end

    # println("\n\nFIRST METHOD")
    # initial_solution_weight = respects_maximum_weight(instance, solution)
    # println("Solution: $solution => situation: $initial_solution_weight")

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


function not_on_the_route(instance, route)
    not_used = []
    for i in 2:length(instance.graph.nodes)
        if !(i in route)
            push!(not_used, i)
        end
    end
    return not_used
end


function shake(instance, route, neighbourhood)
    
    # println(route)
    # neighbour = shuffle(route[2:length(route)-1])
    neighbour = (route[2:length(route)-1])

    # println(neighbour)

    deleteat!(neighbour, rand(1:length(neighbour)))

    # if length(neighbour) > neighbourhood
    #     shaked_part = neighbour[1:neighbourhood]
    #     deleteat!(neighbour, 1:neighbourhood)
    #     # println(neighbour)

    #     where = rand(1:length(neighbour))
    #     # println(where)

    #     shaked_part = append!([neighbour[where]], shaked_part)
    #     # println(shaked_part)

    #     splice!(neighbour, where, shaked_part)
    #     # println(neighbour)
    # end

    neighbour = append!([1], neighbour)
    push!(neighbour, 1)


    if !(respects_maximum_weight(instance, neighbour))
        while !(respects_maximum_weight(instance, neighbour))
            deleteat!(neighbour, rand(2:length(neighbour)-1))
        end
    end

    return neighbour
end

function generate_neighbors(instance, current_state)

    aux_neighbourhood = []
    node_a = 2
    node_b = length(current_state)-1

    if 2 - length(current_state) > 0
        deleteat!(current_state, rand(2:length(current_state)-1))
    end
    not_used = not_on_the_route(instance, current_state)

    for j in 2:floor(length(current_state)/2)-1
        # push!(aux_neighbourhood, two_opt_swap(current_state, node_a, node_b))
        new_current = two_opt_swap(current_state, node_a, node_b)
        for i in 2:length(new_current)-1
            for item in not_used
                route_part1 = new_current[1:i]
                route_part2 = new_current[i+1:length(new_current)]

                new_route = append!(route_part1, [item])
                new_route = append!(new_route, route_part2)
                # println(new_route)
                push!(aux_neighbourhood, new_route)   
            end
        end
        node_a += 1
        node_b -= 1
    end

    # for i in 1:200
    #     new_route = shuffle(2:length(current_state)-1)
    #     new_route = append!([1], new_route)
    #     push!(new_route, 1)
    #     push!(aux_neighbourhood, new_route)
    # end

    neighbourhood = []
    i = 1

    for neighbour in aux_neighbourhood
        aux_neighbour = shuffle(neighbour)
        if respects_maximum_weight(instance, neighbour)
            push!(neighbourhood, neighbour)
            # println("temos $i")
            i += 1
        end

        if respects_maximum_weight(instance, aux_neighbour)
            push!(neighbourhood, aux_neighbour)
            # println("temos $i")
            i += 1            
        end
    end

    # println(length(neighbourhood))
    return neighbourhood
end

function hill_climbing(instance, initial_solution)
    current_state = initial_solution
    while true
        neighborhood = generate_neighbors(instance, current_state)
        best_neighbour = current_state

        for neighbour in neighborhood
            if route_value(instance, neighbour) > route_value(instance, best_neighbour)
                best_neighbour = neighbour
            end
        end

        if route_value(instance, best_neighbour) > route_value(instance, current_state)
            current_state = best_neighbour
        else
            return current_state
        end
    end
end

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


function VNS(instance, initial_solution, max_neighborhoods, max_iterations)
    for i in 1:max_iterations
        k = 1
        while k <= max_neighborhoods
            x1 = shake(instance, initial_solution, k)
            x2 = hill_climbing(instance, x1)
            if (route_value(instance, x2)) > (route_value(instance, x1))
                initial_solution = x2
                k = 1
            else
                k += 1
            end
        end
    end
    return initial_solution
end



# srand(1)

inst = parse_file(ARGS[1])
srand(parse(Int64, ARGS[2]))

ini_sol = initial_solution_one(inst)

println(ini_sol)

final_sol = VNS(inst, ini_sol, 10, 10)

println("ACABOU")

println("SOLUCAO FINAL = $final_sol")

println("VALOR SOLUCAO: $(route_value(inst, final_sol))")
