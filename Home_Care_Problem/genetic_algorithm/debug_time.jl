function debug()
    a = load_home_care_problem("/home/giorgiomelch/BI_AI/workspace/genetic-algorithm/project2/data/train_1.json")
    pop = initialize_pop_random(a, N_POP)
    update_population_fitness!(pop, a)
    println("\n", pop.best_individual.fitness)
    apply_mutation!(pop, N_GEN_SWAP_MUTATION,N_GEN_INVERSION)
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

    cluster = cluster_pazienti(HCP.patients, HCP.nbr_nurses)
    println("\n", length(cluster))
    for c in cluster
        print(" - ", length(c))
    end
    println("\nNumero infermiere:", HCP.nbr_nurses)
    individual = cluster_initialize_individual(HCP.patients, HCP.nbr_nurses, HCP.depot.return_time, HCP.nurse.capacity)
    for (i, route) in enumerate(individual.routes)
        println("Infermiere $(route.nurse.id): Pazienti ", [p.id for p in route.patients])
    end

    knn_initialize_population(HCP, N_POP)

end