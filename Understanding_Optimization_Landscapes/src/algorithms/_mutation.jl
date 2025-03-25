function mutation_bit_flip!(population, bit_flip_probability)
    population_length, number_of_genes = size(population)
    for i in 1:population_length
        # Apply bit flip mutation with a given probability
        if rand() < bit_flip_probability
            gene_to_mutate = rand(1:number_of_genes)
            population[i, gene_to_mutate] = 1 - population[i, gene_to_mutate]
        end
    end
end