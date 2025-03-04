function genetic_algorithm(
    problem::HomeCareRoutingProblem, N_POP::Int, 
    N_ITER::Int,
    TOURNAMENT_SIZE::Int,
    N_GEN_SWAP_MUTATION::Int64, N_GEN_INVERSION::Int64, N_GEN_SHIFT::Int64, PERC_SPLIT_MUTATION::Float64)

    population = knn_initialize_population(problem, N_POP, 10)
    
    update_population_fitness!(population, problem)
    for iter in 1:N_ITER 
        if iter % 100 == 0
            println("Iterazione: ", iter)
            println("Mean fitness: ", population.mean_fitness[end])
            println("Best fitness: ", population.best_individual.fitness, ", feasible: ", population.best_individual.feasible)
            #plot_routes(problem.depot, population.best_individual.routes)
        end
        #SELZIONE GENITORI PER CROSSOVER
        #N_gen_selected = Int(N_POP*POP_REPLACEMENT)
        #parents = tournament_selection(population, N_gen_selected, TOURNAMENT_SIZE)
        # CROSSOVER
        #offsprings = crossover_OX1(parents)
        # aggiungi i figli alla popolazione
        #append!(population.individuals, offsprings)
        #MUTAZIONE
        #append!(population.individuals, deepcopy(population.individuals))
        parents = deepcopy(population.individuals)
        apply_mutation!(population, N_GEN_SWAP_MUTATION, N_GEN_INVERSION, N_GEN_SHIFT, PERC_SPLIT_MUTATION)
        update_population_fitness!(population, problem)
        append!(population.individuals, parents)
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