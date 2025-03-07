function elitism!(population::Population)
    # Ordina la popolazione in base al fitness
    sort!(population.individuals, by = x -> x.fitness)
    # scarta i peggiori individui
    population.individuals = population.individuals[1:population.N_POP]
end

function tournament_selection(population::Population, num_selected::Int, tournament_size::Int)
    selected = Vector{Individual}()
    for _ in 1:num_selected
        # Seleziona casualmente un sottoinsieme della popolazione
        tournament = rand(population.individuals, tournament_size)
        # Sceglie il migliore nel torneo
        best = sort(tournament, by=i -> i.fitness)[1]
        push!(selected, deepcopy(best))
    end
    return selected
end

function elitism_tournament_survivor_selection!(population::Population, tournament_size::Int)
    # Ordina la popolazione per fitness
    sort!(population.individuals, by=i -> i.fitness)
    # Determina il numero di individui da mantenere per elitismo (10%)
    elite_count = max(1, Int(ceil(0.1 * population.N_POP)))
    elite_individuals = population.individuals[1:elite_count]
    # Selezione torneo per il resto della popolazione
    remaining_count = population.N_POP - elite_count
    tournament_winners = tournament_selection(population, remaining_count, tournament_size)
    population.individuals = vcat(elite_individuals, tournament_winners)
end
