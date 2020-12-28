module aoc_20

export read_input, edges, Tile
export make_edges_dict, get_out_edge, get_outer_tiles

struct Tile
    number::Int
    image::BitMatrix
    edges::Vector{Int}
end

const tile_r = r"Tile (\d+):"

function read_input(filename)
    lines = readlines(filename)
    tile_number = -1
    buffer = Vector{BitVector}()
    tiles = Dict{Int,Tile}()
    for line in lines
        if isempty(line)
            image = permutedims( hcat(buffer...) )
            tiles[ tile_number ] = Tile( tile_number, image, edges(image))
            tile_number = -1
            empty!(buffer)
            continue
        end
        if tile_number == -1
            m = match(tile_r, line)
            if isnothing(m) || length(m.captures) < 1
                error("Could not read tile from \"$line\"")
            else
                tile_number = parse(Int, m.captures[1])
                continue
            end
        else
            push!(buffer, Vector{Char}(line) .== '#')
        end
    end
    if tile_number != -1
        image = permutedims( hcat(buffer...) )
        tiles[ tile_number ] = Tile( tile_number, image, edges(image))
    end
    tiles
end

export edge_order
const edge_order = [:top, :bottom, :left, :right, :top_flipped, :bottom_flipped, :left_flipped, :right_flipped]

function edges(image::BitMatrix)
    a = image[1,:][:] # top
    b = image[end,:][:] # bottom
    c = image[:,1][:] # left
    d = image[:,end][:] # right
    e = [a, b, c, d]
    e = append!(e, reverse.(e)) # flipped
    edge2int.(e)
end

function make_edges_dict( tiles::Dict{Int,Tile} )
    edge2tile = Dict{Int,Vector{Int}}()
    for (k,v) in tiles, e in v.edges
        v = get( edge2tile, e, Vector{Int}() )
        edge2tile[ e ] = push!(v, k)
    end
    edge2tile
end

const bits = 0:9
edge2int(b::BitVector) = sum(b .<< bits)

function place_tiles( tiles::Dict{Int,Tile} )
    edge2tile = make_edges_dict( tiles )
    outer_edge = get_outer_edge( edge2tile )
    outer_tiles = get_outer_tiles( outer_edge )
    placed_tiles = Int[]
    n_tiles = length(tiles)
    tiles_per_edge = round(Int, sqrt(n_tiles) )
    image = zeros(Int, tiles_per_edge, tiles_per_edge)
    # Wait, do I need to do this? I just need the corners
    # Yes for part 2

    corners = get_corners( tiles )

    # Start with a corner
    image[1] = first( corners )
    get_neighbors(t, tiles=tiles, edge2tile=edge2tile) = unique(first.(filter.(x->x!=t,filter(x->length(x)==2,[ edge2tile[ e ] for e in tiles[ t ].edges ]))))

    # Build out neighbors
    neighbors = get_neighbors( image[1] )
    image[1,2] = neighbors[1]
    image[2,1] = neighbors[2]
    push!(placed_tiles, image[1])
    append!(placed_tiles, neighbors)

    indices = CartesianIndices(image)
    #last_ind = indices[2,1]
    outer_edge_itr = vcat( indices[3:end,1], indices[end,2:end], indices[end-1:-1:1,end], indices[1, end-1:-1:3] )
    # outer_tiles = filter!(t->!in(t[1],placed_tiles), filter(t->in(t[1],outer_tiles), tiles) )

    is_unplaced_outer_tile(t::Int) = in(t, outer_tiles) & !in(t, placed_tiles)

    last_tile = image[2,1]
    for ind in outer_edge_itr
        #last_tile = image[ last_ind ]
        neighbor = first( filter!(is_unplaced_outer_tile, get_neighbors(last_tile)) )
        
        image[ ind ] = neighbor
        push!(placed_tiles, neighbor)

        last_tile = neighbor

    end

    is_unplaced(t) = !in(t, placed_tiles)
    itr = indices[2:end-1,2:end-1][:]
    for ind in itr
        above = image[ ind - CartesianIndex(1,0) ]
        left = image[ ind - CartesianIndex(0,1) ]
        neighbor = first( filter(is_unplaced, intersect( get_neighbors(above), get_neighbors(left) ) ) )

        image[ ind ] = neighbor
        push!(placed_tiles, neighbor)
    end

    image

end

