using Random

function two_point_crossover(population::Matrix{Bool})
    num_individuals, num_genes = size(population)
    # Creiamo una nuova popolazione per contenere i figli
    offspring = Matrix{Bool}(undef, num_individuals, num_genes)
    # Copiamo la popolazione originale nella nuova matrice di offspring (per mantenere i genitori)
    offspring .= population
    
    # Mescola casualmente gli indici della popolazione per creare coppie casuali
    shuffle_idx = shuffle(1:num_individuals)
    
    for i in 1:2:(num_individuals-1)  # Iteriamo a coppie
        parent1, parent2 = shuffle_idx[i], shuffle_idx[i+1]
        
        # Seleziona due punti di crossover casuali
        point1, point2 = sort(rand(1:num_genes, 2))

        # Esegue il crossover scambiando le sezioni tra i due genitori
        offspring[parent1, point1:point2], offspring[parent2, point1:point2] =
            population[parent2, point1:point2], population[parent1, point1:point2]
    end
    
    # Ritorniamo la nuova popolazione, che contiene sia i genitori che i figli
    return offspring
end