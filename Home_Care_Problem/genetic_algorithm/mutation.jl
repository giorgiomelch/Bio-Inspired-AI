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

function mutation_shift!(individual::Individual, N_GEN_SHIFT::Int64)
    n_routes = length(individual.routes)
    for _ in 1:N_GEN_SHIFT
        if n_routes > 1
            # Seleziona due route diverse
            selected_routes = sample(individual.routes, 2, replace=false)
            route_from = selected_routes[1]
            route_to = selected_routes[2]
            # Assicurati che la route di partenza abbia almeno un paziente da spostare
            if !isempty(route_from.patients)
                # Seleziona un paziente casuale
                patient_index = rand(1:length(route_from.patients))
                patient = popat!(route_from.patients, patient_index)  # Rimuovi paziente
                # Aggiungi il paziente alla nuova route in una posizione casuale
                insert!(route_to.patients, rand(1:length(route_to.patients)+1), patient)
            end
        end
    end
end

function apply_mutation!(population::Population, 
    N_GEN_SWAP_MUTATION::Int64, N_GEN_INVERSION::Int64, N_GEN_SHIFT::Int64)
    for individual in population.individuals
        mutation_swap!(individual, N_GEN_SWAP_MUTATION)
        mutation_inversion!(individual, N_GEN_INVERSION)
        mutation_shift!(individual, N_GEN_SHIFT)
    end
end