function assemble_image( tiles::Dict{Int,Tile}, image = place_tiles( tiles ))
    tile_image = [tiles[ i ] for i in image]
    n_tiles = length(tiles)
    tiles_per_edge = round(Int, sqrt(n_tiles) )

    actual_image = falses( size( first(tiles).second.image ) .*  tiles_per_edge )

    tn, tm = size(tile_image[1].image)

    actual_image[1:tn,1:tm] = orient_tile_down_right( tile_image[1,1], tile_image[2,1], tile_image[1,2] )


    indices = CartesianIndices(image)


    prev_edge = edge2int(actual_image[tn, 1:tm])


    for ind in indices[2:end,1]
        current = tile_image[ ind ]

        eo = edge_order[ findfirst(current.edges .== prev_edge ) ]
        if eo == :left_flipped
            I = rotr90(current.image)
        elseif eo == :bottom_flipped
            I = rot180(current.image)
        elseif eo == :top
            I = current.image
        elseif eo == :right
            I = rotl90(current.image)
        elseif eo == :left
            I = reverse( rotr90(current.image), dims = 2)
        elseif eo == :bottom
            I = reverse( rot180(current.image), dims = 2)
        elseif eo == :top_flipped
            I = reverse( current.image, dims = 2)
        elseif eo == :right_flipped
            I = reverse( rotl90(current.image), dims = 2 )
        else
            error("Orientation")
        end
        #print(eo)
        actual_image[tn*(ind[1]-1) .+ (1:tn), tm*(ind[2]-1) .+ (1:tm)] = I
        prev_edge = edge2int(I[end,:])
    end


    for row = 1:tiles_per_edge
        prev_edge = edge2int( actual_image[(row-1)*tn .+ (1:tn), tm])
    for ind in indices[row,2:end]
        current = tile_image[ ind ]

        eo = edge_order[ findfirst(current.edges .== prev_edge ) ]
        if eo == :bottom
            I = rotr90(current.image)
        elseif eo == :right_flipped
            I = rot180(current.image)
        elseif eo == :left
            I = current.image
        elseif eo == :top_flipped
            I = rotl90(current.image)
        elseif eo == :bottom_flipped
            I = reverse( rotr90(current.image), dims = 1)
        elseif eo == :right
            I = reverse( rot180(current.image), dims = 1)
        elseif eo == :left_flipped
            I = reverse( current.image, dims = 1)
        elseif eo == :top
            I = reverse( rotl90(current.image), dims = 1)
        else
            error("Orientation")
        end
        #print(eo)
        actual_image[tn*(ind[1]-1) .+ (1:tn), tm*(ind[2]-1) .+ (1:tm)] = I
        prev_edge = edge2int(I[:,end])

    end
    end

    ind = filter(i->mod1(i,10)!=10 && mod1(i,10)!=1,1:size(actual_image)[1] )

    actual_image[ind, ind]
end

function orient_tile_down_right( current, down, right)
    down_edges = intersect( down.edges, current.edges )
    right_edges = intersect( right.edges, current.edges )

    #println(current)
    #println(down)
    #println(right)

    #println(down_edges)
    #println(right_edges)

    down_ori = edge_order[ mod1( findfirst(in.(current.edges,first(down_edges))), 4) ]
    right_ori = edge_order[ mod1( findfirst(in.(current.edges,first(right_edges))), 4) ]

    #println(down_ori)
    #println(right_ori)

    if down_ori == :bottom && right_ori == :right
        return current.image
    elseif down_ori == :right && right_ori == :bottom
        return permutedims(current.image)
    elseif down_ori == :right && right_ori == :top
        return rotr90(current.image)
    elseif down_ori == :left && right_ori == :top
        return permutedims( rot180( current.image ) )
    end

    # more needed
end

using IterTools

function get_outer_edge( tiles::Dict{Int,Tile})
    edge2tile = make_edges_dict( tiles )
    get_outer_edge( edge2tile )
end
get_outer_edge( edge2tile::Dict{Int,Vector{Int}} ) = filter(p->length(p.second) == 1, edge2tile)

get_outer_tiles( outer_edge::Dict{Int,Vector{Int}}) = unique(first.(values(outer_edge)))



function get_corners( tiles::Dict{Int,Tile})
    v = get_outer_edge( tiles )
    g = groupby(p->p.second,sort( collect( v ), by=p->first(p.second)))
    g = filter!(g->length(g)==4, collect(g))
    corners = first.(last.(first.( g )))
    corners
end

function part1(tiles = read_input("input.txt"))
    prod( aoc_20.get_corners( tiles ) )
    # 23497974998093
end

# Part 2

function load_pattern(filename = "pattern.txt")
   permutedims(hcat(Vector{Char}.(readlines(filename))...)) .== '#'
end

using ImageFiltering
function part2(tiles = aoc_20.read_input("input.txt"), pattern = aoc_20.load_pattern())
    actual_image = aoc_20.assemble_image(tiles)
    n_pixels_pattern = sum(pattern)
    # Find how many patterns there are across flips and rotations
    total = 0
    for i=1:4
        total += sum(imfilter(Float64,actual_image,rotr90(pattern,i)) .≈ n_pixels_pattern)
    end
    pattern = permutedims(pattern)
    for i=1:4
        total += sum(imfilter(Float64,actual_image,rotr90(pattern,i)) .≈ n_pixels_pattern)
    end
    total
    sum(actual_image) - total*n_pixels_pattern
    # 2256
end

function __init__()
    println("Initializing Advent of Code Day 20 Solution by Mark Kittisopikul: aoc_20.jl")
    if !isinteractive()
        run()
    end
end

function run()
    if isempty(ARGS)
        files = ["input.txt"]
    else
        files = ARGS
    end
    for file in files
        @show file
        input = read_input(file)
        @show part1( input )
        @show part2( input )
    end
end

end

#tiles = aoc_20.read_input("input.txt")
#aoc_20.assemble_image( tiles )