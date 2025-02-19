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
        if length(route.patients) > 2
            # Seleziona un intervallo casuale e invertilo
            i, j = sort(rand(1:length(route.patients), 2)) 
            route.patients[i:j] = reverse(route.patients[i:j])
        end
    end
end
function apply_mutation!(population::Population, N_GEN_SWAP_MUTATION::Int64, N_GEN_INVERSION::Int64)
    for individual in population.individuals
        mutation_swap!(individual, N_GEN_SWAP_MUTATION)
        mutation_inversion!(individual, N_GEN_INVERSION)
    end
end
