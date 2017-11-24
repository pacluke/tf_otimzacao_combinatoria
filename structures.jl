
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

    for item in nodes
        println("Node: $(item.value)\n\tInfo: (x: $(item.coordinate.x), y: $(item.coordinate.x)), Weight: $(item.weight)")
    end

    for node_a in nodes
        line_matrix = []
        for node_b in nodes
            push!(line_matrix, edge_weight(node_a, node_b))
        end
        push!(adjacency_matrix, line_matrix)
    end

    line = 0
    for i in 0:length(adjacency_matrix)
        if i == 0
            for k in 1:length(adjacency_matrix)
                print("\t$k")
            end    
        else
            for j in 0:length(adjacency_matrix)
                if j == 0
                    line += 1
                    print(line)
                else
                    print("\t$(ceil(adjacency_matrix[i][j]))")
                end
            end
        end
        print("\n")
    end

    full_graph = Graph(adjacency_matrix, nodes)
    full_instance = Instance(max_cost_int, full_graph)

    return full_instance
end



parse_file(ARGS[1])








