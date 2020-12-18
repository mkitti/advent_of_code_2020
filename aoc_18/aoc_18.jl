module aoc_18

export ×, ⨸

const newplus = '⨸'
const newtimes = '×'

const inferior_times = '⊕'

const opdict = Dict('+' => newplus, '*' => newtimes)

function read_input(filename, times = newtimes)
    lines = readlines(filename)
    replace.(replace.(lines,('+' => newplus,)),('*' => times,))
end

⨸(x,y) = x + y
×(x,y) = x * y
⊕(x,y) = x * y


part1() = sum(eval.(Meta.parse.( read_input("input.txt") )))
part2() = sum(eval.(Meta.parse.( read_input("input.txt", inferior_times) )))


end