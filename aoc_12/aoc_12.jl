module aoc_12

export Ship, north, south, east, west, left, right, forward
export distance

abstract type Positionable end

mutable struct Ship
    direction::Int64
    x::Float64
    y::Float64
end

Ship() = Ship( 0, 0, 0 )

north( ship::Ship, dist ) = ship.y += dist
east( ship::Ship, dist )  = ship.x += dist
left( ship::Ship, degrees ) = ship.direction += degrees

south( s, d ) = north( s, -d)
west( s, d ) = east( s, -d)
right( s, d) = left( s, -d )

function forward( ship::Ship, dist )
    ship.x += cosd( ship.direction ) * dist
    ship.y += sind( ship.direction ) * dist
end

distance( ship::Ship ) = abs( ship.x ) + abs( ship.y )

const commands = Dict(
    'N' => north,
    'S' => south,
    'E' => east,
    'W' => west,
    'L' => left,
    'R' => right,
    'F' => forward
)

const regexp = r"([NSEWLRF])([0-9]+)"

function read_instructions( filename , ship::Union{Ship,ShipWithWaypoint} = Ship() )
    open( filename, "r") do io
        for line in eachline( filename )
            m = match( regexp, line )
            commands[ m.captures[1][1] ]( ship, parse( Int64, m.captures[2] ) )
        end
    end
    println( distance(ship) )
    return ship
end

# Part 2
export ShipWithWaypoint

mutable struct Waypoint
    x::Float64
    y::Float64
end
Waypoint() = Waypoint(10,1)
mutable struct ShipWithWaypoint 
    s::Ship
    w::Waypoint
end
ShipWithWaypoint() = ShipWithWaypoint(Ship(),Waypoint())
north(s::ShipWithWaypoint, dist) = s.w.y += dist
east(s::ShipWithWaypoint, dist) = s.w.x += dist
function left(s::ShipWithWaypoint, degrees)
    radius = hypot(s.w.y, s.w.x)
    angle = atand(s.w.y, s.w.x )
    angle += degrees
    s.w.x = cosd( angle ) * radius
    s.w.y = sind( angle ) * radius
end
function forward(s::ShipWithWaypoint, dist)
    s.s.x += s.w.x * dist
    s.s.y += s.w.y * dist
end
distance(s::ShipWithWaypoint) = distance( s.s )

end