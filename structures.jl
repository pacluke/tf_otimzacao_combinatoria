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
