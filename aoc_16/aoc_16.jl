module aoc_16

using Test

export read_input, test_part1, solve_part1

const letters_r = r"([a-z\s]*):"
const ranges_r = r"([0-9]*)\-([0-9]*)"

function __init__()
#    test_part1()
end

function test_part1()
    debug_notes = read_input("debug.txt")
    @test solve_part1(debug_notes) == 71
end

struct Notes
    ranges::Dict{String,Tuple{UnitRange{Int64},UnitRange{Int64}}}
    your_ticket::Vector{Int}
    nearby_tickets::Vector{ Vector{Int} }
end

function read_input(filename)
    lines = readlines(filename)
    ranges = Dict{String,Tuple{UnitRange{Int64},UnitRange{Int64}}}()
    your_ticket = Vector{Int}()
    nearby_tickets = Vector{ Vector{Int} }()

    header_flag = true
    your_ticket_flag = false
    nearby_tickets_flag = false

    i = 1
    for line in lines
        @info i
        i = i+1
        if isempty(line)
            continue
        end
        m = match(letters_r, line)
        if isnothing( m )
            key = ""
        else
            key = m.captures[1]
        end
        @info "Key: " * key
        if key == "your ticket"
            your_ticket_flag = true
            header_flag = false
        elseif key == "nearby tickets"
            nearby_tickets_flag = true
        elseif your_ticket_flag
            @info "Your Ticket Flag line"
            your_ticket_flag = false
            your_ticket = [parse(Int,n) for n in split(line,",")]
        elseif nearby_tickets_flag
            @info "Nearby Ticket Flag line"
            ticket = [parse(Int,n) for n in split(line,",")]
            println(ticket)
            push!(nearby_tickets, ticket)
        elseif isempty(key)
        elseif header_flag
            @info "Header: " * line
            ranges_match = eachmatch(ranges_r, line)
            gen = (
                UnitRange( parse(Int, range.captures[1] ),
                           parse(Int, range.captures[2] ) )
                for range in ranges_match
            )
            ranges[ key ] = tuple( gen... )
        else
            error("Unknown state: " * line)
        end
    end
    return Notes(ranges, your_ticket, nearby_tickets)
end

function solve_part1(notes = read_input("input.txt"))
    flat = flat_ranges(notes)
    error_rate = 0
    for ticket in notes.nearby_tickets
        for x in ticket
            if !any([x in r for r in flat])
                error_rate += x
            end
        end
    end
    return error_rate
end

# Part 2

function flat_ranges(notes::Notes)
    return Iterators.flatten( values(notes.ranges) )
end

function test_part2()
    notes = read_input("debug2.txt")
#    solve_part2(notes)
end

function is_valid_ticket(ticket, notes::Notes)
    return all( [any([ x in r for r in flat_ranges(notes) ]) for x in ticket] )
end

function solve_part2(notes::Notes = read_input("input.txt"))
    valid_ticket_matrix = hcat([ticket for ticket in notes.nearby_tickets if aoc_16.is_valid_ticket(ticket,notes)]...)
    valid_dict = Dict{String,Vector{Bool}}()
    for (field,ranges) in notes.ranges
        valid_dict[field] = [
            all([x in ranges[1] || x in ranges[2] for x in row])
            for row in eachrow(valid_ticket_matrix)
        ]
    end
    key_perm = sortperm([sum(value) for (key,value) in valid_dict])
    row_perm = sortperm( sum( hcat(values(valid_dict)...) , dims = 2)[:], rev=true )
    key_to_row = Dict(zip([keys(valid_dict)...][key_perm],row_perm))
    fvalues = [ notes.your_ticket[ row ] for (key,row) in key_to_row if occursin("departure",key) ]
    return prod(fvalues)
    # return key_to_row
end

end