using JSON3

function load_home_care_problem(filename::String)
    data = JSON3.read(read(filename, String))
    # Creazione del depot
    depot = Depot(data["depot"]["return_time"],
                  data["depot"]["x_coord"],
                  data["depot"]["y_coord"])

    # Creazione della lista di pazienti
    patients = [
        Patient(parse(Int, string(pid)),  # Converte la chiave "pid" da stringa a intero
                p["demand"],      # Legge il valore della domanda
                p["care_time"],   # Legge il tempo di cura
                p["start_time"],  # Legge il tempo di inizio
                p["end_time"],    # Legge il tempo di fine
                p["x_coord"],     # Legge la coordinata x
                p["y_coord"])     # Legge la coordinata y
        for (pid, p) in data["patients"]  # Itera su chiave-valore del JSON
    ]

    nurse = Nurse(1, data["capacity_nurse"])
    nbr_nurses = data["nbr_nurses"]
    # Creazione della matrice dei tempi di viaggio
    travel_times = Matrix{Float64}(undef, length(data["travel_times"]), length(data["travel_times"][1]))
    for i in 1:length(data["travel_times"])
        for j in 1:length(data["travel_times"][i])
            travel_times[i, j] = Float64(data["travel_times"][i][j])
        end
    end

    return HomeCareRoutingProblem(travel_times,
                                  depot,
                                  patients,
                                  nurse,
                                  nbr_nurses)
end

a = load_home_care_problem("/home/giorgiomelch/BI_AI/workspace/genetic-algorithm/project2/data/train_1.json")
println(a.depot)