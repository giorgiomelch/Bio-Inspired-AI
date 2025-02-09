function hamming_distance(x::Vector{Bool}, y::Vector{Bool})
    return sum(x .≠ y)  # Conta i bit diversi
end

function mean_hamming_distance(population::Matrix{Bool})
    n = size(population, 1)  # Numero di individui
    total_distance = 0
    count = 0

    for i in 1:n, j in i+1:n  # Confronta ogni coppia una sola volta
        total_distance += hamming_distance(population[i, :], population[j, :])
        count += 1
    end

    return total_distance / count  # Media della distanza
end