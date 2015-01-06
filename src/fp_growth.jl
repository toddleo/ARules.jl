include("fp_tree.jl")

function gen_tree(T)
    N = Array(FPTree,0)
    # TODO: Sort T
    # Add null node
    n0 = FPTreeNode(0,0)
    push!(N,n0)
    for t in T
        climb_grow(0,t,N)
    end
#     @show N
    N
end

function test()
    T = Array(Array{Int64,1},10)
    T[1] = [1,2]
    T[2] = [2,3,4]
    T[3] = [1,3,4,5]
    T[4] = [1,4,5]
    T[5] = [1,2,3]
    T[6] = [1,2,3,4]
    T[7] = [1]
    T[8] = [1,2,3]
    T[9] = [1,2,4]
    T[10] = [2,3,5]
    N = gen_tree(T)
end

function fp_growth!(N, minsupp_cnt)
    # get itemset
    I = filter(n->n>0,unique(sort([Int64(n.name) for n in N])))
    # get the 1-consequent item. if the item is infrequent, find the preceding frequent item
    last_nodes = []
    while true
        last = pop!(I)
        last_nodes = filter(n->n.name==last && isempty(n.children), N)
        supp = 0
        for n in last_nodes
            supp += n.cnt
        end
        supp >= minsupp_cnt && break
        isempty(I) && error("No item is frequent enough in given transactions.")
    end
    # get path with the 1-consequent
    paths = []
    for l in last_nodes
        path = Array(Int64, 0)
        climb_down!(l.key,N,path)
        isempty(path) || push!(paths, path)
    end
    # prune items not in any path
    I = unique(sort(reduce(vcat,paths)))
    remove_idx = filter(i->!(i in I), map(i->i.key,N))
    for i in remove_idx
        N = remove_node(i,N)
    end
    cond_fp_tree(N, paths, minsupp_cnt)
end

function cond_fp_tree(N, paths, minsupp_cnt)
    last_item = 0
    # update support count on each path
    for n in N # set all count but last to 0
        isempty(n.children) || (n.cnt = 0)
    end
    for path in paths
        sort!(path)
        last_item == 0 && (last_item = getnode(path[end],N).name) # update last_item when not assigned
        for i in length(path)-1:-1:1
            getnode(path[i],N).cnt += getnode(path[i+1],N).cnt
        end
        N = remove_node(path[end],N)# remove the 1-consequent in paths
    end
    # prune the items that nolonger frequent
    item_cnt = Dict{Int64, Int64}()
    for n in N # collect item count
        haskey(item_cnt,n.name) || (item_cnt[n.name] = 0)
        item_cnt[n.name] += n.cnt
    end
    for (k,v) in item_cnt
        v < minsupp_cnt && delete!(item_cnt, k)
    end
    remove_idx = [n.key for n in filter(n->!(n.name in keys(item_cnt)) && n.name != 0,N)]
    for ridx in remove_idx # prune infrequent items
        N = remove_node(ridx,N)
    end
    candidates = []
    paths = []
    leaves = filter(n->isempty(n.children), N)
    isempty(leaves) && return candidates
    for l in leaves
        path = Array(Int64, 0)
        climb_down!(l.key,N,path)
        length(path) >= 2 && push!(paths, path)
    end
    paths
#     last_item
    # Extract frequent candidate
    for path in paths
        length(path) < 2 && continue
        push!(candidates, path[end-1:end])
        pop!(path)
    end


end

N = test()
#fp_growth!(N, 2)
