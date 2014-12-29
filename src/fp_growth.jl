include("fp_tree.jl")

function gen_tree(T)
    N = []
    # TODO: Sort T
    K, V = Int64, Int64
    # Add null node
    n0 = FPTrees.FPTreeNode{K,V}(1,0)
    push!(N,n0)
    for t in T
        FPTrees.climb_grow(1,t,N,K,V)
    end
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

    gen_tree(T)
end
test()
