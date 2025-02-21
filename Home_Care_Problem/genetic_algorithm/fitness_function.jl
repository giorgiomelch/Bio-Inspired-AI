function is_in_care_time_window(patient, current_time)
    return current_time >= patient.start_time && (current_time + patient.care_time) <= patient.end_time
end

function travel_from_Pa_to_Pb!(total_time, curr_time, patient_a, patient_b, travel_times)
    travel_time = travel_times[patient_a.id + 1, patient_b.id + 1]
    return total_time + travel_time, curr_time + travel_time
end
function travel_to_from_depot_time!(total_time, curr_time, patient, travel_times)
    travel_time = travel_times[1, patient.id + 1]
    return total_time + travel_time, curr_time + travel_time
end
function wait_to_care_time!(total_time, curr_time, patient)
    wait_time = max(0.0, patient.start_time - curr_time)
    return total_time + wait_time, curr_time + wait_time
end
function care_time!(total_time, curr_time, patient, nurse_capicity)
    total_time += patient.care_time
    curr_time += patient.care_time
    nurse_capicity -= patient.demand
    return total_time, curr_time, nurse_capicity
end

function calculate_route_time(route, travel_times)
    nurse_capicity = route.nurse.capacity
    curr_time = 0.0
    total_time = 0.0
    if !isempty(route.patients)
        # Tempo necessario dal deposito a cura del primo paziente
        total_time, curr_time = travel_to_from_depot_time!(total_time, curr_time, route.patients[1], travel_times)
        total_time, curr_time = wait_to_care_time!(total_time, curr_time, route.patients[1])
        route.feasible = is_in_care_time_window(route.patients[1], curr_time)
        total_time, curr_time, nurse_capicity = care_time!(total_time, curr_time, route.patients[1], nurse_capicity)
        if length(route.patients) > 1
            # Itera sulla lista di pazienti 
            for i in 2:length(route.patients) # paziente precedente: route.patients[i-1], paziente corrente: route.patients[i]
                total_time, curr_time = travel_from_Pa_to_Pb!(total_time, curr_time, route.patients[i-1], route.patients[i], travel_times)
                total_time, curr_time = wait_to_care_time!(total_time, curr_time, route.patients[i])
                route.feasible = route.feasible && is_in_care_time_window(route.patients[i], curr_time)
                total_time, curr_time, nurse_capicity = care_time!(total_time, curr_time, route.patients[i], nurse_capicity)
            end
        end

    if !route.feasible || nurse_capicity < 0
        total_time *= 1.5
    end
        # Tempo necessario dall'ultimo paziente al deposito
        total_time, curr_time = travel_to_from_depot_time!(total_time, curr_time, route.patients[end], travel_times)
    end
    return total_time
end

function update_population_fitness!(population::Population, problem::HomeCareRoutingProblem)
    travel_times = problem.travel_times
    for individual in population.individuals
        individual.fitness = sum(calculate_route_time(route, travel_times) for route in individual.routes)
        if individual.fitness < population.best_individual.fitness # aggiorna se minore
            population.best_individual = deepcopy(individual)
        end
    end
end
