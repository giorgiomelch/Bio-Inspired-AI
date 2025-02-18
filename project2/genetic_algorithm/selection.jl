function elitism!(population::Population)
    # Ordina la popolazione in base al fitness
    sort!(population.individuals, by = x -> x.fitness)
    # scarta i peggiori individui
    population.individuals = population.individuals[1:population.N_POP]
end

function tournament_selection(population::Population, num_survivors::Int, tournament_size::Int)
    survivors = Vector{Individual}(undef, num_survivors)
    for i in 1:num_survivors
        # Seleziona un sottoinsieme casuale di individui
        candidates_indices = randperm(population.N_POP)[1:tournament_size]
        individuals_in_tournament = [population.individuals[idx] for idx in candidates_indices]
        # Trova l'individuo con il fitness massimo
        best_individual = argmax(ind -> ind.fitness, individuals_in_tournament)
        # Aggiungi il miglior individuo alla lista dei genitori
        survivors[i] = best_individual
    end
    
    return survivors
end

