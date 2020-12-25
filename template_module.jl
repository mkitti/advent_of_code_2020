module aoc_01
    using Test
    export read_input, part1, part2
    export test_part1, test_part2, test
    export input, demo

    const input_r = r""

    function read_input(filename = "input.txt")
        lines = readlines(filename)
        # for line in eachline(filename)
        for line in lines
        end
        # [parse_line(line) for line in eachline(filename)]
        lines
    end

    function parse_line(line)
    end

    const input = read_input("input.txt")
    # const demo = read_input("demo.txt")

    function part1(input = input)
    end

    function test_part1()
        part1( demo )
    end

    function part2(input = input)
    end

    function test_part2()
        part2( demo )
    end

    function test()
        test_part1()
        test_part2()
    end
end