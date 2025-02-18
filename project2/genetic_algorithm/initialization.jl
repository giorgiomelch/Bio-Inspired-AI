using Random
function initialize_pop_random(problem::HomeCareRoutingProblem, N_POP::Int)
    individuals = Vector{Individual}()

    for _ in 1:N_POP
        curr_routes = Vector{Route}()
        for _ in 1:problem.nbr_nurses
            # Creiamo una route con il nurse assegnato e il tempo di ritorno al depot
            route = Route(problem.nurse, problem.depot.return_time)
            # Creiamo una copia dei pazienti e li mescoliamo per assegnazione casuale
            shuffled_patients = shuffle(problem.patients)

            total_demand = 0.0
            for patient in shuffled_patients
                if total_demand + patient.demand <= problem.nurse.capacity
                    push!(route.patients, patient)
                    total_demand += patient.demand
                end
            end
            push!(curr_routes, route)
        end
        individual = Individual(curr_routes)
        push!(individuals, individual)
    end

    # Determiniamo il miglior individuo iniziale (per ora, prendiamo il primo)
    best_individual = individuals[1]

    return Population(individuals, problem.nbr_nurses, best_individual)
end