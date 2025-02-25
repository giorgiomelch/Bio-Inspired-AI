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