function tournament_selection(fitness::Vector{Float64}, num_parents::Int, tournament_size::Int)
    parents = Vector{Int}(undef, num_parents)
    for i in 1:num_parents
        # Seleziona un sottoinsieme casuale della popolazione
        candidates = rand(1:length(fitness), tournament_size)
        # Trova l'individuo con il fitness massimo tra i candidati
        best_candidate = argmax(fitness[candidates])
        parents[i] = candidates[best_candidate]
    end
    return parents
end

function elitism(fitness::Vector{Float64}, num_parents::Int64)
    # Ordina i fitoness in ordine decrescente e seleziona i migliori
    best_indices = sortperm(fitness, rev=true)[1:num_parents]
    return best_indices
end
