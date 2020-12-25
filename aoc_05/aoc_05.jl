module aoc_05
    using Test
    export read_input, part1, part2
    export test_part1, test_part2, test
    export input, demo

    const input_r = r"([FB]{7})([LR]{3})"

    function read_input(filename = "input.txt")
        lines = readlines(filename)
        # for line in eachline(filename)
        # for line in lines
        # end
        [parse_line(line) for line in eachline(filename)]
        # lines
    end

    function parse_line(line)
        m = match( input_r , line )
        ( m.captures[1], m.captures[2] )
    end

    const input = read_input("input.txt")
    const demo = read_input("demo.txt")

    function binspace2int(string::AbstractString, high::Char, shift::Int)
        ba = Vector{Char}(string) .== high
        Int(bitreverse(UInt8(ba.chunks[1])) >> shift)
    end

    function seat2rc(seat::Tuple{AbstractString,AbstractString})
        r = binspace2int(seat[1], 'B', 1)
        c = binspace2int(seat[2], 'R', 5)
        (r,c)
    end

    function rc2seatid(seat::Tuple{Int,Int})
        seat[1]*8 + seat[2]
    end

    seatid(seat) = rc2seatid( seat2rc(seat) )

    function part1(input = input)
        maximum( seatid.( input ) )
    end

    function test_part1()
        @test seatid( demo[1] ) == 357
        @test seatid( demo[2] ) == 567
        @test seatid( demo[3] ) == 119
        @test seatid( demo[4] ) == 820
        @test part1( demo ) == 820
    end

    function part2(input = input)
        seatids = seatid.(input)
        e = extrema(seatids)
        seq = e[1]:e[2]
        (seq)[findfirst(.~in.(seq, (seatid.(input),) ))]
    end

    function test_part2()
        seatids = seatid.(input)
        @test part2()-1 ∈ seatids
        @test part2()+1 ∈ seatids
        @test part2() == 615
    end

    function test()
        test_part1()
        test_part2()
    end
end