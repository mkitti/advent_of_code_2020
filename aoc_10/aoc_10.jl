module aoc_10
    using Test
    export read_input, part1, part2
    export test_part1, test_part2, test
    export input, demo

    const input_r = r""

    function read_input(filename = "input.txt")
        [parse_line(line) for line in eachline(filename)]
    end

    function parse_line(line)
        parse(Int,line)
    end

    const input = read_input("input.txt")
    const demo = read_input("demo.txt")
    const demo2 = read_input("demo2.txt")

    function part1(input = input)
        diffs = diff(sort([input; 0]))
        accum = zeros(maximum(diffs))
        for d in diffs
            accum[d] += 1
        end
        accum[3] += 1
        accum
        # accum[1] * accum[3]
    end

    function test_part1()
        @testset "Part 1" begin
            @test true
        end
        part1( demo )
        #part1( demo2 )
    end

    "Calculate length of differences by only one"
    function calculate_run_lengths(input = input)
        # We need to add zero to the beginning
        # but not the device adapter since that has to remain
        sorted = sort([input; 0])
        diffs = diff(sorted)
        total = 0
        inrun = false
        runlength = 0
        runs = Vector{Int}()
        for i=1:length(diffs)
            if inrun
                if diffs[i] == 1
                    # println(sorted[i+1])
                    total += 1
                    runlength += 1
                else
                    push!(runs, runlength)
                    inrun = false
                end
            else
                if diffs[i] == 1
                    inrun = true
                    # println(sorted[i+1])
                    runlength = 1
                else
                    inrun = false
                end
            end
        end
        if inrun
            push!(runs, runlength)
        end
        runs
    end

    function run_lengths_to_combinations(runs)
        # After having calculated the runs of differences of 1,
        # we have to map them to combinations

        # Generally, the the combinations is 2^(length-1)
        runs2mul = zeros(Int,4)
        runs2mul[4] = 7 # We remove the possibility of three numbers being removed
        runs2mul[3] = 4 # The rest are multiples
        runs2mul[2] = 2
        runs2mul[1] = 1
        runs2mul[runs]
    end

    function part2(input = input)
        runs = calculate_run_lengths(input)
        combinations = run_lengths_to_combinations(runs)
        prod(combinations)
    end

    function test_part2()
        @testset "Part 2" begin
            @test part2(demo) == 8
            @test part2(demo2) == 19208
            @test part2() == 1727094849536
        end
        part2( demo2 )
    end

    function test()
        test_part1()
        test_part2()
    end
end