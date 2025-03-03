function save_individual_routes(individual::Individual, problem_number::Int, filename::String, directory::String)
    # Assicurati che la directory esista
    if !isdir(directory)
        mkdir(directory)
    end
    
    # Costruisci il percorso completo del file
    full_filename = joinpath(directory, filename)

    # Se il file non esiste, crea il file e scrivi l'intestazione
    if !isfile(full_filename)
        open(full_filename, "w") do file
            println(file, "Problem Number, Route, Patient IDs, Fitness, Feasible")
            println(file, "------------------------------------")
        end
    end
    
    open(full_filename, "a") do file  
        write(file, "\n--- New Solution ---\n")
        for route in individual.routes
            # Estrai gli ID dei pazienti dalle rotte
            patient_ids = [p.id for p in route.patients]
            # Scrivi la route nel file
            write(file, "Route: ", string(patient_ids), "\n")
        end
        
        # Scrivi la fitness e se è feasible
        write(file, "Fitness: ", string(individual.fitness), "\n")
        write(file, "Feasible: ", string(individual.feasible), "\n")
        write(file, "Problem Number: ", string(problem_number), "\n")
    end
end
