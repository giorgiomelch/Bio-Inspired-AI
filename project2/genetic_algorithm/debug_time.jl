function debug()
    a = load_home_care_problem("/home/giorgiomelch/BI_AI/workspace/genetic-algorithm/project2/data/train_1.json")
    pop = initialize_pop_random(a, N_POP)
    update_population_fitness!(pop, a)
    println("\n", pop.best_individual.fitness)
    apply_mutation!(pop, N_GEN_SWAP_MUTATION)
    update_population_fitness!(pop, a)
    println("\n", pop.best_individual.fitness)

    println("\n", length(pop.individuals))
    append!(pop.individuals, pop.individuals)
    println("\n", length(pop.individuals))

    elitism!(pop)
    println("\n", length(pop.individuals))

    indi = tournament_selection(pop, 250, 10)
    println("\n", length(indi))
    push_mean_fitness!(pop)
    push_min_fitness!(pop)
end