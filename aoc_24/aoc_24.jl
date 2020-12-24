module aoc_24
    export read_input, part1, part2, test_part1, test_part2, factorial
    export direction_dict

    using OffsetArrays, ImageFiltering, Test

    const directions_r = r"e|se|sw|w|nw|ne"

    "Map hexagonal neighbors to cartesian grid"
    const direction_dict = Dict("e" => (0,1), "se" => (1,0), "sw" => (1,-1), "w" => (0,-1), "nw" => (-1,0), "ne" => (-1,1))

    function read_input(filename = "input.txt")
        out = [[m.match for m in eachmatch(directions_r, line)] for line in eachline(filename)]
    end

    const input = read_input()
    const demo = read_input("demo.txt")
    const mini_demo = read_input("demo2.txt")

    function part1(input = input)
        A = parse(input)
        sum(A)
        #282
    end

    "Creates a cartesian image grid"
    function parse(directions = input)
        offsets = [mapreduce(x->aoc_24.direction_dict[x], (x,y)->x .+ y, d) for d in directions]
        ci = CartesianIndex.(offsets)
        ci_max = maximum(ci)
        ci_min = minimum(ci)
        sz = ci_max - ci_min + CartesianIndex(1,1)
        A = OffsetArray( falses(sz.I), OffsetArrays.Origin(ci_min.I...) )
        for c in ci
            A[c] = ~A[c]
        end
        A
    end

    "For Part 2"
    function run( input = input , steps = 100)
        F = OffsetArray(zeros(3,3), -1:1, -1:1)
        F[CartesianIndex.(values(direction_dict))] .= 1
        F
        A = parse(input)

        max_steps = maximum( steps )

        black_tiles = Vector{Int}()

        for step=1:max_steps
            A = padarray(A, Fill(0,(1,1)))

            neighbors = imfilter(A, F, Fill(0))

            # Any black tile with zero or more than 2 black tiles immediately adjacent to it is flipped to white.
            # Any white tile with exactly 2 black tiles immediately adjacent to it is flipped to black.
            flip = ( A .& ( (neighbors .> 2) .| (neighbors .== 0) ) ) .| ( .~A .& (neighbors .== 2) )
            A[ flip ] = .~A[ flip ]

            A = compact(A)

            if step in steps
                push!(black_tiles, sum(A) )
            end

        end
        black_tiles, A
    end

    function part2()
        run()[1][1]
        # 3445
    end

    function test_part1()
        @testset "Part 1" begin
            @test part1(mini_demo) == 2
            @test part1(demo) == 10
            @test part1() == 282
        end
    end
    function test_part2()
        @testset "Part 2" begin
            @test run( demo, [ 1:10 ; 20:10:100 ] )[1] ==[15, 12, 25, 14, 23, 28, 41, 37, 49, 37, 132, 259, 406, 566, 788, 1106, 1373, 1844, 2208]
            @test part2() == 3445
        end
    end

    function test()
        test_part1()
        test_part2()
    end

    "Shrink cartesian image to only contain area that has black tiles"
    function compact(universe)
        # Originall from aoc_17
        e = extrema(findall(universe))
        v = view(universe, [a:b for (a,b) in zip(Tuple.(e)...)]...)
        copy(v)
    end

end