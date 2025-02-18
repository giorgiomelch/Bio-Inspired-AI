function mutation_swap!(individual::Individual, N_GEN_SWAP_MUTATION::Int)
    n_routes = length(individual.routes)
    for _ in 1:N_GEN_SWAP_MUTATION
        #scegli una rotta a caso
        route = individual.routes[rand(1:n_routes)]
        if length(route.patients) > 2
            #cambia due pazienti di posto
            i = rand(1:length(route.patients))
            j = rand(1:length(route.patients))
            route.patients[i], route.patients[j] = route.patients[j], route.patients[i]
        end
    end
end

function apply_mutation!(population::Population, N_GEN_SWAP_MUTATION::Int)
    for individual in population.individuals
        mutation_swap!(individual, N_GEN_SWAP_MUTATION)
    end
end
