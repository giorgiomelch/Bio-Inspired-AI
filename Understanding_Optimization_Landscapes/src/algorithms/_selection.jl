function tournament_selection(population, fitness, number_of_survivors, tournament_size)
    survivors_index = zeros(Int, number_of_survivors)
    for i in 1:number_of_survivors
        # Select a random subset from the population
        candidates = randperm(length(fitness))[1:tournament_size]
        # Find the individual with the minimum fitness among the candidates
        best_index = argmin(fitness[candidates])
        survivors_index[i] = candidates[best_index]
    end
    survivors = population[survivors_index, :]
    return survivors
end


function elitism(population, fitness, number_of_survivors)
    best_indices = sortperm(fitness, rev=false)[1:number_of_survivors]
    return population[best_indices, :], fitness[best_indices]
end

                            ############
                            ## NSGA2 ##
                            ############

function dominates(p::Int, q::Int, fitness::Vector{Float64}, n_feature_used::Vector{Int})
    le = (fitness[p] <= fitness[q]) && (n_feature_used[p] <= n_feature_used[q])
    lt = (fitness[p] < fitness[q]) || (n_feature_used[p] < n_feature_used[q])
    return le && lt
end
                            
function non_dominated_sort(fitness::Vector{Float64}, n_feature_used::Vector{Int})
    N = length(fitness)
    S = [Int[] for _ in 1:N]            # Per ciascun individuo, la lista degli indici che esso domina
    domination_count = zeros(Int, N)    # Numero di individui che dominano ciascun individuo
    fronts = Vector{Vector{Int}}()      # Lista dei front

    # Calcolo di S e domination_count
    for p in 1:N
        for q in 1:N
            if p == q
                continue
            end
            if dominates(p, q, fitness, n_feature_used)
                push!(S[p], q)
            elseif dominates(q, p, fitness, n_feature_used)
                domination_count[p] += 1
            end
        end
    end

    # Primo fronte: individui non dominati (domination_count == 0)
    front1 = [p for p in 1:N if domination_count[p] == 0]
    push!(fronts, front1)

    # Costruzione degli altri front
    i = 1
    while !isempty(fronts[i])
        next_front = Int[]
        for p in fronts[i]
            for q in S[p]
                domination_count[q] -= 1
                if domination_count[q] == 0
                    push!(next_front, q)
                end
            end
        end
        push!(fronts, next_front)
        i += 1
    end
    pop!(fronts)
    return fronts
end

# Funzione per calcolare la crowding distance di un fronte.
function crowding_distance(front::Vector{Int}, fitness_vector::Vector{Float64}, n_feature_used_vector::Vector{Int})
    distances = Dict{Int, Float64}()
    for i in front
        distances[i] = 0.0
    end

    objectives = [:fitness, :n_feature_used]
    for obj in objectives
        # Ordina il fronte in base al valore dell'obiettivo corrente
        sorted_indices = sort(front, by = i -> obj == :fitness ? fitness_vector[i] : n_feature_used_vector[i])
        distances[sorted_indices[1]] = Inf
        distances[sorted_indices[end]] = Inf
        if obj == :fitness
            min_val = fitness_vector[sorted_indices[1]]
            max_val = fitness_vector[sorted_indices[end]]
        else
            min_val = n_feature_used_vector[sorted_indices[1]]
            max_val = n_feature_used_vector[sorted_indices[end]]
        end
        range_val = max_val - min_val
        if range_val == 0
            range_val = 1  # Evita divisione per zero
        end
        # Calcola la distanza per i restanti individui
        for j in 2:(length(sorted_indices)-1)
            i_index = sorted_indices[j]
            if obj == :fitness
                diff = fitness_vector[sorted_indices[j+1]] - fitness_vector[sorted_indices[j-1]]
            else
                diff = n_feature_used_vector[sorted_indices[j-1]] - n_feature_used_vector[sorted_indices[j+1]]
            end
            distances[i_index] += diff / range_val
        end
    end

    # Ritorna le distanze rispettando l'ordine originale del fronte
    return [distances[i] for i in front]
end

function nsga_selection(population, accuracy_vector::Vector{Float64}, fitness_vector::Vector{Float64}, n_feature_used_vector::Vector{Int}, POPULATION_SIZE::Int)
    errors = 1 .-1 .* accuracy_vector
    fronts = non_dominated_sort(errors, n_feature_used_vector)
    survivors_indices = Int[]
    for front in fronts
        if length(survivors_indices) + length(front) ≤ POPULATION_SIZE
            append!(survivors_indices, front)
        else
            cd = crowding_distance(front, errors, n_feature_used_vector)
            front_cd = zip(front, cd)
            # Ordina il fronte in base alla crowding distance in ordine decrescente (priorità a quelli più distanti)
            sorted_front = sort(collect(front_cd), by = x -> x[2], rev = true)
            remaining = POPULATION_SIZE - length(survivors_indices)
            selected = [x[1] for x in sorted_front[1:remaining]]
            append!(survivors_indices, selected)
            break
        end
    end
    new_population = population[survivors_indices, :]
    new_accuracy = accuracy_vector[survivors_indices]
    new_fitness = fitness_vector[survivors_indices]
    new_n_feature_used = n_feature_used_vector[survivors_indices]
    return new_population, new_accuracy, new_fitness, new_n_feature_used
end
