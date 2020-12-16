module aoc_14

export read_input

const mask_rx = r"mask\s*=\s*([10X]{36})"
const assign_rx = r"mem\[([0-9]*)\]\s=\s([0-9]*)"

abstract type Command end

struct Mask <: Command
    zero_mask::UInt64
    one_mask::UInt64
end

struct Assign <: Command
    address::UInt64
    value::UInt64
end

Mask(zero_mask::BitVector, one_mask::BitVector) = Mask(reverse(zero_mask).chunks[1], reverse(one_mask).chunks[1])
function Mask(m::AbstractString)
    Mask(convert(BitVector,[c .== '0' for c in m]), convert(BitVector,[c .== '1' for c in m]))
end
function Assign(address::AbstractString, value::AbstractString)
    Assign( Base.parse(Int64, address), Base.parse(Int64, value) )
end

function read_input(filename)
    lines = readlines(filename)
    commands = Vector{Command}();
    for line in lines
        if ( (m = match(assign_rx,line) ) != nothing)
            push!( commands, Assign(m.captures[1], m.captures[2]) )
        elseif ( ( m = match(mask_rx,line) ) != nothing)
            push!( commands, Mask(m.captures[1]) )
        else
            error("Cannot parse \"" * line * "\"")
        end
    end
    return commands
end

function parse(commands::Vector{Command})
    mask = Mask( falses( 36 ), falses( 36 ) )
    addresses = [assign.address for assign in commands if assign isa Assign]
    mem = zeros(UInt64, maximum(addresses) )
    for command in commands
        mask = evaluate!( command, mask, mem)
    end
    println(sum(mem))
    return mem
end

function evaluate!( command::Mask, mask::Mask, args...)
    return command
end

function evaluate!( assign::Assign, mask::Mask, mem::Vector{UInt64})
    mem[ assign.address ] = ~( ~( assign.value | mask.one_mask ) | mask.zero_mask )
    return mask
end

# Part 2

const thirtysixbitmask = UInt64(2^36-1)
const bitscan36 = 1 .<< (0:35)

getxs( command::Mask ) = ~command.zero_mask & ~command.one_mask & thirtysixbitmask
getxpos( mask::UInt64 ) = findall( mask .& bitscan36 .!= 0 )
getxpos( command::Mask ) = getxpos( getxs(command) )

function get_floating_memory( address::UInt64, mask::Mask)
    xs = getxs( mask )
    xpos = getxpos( xs )
    addresses = zeros(UInt64, 2^length(xpos))
    address = address | mask.one_mask
    address = address & ~xs
    for a = 1:length(addresses)
        bits = (UInt64(a) - 1) .& bitscan36[1:length(xpos)] .!= 0
        addresses[a] = address | sum(bits .<< (xpos .- 1))
    end
    return addresses
end

function parse2(commands::Vector{Command})
    mask = Mask( falses( 36 ), falses( 36 ) )
    # addresses = [assign.address for assign in commands if assign isa Assign]
    #mem = zeros(UInt64, 2^30 )
    mem = Dict{UInt64,UInt64}()
    for command in commands
        mask = evaluate2!( command, mask, mem)
    end
    #println(sum(mem))
    return mem
end

function evaluate2!( command::Mask, mask::Mask, args...)
    println( command )
    return command
end
function evaluate2!( command::Assign, mask::Mask, mem::Dict{UInt64,UInt64})
    println( command.address )
    addresses = get_floating_memory( command.address, mask)
    for address in addresses
        mem[ address ] = command.value
    end
    return mask
end


end