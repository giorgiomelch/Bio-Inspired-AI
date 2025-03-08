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

    if isempty(route.patients)
        route.time_windows_respected = true
        route.capacity_respected = true
        route.is_back_before_return_time = true
        return tot_travel_time
    end
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
            tot_travel_time *= 3
        end
        if !route.capacity_respected
            tot_travel_time *= 3
        end
        if !route.is_back_before_return_time
            tot_travel_time *= 3
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



function funz_print_all_info_route(route, travel_t_mtrx)
    nurse_capicity = route.nurse.capacity
    route.feasible = true
    curr_time = 0.0
    tot_travel_time = 0.0

    if isempty(route.patients)
        route.time_windows_respected = true
        route.capacity_respected = true
        route.is_back_before_return_time = true
        return tot_travel_time
    end
    if !isempty(route.patients)
        print("D(0) -> ")
        # Tempo necessario dal deposito a cura del primo paziente
        tot_travel_time, curr_time = travel_to_from_depot_time!(tot_travel_time, curr_time, route.patients[1], travel_t_mtrx)
        curr_time = wait_to_care_time!(curr_time, route.patients[1])
        route.time_windows_respected = is_in_care_time_window(route.patients[1], curr_time)
        st_pc = curr_time
        curr_time, nurse_capicity = care_time!(curr_time, route.patients[1], nurse_capicity)
        print("P:", route.patients[1].id, " (", round(st_pc, digits=2), "-", round(curr_time, digits=2), 
        ") [", Int(route.patients[1].start_time), "-", Int(route.patients[1].end_time), "] ")
        if length(route.patients) > 1
            # Itera sulla lista di pazienti 
            for i in 2:length(route.patients) # paziente precedente: route.patients[i-1], paziente corrente: route.patients[i]
                tot_travel_time, curr_time = travel_from_Pa_to_Pb!(tot_travel_time, curr_time, route.patients[i-1], route.patients[i], travel_t_mtrx)
                pc = route.patients[i]
                curr_time = wait_to_care_time!(curr_time, route.patients[i])
                st_pc = curr_time
                route.time_windows_respected = route.time_windows_respected && is_in_care_time_window(route.patients[i], curr_time)
                curr_time, nurse_capicity = care_time!(curr_time, route.patients[i], nurse_capicity)
                print("P:", pc.id, " (", round(st_pc, digits=0), "-", round(curr_time, digits=0), 
                ") [", Int(pc.start_time), "-", Int(pc.end_time), "] ")
            end
        end
        # Tempo necessario dall'ultimo paziente al deposito
        tot_travel_time, curr_time = travel_to_from_depot_time!(tot_travel_time, curr_time, route.patients[end], travel_t_mtrx)
        print("D(", round(tot_travel_time, digits=2), ")")
    end
    route.capacity_respected = (nurse_capicity >= 0)
    route.is_back_before_return_time = is_back_before_return_time(curr_time, route.depot_return_time)
    println("Route duration: ", tot_travel_time)
    println("Nurse capacity:", route.nurse.capacity - nurse_capicity)
    return tot_travel_time
end

function funz_print_all_info_ind(population::Population, problem::HomeCareRoutingProblem)
    travel_times = problem.travel_times
    for individual in population.individuals
        individual.fitness = sum(funz_print_all_info_route(route, travel_times) for route in individual.routes)
        individual.feasible = all(r -> r.feasible, individual.routes) # controlla se tutte le rotte sono fattibili
        if individual.fitness < population.best_individual.fitness # aggiorna se minore
            population.best_individual = deepcopy(individual)
        end
    end
end