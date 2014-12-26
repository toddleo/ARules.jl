module FPTrees

export FPTree, FPEmptyTree, FPTreeNode

include( string(Pkg.dir(), "/DataStructures/src/tree.jl"))

abstract FPTree{K,V} <: Tree{K,V}

type FPEmptyTree{K,V} <: FPTree{K,V}
end

type FPTreeNode{K,V} <: FPTree{K,V}
    key::K
    data::V
    children::Array{Any}

    function FPTreeNode(k,v)
        node = new(k,v)
        _arr = Array(Any,1)
        push!(_arr, FPEmptyTree{K,V}())
        node.children = _arr
        node
    end

    function FPTreeNode(k,v,c)
        node = new(k,v)
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

end # End of module FPTrees
