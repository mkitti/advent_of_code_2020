module aoc_23
    using CircularArrays
    using CircularList
    using Test

    const input = "685974213"
    const input_array = CircularArray( parse.(UInt8, Vector{Char}(input) ) )
    const demo = "389125467"
    const demo_array = CircularArray( parse.(UInt8, Vector{Char}(demo) ) )

    const demo_destinations = [2, 7, 3, 7, 3, 9, 8, 1, 5, 3]

    import Base: deleteat!, insert!, findfirst
    function deleteat!(a::CircularArray{T,1,A}, r::UnitRange{U}) where {T, A, U <: Integer}
        ind = mod1.(r, length(a))
        deleteat!(a.data, sort(ind))
        a
    end

    function insert!(a::CircularArray{T,1,A}, i::Integer, item) where {T,A}
        ind = mod1(i, length(a))
        insert!(a.data, ind, item)
    end
    function insert!(a::CircularArray{T,1,A}, i::Integer, items::AbstractArray{T,1}) where {T,A}
        ind = mod1(i, length(a))
        insert!.( (a.data,), ind, reverse(items))
        a
    end
    function findfirst(predicate::Function, a::CircularArray)
        findfirst(predicate, a.data)
    end

    import CircularList: List, Node
    import Base: getindex, setindex!, size, IndexStyle
    function getnode(CL::List, i::Int)
        node = head(CL)
        forward_steps = mod(i-1, length(CL))
        if forward_steps == 0
            return node
        end
        backward_steps = abs(mod(i-1, -length(CL)))
        if forward_steps <= backward_steps
            for i=1:forward_steps
                node = node.next
            end
        else
            for i=1:backward_steps
                node = node.prev
            end
        end
        node
    end
    function getindex(CL::List, i::Int)
        node = getnode(CL, i)
        node.data
    end
    function getindex(CL::List, r::UnitRange{T}) where T
        out = Vector{T}( undef, length(r) )
        node = getnode( CL, first(r) )
        for i=1:length(r)
            out[i] = node.data
            node = node.next
        end
        out
    end
    function getindex(CL::List, I::Int...)
        if length(I) == 0
            CL.current
        else
            getindex(CL, I[1])
        end
    end
    function setindex!(CL::List{T}, v, i::Int) where T
        node = getnode(CL, i)
        node.data = v
    end
    function setindex!(CL::List{T}, v, r::UnitRange{S}) where {T, S}
        node = getnode(CL, first(r))
        for i=1:length(r)
            node.data = v[ mod1(i, length(v) ) ]
            node = node.next
        end
    end
    function insert!(CL::List{T}, i::Integer, item) where {T}
        current = CL.current
        jump!( CL, getnode(CL,i-1) )
        insert!(CL, item)
        CL.current = current
        CL
    end
    function insert!(CL::List{T}, i::Integer, items::AbstractVector{S}) where {T,S}
        current = CL.current
        jump!( CL, getnode(CL,i-1) )
        for item in items
            insert!(CL, convert(T,item))
        end
        CL.current = current
        CL
    end
    import Base: copy
    function copy(CL::List{T}) where {T}
        List{T}(CL.nodes, CL.current, CL.length, CL.last, CL.capacity)
    end
    function deleteat!(CL::List, i::Integer)
        current = CL.current
        jump!( CL, getnode( CL, i ) )
        delete!(CL)
        CL.current = current
        CL
    end
    function deleteat!(CL::List, r::UnitRange)
        current = CL.current
        jump!( CL, getnode( CL, last(r) ) )
        for i=1:length(r)
            delete!(CL)
        end
        # CL.current = current
        CL
    end
    function findfirst( predicate::Function, CL::List )
        current = CL.current
        node = current
        counter = 1
        while !predicate(node.data)
            node = node.next
            counter += 1
        end
        counter
    end

    # Node
    getindex(node::Node) = node.data


    # CircularArrayList
    export CircularListArray
    struct CircularListArray{T} <: AbstractArray{T,1}
        list::List{T}
    end
    CircularListArray(x...) = CircularListArray( circularlist(x...) )
    size(cla::CircularListArray) = size(cla.list)
    getindex(cla::CircularListArray, x) = getindex(cla.list, x)
    setindex!(cla::CircularListArray, v, i::Int) = setindex!(cla.list, v, i)
    setindex!(cla::CircularListArray, X, I::UnitRange) = setindex!(cla.list, X, I)
    IndexStyle(::CircularListArray) = IndexLinear()
    deleteat!(cla::CircularListArray, x) = deleteat!(cla.list, x)
    insert!(cla::CircularListArray, x...) = insert!(cla.list, x...)
    copy(cla::CircularListArray) = CircularListArray( copy(cla.list) )
    findfirst(predicate::Function, cla::CircularListArray) = findfirst( predicate, cla.list )
    

    function play( input = input_array , n = 100)
        select = 1
        #A = deepcopy(input)
        A = input
        min_cup = minimum(A)
        max_cup = maximum(A)

        # println(A)
        # println(typeof(A))

        for i=1:n
            if i % 100 == 0
                @info i
            end
            selected = select+1:select+3
            current = A[ select ]
            destination = current - 1
            snip = A[ selected ]
            deleteat!(A, selected)
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

    function part2( input = input_array)
        input = deepcopy( input )
        one_million = CircularListArray([input; maximum(input)+1:1_000_000])
        play( one_million , 10_000_000 )
        cup_1 = findfirst(A .== 1)
        println( A[cup_1+1:cup_1+2] )
    end
end