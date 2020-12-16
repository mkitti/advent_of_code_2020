module aoc_15

using Test

export read_input, test_part1, solve_part1, test_part2, solve_part2

function read_input(filename)
    lines = readlines(filename)
    numbers = split(lines[1],",")
    return [parse(Int,x) for x in numbers]
end

function test_part1()
    starting = [0,3,6]
    @test solve_part1(starting) == 436
end

function solve_part1(starting = read_input("input.txt"), finish = 2020)
    memory = Dict{Int,Int}()
    for i = 1:length(starting)
        memory[ starting[ i ] ] = i
    end
    last = starting[end]
    age = 0
    for i = length( starting ) : finish - 1
        last_turn = get( memory, last, i )
        memory[ last ] = i
        age = i - last_turn
        last = age
    end
    return age
end

# Part 2

function test_part2()
#=     Given 0,3,6, the 30000000th number spoken is 175594.
Given 1,3,2, the 30000000th number spoken is 2578.
Given 2,1,3, the 30000000th number spoken is 3544142.
Given 1,2,3, the 30000000th number spoken is 261214.
Given 2,3,1, the 30000000th number spoken is 6895259.
Given 3,2,1, the 30000000th number spoken is 18.
Given 3,1,2, the 30000000th number spoken is 362. =#
    @test solve_part2([0,3,6]) == 175594 
    @test solve_part2([1,3,2]) == 2578
    @test solve_part2([2,1,3]) == 3544142
    @test solve_part2([1,2,3]) == 261214
    @test solve_part2([2,3,1]) == 6895259
    @test solve_part2([3,2,1]) == 18
    @test solve_part2([3,1,2]) == 362
end

function solve_part2(starting = read_input("input.txt"))
    return solve_part1(starting, 30000000)
end

end