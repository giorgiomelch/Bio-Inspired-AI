function remove_patients!(individual::Individual, patients::Vector{Patient})
    for route in individual.routes
        route.patients = filter(p -> !(p in patients), route.patients)
    end
end

function best_insertion(individual::Individual, patient::Patient, travel_times::Matrix{Float64})
    best_individual = deepcopy(individual)  # Copia dell'individuo di partenza
    best_cost = Inf
    for route_idx in 1:length(individual.routes)
        route_curr = individual.routes[route_idx]
        for i in 1:(length(route_curr.patients) + 1)
            # Creiamo una copia dell'intero individuo e della rotta
            temp_individual = deepcopy(individual)
            temp_route = deepcopy(temp_individual.routes[route_idx])
            # Inseriamo il paziente nella copia
            insert!(temp_route.patients, i, patient)
            temp_individual.routes[route_idx] = temp_route
            # Ricalcoliamo il costo dopo l'inserimento
            new_cost = sum(calculate_route_time(r, travel_times) for r in temp_individual.routes)
            # Se il nuovo costo è migliore, aggiorniamo il miglior individuo
            if new_cost < best_cost
                best_cost = new_cost
                best_individual = deepcopy(temp_individual)
            end
        end
    end
    return best_individual
end


function crossover(offA::Individual, offB::Individual, travel_times::Matrix{Float64})
    #create the offsprings
    offA = deepcopy(offA)
    offB = deepcopy(offB)
    # select a random route from each individual
    dacanc1=rand(1:length(offA.routes))
    #println(dacanc1)
    dacanc2=rand(1:length(offB.routes))
    #println(dacanc2)
    routeA = offA.routes[dacanc1]
    routeB = offB.routes[dacanc2]
    # Identify the patients
    patientsA = copy(routeA.patients)
    patientsB = copy(routeB.patients)
    # remove the patients selected from Individual B in Individual A
    remove_patients!(offA, patientsB)
    remove_patients!(offB, patientsA)
    # for each patient without a route find the best insertion 
    for patient in patientsA
        offB = best_insertion(offB, patient, travel_times)
    end
    for patient in patientsB
        offA = best_insertion(offA, patient, travel_times)
    end
    return offA, offB
end

function crossover_pop!(population::Population, travel_times::Matrix{Float64})
    # Ordina la popolazione per fitness
    sort!(population.individuals, by=i -> i.fitness)
    population.individuals = deepcopy(population.individuals[1:population.N_POP])
    shuffle!(population.individuals)
    new_individuals = Individual[]  
    for i in 1:2:length(population.individuals)-1
        parent1 = population.individuals[i]
        parent2 = population.individuals[i+1]
        child1, child2 = crossover(parent1, parent2, travel_times)

        push!(new_individuals, child1, child2)
    end
    # Aggiungiamo i nuovi individui alla popolazione
    append!(population.individuals, new_individuals)
end