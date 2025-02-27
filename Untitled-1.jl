#############################
#        LIBRERIE         #
#############################
using Random
using Plots
using Statistics
using JSON3
using Clustering

#############################
#   STRUTTURE DATI        #
#############################
struct Depot
    return_time::Float64
    x_coord::Int
    y_coord::Int
end

struct Patient
    id::Int
    demand::Float64          # strain demand
    care_time::Float64       # tempo di cura
    start_time::Float64      # inizio finestra temporale
    end_time::Float64        # fine finestra temporale
    x_coord::Int64           # coordinata x (per il plot)
    y_coord::Int64           # coordinata y (per il plot)
end

struct Nurse
    id::Int
    capacity::Float64        # capacità massima
end

mutable struct Route
    nurse::Nurse
    patients::Vector{Patient}  # lista dei pazienti assegnati (l’ordine conta!)
    start_time::Float64        # orario di partenza dal depot (fisso a 0)
    depot_return_time::Float64 # orario massimo di ritorno al depot
    is_back_before_return_time::Bool
    capacity_respected::Bool
    time_windows_respected::Bool
    feasible::Bool
    function Route(nurse::Nurse, depot_return_time::Float64)
        new(nurse, Vector{Patient}(), 0.0, depot_return_time, true, true, true, true)
    end
end

mutable struct Individual
    routes::Vector{Route}
    fitness::Float64
    feasible::Bool
    function Individual(routes::Vector{Route})
        new(routes, 0.0, true)
    end
end

mutable struct Population
    individuals::Vector{Individual}
    N_POP::Int
    best_individual::Individual
    mean_fitness::Vector{Float64}
    min_fitness::Vector{Float64}
    function Population(individuals::Vector{Individual}, N_POP::Int, best_individual::Individual)
        new(individuals, N_POP, best_individual, Vector{Float64}(), Vector{Float64}())
    end    
end

struct HomeCareRoutingProblem
    travel_times::Matrix{Float64}  # matrice dei tempi di viaggio (indice 1 = depot)
    depot::Depot
    benchmark::Float64
    patients::Vector{Patient}
    nurse::Nurse
    nbr_nurses::Int
end

#############################
#     FUNZIONI AUSILIARIE  #
#############################
function print_individual_routes(individual::Individual)
    for route in individual.routes
        patient_ids = [p.id for p in route.patients]
        println("Route (Nurse $(route.nurse.id)): ", patient_ids)
    end
end

function push_mean_fitness!(population::Population)
    mean_fit = mean(ind.fitness for ind in population.individuals)
    push!(population.mean_fitness, mean_fit)
end

function push_min_fitness!(population::Population)
    min_fit = minimum(ind.fitness for ind in population.individuals)
    push!(population.min_fitness, min_fit)
end

#############################
#    FUNZIONE DI PLOTTING  #
#############################
function plot_routes(depot::Depot, routes::Vector{Route})
    plt = scatter(title="Percorsi delle Infermiere e Pazienti", xlabel="X", ylabel="Y", legend=:outertopright)
    # Plot del depot
    scatter!(plt, [depot.x_coord], [depot.y_coord], color=:blue, markersize=8, label="Depot")
    # Plot dei pazienti (con annotazioni)
    for route in routes
        for patient in route.patients
            scatter!(plt, [patient.x_coord], [patient.y_coord], color=:red, markersize=6, label="P$(patient.id)")
            annotate!(plt, patient.x_coord, patient.y_coord+2, text("P$(patient.id)", :black, 8))
        end
    end
    # Disegna le route per ogni infermiera
    nurse_colors = [:green, :purple, :orange, :cyan, :magenta, :brown, :pink, :gray, :olive, :teal]
    for route in routes
        pts_x = [depot.x_coord]
        pts_y = [depot.y_coord]
        for patient in route.patients
            push!(pts_x, patient.x_coord)
            push!(pts_y, patient.y_coord)
        end
        push!(pts_x, depot.x_coord)
        push!(pts_y, depot.y_coord)
        color = nurse_colors[mod1(route.nurse.id, length(nurse_colors))]
        plot!(plt, pts_x, pts_y, color=color, linewidth=2, label="Nurse $(route.nurse.id)")
    end
    return plt
