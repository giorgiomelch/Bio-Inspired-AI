using JSON3

include("myStructs.jl")

function load_home_care_problem(filename::String)
    data = JSON3.read(read(filename, String))
    # Creazione del depot
    depot = Depot(data["depot"]["return_time"],
                  data["depot"]["x_coord"],
                  data["depot"]["y_coord"])

    println(typeof(data["patients"]))  # Scopri se è un `JSON3.Object` o un `Array`

    println("DUE")
    # Creazione della lista di pazienti
    patients = [
        Patient(parse(Int, pid),  # Converte la chiave "pid" da stringa a intero
                p["demand"],      # Legge il valore della domanda
                p["care_time"],   # Legge il tempo di cura
                p["start_time"],  # Legge il tempo di inizio
                p["end_time"],    # Legge il tempo di fine
                p["x_coord"],     # Legge la coordinata x
                p["y_coord"])     # Legge la coordinata y
        for (pid, p) in data["patients"]  # Itera su chiave-valore del JSON
    ]

    println("TRE")

    # Creazione della lista di infermieri
    nurses = [Nurse(i, data["capacity_nurse"]) for i in 1:data["nbr_nurses"]]

    println("QUATTRO")

    # Creazione della matrice dei tempi di viaggio
    travel_times = Matrix{Float64}(data["travel_times"])

    println("CINQUE")

    # Creazione delle rotte iniziali (vuote)
    routes = [Route(n, depot.return_time) for n in nurses]
    println(typeof(routes))
    return HomeCareRoutingProblem(routes, travel_times, depot, patients)
end

a = load_home_care_problem(
                        "/home/giorgiomelch/BI_AI/workspace/genetic-algorithm/project2/data/train_0.json")