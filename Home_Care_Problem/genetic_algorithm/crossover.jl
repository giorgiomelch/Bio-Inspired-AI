function best_insertion(individual::Individual, patient::Patient, travel_times::Matrix{Float64})
    best_route = nothing
    best_cost = Inf
    for route in individual.routes
        for i in 1:(length(route.patients)+1)
            insert!(route.patients, i, patient)
            new_cost = sum(calculate_route_time(route, travel_times) for route in individual.routes)
            if new_cost < best_cost
                best_cost = new_cost
                ind_best_insertion = deepcopy(individual)
            end
            deleteat!(route.patients, i)
        end
    end
    return ind_best_insertion
end


function crossover(indA::Individual, indB::Individual)
    indA = deepcopy(indA)
    indB = deepcopy(indB)
    # select a random route from each individual
    routeA = indA.routes[rand(1:length(indA.routes))]
    routeB = indB.routes[rand(1:length(indB.routes))]
    # identify the patients in the selected routes
    patientsA = routeA.patients
    patientsB = routeB.patients
    # remove the patients from the routes
    routeA.patients = []
    routeB.patients = []
    # for each patient without a route find the best insertion 
    indA = best_insertion(indA, patientsB[1], travel_times)
    indB = best_insertion(indB, patientsA[1], travel_times)
    return indA, indB
end

function crossover_pop!(population::Population, travel_times::Matrix{Float64})
    # Ordina la popolazione per fitness
    sort!(population.individuals, by=i -> i.fitness)
    # Determina il numero di individui da mantenere per elitismo (10%)
    elite_count = max(1, Int(ceil(1 * population.N_POP))) 
    elite_individuals = population.individuals[1:elite_count]
    for ind in population.individuals
        
    end
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