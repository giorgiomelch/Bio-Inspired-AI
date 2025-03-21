function initialize_random_population(population_size, number_of_genes)
    return rand(0:1, population_size, number_of_genes)
end