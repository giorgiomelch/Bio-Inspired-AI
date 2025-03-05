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
    new_individuals = Individual[]  # Nuova lista di individui generati

    for i in 1:2:length(population.individuals)-1
        parent1 = population.individuals[i]
        parent2 = population.individuals[i+1]

        # Generiamo due figli con crossover
        child1, child2 = crossover(parent1, parent2, travel_times)

        push!(new_individuals, child1, child2)
    end

    # Se la popolazione diventa più grande di N_POP, la riduciamo
    if length(new_individuals) > population.N_POP
        new_individuals = new_individuals[1:population.N_POP]
    end
    # Aggiungiamo i nuovi individui alla popolazione
    append!(population.individuals, new_individuals)
end


































































































function i1_i2_OX1(individual1::Individual, individual2::Individual)
    patients1 = [p for route in individual1.routes for p in route.patients]
    patients2 = [p for route in individual2.routes for p in route.patients]
    # Choose an arbitrary part from the first parent
    start_idx = rand(1:length(patients1))
    end_idx = rand(start_idx:length(patients1))
    part = patients1[start_idx:end_idx]
    # Create a set of patients that are already in the child
    assigned_patients = Set{Int}(p.id for p in part)
    # Create the child come lista di pazienti
    child_patients = deepcopy(part)
    # Add the remaining patients from the second parent
    for p in patients2
        if !(p.id in assigned_patients)
            push!(child_patients, p)
            push!(assigned_patients, p.id)
        end
    end
    # Crea un nuovo individuo figlio
    child = Individual(Vector{Route}())
    # Distribuisci i pazienti tra le route (stessa struttura del genitore 1)
    route_idx = 1
    for p in child_patients
        if route_idx > length(individual1.routes)
            route_idx = 1  # Ciclo tra le route se necessario
        end
        if length(child.routes) < route_idx
            push!(child.routes, Route(individual1.routes[route_idx].nurse, individual1.routes[route_idx].depot_return_time))
        end
        push!(child.routes[route_idx].patients, p)
        route_idx += 1
    end

    return child
end


function crossover_OX1(parents::Vector{Individual})
    nbr_offsprings = length(parents)
    offsprings = [Individual(Vector{Route}()) for _ in 1:nbr_offsprings]
    for i in 1:2:(length(parents)-1)
        figlio1 = i1_i2_OX1(parents[i], parents[i+1])
        figlio2 = i1_i2_OX1(parents[i+1], parents[i])
        offsprings[i] = figlio1
        offsprings[i+1] = figlio2
    end
    return offsprings
end