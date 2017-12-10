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
    return floor(sqrt(x1_x2 + y1_y2))
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

    print("\n\n")
end


function respects_maximum_weight(instance, route)

    total_weight = 0
    maximum_weight = instance.max_route_cost
    edge_weight = instance.graph.edges

    node_a = 0
    node_b = 0

    for i in 1:length(route)-1
        node_a = route[i]
        node_b = route[i+1]
        total_weight += edge_weight[node_a][node_b]
    end

    if total_weight <= maximum_weight
        # println(total_weight)
        return true
    end

    return false
end

function route_maximum_weight(instance, route)

    total_weight = 0
    maximum_weight = instance.max_route_cost
    edge_weight = instance.graph.edges

    node_a = 0
    node_b = 0

    for i in 1:length(route)-1
        node_a = route[i]
        node_b = route[i+1]
        total_weight += edge_weight[node_a][node_b]
    end

    return total_weight
end

function route_value(instance, route)

    nodes = instance.graph.nodes
    total_value = 0

    for i in 1:length(route)
        total_value += nodes[route[i]].weight
    end
    return total_value

end


function edge_cost(instance, node_a, node_b)
    return instance.graph.edges[node_a][node_b]
end


function initial_solution_one(instance)

    # aux_inst = deepcopy(instance.graph.edges)

    # solution = [1]

    # minimum_index = 1
    # current_node = 1

    # for i in 2:length(aux_inst)
    #     minimum_index = indmin(aux_inst[current_node])
    #     # println(minimum_index)
    #     if minimum_index in solution
    #         while minimum_index in solution
    #             aux_inst[current_node][minimum_index] = 999999.9999999999
    #             minimum_index = indmin(aux_inst[current_node])
    #         end
    #     end
    #     push!(solution, minimum_index)
    #     current_node = minimum_index
    # end
    # push!(solution, 1)

    solution = [1]
    append!(solution, shuffle(2:length(instance.graph.nodes)))
    append!(solution, [1])

  ########################################################################
    while !respects_maximum_weight(instance, solution)
        deleteat!(solution, length(solution)-1)
        # solution = [1]
        # append!(solution, shuffle(2:length(instance.graph.nodes)))
        # append!(solution, [1])
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


function insert_at(route, where, node_a)

    new_route = []

    route_part1 = route[1:where]
    route_part2 = route[where+1:length(route)]

    new_route = append!(route_part1, [node_a])
    new_route = append!(new_route, route_part2)

    return new_route

end

function remove_at(route, node_a)

    new_route = []

    for i in route
        if i != node_a
            push!(new_route, i)
        end
    end

    return new_route

end

function shuffle_route(route)

    shuffled = shuffle(route[2:length(route)-1])

    shuffled = append!([1], shuffled)

    shuffled = push!(shuffled, 1)

    return shuffled

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

    neighbour = shuffle_route(deepcopy(route))

    if length(neighbour)-2 > floor(neighbourhood*1)
        for i in 1:floor(neighbourhood*1)
            deleteat!(neighbour, rand(2:length(neighbour)-1))
        end
    # else
        # neighbour = [1, 1]
    end

    while !respects_maximum_weight(instance, neighbour)
        deleteat!(neighbour, rand(2:length(neighbour)-1))
    end

    return neighbour
end

function generate_neighbors(instance, current_state, neighbourhood_num)

    aux_neighbours_swap = []
    aux_neighbours = []
    neighbourhood = []

    current_neighbour = deepcopy(current_state)


    for i in 1:5
        if length(current_state) > 3
            node_a_index = rand(2:length(current_neighbour)-1)
            node_b_index = rand(2:length(current_neighbour)-1)

            if node_a_index > node_b_index
                push!(aux_neighbours_swap, two_opt_swap(current_neighbour, node_b_index, node_a_index))
            elseif node_a_index < node_b_index
                push!(aux_neighbours_swap, two_opt_swap(current_neighbour, node_a_index, node_b_index))
            else
                push!(aux_neighbours_swap, current_neighbour)
            end
        else
            push!(aux_neighbours_swap, current_neighbour)
        end
    end

    # println(aux_neighbours_swap)

    for item in aux_neighbours_swap
        for number in 1:ceil(neighbourhood_num*(length(instance.graph.nodes)*0.25))
            not_used = not_on_the_route(instance, item)
            if length(not_used) > 0
                if length(item) < 2
                    push!(aux_neighbours, insert_at(item, 1, rand(not_used)))
                else
                    push!(aux_neighbours, insert_at(item, rand(1:length(item)-1), rand(not_used)))
                    # println(item)
                end
            end
        end
    end


    for item in aux_neighbours
        if respects_maximum_weight(instance, item)
            push!(neighbourhood, item)
        end
    end

    # println(neighbourhood)


    return neighbourhood
