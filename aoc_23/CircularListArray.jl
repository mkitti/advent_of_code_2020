import Base: maximum, minimum, Fix2
export CircularListArray

# Implement interface functions directly on 
include("circularlist_abstractarray.jl")

struct CircularListArray{T} <: AbstractArray{T,1}
    list::List{T}
    dict::Dict{T,Node{T}}
end
function CircularListArray(x; capacity=length(x))
    list = circularlist(x; capacity=capacity)
    dict = Dict(zip(x, list.nodes))
    CircularListArray(list, dict)
end
size(cla::CircularListArray) = size(cla.list)
getindex(cla::CircularListArray, x) = getindex(cla.list, x)
setindex!(cla::CircularListArray, v, i::Int) = setindex!(cla.list, v, i)
setindex!(cla::CircularListArray, X, I::UnitRange) = setindex!(cla.list, X, I)
IndexStyle(::CircularListArray) = IndexLinear()
function deleteat!(cla::CircularListArray, x)
    pop!.((cla.dict,), cla.list[x])
    deleteat!(cla.list, x)
end
function insert!(cla::CircularListArray, i::Integer, x)
    # TODO move dict logic here
    insert!(cla.list, i, x)
end
function insert!(cla::CircularListArray{T}, node::Node{T}, x) where T
    insert!(cla.list, node, x)
    for i = 1:length(x)
        cla.dict[node.next.data] = node.next
        node = node.next
    end
end
copy(cla::CircularListArray) = CircularListArray(copy(cla.list))
function findfirst(predicate::Function, cla::CircularListArray)
    findfirst(predicate, cla.list)
end
function findfirstnode( predicate::Base.Fix2{F,X}, cla::CircularListArray) where {F, X}
    if predicate.f ∈ ( isequal, (==) ,(===) )
        node = cla.dict[ predicate.x ]
    else
        findfirst(predicate, cla.list)
    end
end
maximum(cla::CircularListArray) = maximum(cla.list)
minimum(cla::CircularListArray) = minimum(cla.list)