using HypothesisTests

function adaptive_mutation!(fitness_history, 
    N_MOVE::Int64, N_SWAP::Int64, N_INVERSION::Int64, N_SHIFT::Int64, PERC_SPLIT_MUTATION::Float64,
    N_MOVE_CURR::Int64, N_SWAP_CURR::Int64, N_INVERSION_CURR::Int64, N_SHIFT_CURR::Int64, PERC_SPLIT_MUTATION_CURR::Float64)

    if length(fitness_history) >= 12  # Almeno 12 iterazioni per avere due blocchi di 6
        old_fitness = fitness_history[1:6]
        new_fitness = fitness_history[7:12]
        old_fitness = Float64.(old_fitness)
        new_fitness = Float64.(new_fitness)
        p_value = pvalue(OneSampleTTest(old_fitness, new_fitness))
        if p_value > 0.05
            N_MOVE_CURR *=2
            N_SWAP_CURR *= 2
            N_INVERSION_CURR *= 2
            N_SHIFT_CURR *= 2
            PERC_SPLIT_MUTATION_CURR *= 2
        else
            N_MOVE_CURR = N_MOVE
            N_SWAP_CURR = N_SWAP
            N_INVERSION_CURR = N_INVERSION
            N_SHIFT_CURR = N_SHIFT
            PERC_SPLIT_MUTATION_CURR = PERC_SPLIT_MUTATION
        end
        popfirst!(fitness_history)
    end
end

function mutation_move!(individual::Individual, N_GEN_MOVE_MUTATION::Int64)
    n_routes = length(individual.routes)
    for _ in 1:N_GEN_MOVE_MUTATION
        route = individual.routes[rand(1:n_routes)]
        if length(route.patients) > 2
            i = rand(1:length(route.patients)) # Scegli un paziente a caso
            j = rand(setdiff(1:length(route.patients), i)) # Scegli una nuova posizione diversa da i
            # Rimuovi il paziente dalla posizione originale e reinseriscilo in j
            patient = popat!(route.patients, i)
            insert!(route.patients, j, patient)
        end
    end
end

function mutation_swap!(individual::Individual, N_GEN_SWAP_MUTATION::Int64)
    n_routes = length(individual.routes)
    for _ in 1:N_GEN_SWAP_MUTATION
        #scegli una rotta a caso
        route = individual.routes[rand(1:n_routes)]
        if length(route.patients) > 2
            #cambia due pazienti di posto
            i, j = randperm(length(route.patients))[1:2] # [1:2] evita i=j
            route.patients[i], route.patients[j] = route.patients[j], route.patients[i]
        end
    end
end
function mutation_inversion_old!(individual::Individual, N_GEN_INVERSION::Int64)
    n_routes = length(individual.routes)
    for _ in 1:N_GEN_INVERSION
        # Scegli una rotta a caso
        route = individual.routes[rand(1:n_routes)]
        if length(route.patients) >= 2
            # Seleziona un intervallo casuale e invertilo
            i, j = sort(rand(1:length(route.patients), 2)) 
            route.patients[i:j] = reverse(route.patients[i:j])
        end
    end
end

# esegui uno shuffle di un subset dei una rotta se time_windows_respected è false
function mutation_inversion!(individual::Individual, N_GEN_INVERSION::Int64)
    n_length = length(individual.routes)
    for _ in 1:N_GEN_INVERSION
        r_idxs = shuffle!(collect(1:n_length))
        mutation_done = false
        i = 1
        while !mutation_done && i < n_length
            r_id = r_idxs[i]
            route_curr = individual.routes[r_id]
            if length(route_curr.patients) >= 2 && !route_curr.time_windows_respected # Controlla se la route ha più di due pazienti e ha time_windows_respected false
                # Seleziona un intervallo casuale e invertilo
                i, j = sort(rand(1:length(route_curr.patients), 2)) 
                route_curr.patients[i:j] = reverse(route_curr.patients[i:j])
                mutation_done = true
                break
            end
            i += 1
        end
    end
end


# Esegue N_GEN_SHIFT mutazioni su un individuo modificando la disposizione dei pazienti tra le route
# verificando che il paziente che si sta spostando non sia messo in una route con nurse con capacità piena.
function mutation_shift!(individual::Individual, N_GEN_SHIFT::Int64)
    for _ in 1:N_GEN_SHIFT
        n_length = length(individual.routes)
        r_idxs = shuffle!(collect(1:n_length))
        mutation_done = false
        ind_from = 1
        while !mutation_done && ind_from < n_length
            r_id = r_idxs[ind_from]
            route_from = individual.routes[r_id]
            if !isempty(route_from.patients) # Controlla se la route ha pazienti da spostare
                patient_index = rand(1:length(route_from.patients))
                patient = route_from.patients[patient_index]
                for ind_to in r_idxs
                    if !(r_id==ind_to)
                        route_to = individual.routes[ind_to]
                        if route_to.capacity_respected
                            #rimuovi paziente da route_from
                            popat!(route_from.patients, patient_index)
                            #aggiungi paziente a route_to, se route_to è vuoto, inserisci in posizione 1
                            insert_pos = isempty(route_to.patients) ? 1 : rand(1:length(route_to.patients) + 1)
                            insert!(route_to.patients, insert_pos, patient)
                            mutation_done = true
                            break
                        end
                    end
                end
            end
            ind_from += 1
        end
    end
end

function mutation_split!(individual::Individual, PROB_SPLIT::Float64)
    if rand() < PROB_SPLIT && length(filter(route -> length(route.patients) > 0, individual.routes)) < length(individual.routes)
        # Filtra le rotte non vuote e con più di 2 pazienti
        non_empty_long_routes = filter(route -> length(route.patients) > 2, individual.routes)
        route = non_empty_long_routes[rand(1:length(non_empty_long_routes))]
        if length(route.patients) > 2
            # Scegli un punto di divisione casuale (compreso tra 1 e length(patients)-1)
            split_point = rand(1:length(route.patients)-1)
            # Crea due nuove rotte
            route1_patients = route.patients[1:split_point]
            route2_patients = route.patients[split_point+1:end]
            # Crea due nuove rotte con la stessa infermiere, ma diverse sequenze di pazienti
            new_route1 = Route(route.nurse, route.depot_return_time)
            new_route2 = Route(route.nurse, route.depot_return_time)
            new_route1.patients = route1_patients
            new_route2.patients = route2_patients
            # Aggiungi le nuove rotte all'individuo
            push!(individual.routes, new_route1)
            push!(individual.routes, new_route2)
            # Rimuovi la rotta originale
            deleteat!(individual.routes, findfirst(x -> x == route, individual.routes))
            # Rimuovi una rotta vuota
            empty_index = findfirst(route -> isempty(route.patients), individual.routes)
            deleteat!(individual.routes, empty_index)
        end
    end
end


function apply_mutation!(population::Population, 
    N_MOVE::Int64, N_GEN_SWAP_MUTATION::Int64, N_GEN_INVERSION::Int64, N_GEN_SHIFT::Int64, PERC_SPLIT_MUTATION::Float64)
    for individual in population.individuals
        mutation_move!(individual, N_MOVE)
        mutation_swap!(individual, N_GEN_SWAP_MUTATION)
        mutation_inversion!(individual, N_GEN_INVERSION)
        mutation_shift!(individual, N_GEN_SHIFT)
        mutation_split!(individual, PERC_SPLIT_MUTATION)
    end
end