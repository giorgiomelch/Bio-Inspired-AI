function genetic_algorithm(
    problem::HomeCareRoutingProblem, N_POP::Int, 
    N_ITER::Int,
    TOURNAMENT_SIZE::Int,
    N_GEN_SWAP_MUTATION::Int64, N_GEN_INVERSION::Int64, N_GEN_SHIFT::Int64, PERC_SPLIT_MUTATION::Float64)

    population = knn_initialize_population(problem, N_POP, 10)
    
    update_population_fitness!(population, problem)
    for iter in 1:N_ITER 
        if iter % 2 == 0
            println("Iterazione: ", iter)
            println("Mean fitness: ", population.mean_fitness[end])
            println("Best fitness: ", population.best_individual.fitness, ", feasible: ", population.best_individual.feasible)
            
            
            capacity_respected = all(route -> route.capacity_respected, population.best_individual.routes)
            time_windows_respected = all(route -> route.time_windows_respected, population.best_individual.routes)
            return_time_respected = all(route -> route.is_back_before_return_time, population.best_individual.routes)
            println("Tutte le rotte rispettano la capacità: ", capacity_respected)
            println("Tutte le rotte rispettano le finestre temporali: ", time_windows_respected)
            violations = count(route -> !route.time_windows_respected, population.best_individual.routes)
            println("Numero di rotte che violano le finestre temporali: ",violations)
            println("Tutte le rotte tornano prima del tempo massimo: ", return_time_respected)
    
            plot_routes(problem.depot, population.best_individual.routes)
        end
        # CROSSOVER
        crossover_pop!(population, problem.travel_times)
        #MUTAZIONE
        #parents = deepcopy(population.individuals)
        apply_mutation!(population, N_GEN_SWAP_MUTATION, N_GEN_INVERSION, N_GEN_SHIFT, PERC_SPLIT_MUTATION)
        update_population_fitness!(population, problem)
        #append!(population.individuals, parents)
        #SELEZIONE SURVIVORS
        elitism_tournament_survivor_selection!(population, TOURNAMENT_SIZE)
        # MAPPA I PROGRESSI
        push_mean_fitness!(population)
        push_min_fitness!(population)
    end
    plot_routes(problem.depot, population.best_individual.routes)
    plot_fitness_evolution(population)
    return population.best_individual
end