using Random
function initialize_pop_random(problem::HomeCareRoutingProblem, N_POP::Int)
    individuals = Vector{Individual}()

    for _ in 1:N_POP
        curr_routes = Vector{Route}()
        for _ in 1:problem.nbr_nurses
            # Crea una route con il nurse assegnato e il tempo di ritorno al depot
            route = Route(problem.nurse, problem.depot.return_time)
            # Crea una copia dei pazienti e li mescola per assegnazione casuale
            shuffled_patients = shuffle(problem.patients)
            total_demand = 0.0
            for patient in shuffled_patients
                if total_demand + patient.demand <= problem.nurse.capacity
                    push!(route.patients, patient)
                    total_demand += patient.demand
                end
            end
            push!(curr_routes, route)
        end
        individual = Individual(curr_routes)
        push!(individuals, individual)
    end
    # Determiniamo il miglior individuo iniziale (per ora, prendiamo il primo)
    best_individual = individuals[1]

    return Population(individuals, N_POP, best_individual)
end



using Clustering

function cluster_pazienti(patients::Vector{Patient}, N_nurses::Int)
    # Prepara i dati per k-means
    data = hcat([p.x_coord for p in patients], [p.y_coord for p in patients])'

    result = kmeans(data, N_nurses) # K-MEANS!!
    # Raggruppa i pazienti nei cluster assegnati
    clusters = [Patient[] for _ in 1:N_nurses]
    for (i, label) in enumerate(result.assignments)
        push!(clusters[label], patients[i])
    end
    return clusters
end

function cluster_initialize_individual(patients::Vector{Patient},  N_nurses::Int, depot_return_time::Float64, nurse_capacity::Float64)
    # Raggruppa i pazienti in cluster usando k-means
    clusters = cluster_pazienti(patients, N_nurses)

     # Crea gli infermieri
    nurses = [Nurse(i, nurse_capacity) for i in 1:N_nurses]
    # Crea le rotte per ogni infermiere
    routes = [Route(nurses[i], depot_return_time) for i in 1:N_nurses]
    # Assegna i pazienti ai rispettivi infermieri
    for (i, cluster) in enumerate(clusters)
        routes[i].patients = cluster
    end
    return Individual(routes)
end

function knn_initialize_population(problem::HomeCareRoutingProblem, N_POP::Int)
    individuals = Vector{Individual}()
    for _ in 1:N_POP
        n = rand(problem.nbr_nurses-3:problem.nbr_nurses)
        individual = cluster_initialize_individual(problem.patients, n, problem.depot.return_time, problem.nurse.capacity)
        push!(individuals, individual)
    end
    best_individual = individuals[1]
    return Population(individuals, N_POP, best_individual)
end