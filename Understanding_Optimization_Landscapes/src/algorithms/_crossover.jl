function two_point_crossover(parents)
    number_of_individuals, number_of_genes = size(parents)
    # Creiamo una nuova popolazione per contenere i figli, inizializzata con i genitori
    offspring = copy(parents)
    # Mescoliamo casualmente gli indici per formare coppie di genitori
    shuffled_indices = shuffle(1:number_of_individuals)
    for i in 1:2:(number_of_individuals-1)  # Iteriamo a coppie
        parent1, parent2 = shuffled_indices[i], shuffled_indices[i+1]
        # Selezioniamo due punti di crossover in ordine crescente
        point1, point2 = sort(rand(1:number_of_genes, 2))
        # Scambiamo i segmenti tra i due genitori
        offspring[parent1, point1:point2], offspring[parent2, point1:point2] =
            offspring[parent2, point1:point2], offspring[parent1, point1:point2]
    end
    return offspring
end