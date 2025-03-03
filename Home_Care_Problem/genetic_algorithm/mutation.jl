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
function mutation_inversion!(individual::Individual, N_GEN_INVERSION::Int64)
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

function mutation_inversion2!(individual::Individual, N_GEN_INVERSION::Int64)
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
                            #aggiungi paziente a route_to 
                            # Se route_to è vuoto, inserisci in posizione 1
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


function apply_mutation!(population::Population, 
    N_GEN_SWAP_MUTATION::Int64, N_GEN_INVERSION::Int64, N_GEN_SHIFT::Int64)
    for individual in population.individuals
        mutation_swap!(individual, N_GEN_SWAP_MUTATION)
        mutation_inversion!(individual, N_GEN_INVERSION)
        mutation_shift!(individual, N_GEN_SHIFT)
        #mutation_split!(individual, N_GEN_SHIFT, 1.0)
    end
end