function genetic_algorithm(
    problem::HomeCareRoutingProblem, N_POP::Int, POP_REPLACEMENT::Float64, 
    N_ITER::Int,
    TOURNAMENT_SIZE::Int,
    N_GEN_SWAP_MUTATION::Int64, N_GEN_INVERSION::Int64, N_GEN_SHIFT::Int64)

    population = knn_initialize_population(problem, N_POP)
    #population = initialize_pop_random(problem, N_POP)
    update_population_fitness!(population, problem)
    for _ in 1:N_ITER 
        #SELZIONE GENITORI PER CROSSOVER
        #N_gen_selected = Int(N_POP*POP_REPLACEMENT)
        #indi = tournament_selection(population, N_gen_selected, TOURNAMENT_SIZE)
        # TO DO - CROSSOVER - TO DO
        # crossover!(indi)
        # aggiungi i figli alla popolazione
        #MUTAZIONE
        apply_mutation!(population, N_GEN_SWAP_MUTATION, N_GEN_INVERSION, N_GEN_SHIFT)
        update_population_fitness!(population, problem)
        #SELEZIONE SURVIVORS
        elitism!(population)
        
        # MAPPA I PROGRESSI
        push_mean_fitness!(population)
        push_min_fitness!(population)
    end
    plot_routes(problem.depot, population.best_individual.routes)
    plot_fitness_evolution(population)
end