end

#############################
#   CARICAMENTO DATI      #
#############################
function load_home_care_problem(filename::String)
    data = JSON3.read(read(filename, String))
    depot = Depot(data["depot"]["return_time"],
                  data["depot"]["x_coord"],
                  data["depot"]["y_coord"])
    patients = [
        Patient(parse(Int, string(pid)),
                p["demand"],
                p["care_time"],
                p["start_time"],
                p["end_time"],
                p["x_coord"],
                p["y_coord"])
        for (pid, p) in data["patients"]
    ]
    nurse = Nurse(1, data["capacity_nurse"])
    nbr_nurses = data["nbr_nurses"]
    travel_times = Matrix{Float64}(undef, length(data["travel_times"]), length(data["travel_times"][1]))
    for i in 1:length(data["travel_times"])
        for j in 1:length(data["travel_times"][i])
            travel_times[i, j] = Float64(data["travel_times"][i][j])
        end
    end
    benchmark = data["benchmark"]
    return HomeCareRoutingProblem(travel_times, depot, benchmark, patients, nurse, nbr_nurses)
end

#############################
#  INIZIALIZZAZIONE POP.   #
#############################
function cluster_pazienti(patients::Vector{Patient}, n_cluster::Int)
    data = hcat([p.x_coord for p in patients], [p.y_coord for p in patients])'
    result = kmeans(data, n_cluster)
    clusters = [Patient[] for _ in 1:n_cluster]
    for (i, label) in enumerate(result.assignments)
        push!(clusters[label], patients[i])
    end
    return clusters
end

function cluster_initialize_individual(patients::Vector{Patient}, N_nurses::Int, n::Int, depot_return_time::Float64, nurse_capacity::Float64)
    clusters = cluster_pazienti(patients, n)
    nurses = [Nurse(i, nurse_capacity) for i in 1:N_nurses]
    routes = [Route(nurses[i], depot_return_time) for i in 1:N_nurses]
    for (i, cluster) in enumerate(clusters)
        routes[i].patients = cluster
    end
    return Individual(routes)
end

function knn_initialize_population(problem::HomeCareRoutingProblem, N_POP::Int, N_CLUSTERS::Int)
    individuals = Vector{Individual}()
    for _ in 1:N_POP
        n_min = problem.nbr_nurses - N_CLUSTERS
        n = rand(n_min:problem.nbr_nurses)
        individual = cluster_initialize_individual(problem.patients, problem.nbr_nurses, n, problem.depot.return_time, problem.nurse.capacity)
        push!(individuals, individual)
    end
    best_individual = individuals[1]
    return Population(individuals, N_POP, best_individual)
end

#############################
#   FUNZIONI DI CONVERSIONE
#    TRA INDIVIDUO E VETTORE
#############################
# Converte un Individual (basato su route) in un vettore di assegnamento.
# Qui l'ordine dei pazienti all'interno di ciascuna route viene mantenuto.
function individual_to_assignment(ind::Individual, problem::HomeCareRoutingProblem)
    assignment = Int[]
    # Per ciascuna route, aggiungiamo le assegnazioni nell'ordine in cui compaiono
    for route in ind.routes
        for patient in route.patients
            push!(assignment, route.nurse.id)
        end
    end
    return assignment
end

# Converte un vettore di assegnamento in un Individual.
# NOTA: per semplicità, qui ricostruiamo le route assegnando i pazienti in base
# all'ordine naturale (ossia, l'ordine in cui compaiono in problem.patients).
# Questo operatore verrà poi raffinato dalla mutation_shift! che riordina le route.
function assignment_to_individual(assignment::Vector{Int}, problem::HomeCareRoutingProblem)
    # Inizializza route vuote per ciascun infermiere
    routes = [Route(Nurse(i, problem.nurse.capacity), problem.depot.return_time) for i in 1:problem.nbr_nurses]
    # Assegna i pazienti nell'ordine naturale
    for patient in problem.patients
        nurse_assigned = assignment[patient.id]  # Si assume che patient.id sia tra 1 e N
        if nurse_assigned != -1 && nurse_assigned <= problem.nbr_nurses
            push!(routes[nurse_assigned].patients, patient)
        end
    end
    return Individual(routes)
