module aoc_06
    using Test
    export read_input, part1, part2
    export test_part1, test_part2, test
    export input, demo

    const input_r = r""

    function read_input(filename = "input.txt")
        lines = readlines(filename)
        # for line in eachline(filename)
        groups = Vector{Vector{String}}()
        group = Vector{String}()
        for line in lines
            if isempty(line)
                push!(groups, copy(group))
                empty!(group)
            else
                push!(group, line)
            end
        end
        push!(groups, copy(group))
        # [parse_line(line) for line in eachline(filename)]
        groups
    end

    function parse_line(line)
    end

    const input = read_input("input.txt")
    const demo = read_input("demo.txt")

    function part1(input = input)
        sum(length.(unique.(Vector{Char}.(join.(input)))))
    end

    function test_part1()
        @test part1( demo ) == 11
        @test part1() == 6457
    end

    function part2(input = input)
        sum(length.([intersect.( group... ) for group in input]))
    end

    function test_part2()
        @test part2( demo ) == 6
        @test part2() == 3260
    end

    function test()
        test_part1()
        test_part2()
    end
end