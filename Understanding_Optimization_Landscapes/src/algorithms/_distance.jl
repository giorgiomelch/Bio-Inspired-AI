function average_hamming_distance(population)
    population_size, number_of_genes = size(population)
    total_distance = 0
    count = 0
    for i in 1:population_size-1
        for j in i+1:population_size
            total_distance += sum(population[i, :] .!= population[j, :])
            count += 1
        end
    end
    return total_distance / count
end