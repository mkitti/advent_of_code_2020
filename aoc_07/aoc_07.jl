module aoc_07
    using Test
    export read_input, part1, part2
    export test_part1, test_part2, test
    export input, demo


    # light red bags contain 1 bright white bag, 2 muted yellow bags.
    const input_r = r"(.*) bags contain (.*)"
    const bag_r = r"([\d|no]*) ([a-z\s]*) bags?,?"

    function read_input(filename = "input.txt")
        lines = readlines(filename)
        [parse_line(line) for line in eachline(filename)]
    end

    function parse_line(line)
        m = match( input_r, line )
        m.captures[1]
        m2 = eachmatch( bag_r, m.captures[2])
        zeroifnothing(x) = x == nothing ? 0 : x
        quantity(x) = zeroifnothing( tryparse(Int,x) )
        (m.captures[1], [ quantity(mm.captures[1]) => mm.captures[2] for mm in m2])
    end

    const input = read_input("input.txt")
    const demo = read_input("demo.txt")

    function part1(input = input)
        containedin = Dict{String,Vector{String}}()
        for a in input
            container = a[1]
            for (num, containee) in a[2]
                if num != 0
                    v = get(containedin, containee, String[])
                    push!(v, container)
                    containedin[ containee ] = v
                end
            end
        end
        # return containedin

        containers = Set{String}()
        bags = Set(["shiny gold"])
        n_bags = 0
        while true
            new_bags = Set{String}()
            for bag in bags
                for innerbag in get(containedin, bag, String[])
                    push!(new_bags, innerbag)
                    # push!(bags, innerbag)
                    # push!(containers, innerbag )
                end
            end
            bags = setdiff(new_bags, containers)
            union!(containers, bags)
            # println(bags)
            # println(n_bags)
            if n_bags == length(containers)
                break
            else
                n_bags = length(containers)
            end
        end
        length( containers )
    end

    function test_part1()
        @testset "Part 1" begin
            @test part1( demo ) == 4
            @test part1() == 119
        end
    end

    function part2(input = input)
        dict = Dict{String,Array{Pair{Int,String}}}()
        for a in input
            dict[ a[1] ] = a[2]
        end
        # dict
        count_bags("shiny gold", dict)
    end

    function count_bags(key, dict)
        if key == "other"
            return 0
        end
        a = dict[ key ]
        total = 0
        for (q, c) in a
            total += q + q * count_bags(c, dict) 
        end
        @info "$key: $total"
        total
    end

# faded blue bags contain 0 other bags.
# dotted black bags contain 0 other bags.
# vibrant plum bags contain 11 other bags: 5 faded blue bags and 6 dotted black bags.
# dark olive bags contain 7 other bags: 3 faded blue bags and 4 dotted black bags.

    function test_part2()
        @testset "Part 2" begin
            @test part2( demo ) == 32
            @test part2( read_input("demo2.txt") ) == 126
            @test part2() == 155802
        end
    end

    function test()
        test_part1()
        test_part2()
    end
end