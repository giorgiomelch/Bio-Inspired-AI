using Random

function order1_crossover(parent1::Individual, parent2::Individual)
    # Estrai la sequenza di pazienti da entrambi i genitori
    p1_patients = parent1.route.patients
    p2_patients = parent2.route.patients
    
    if length(p1_patients) != length(p2_patients)
        error("I genitori devono avere lo stesso numero di pazienti")
    end
    
    n = length(p1_patients)
    
    # Seleziona un segmento casuale
    start_idx = rand(1:n)
    end_idx = rand(start_idx:n)
    
    # Copia la sottosequenza dal primo genitore
    child_patients = fill(nothing, n)
    child_patients[start_idx:end_idx] = p1_patients[start_idx:end_idx]
    
    # Riempie gli slot vuoti mantenendo l'ordine dal secondo genitore
    idx = 1
    for p in p2_patients
        if p ∉ child_patients
            while child_patients[idx] !== nothing
                idx += 1
            end
            child_patients[idx] = p
        end
    end
    
    # Crea un nuovo individuo figlio con la nuova route
    child_route = Route(parent1.route.nurse, parent1.route.depot_return_time)
    child_route.patients = child_patients
    
    return Individual(child_route)
end




























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