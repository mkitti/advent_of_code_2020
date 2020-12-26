module aoc_09
    using Test
    export read_input, part1, part2
    export test_part1, test_part2, test
    export input, demo

    const input_r = r""

    function read_input(filename = "input.txt")
        #lines = readlines(filename)
        # for line in eachline(filename)
        #for line in lines
        #end
        [parse_line(line) for line in eachline(filename)]
        #lines
    end

    function parse_line(line)
        parse(Int,line)
    end

    const input = read_input("input.txt")
    const demo = read_input("demo.txt")

    function part1(input = input, preamble = 25)
        for i = preamble + 1 : length(input)
            prev = input[i-preamble:i-1]
            valid = any(in.(input[i] .- prev, (prev,)))
            if !valid
                return input[i]
            end
        end
        0
    end

    function test_part1()
        @testset "Part 1" begin
            @test part1( demo , 5) == 127
            @test part1() == 2089807806
        end
    end

    function part2(input = input, preamble = 25)
        target = part1(input, preamble)
        cs = cumsum(input)
        # min_cs = cs[1]
        # gt_cs = filter(>=(target+min_cs), cs)
        # lt_cs = filter(<=(gt_cs[end] - target), cs)
        cs_range = ()
        for gt in cs
            valid = gt .- cs .== target
            if any( valid )
                cs_range = ( cs[ findfirst(valid) ], gt )
                break
            end
        end
        ind = ( (x,y)->findfirst(isequal( x ), cs) + y ).(cs_range,(1,0))
        sum( extrema( input[ind[1]:ind[2]] ) )
    end

    function test_part2()
        @testset "Part 2" begin
            @test part2( demo , 5) == 62
            @test part2() == 245848639
        end
    end

    function test()
        test_part1()
        test_part2()
    end
end