end

#############################
#   FUNZIONE DI FITNESS     #
#############################
# Utilizza la funzione originale che calcola il tempo della route,
# così da tener conto dell'ordine dei pazienti.
function calculate_route_time(route, travel_t_mtrx)
    nurse_capicity = route.nurse.capacity
    curr_time = 0.0
    tot_travel_time = 0.0
    if !isempty(route.patients)
        tot_travel_time += travel_t_mtrx[1, route.patients[1].id+1]
        tot_travel_time += travel_t_mtrx[route.patients[end].id+1, 1]
        # Calcola il percorso tra pazienti nell'ordine in cui sono presenti nella route
        for i in 2:length(route.patients)
            tot_travel_time += travel_t_mtrx[route.patients[i-1].id+1, route.patients[i].id+1]
        end
    end
    return tot_travel_time
end

# Aggiorna la fitness usando la somma dei tempi di tutte le route
function update_population_fitness!(population::Population, problem::HomeCareRoutingProblem)
    for individual in population.individuals
        individual.fitness = sum(calculate_route_time(route, problem.travel_times) for route in individual.routes)
        individual.feasible = all(r -> r.feasible, individual.routes)
        if individual.fitness < population.best_individual.fitness
            population.best_individual = deepcopy(individual)
        end
    end
end

#############################
#    FUNZIONE DI CROSSOVER  #
#############################
# Usa la logica di cx_swap del secondo problema per modificare l'assegnamento degli infermieri.
function cx_swap_wrapper(ind1::Individual, ind2::Individual, problem::HomeCareRoutingProblem)
    assignment1 = individual_to_assignment(ind1, problem)
    assignment2 = individual_to_assignment(ind2, problem)
    size = length(assignment1)
    a, b = sort(randperm(size)[1:2])
    assignment1[a], assignment2[b] = assignment2[b], assignment1[a]
    child1 = assignment_to_individual(assignment1, problem)
    child2 = assignment_to_individual(assignment2, problem)
    return child1, child2
end

#############################
#     FUNZIONE DI MUTATION  #
#############################
# Applica la logica di mut_shuffle del secondo problema (per l'assegnamento)
function mut_shuffle_wrapper(ind::Individual, problem::HomeCareRoutingProblem)
    assignment = individual_to_assignment(ind, problem)
    valid = [x for x in assignment if x != -1]
    shuffled = shuffle(valid)
    idx = 1
    for i in eachindex(assignment)
        if assignment[i] != -1
            assignment[i] = shuffled[idx]
            idx += 1
        end
    end
    return assignment_to_individual(assignment, problem)
end

# La mutation_shift! originaria, che modifica l'ordine all'interno delle route
function mutation_shift!(individual::Individual, N_GEN_SHIFT::Int)
    for _ in 1:N_GEN_SHIFT
        n_routes = length(individual.routes)
        r_idxs = shuffle!(collect(1:n_routes))
        mutation_done = false
        ind_from = 1
        while !mutation_done && ind_from < n_routes
            r_id = r_idxs[ind_from]
            route_from = individual.routes[r_id]
            if !isempty(route_from.patients)
                patient_index = rand(1:length(route_from.patients))
                patient = route_from.patients[patient_index]
                for ind_to in r_idxs
                    if r_id != ind_to
                        route_to = individual.routes[ind_to]
                        if length(route_to.patients) < 10  # ipotetico limite per consentire l'inserimento
                            popat!(route_from.patients, patient_index)
                            insert_pos = isempty(route_to.patients) ? 1 : rand(1:length(route_to.patients)+1)
                            insert!(route_to.patients, insert_pos, patient)
                            mutation_done = true
                            break
                        end
                    end
                end
            end
            ind_from += 1
        end
    end
end

