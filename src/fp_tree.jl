module FPTrees

export FPTree, FPEmptyTree, FPTreeNode, haschild, growchild!

include( string(Pkg.dir(), "/DataStructures/src/tree.jl"))

abstract FPTree{K,V} <: Tree{K,V}

type FPEmptyTree{K,V} <: FPTree{K,V}
end

type FPTreeNode{K,V} <: FPTree{K,V}
    key::K
    name::V
    cnt::Int64
    children::Array{Any}

    function FPTreeNode(k,v)
        node = new(k,v,1)
        _arr = Array(Any,0)
        push!(_arr, FPEmptyTree{K,V}())
        node.children = _arr
        node
    end

    function FPTreeNode(k,v,c)
        node = new(k,v)
        cnt = 1
        if typeof(c) <: AbstractArray
            node.children = c
        else
            _arr = Array(Any,1)
            push!(_arr, c)
            node.children = _arr
        end
        node
    end
end

function haschild(idx,childname,N,K,V)
    if length(N[idx].children) < 1 return false; end
    for c in N[idx].children
        if !(typeof(c) <: FPEmptyTree{K,V}) && N[c].name == childname
            return true
        end
    end
    return false
end

function getchildindex(idx,childname,N,K,V)
    for c in N[idx].children
        if typeof(c) != FPEmptyTree{K,V} && N[c].name == childname
            return c
        end
    end
end

haschild(t) = ifelse(length(t.children) < 1,false,true)

function growchild!(idx, childlist::AbstractArray, N::AbstractArray, K::Any, V::Any)
    nchild = length(childlist)
    if nchild < 1 return
    else
        child_idx = length(N) + 1
        child_name = childlist[1]
        deleteat!(childlist,1)
        n = FPTreeNode{K,V}(child_idx, child_name)
        filter!(x -> !(typeof(x) <: FPEmptyTree{K,V}), N[idx].children)
        push!(N[idx].children, child_idx)
        push!(N, n)
    end
    growchild!(child_idx, childlist,N,K,V)
end

function climb_grow(idx, childlist, N, K, V)
    if isempty(childlist) return 1;end
    childname = childlist[1]
    if haschild(idx, childname, N,K,V)
        childindex = getchildindex(idx, childname,N,K,V)
        N[childindex].cnt += 1
        deleteat!(childlist,1)
        climb_grow(childindex, childlist, N, K, V)
    else growchild!(idx, childlist,N,K,V)
    end
end

end # End of module FPTrees