end

function hill_climbing(instance, initial_solution, neighbourhood_num)
    current_state = deepcopy(initial_solution)
    while true
        neighborhood = generate_neighbors(instance, current_state, neighbourhood_num)
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

function VND(instance, initial_solution, max_neighborhoods)
    best_solution = deepcopy(initial_solution)
    k = 1
    while k <= max_neighborhoods
        best_neighbour = hill_climbing(instance, best_solution, k)
        if (route_value(instance, best_neighbour)) > (route_value(instance, best_solution))
            best_solution = best_neighbour
            # println("solucao ate o momento VND: $(route_value(instance, best_solution))")
            k = 1
        else
            k += 1
        end 
    end
    # println("solucao ate o momento VND: $(route_value(instance, best_solution))")
    return best_solution
end


function VNS(instance, initial_solution, max_neighborhoods, max_iterations)
    tic()
    for i in 1:max_iterations
        k = 1
        while k <= max_neighborhoods
            x1 = shake(instance, initial_solution, k)
            x2 = VND(instance, x1, k)
            # x2 = hill_climbing(instance, x1, k)
            if (route_value(instance, x2)) > (route_value(instance, initial_solution))
                initial_solution = x2
                k = 1
                println("SLUCAO ATUAL DO VNS NA ITERACAO $i NA VIZINHANCA $k: $(route_value(instance, initial_solution))")
            else
                k += 1
            end
        end
    end
    toc()
    return initial_solution
end



# for i in 1:10
#     tic()
#     inst = parse_file(ARGS[1])
#     srand(parse(Int64, ARGS[2]))
#     toc()
# end


# inst = parse_file(ARGS[1])
# srand(parse(Int64, ARGS[2]))

# ini_sol = initial_solution_one(inst)

# println(ini_sol)
# println(route_value(inst, ini_sol))

# final_sol = VNS(inst, ini_sol, length(inst.graph.nodes), length(inst.graph.nodes))

# println("ACABOU")

# println("SOLUCAO FINAL = $final_sol")

# println("VALOR SOLUCAO: $(route_value(inst, final_sol))")


function main()

    file_names = ["instances/a8.oplib", "instances/a16.oplib", "instances/ber25.oplib", "instances/eil51.oplib", "instances/eil76.oplib", "instances/rat99.oplib", "instances/lin105.oplib", "instances/bier127.oplib", "instances/pr152.oplib", "instances/kroA200.oplib"]
    bks = [190, 245, 609, 1399, 2467, 2908, 2986, 2365, 3905, 6123]
    bks_index = 1
    for name in file_names
        parsed_instance = parse_file(name)
        results = []
        m_results = 0
        gap = 0
        for i in 1:20
            println("\n\n")
            srand(i)
            ini_sol = initial_solution_one(parsed_instance)
            println("#$i: Instance: $name")
            println("SOLUCAO INICIAL = $ini_sol")
            println("VALOR SOLUCAO: $(route_value(parsed_instance, ini_sol))")
            # print("Time: ") # floor(length(parsed_instance.graph.nodes)*0.5)
            final_sol = VNS(parsed_instance, ini_sol, 8, 4)
            println("SOLUCAO FINAL = $final_sol")
            println("VALOR SOLUCAO: $(route_value(parsed_instance, final_sol))")
            push!(results, route_value(parsed_instance, final_sol))
        end
        println("\n")
        m_results = floor(sum(results)/20)
        gap = 100*((bks[bks_index] - m_results)/bks[bks_index])
        println("MEDIA DE 20 ITERACOES DA INSTANCIA $name: $m_results")
        println("GAP: $gap%")
        println("\n")
        bks_index += 1
    end
end

main()