# Applica mutation: prima modifica l'assegnamento (mut_shuffle) e poi l'ordine (mutation_shift!)
function apply_mutation!(population::Population, N_GEN_SWAP_MUTATION, N_GEN_INVERSION, N_GEN_SHIFT, problem::HomeCareRoutingProblem)
    for i in 1:length(population.individuals)
        # Modifica l'assegnamento degli infermieri
        population.individuals[i] = mut_shuffle_wrapper(population.individuals[i], problem)
        # Modifica l'ordine all'interno delle route
        mutation_shift!(population.individuals[i], N_GEN_SHIFT)
    end
end

#############################
#      SELEZIONE & ELITISM
#############################
function elitism!(population::Population)
    sort!(population.individuals, by = x -> x.fitness)
    population.individuals = population.individuals[1:population.N_POP]
end

function tournament_selection(population::Population, num_survivors::Int, tournament_size::Int)
    survivors = [Individual(Vector{Route}()) for _ in 1:num_survivors]
    for i in 1:num_survivors
        candidates_indices = randperm(population.N_POP)[1:tournament_size]
        individuals_in_tournament = [population.individuals[idx] for idx in candidates_indices]
        best_individual = argmin(ind -> ind.fitness, individuals_in_tournament)
        survivors[i] = best_individual
    end
    return survivors
end

#############################
#    ALGORITMO GENETICO    #
#############################
function genetic_algorithm(
    problem::HomeCareRoutingProblem, 
    N_POP::Int, 
    POP_REPLACEMENT::Float64, 
    N_ITER::Int,
    TOURNAMENT_SIZE::Int,
    N_GEN_SWAP_MUTATION::Int64, 
    N_GEN_INVERSION::Int64, 
    N_GEN_SHIFT::Int64)

    population = knn_initialize_population(problem, N_POP, 3)
    update_population_fitness!(population, problem)
    display(plot_routes(problem.depot, population.best_individual.routes))
    
    for iter in 1:N_ITER 
        if iter % 100 == 0
            println("Iterazione: ", iter)
            println("Mean fitness: ", population.mean_fitness[end])
            println("Best fitness: ", population.best_individual.fitness, ", feasible: ", population.best_individual.feasible)
            display(plot_routes(problem.depot, population.best_individual.routes))
        end
        
        # Selezione dei genitori (copia della popolazione)
        parents = deepcopy(population.individuals)
        
        # CROSSOVER: applica cx_swap_wrapper
        offsprings = [Individual(Vector{Route}()) for _ in 1:length(parents)]
        for i in 1:2:(length(parents)-1)
            child1, child2 = cx_swap_wrapper(parents[i], parents[i+1], problem)
            offsprings[i] = child1
            offsprings[i+1] = child2
        end
        append!(population.individuals, offsprings)
        
        # MUTATION: modifica assegnamento e ordine
        apply_mutation!(population, N_GEN_SWAP_MUTATION, N_GEN_INVERSION, N_GEN_SHIFT, problem)
        
        update_population_fitness!(population, problem)
        elitism!(population)
        
        push_mean_fitness!(population)
        push_min_fitness!(population)
    end
    
    return population.best_individual
end

#############################
#       COSTANTI           #
#############################
N_ITER = 20_000
N_POP = 500
POP_REPLACEMENT = 0.8
TOURNAMENT_SIZE = 20
N_GEN_SWAP_MUTATION = 4
N_GEN_INVERSION = 1
N_GEN_SHIFT = 2

# Carica il problema (modifica il path se necessario)
data_train_nbr = 0
HCP = load_home_care_problem("C:/Users/giovy/Desktop/Home_Care_Problem/data/train_" * string(data_train_nbr) * ".json")

#############################
#       ESECUZIONE         #
#############################
@time best_individual = genetic_algorithm(HCP, N_POP, POP_REPLACEMENT, 
        N_ITER,
        TOURNAMENT_SIZE,
        N_GEN_SWAP_MUTATION, N_GEN_INVERSION, N_GEN_SHIFT)

println("----- Risultato migliore -----")
print_individual_routes(best_individual)
println("Best fitness: ", best_individual.fitness, ", feasible: ", best_individual.feasible)
println("Benchmark: ", HCP.benchmark)

# Visualizza il grafico finale dei percorsi
display(plot_routes(HCP.depot, best_individual.routes))
