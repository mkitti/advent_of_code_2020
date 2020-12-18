module aoc_17
    using ImageFiltering
    using Test

    # Replaced by NeighborhoodFilter type below
    const nhood_filter = setindex!( centered( ones(3,3,3) ) ,0,0,0,0 )
    const nhood_filter_4d = setindex!( centered( ones(3,3,3,3) ) ,0,0,0,0,0 )

    function read_input(filename, nd = 3)
        lines = readlines(filename)
        universe = permutedims(hcat(Vector{Char}.(lines)...)) .== '#'
        reshape(universe, ( size(universe)..., ntuple(i->1, nd-2)... ) )
    end

    remain_active(neighbors) = (neighbors .== 2) .| (neighbors .== 3)
    become_active(neighbors) = neighbors .== 3

    function compact(universe)
        e = extrema(findall(universe))

        # 3D
        # v = view(universe, e[1][1]:e[2][1], e[1][2]:e[2][2], e[1][3]:e[2][3])
        # 4D
        # v = view(universe, e[1][1]:e[2][1], e[1][2]:e[2][2], e[1][3]:e[2][3], e[1][4]:e[2][4])

        # ND
        v = view(universe, [a:b for (a,b) in zip(Tuple.(e)...)]...)
        copy(v)
    end

    function part1(universe = read_input("input.txt",3) )
        simulate(universe, 6)[1]
    end

    function test1()
        @test simulate( read_input("demo.txt",3) , 6 )[1] == 112
    end

    function answer1()
        @test part1() == 322
    end

    # Part 2

    # === Begin NeighborhoodFilter type === #

    struct NeighborhoodFilter{N} <: AbstractArray{Float64,N}
        linear_center::UInt
        center::NTuple{N,UInt}
    end
    function NeighborhoodFilter{N}() where N
        linear_center = ceil(UInt,3^N/2)
        center = ntuple(i->UInt(0),N)
        NeighborhoodFilter{N}( linear_center, center )
    end

    import Base: size, getindex, axes
    size(f::NeighborhoodFilter{N}) where N = ntuple(i->3, N)
    getindex(f::NeighborhoodFilter{N}, i::Int) where N = f.linear_center == i ? 0 : 1
    getindex(f::NeighborhoodFilter{N}, I::Vararg{Int,N}) where N = I == f.center ? 0 : 1
    axes(f::NeighborhoodFilter{N}) where {N} = ntuple(i->-1:1,N)

    # === End NeighborhoodFilter type === #

    # n-Dimensional step
    function step(universe::BitArray{N}, make_compact = true) where {N}
        universe = padarray(universe, Fill(0, ntuple(i->1, N) ) )
        neighbors = round.(imfilter(universe, NeighborhoodFilter{N}(), Fill(0)))
        # If a cube is active and exactly 2 or 3 of its neighbors are also active, the cube remains active. Otherwise, the cube becomes inactive.
        active_state = copy(universe)
        inactive_state = .~active_state
        active = @view universe[ active_state ]
        inactive = @view universe[ inactive_state ]
        active .= remain_active( neighbors[ active_state ] )
        inactive .= become_active( neighbors[ inactive_state ] )
        if make_compact
            compact(universe)
        else
            universe
        end
    end

    function test2()
        @test simulate( read_input("demo.txt", 4), 6 )[1] == 848
    end

    function part2(universe = read_input("input.txt", 4); cycles = 6)
        simulate(universe, cycles)[1]
    end

    function answer2()
        @test part2() == 2000
    end

    function simulate(universe, cycles = 6)
        for i = 1:cycles
            @debug i
            universe = step(universe)
        end
        sum(universe), universe
    end

    function test()
        test1()
        answer1()
        test2()
        answer2()
    end

end