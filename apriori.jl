# Find k-freq-itemset in given transactions of items queried together
using StatsBase
using Base.Test

# Support Count: σ(x) = | {tᵢ|x ⊆ tᵢ,tᵢ∈ T}|
function σ(x, T)
    ret = 0
    for t in T
        ⊆(x,t) && (ret += 1)
    end
    ret
end

# Support of itemset x -> y, which x does not intersect y.
supp(x,y,T) = σ(∪(x,y),T)/length(T)

# Confidence of itemset x-> y, which x does not intersect y.
conf(x,y,T) = σ(∪(x,y),T)/σ(x,T)

function _gen_dummy_data!(transactions)
    range = [1:10]
    for i in 1:length(transactions)
        transactions[i] = sample(range, sample(range, 1)[1], replace = false)
    end
    transactions
end

function find_freq_itemset(T, minsupp)
    N = length(T)

    # Find itemset I from transaction list T
    I = Array(Int64,0)
    for t in T
        for i in t
            push!(I,i)
        end
    end
    I = Set(I)

    # Find freq-itemset when k = 1: Fₖ = {i | i ∈ I^σ({i}) ≥ N × minsupp}
    k = 1
    F = []
    push!(F,map(x->[x],filter(i->σ(i,T) >= N * minsupp, I))) # F₁
    while true
        Cₖ = gen_candidate(F[end]) # Generate candidate set Cₖ from Fₖ₋₁
        @show Cₖ, σ(Cₖ[1],T)
        Fₖ = filter(c->σ(c,T) >= N * minsupp, Cₖ)
        @show Fₖ
        if !isempty(Fₖ)
            push!(F,Fₖ) # Eliminate infrequent candidates, then set to Fₖ
        else break
        end
    end
    F
end

function gen_candidate(x)
    n = length(x)
    Cₖ = Array(Array{Int64,1},0)
    for a = 1:n, b = 1:n
        if a >= b;continue
        end
        is_candidate = true
        sort!(x[a]); sort!(x[b])
        for i in 1:length(x[1])-1
            if x[a][i] == x[b][i]; continue
            else is_candidate = false; break
            end
        end
        if is_candidate
            push!(Cₖ, sort!([ x[a][1:end-1], x[a][end], x[b][end] ]))
        end
    end
    Cₖ
end
