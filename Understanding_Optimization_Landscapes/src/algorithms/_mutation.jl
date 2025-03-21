function mutation_bit_flip!(population, bit_flip__probability)
    population_length, number_of_genes = size(population)
    # Iterate for every individual in the population
    for i in 1:population_length
        gene_to_mutate = rand(1:number_of_genes)
        # Apply bit flip mutation with a given probability
        if rand() < bit_flip__probability
            population[i, gene_to_mutate] = mod(population[i, gene_to_mutate] + 1, 1)
        end
    end
end