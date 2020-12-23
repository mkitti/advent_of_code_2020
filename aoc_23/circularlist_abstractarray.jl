    import CircularList: List, Node
    import Base: getindex, setindex!, size, IndexStyle, copy
    import Base: deleteat!, insert!, findfirst
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
    function findfirstnode( predicate::Function, CL::List )
        current = CL.current
        node = current
        while !predicate(node.data)
            node = node.next
        end
        node
    end

    # Node
    getindex(node::Node) = node.data