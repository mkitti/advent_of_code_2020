module aoc_01
    using Test
    export read_input, part1, part2
    export test_part1, test_part2, test
    export input, demo

    function read_input(filename = "input.txt")
        lines = readlines(filename)
        # for line in eachline(filename)
        [parse(Int,line) for line in lines]
    end


    const input = read_input("input.txt")
    const demo = read_input("demo.txt")

    function part1(input=input)
        for i in eachindex(input), j in eachindex(input[i+1:end])
            if input[i] + input[j] == 2020
                return input[i]*input[j]
            end
        end
        error("Could not find two numbers which add up to 2020")
    end

    function test_part1()
    end

    function part2()
        for i in eachindex(input),
            j in eachindex(input[i+1:end]),
            k in eachindex(input[i+2:end])
            if input[i] + input[j] + input[k] == 2020
                return input[i]*input[j]*input[k]
            end
        end

    end

    function test_part2()
    end
end
