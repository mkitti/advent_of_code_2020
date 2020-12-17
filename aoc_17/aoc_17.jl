module aoc_17
    using ImageFiltering

    const nhood_filter = setindex!( centered( ones(3,3,3) ) ,0,0,0,0 )
    const nhood_filter_4d = setindex!( centered( ones(3,3,3,3) ) ,0,0,0,0,0 )

    function read_input(filename, nd = 3)
        lines = readlines(filename)
        universe = permutedims(hcat(Vector{Char}.(lines)...)) .== '#'
        if nd == 3
            reshape(universe, ( size(universe)..., 1 ) )
        else nd == 4
            reshape(universe, ( size(universe)..., 1, 1 ) )
        end
    end

    remain_active(neighbors) = (neighbors .== 2) .| (neighbors .== 3)
    become_active(neighbors) = neighbors .== 3

    function step(universe)
        universe = padarray(universe, Fill(0, (1,1,1) ) )
        neighbors = imfilter(universe, nhood_filter, Fill(0))
        # If a cube is active and exactly 2 or 3 of its neighbors are also active, the cube remains active. Otherwise, the cube becomes inactive.
        active_state = copy(universe)
        inactive_state = .~active_state
        active = @view universe[ active_state ]
        inactive = @view universe[ inactive_state ]
        active .= remain_active( neighbors[ active_state ] )
        inactive .= become_active( neighbors[ inactive_state ] )
        compact(universe)
    end

    function compact(universe)
        e = extrema(findall(universe))
        v = view(universe, e[1][1]:e[2][1], e[1][2]:e[2][2], e[1][3]:e[2][3])
        copy(v)
    end

    function part1(universe = read_input("input.txt"))
        for i = 1:6
            universe = step(universe)
        end
        sum(universe)
    end

    # Part 2

    function step2(universe)
        universe = padarray(universe, Fill(0, (1,1,1,1) ) )
        neighbors = round.(imfilter(universe, nhood_filter_4d, Fill(0)))
        # If a cube is active and exactly 2 or 3 of its neighbors are also active, the cube remains active. Otherwise, the cube becomes inactive.
        active_state = copy(universe)
        inactive_state = .~active_state
        active = @view universe[ active_state ]
        inactive = @view universe[ inactive_state ]
        active .= remain_active( neighbors[ active_state ] )
        inactive .= become_active( neighbors[ inactive_state ] )
        compact2(universe)
    end

    function compact2(universe)
        e = extrema(findall(universe))
        # v = view(universe, e[1][1]:e[2][1], e[1][2]:e[2][2], e[1][3]:e[2][3], e[1][4]:e[2][4])
        v = view(universe, [a:b for (a,b) in zip(Tuple.(e)...)]...)
        copy(v)
    end

    function part2(universe = read_input("input.txt", 4); cycles = 6)
        for i = 1:cycles
            @info i
            universe = step2(universe)
        end
        sum(universe)
    end

     
end