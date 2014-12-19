using Base.Test
include("apriori.jl")

minsupp = 0.6
T = Array(Array{Int64,1},5)
T[1] = [1,2]
T[2] = [1,3,4,5]
T[3] = [2,3,4,6]
T[4] = [1,2,3,4]
T[5] = [1,2,3,6]

@test_approx_eq σ([2,3,4],T) 2
@test_approx_eq supp([2,3],4,T) 0.4
@test_approx_eq_eps conf([2,3],4,T) 0.67 1e-2

F₂ = Array(Array{Int64,1},4)
F₂[1] = [3,4]
F₂[2] = [1,3]
F₂[3] = [1,2]
F₂[4] = [2,3]
@test length(gen_candidate(F₂)) == 1
@test gen_candidate(F₂)[1] == [1,2,3]

F = find_freq_itemset(T, minsupp)
@test length(F) == 2
@test Set(F[1]) == Set([1],[2],[3],[4])
@test Set(F[2]) == Set([3,4],[1,3],[1,2],[2,3])
