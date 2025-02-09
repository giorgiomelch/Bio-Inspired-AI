using JSON3

include("myStructs.jl")

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

    # Creazione della lista di infermieri
    nurses = [Nurse(i, data["capacity_nurse"]) for i in 1:data["nbr_nurses"]]

    # Creazione della matrice dei tempi di viaggio
    travel_times = Matrix{Float64}(undef, length(data["travel_times"]), length(data["travel_times"][1]))
    for i in 1:length(data["travel_times"])
        for j in 1:length(data["travel_times"][i])
            travel_times[i, j] = Float64(data["travel_times"][i][j])
        end
    end

    # Creazione delle rotte iniziali (vuote)
    routes = [Route(n, depot.return_time) for n in nurses]
    return HomeCareRoutingProblem(routes, travel_times, depot, patients)
end

a = load_home_care_problem(
                        "/home/giorgiomelch/BI_AI/workspace/genetic-algorithm/project2/data/train_1.json")
a.travel_times[1][1]