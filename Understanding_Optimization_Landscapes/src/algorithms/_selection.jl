function tournament_selection(population, fitness, number_of_survivors, tournament_size)
    survivors_index = zeros(Int, number_of_survivors)
    for i in 1:number_of_survivors
        # Select a random subset from the population
        candidates = randperm(length(fitness))[1:tournament_size]
        # Find the individual with the maximum fitness among the candidates
        best_index = argmin(fitness[candidates])
        survivors_index[i] = candidates[best_index]
    end
    survivors = population[survivors_index, :]
    return survivors
end


function elitism(population, fitness, number_of_survivors)
    best_indices = sortperm(fitness, rev=true)[1:number_of_survivors]
    return population[best_indices, :], fitness[best_indices]
end
