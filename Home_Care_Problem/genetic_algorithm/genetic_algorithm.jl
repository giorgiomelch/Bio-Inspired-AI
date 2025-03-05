function genetic_algorithm(
    problem::HomeCareRoutingProblem, N_POP::Int, 
    N_ITER::Int,
    TOURNAMENT_SIZE::Int,
    N_SWAP::Int64, N_INVERSION::Int64, N_SHIFT::Int64, PERC_SPLIT_MUTATION::Float64)
    
    #Variabili per adaptive mutation
    N_SWAP_CURR = N_SWAP
    N_INVERSION_CURR = N_INVERSION
    N_SHIFT_CURR = N_SHIFT
    PERC_SPLIT_MUTATION_CURR = PERC_SPLIT_MUTATION
    fitness_history = []

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
            println("Tutte le rotte rispettano le finestre temporali: ", time_windows_respected, ", n violazioni: ", count(route -> !route.time_windows_respected, population.best_individual.routes))
            println("Tutte le rotte tornano prima del tempo massimo: ", return_time_respected)
            
            #plot_routes(problem.depot, population.best_individual.routes)
        end
        # CROSSOVER
        crossover_pop!(population, problem.travel_times)
        #MUTAZIONE
        adaptive_mutation!(fitness_history, ADAPTIVE_MUT_THRESHOLD,
            N_SWAP, N_INVERSION, N_SHIFT, PERC_SPLIT_MUTATION,
            N_SWAP_CURR, N_INVERSION_CURR, N_SHIFT_CURR, PERC_SPLIT_MUTATION_CURR)
        apply_mutation!(population, N_SWAP_CURR, N_INVERSION_CURR, N_SHIFT_CURR, PERC_SPLIT_MUTATION_CURR)
        update_population_fitness!(population, problem)
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