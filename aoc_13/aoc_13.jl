module aoc_13

using LinearAlgebra

export parse_input, problem13, time_until_next_bus, find_next_sync
export solve_p2

struct problem13
    timestamp::Int
    bus_ids::Vector{Int}
    positions::Vector{Int}
end

function parse_input(filename, keepx=false)
    lines = readlines(filename)
    timestamp = parse(Int,lines[1])
    strings = split(lines[2],",")
#    if keepx
    bus_ids = [parse(Int,replace(s, "x" => "0")) for s in strings]
    positions = findall(bus_ids .!= 0 )
    bus_ids = bus_ids[ positions ]

#    else
#        bus_ids = [parse(Int,s) for s in strings if s != "x"]
#    end
    return problem13(timestamp, bus_ids, positions)
end

time_until_next_bus(p) = p.bus_ids .- mod.(p.timestamp, p.bus_ids)

function get_product(p)
    time_until = time_until_next_bus(p)
    min_index = findmin(time_until)
    return p.bus_ids[ min_index[2] ] * min_index[1]
end

function find_next_sync(bus_ids, positions, start=0)
    i = 0
    t = start
    product = prod(bus_ids[1:end-1])
    while true
        if all( mod(t + positions[end] - positions[1],bus_ids[end]) == 0 )
            println(t)
            break
        end
        t += product
    end
    return t
end

function solve_p2(p::problem13)
    perm = sortperm(p.bus_ids, rev=true)
    p_sorted = problem13( 0 , p.bus_ids[perm], p.positions[perm] )
    prev_sync = 0
    for l = 2:length(perm)
        prev_sync = find_next_sync(p_sorted.bus_ids[1:l], p_sorted.positions[1:l], prev_sync)
    end
    return prev_sync - p_sorted.positions[1] + p.positions[1]
end

end