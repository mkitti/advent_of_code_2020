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
    function getindex(CL::List{T}, r::UnitRange) where T
        n = length(r)
        nodes = Vector{Node{T}}( undef, n )
        nodes[1] = getnode( CL, first(r) )
        for i=2:n
            nodes[i] = nodes[i-1].next
        end
        sublist = List{T}(nodes, nodes[1], n, n, n)
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
    "Insert items::List{T} such that the items.node[1] is at index i"
    function insert!(CL::List{T}, i::Integer, items::List{T}) where T
        insert!(CL, getnode( CL, i - 1), items)
    end
    "Insert items::List{T} after node"
    function insert!(CL::List{T}, node::Node{T}, items::List{T}) where T
        # No allocations needed!
        #current = CL.current
        #jump!( CL, getnode(CL,i-1) )
        if node in items.nodes
            error("Cannot insert items into themselves")
        end

        # Remove snippet from where it came from first
        source_prev = items.nodes[1].prev
        source_next = items.nodes[end].next

        # Link old ends
        source_prev.next = source_next
        source_next.prev = source_prev

        # Identify nodes at target
        # We must do this at the beginning
        target_prev = node 
        target_next = target_prev.next

        # Connect beginning of insert
        target_prev.next = items.nodes[1]
        items.nodes[1].prev = target_prev

        # Connect end of insert
        items.nodes[end].next = target_next
        target_next.prev = items.nodes[end]

        # Reset head node to where it was
        #CL.current = current
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
    function getindex(node::Node, i::Int)
        i -= 1
        if i >= 0
            for i=1:i
                node = node.next
            end
        else
            for i=1:abs(i)
                node = node.prev
            end
        end
        node
    end
    function getindex(node::Node, r::UnitRange)
        node = node[ first(r) ]
        collect( Iterators.take(node, length(r)) )
    end
    import Base: iterate, eltype, IteratorSize
    function iterate(node::Node, state = node)
        (state, state.next)
    end
    eltype(::Type{Node{T}}) where T = Node{T}
    IteratorSize(::Type{Node{T}}) where T = Base.IsInfinite()