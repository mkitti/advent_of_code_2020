using BenchmarkTools

# Originally from Teo ShaoWei via Zulip

const INT = UInt32
const cups = parse.(INT, collect("389125467"))

@inline function peek(next, at, n::Int, result=similar(next,n))
  for i in 1:n
    result[i] = next[at]
    at = next[at]
  end
  result
end

@inline function peek(next, at, ::Val{3})
    a = next[at]
    b = next[ a ]
    c = next[ b ]
    ( a, b, c )
end

function next1(cups)
  N = length(cups)
  next = similar(cups)
  for i in 1:N
    next[cups[i]] = cups[mod1(i+1,N)]
  end
  next
end
function next2(cups)
  next = similar(cups)
  next[cups] = circshift(cups,-1)
  next
end

const cups_next = next2(cups)

function run(current::INT, next::Vector{INT}, steps::Int=1)
  N = INT(length(next))

  @inbounds for i in 1:steps
    #pickups = peek(next, current, Val(3))
    a = next[ current ]
    b = next[ a ]
    c = next[ b ]

    #dst = mod1(current-1, N)
    #while dst in pickups
    #  dst = mod1(dst-1, N)
    #end
    dst = current - INT(1)
    if dst == INT(0)
        dst = N
    end
    while dst == a || dst == b || dst == c
        dst -= INT(1)
        if dst == INT(0)
            dst = N
        end
    end

    next[current] = next[c]
    next[c] = next[dst]
    next[dst] = a
    current = next[current]
  end

  return next
end

part1() = join(peek(run(cups[1], cups_next, 10), 1, 8))
#part2() = prod(peek(run(vcat(cups, 10:1_000_000), 10_000_000), 1, 2))
function part2()
    #cups2 = vcat(cups, Int32(10):Int32(1_000_000))
    next = vcat(cups_next, INT(11):INT(1_000_000), cups[1])
    next[cups[end]] = 10
    # cups2_next == next2(cups2) == next1(cups2)
    next = run(cups[1], next, 10_000_000)
    prod( peek( next , 1 , 2) )
end
println( part2() )
@btime part2() #   171.104 ms (30 allocations: 3.82 MiB)
# 149245887792