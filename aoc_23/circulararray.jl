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