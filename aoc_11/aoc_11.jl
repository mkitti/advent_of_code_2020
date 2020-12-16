using ImageFiltering

# Part 1

const nhood_filter = centered( [ 1 1 1; 1 0 1; 1 1 1 ])

get_neighbors( I ) = imfilter( I , nhood_filter, Fill(0) )

function fill_seats( occupied, seats )
    neighbors = get_neighbors( occupied )
    occupied = ( neighbors .== 0 ) .* seats .| occupied
    neighbors = get_neighbors( occupied )
    occupied = ( neighbors .< 4 ) .* occupied
    return occupied
end

function fill_seats!( occupied, seats )
    neighbors = get_neighbors( occupied )
    occupied .= ( neighbors .== 0 ) .* seats .| occupied
    neighbors = get_neighbors( occupied )
    occupied .= ( neighbors .< 4 ) .* occupied
    return occupied
end

function read_input( filename )
    lines = readlines(filename)
    seats = hcat([Vector{Char}(l) .== 'L' for l in lines]...)
    return copy( transpose(seats) )
end

const seats = read_input("part_1\\input.txt")

# Part 2

const graph_neighbors = findall( nhood_filter .== 1 )

const ci_seats = CartesianIndices( seats )

const one_padded_seats = padarray( seats, Fill(1, ize(seats) ) )

const min_seat = ci_seats[1]
const max_seat = ci_seats[end]

function valid_neighbor( n )
    all( (n.I .>= min_seat.I) .& (n.I .<= max_seat.I) )
end
function filter_neighbors!( neighbors )
    filter!( valid_neighbor , neighbors )
end

function get_neighboring_seats( current, seats = one_padded_seats)
    n = 1
    neighbors = CartesianIndex{2}[]
    unit_neighbors = graph_neighbors
    current_neighbors = (current,) .+ graph_neighbors
    while( !isempty(current_neighbors) )
        neighbor_seats = seats[ current_neighbors ]
        append!( neighbors, current_neighbors[ neighbor_seats] )
        unit_neighbors = unit_neighbors[ .!neighbor_seats ]
        n = n + 1
        current_neighbors = (current,) .+ (unit_neighbors .* n)
    end
    filter_neighbors!( neighbors )
end

const seat_neighbors = [get_neighboring_seats( c, one_padded_seats ) for c in ci[ seats ]]

function get_neighbors_part_2( occupied )
    neighbors = zeros( Int64, size( occupied ) )
    neighbors[ seats ] = [sum( occupied[ s ] ) for s in seat_neighbors]
    return neighbors
end

function fill_seats_part_2!( occupied, seats )
    neighbors = get_neighbors_part_2( occupied )
    occupied .= ( neighbors .== 0 ) .* seats .| occupied
    neighbors = get_neighbors_part_2( occupied )
    occupied .= ( neighbors .< 5 ) .* occupied
    return occupied
end