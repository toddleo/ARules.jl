abstract FPTree

type FPEmptyNode <: FPTree end

type FPTreeNode <: FPTree
    key::Int64 # I thought Generic Types should be used here, but it is much more harder to implement than I expected
    name::Int64
    cnt::Int64
    parent::Int64
    children::Array{Int64}

    function FPTreeNode(k,v)
        node = new(k,v,1,0)
        node.children = Array(Int64,0)
        node
    end

    function FPTreeNode(k,v,p)
        node = new(k,v,1,p)
        node.children = Array(Int64,0)
        node
    end

    function FPTreeNode(k,v,p,c)    for i in remove_idx
        N = FPTrees.remove_node(i,N)
    end
        node = new(k,v,1,p)
        if typeof(c) <: Array{Int64}
            node.children = c
        else
            node.children = Array(Int64,0)
        end
        node
    end
end

function haschild(idx,childname,N)
    if length(N[idx].children) < 1 return false; end
    for c in N[idx].children
        if !isempty(c) && N[c].name == childname
            return true
        end
    end
    return false
end

function getchildindex(idx,childname,N)
    for c in N[idx].children
        if !isempty(c) && N[c].name == childname
            return c
        end
    end
end

haschild(t) = ifelse(length(t.children) < 1,false,true)

function growchild!(idx, childlist::AbstractArray, N::AbstractArray)
    nchild = length(childlist)
    if nchild < 1 return
    else
        child_idx = length(N) + 1
        child_name = childlist[1]
        deleteat!(childlist,1)
        n = FPTreeNode(child_idx, child_name, idx)
        filter!(x -> !isempty(x), N[idx].children)
        push!(N[idx].children, child_idx)
        push!(N, n)
    end
    growchild!(child_idx, childlist,N)
end

function climb_grow(idx, childlist, N)
    if isempty(childlist) return 1;end
    childname = childlist[1]
    if haschild(idx, childname, N)
        childindex = getchildindex(idx, childname,N)
        N[childindex].cnt += 1
        deleteat!(childlist,1)
        climb_grow(childindex, childlist, N)
    else growchild!(idx, childlist,N)
    end
end

# Climb down from tree node to root, and record the path
function climb_down!(idx, N, path)
    idx == 0 && return path
    push!(path, idx)
    climb_down!(N[idx].parent, N, path)
end

function remove_node(idx, N)
    _N = Array(FPTree,0)
    for n in N
        n.key == idx && continue
        n.parent == idx && (n.parent = 1) # if parent node is going to be removed, set root(null) node as parent
        if !isempty(n.children)
            _children = Array(Int64, 0)
            for i in 1:length(n.children)
                if n.children[i] != idx
                    push!(_children, n.children[i])
                end
            end
            n.children = _children
        end
        push!(_N, n)
    end
    _N
end

# Get a certain node by its key
function getnode(idx::Int64,N::Array{FPTree})
    for n in N
        if n.key == idx return n
        end
    end
    throw(BoundsError())
end
