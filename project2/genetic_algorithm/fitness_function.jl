function calculate_fitness!(population::Population, problem::HomeCareRoutingProblem)
    # Estrai la matrice dei tempi di viaggio
    travel_times = problem.travel_times

    # Itera su ogni individuo nella popolazione
    for individual in population.population
        route = individual.route
        total_time = 0.0

        # Tempo di partenza dal deposito
        current_time = route.start_time

        # Se ci sono pazienti nella route
        if !isempty(route.patients)
            # Tempo di viaggio dal deposito al primo paziente
            first_patient = route.patients[1]
            total_time += travel_times[1, first_patient.id + 1]  # +1 perché il deposito è l'indice 1

            # Tempo di cura del primo paziente
            total_time += first_patient.care_time

            # Itera sui pazienti successivi
            for i in 2:length(route.patients)
                prev_patient = route.patients[i-1]
                current_patient = route.patients[i]
                # Tempo di viaggio tra i pazienti
                total_time += travel_times[prev_patient.id + 1, current_patient.id + 1]
                # Tempo di cura del paziente corrente
                total_time += current_patient.care_time
            end

            # Tempo di viaggio dall'ultimo paziente al deposito
            last_patient = route.patients[end]
            total_time += travel_times[last_patient.id + 1, 1]
        end
        # Aggiorna la fitness dell'individuo
        individual.fitness = total_time
    end
end