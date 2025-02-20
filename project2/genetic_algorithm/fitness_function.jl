

function calculate_route_time(route, travel_times)
    total_time = 0.0
    is_feasible = true
    if !isempty(route.patients)
        nurse_capicity = route.nurse.capacity
        # Tempo di viaggio dal deposito al primo paziente
        first_patient = route.patients[1]
        total_time += travel_times[1, first_patient.id + 1] + first_patient.care_time
        # Itera sui pazienti della rotta
        for i in 2:length(route.patients)
            prev_patient = route.patients[i - 1]
            current_patient = route.patients[i]
            total_time += travel_times[prev_patient.id + 1, current_patient.id + 1] # Tempo di viaggio tra i pazienti
            total_time += current_patient.care_time # Tempo di cura del paziente corrente
            if total_time < current_patient.start_time || total_time > current_patient.end_time
                is_feasible = false
            end
            nurse_capicity -= current_patient.demand
            if nurse_capicity < 0
                is_feasible = false
            end
        end
        # Tempo di viaggio dall'ultimo paziente al deposito
        last_patient = route.patients[end]
        total_time += travel_times[last_patient.id + 1, 1]
        # PENALITA' SE I COSTRAINS NON SONO RISPETTATI
        if !is_feasible
            total_time *=1.5
        end
    end
    return total_time
end

function update_population_fitness!(population::Population, problem::HomeCareRoutingProblem)
    travel_times = problem.travel_times
    for individual in population.individuals
        individual.fitness = sum(calculate_route_time(route, travel_times) for route in individual.routes)
        if individual.fitness < population.best_individual.fitness # aggiorna se migliore
            population.best_individual = individual
        end
    end
end
