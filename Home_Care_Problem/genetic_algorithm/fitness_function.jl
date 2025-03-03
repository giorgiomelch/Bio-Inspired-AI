function is_in_care_time_window(patient, current_time)
    return current_time >= patient.start_time && (current_time + patient.care_time) <= patient.end_time
end
function is_back_before_return_time(curret_time, return_time)
    return curret_time <= return_time
    
end

function travel_from_Pa_to_Pb!(tot_travel_time, curr_time, patient_a, patient_b, travel_t_mtrx)
    travel_time = travel_t_mtrx[patient_a.id + 1, patient_b.id + 1]
    return tot_travel_time + travel_time, curr_time + travel_time
end
function travel_to_from_depot_time!(tot_travel_time, curr_time, patient, travel_t_mtrx)
    travel_time = travel_t_mtrx[1, patient.id + 1]
    return tot_travel_time + travel_time, curr_time + travel_time
end
function wait_to_care_time!(curr_time, patient)
    wait_time = max(0.0, patient.start_time - curr_time)
    return curr_time + wait_time
end
function care_time!(curr_time, patient, nurse_capicity)
    curr_time += patient.care_time
    nurse_capicity -= patient.demand
    return curr_time, nurse_capicity
end

function calculate_route_time(route, travel_t_mtrx)
    nurse_capicity = route.nurse.capacity
    route.feasible = true
    curr_time = 0.0
    tot_travel_time = 0.0
    if !isempty(route.patients)
        # Tempo necessario dal deposito a cura del primo paziente
        tot_travel_time, curr_time = travel_to_from_depot_time!(tot_travel_time, curr_time, route.patients[1], travel_t_mtrx)
        curr_time = wait_to_care_time!(curr_time, route.patients[1])
        route.time_windows_respected = is_in_care_time_window(route.patients[1], curr_time)
        curr_time, nurse_capicity = care_time!(curr_time, route.patients[1], nurse_capicity)
        if length(route.patients) > 1
            # Itera sulla lista di pazienti 
            for i in 2:length(route.patients) # paziente precedente: route.patients[i-1], paziente corrente: route.patients[i]
                tot_travel_time, curr_time = travel_from_Pa_to_Pb!(tot_travel_time, curr_time, route.patients[i-1], route.patients[i], travel_t_mtrx)
                curr_time = wait_to_care_time!(curr_time, route.patients[i])
                route.time_windows_respected = route.time_windows_respected && is_in_care_time_window(route.patients[i], curr_time)
                curr_time, nurse_capicity = care_time!(curr_time, route.patients[i], nurse_capicity)
            end
        end
        # Tempo necessario dall'ultimo paziente al deposito
        tot_travel_time, curr_time = travel_to_from_depot_time!(tot_travel_time, curr_time, route.patients[end], travel_t_mtrx)
    end
    route.capacity_respected = (nurse_capicity >= 0)
    route.is_back_before_return_time = is_back_before_return_time(curr_time, route.depot_return_time)
    if !(route.time_windows_respected && route.capacity_respected && route.is_back_before_return_time)
        route.feasible = false
        if !route.time_windows_respected
            tot_travel_time *= 2
        end
        if !route.capacity_respected
            tot_travel_time *= 4
        end
        if !route.is_back_before_return_time
            tot_travel_time *= 4
        end
    end
    return tot_travel_time
end

function update_population_fitness!(population::Population, problem::HomeCareRoutingProblem)
    travel_times = problem.travel_times
    for individual in population.individuals
        individual.fitness = sum(calculate_route_time(route, travel_times) for route in individual.routes)
        individual.feasible = all(r -> r.feasible, individual.routes) # controlla se tutte le rotte sono fattibili
        if individual.fitness < population.best_individual.fitness # aggiorna se minore
            population.best_individual = deepcopy(individual)
        end
    end
end








## DA CANC
## SERVE PER CALCOLARE SOLO IL TEMPO DI VIAGGIO DI UNA SOLUZIONE

function calculate_route_travel_time(route, travel_t_mtrx)
    nurse_capicity = route.nurse.capacity
    route.feasible = true
    curr_time = 0.0
    tot_travel_time = 0.0
    if !isempty(route.patients)
        # Tempo necessario dal deposito a cura del primo paziente
        tot_travel_time, curr_time = travel_to_from_depot_time!(tot_travel_time, curr_time, route.patients[1], travel_t_mtrx)
        curr_time = wait_to_care_time!(curr_time, route.patients[1])
        route.time_windows_respected = is_in_care_time_window(route.patients[1], curr_time)
        curr_time, nurse_capicity = care_time!(curr_time, route.patients[1], nurse_capicity)
        if length(route.patients) > 1
            # Itera sulla lista di pazienti 
            for i in 2:length(route.patients) # paziente precedente: route.patients[i-1], paziente corrente: route.patients[i]
                tot_travel_time, curr_time = travel_from_Pa_to_Pb!(tot_travel_time, curr_time, route.patients[i-1], route.patients[i], travel_t_mtrx)
                curr_time = wait_to_care_time!(curr_time, route.patients[i])
                route.time_windows_respected = route.time_windows_respected && is_in_care_time_window(route.patients[i], curr_time)
                curr_time, nurse_capicity = care_time!(curr_time, route.patients[i], nurse_capicity)
            end
        end
        # Tempo necessario dall'ultimo paziente al deposito
        tot_travel_time, curr_time = travel_to_from_depot_time!(tot_travel_time, curr_time, route.patients[end], travel_t_mtrx)
    end
    route.capacity_respected = (nurse_capicity >= 0)
    route.is_back_before_return_time = is_back_before_return_time(curr_time, route.depot_return_time)
    if !(route.time_windows_respected && route.capacity_respected && route.is_back_before_return_time)
        route.feasible = false
    end
    return tot_travel_time
end

function calc_travel_time(individual::Individual, problem::HomeCareRoutingProblem)
    travel_times = problem.travel_times
    individual.fitness = sum(calculate_route_travel_time(route, travel_times) for route in individual.routes)
    individual.feasible = all(r -> r.feasible, individual.routes) # controlla se tutte le rotte sono fattibili
    print("Fitness: ", individual.fitness, ", feasible: ", individual.feasible, "\nis_back_before_return_time: ", all(r -> r.is_back_before_return_time, individual.routes), "\ncapacity_respected: ", all(r -> r.capacity_respected, individual.routes), "\ntime_windows_respected: ", all(r -> r.time_windows_respected, individual.routes))

end