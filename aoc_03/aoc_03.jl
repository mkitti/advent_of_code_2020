module aoc_03
    using Test
    export read_input, part1, part2
    export test_part1, test_part2, test
    export input, demo

    const input_r = r""

    function read_input(filename = "input.txt")
        lines = readlines(filename)
        # for line in eachline(filename)
        input = [parse_line(line) for line in eachline(filename)]
        permutedims(hcat(input...))
    end

    function parse_line(line)
        Vector{Char}(line) .== '#'
    end

    const input = read_input("input.txt")
    const demo = read_input("demo.txt")

    function part1(input = input, slope = CartesianIndex(1,3))
        pos = CartesianIndex(1,1)
        N = size(input,1)
        M = size(input,2)
        trees = 0
        while pos[1] <= N
            trees += input[ pos ]
            pos += slope
            pos = CartesianIndex( pos[1], mod1( pos[2] , M))
        end
        trees
    end

    function test_part1()
        @test part1( demo ) == 7
        @test part1() == 228
    end

    function part2(input = input)
# Right 1, down 1.
# Right 3, down 1. (This is the slope you already checked.)
# Right 5, down 1.
# Right 7, down 1.
# Right 1, down 2.
        slopes = [
            CartesianIndex(1,1),
            CartesianIndex(1,3),
            CartesianIndex(1,5),
            CartesianIndex(1,7),
            CartesianIndex(2,1)
        ]
        prod( part1.( (input,), slopes ) )
    end

    function test_part2()
        @test part2( demo ) == 336
    end

    function test()
        test_part1()
        test_part2()
    end
end