module aoc_02
    using Test
    export read_input, part1, part2
    export test_part1, test_part2, test
    export input, demo

    const input_r = r"(\d+)-(\d+) ([a-z]): ([a-z]+)"

    function read_input(filename = "input.txt")
        lines = readlines(filename)
        # for line in eachline(filename)
        # for line in lines
        #end
        [parse_line(line) for line in eachline(filename)]
        # lines
    end

    function parse_line(line)
        m = match( input_r, line )
        # policy = Regex("$(m.captures[3]){$(m.captures[1]),$(m.captures[2])}")
        policy = parse(Int,m.captures[1]):parse(Int,m.captures[2])
        (policy, m.captures[3], m.captures[4])
    end

    input = read_input("input.txt")
    demo = read_input("demo.txt")

#= Each line gives the password policy and then the password. The password policy indicates the lowest and highest number of times a given letter must appear for the password to be valid. For example, 1-3 a means that the password must contain a at least 1 time and at most 3 times.

In the above example, 2 passwords are valid. The middle password, cdefg, is not; it contains no instances of b, but needs at least 1. The first and third passwords are valid: they contain one a or nine c, both within the limits of their respective policies.

How many passwords are valid according to their policies? =#



    function part1(input = input)
        sum( [sum(Vector{Char}(l[3]) .== l[2][1]) ∈ l[1] for l in input] )
    end

    function test_part1()
        @test part1( demo ) == 2
        @test part1() == 439
    end

    function part2(input = input)
        total = 0
        for line in input
            r = line[1]
            total += xor(line[3][r.start] == line[2][1], line[3][r.stop] == line[2][1])
        end
        total
    end

    function test_part2()
        @test part2( demo ) == 1
        @test part2() == 584
    end
end