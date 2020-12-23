module aoc_23
    using CircularArrays
    using CircularList
    using Test

    const input = "685974213"
    const input_array = CircularArray( parse.(UInt8, Vector{Char}(input) ) )
    const demo = "389125467"
    const demo_array = CircularArray( parse.(UInt8, Vector{Char}(demo) ) )

    const demo_destinations = [2, 7, 3, 7, 3, 9, 8, 1, 5, 3]

    # CircularArray delete / insert enhancement
    include("circulararray.jl")

    # CircularArrayList actually subtypes AbstractArray
    # We also added a dict into it
    include("CircularListArray.jl")


    function play( input = input_array , n = 100)
        select = 1
        #A = deepcopy(input)
        A = input
        # @info "Finding min and max"
        min_cup = minimum(A)
        # @info "Minimum", min_cup
        max_cup = maximum(A)
        # @info "Maximum", max_cup

        # println(A)
        # println(typeof(A))

        for i=1:n
            if i % 1_000_000 == 0
                @info i
            end
            selected = select+1:select+3
            current = A[ select ]
            destination = current - 1
            # For CircularListArray the following will return a CircularList
            snip = A[ selected ]
            if !isa(A, CircularListArray)
                # We will does this while we insert
                deleteat!(A, selected)
            end
            if destination < min_cup
                destination = max_cup
            end
            while destination ∈ snip
                destination -= 1
                #println("Destination", destination)
                if destination < min_cup
                    destination = max_cup
                end
            end
            #println("Final destination: ", destination )
            #println(A)
            insertaftervalue!(A, destination, snip)
            #println(A)
            if isa( A, CircularListArray )
                jump!( A.list, next(A.list) )
                select = 1
            else
                select = findfirst(isequal(current), A) + 1
            end
        end
        A
    end

    function insertaftervalue!(A, value, inserter)
        dest_ind = findfirst(isequal(value), A) + 1
        insert!(A, dest_ind, inserter)
    end

    function insertaftervalue!(A::CircularListArray, value, inserter)
        # c = current(A.list)
        node = findfirstnode(isequal(value), A)
        # node = A.dict[value]
        # jump!(A.list, node.next)
        insert!(A, node, inserter)
        # jump!(A.list, c)
    end

    function report( A )
        cup_1 = findfirst(isequal(1), A)
        print.(A[cup_1+1:cup_1+8])
        nothing
    end

    part1() = report( play() ) # 82635947

    function test_part1( input = input_array )
        part1_real_answer = [8,2,6,3,5,9,4,7] 

        A = play( deepcopy( input ) )
        cup_1 = findfirst(isequal(1), A)
        @test all( .==( A[cup_1+1:cup_1+8], part1_real_answer ) )

        A = play( CircularListArray( deepcopy( input ) ) )
        cup_1 = findfirst(isequal(1), A)
        @test all( .==( A[cup_1+1:cup_1+8], part1_real_answer ) )
    end

    function part2( input = input_array, n = 10_000_000 )
        input = deepcopy( input )
        A = CircularListArray([input; maximum(input)+1:1_000_000])
        @info "One million array created"
        play( A , n )
        cup_1 = findfirst(isequal(1), A)
        println( A[cup_1+1:cup_1+2] )
        A
        # 157047826689
    end
end