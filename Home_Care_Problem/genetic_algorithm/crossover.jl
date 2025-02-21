function order1_crossover_(individual1::Individual, individual2::Individual)
    # Step 1: Selezione casuale di una sottostringa
    num_routes = length(individual1.routes)
    start_idx = rand(1:num_routes)
    end_idx = rand(start_idx:num_routes)

    # Step 2: Copia la sottostringa nel figlio
    child_routes = deepcopy(individual1.routes[start_idx:end_idx])
    
    # Step 3: Creazione di una lista di pazienti già assegnati
    assigned_patients = Set{Int}(p.id for route in child_routes for p in route.patients)

    # Step 4: Riempimento con le route di individual2 rispettando l'ordine
    for route in individual2.routes
        new_route = Route(route.nurse, route.depot_return_time)
        for patient in route.patients
            if !(patient.id in assigned_patients)
                push!(new_route.patients, patient)
                push!(assigned_patients, patient.id)
            end
        end
        push!(child_routes, new_route)
    end

    # Step 5: Creazione del nuovo individuo e calcolo della fitness
    child = Individual(child_routes)
    return child
end
