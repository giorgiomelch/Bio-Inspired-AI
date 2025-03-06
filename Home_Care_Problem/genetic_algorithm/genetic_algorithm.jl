function mean_non_empty_routes(population::Population)
    total_non_empty_routes = sum(count(r -> !isempty(r.patients), ind.routes) for ind in population.individuals)
    return total_non_empty_routes / length(population.individuals)
end


function genetic_algorithm(
    problem::HomeCareRoutingProblem, N_POP::Int, 
    N_ITER::Int,
    TOURNAMENT_SIZE::Int,
    N_MOVE::Int64, N_SWAP::Int64, N_INVERSION::Int64, N_SHIFT::Int64, PERC_SPLIT_MUTATION::Float64)
    
    # VARIABILI PER ADAPTIVE MUTATION
    N_MOVE_CURR = N_MOVE
    N_SWAP_CURR = N_SWAP
    N_INVERSION_CURR = N_INVERSION
    N_SHIFT_CURR = N_SHIFT
    PERC_SPLIT_MUTATION_CURR = PERC_SPLIT_MUTATION
    fitness_history = []

    #population = knn_initialize_population(problem, N_POP, 10)
    population = mixed_initialize_population(problem, N_POP, 10)
    update_population_fitness!(population, problem)

    for iter in 1:N_ITER 
        if iter % 2 == 0
            println("--------------------")
            println("Iterazione: ", iter)
            println("Mean fitness: ", population.mean_fitness[end])
            println("Best fitness: ", population.best_individual.fitness, ", feasible: ", population.best_individual.feasible)
            
            capacity_respected = all(route -> route.capacity_respected, population.best_individual.routes)
            time_windows_respected = all(route -> route.time_windows_respected, population.best_individual.routes)
            return_time_respected = all(route -> route.is_back_before_return_time, population.best_individual.routes)
            println("All routes respect capacity: ", capacity_respected)
            println("All routes respect time windows: ", time_windows_respected, ", number of violations: ", count(route -> !route.time_windows_respected, population.best_individual.routes))
            println("All routes return before the maximum time: ", return_time_respected)
            println("media rotte non vuote: ", mean_non_empty_routes(population))

            #plot_routes(problem.depot, population.best_individual.routes)
        end
        # CROSSOVER
        crossover_pop!(population, problem.travel_times)
        # MUTATION
        #adaptive_mutation!(fitness_history,
        #    N_MOVE, N_SWAP, N_INVERSION, N_SHIFT, PERC_SPLIT_MUTATION,
        #    N_MOVE_CURR, N_SWAP_CURR, N_INVERSION_CURR, N_SHIFT_CURR, PERC_SPLIT_MUTATION_CURR)
        apply_mutation!(population, N_MOVE_CURR, N_SWAP_CURR, N_INVERSION_CURR, N_SHIFT_CURR, PERC_SPLIT_MUTATION_CURR)
        update_population_fitness!(population, problem)
        # SURVIVORS SELECTION
        elitism_tournament_survivor_selection!(population, TOURNAMENT_SIZE)
        # MAPPA I PROGRESSI
        push_mean_fitness!(population)
        push_min_fitness!(population)
        push!(fitness_history, population.mean_fitness[end])
    end
    plot_routes(problem.depot, population.best_individual.routes)
    plot_fitness_evolution(population)
    return population.best_individual
end
