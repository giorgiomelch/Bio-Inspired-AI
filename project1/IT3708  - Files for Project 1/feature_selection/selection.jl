function tournament_selection(fitness::Vector{Float64}, num_parents::Int64, tournament_size::Int64)
    parents = Vector{Int}(undef, num_parents)
    for i in 1:num_parents
        # Seleziona un sottoinsieme casuale della popolazione
        candidates = rand(1:length(fitness), tournament_size)
        # Trova l'individuo con il fitness massimo tra i candidati
        best_candidate = argmin(fitness[candidates])
        parents[i] = candidates[best_candidate]
    end
    return parents
end

function roulette_wheel_selection(fitness_values::Vector{Float64}, num_parents::Int64)
    num_parents = min(num_parents, length(fitness_values))  # Evita problemi di overflow
    total_fitness = sum(fitness_values)
    probabilities = fitness_values ./ total_fitness  # Normalizzazione

    cumulative_probabilities = cumsum(probabilities)
    sub_set = Int[]  # Lista vuota di interi
    
    while length(sub_set) < num_parents
        r = rand()
        for (i, cp) in enumerate(cumulative_probabilities)
            if r <= cp && !(i in sub_set)
                push!(sub_set, i)
                break  # Esci dal loop una volta trovato un individuo
            end
        end
    end
    
    return sub_set
end

function elitism(fitness::Vector{Float64}, num_parents::Int64)
    # Ordina i fitoness in ordine decrescente e seleziona i migliori
    best_indices = sortperm(fitness, rev=false)[1:num_parents]
    return best_indices
end
