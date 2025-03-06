using Random

function random_initialize_population(problem::HomeCareRoutingProblem, num_individuals::Int)
    patients = problem.patients
    nurse_capacity = problem.nurse.capacity
    N_nurses = problem.nbr_nurses
    depot_return_time = problem.depot.return_time

    population = Vector{Individual}()
    nurses = [Nurse(i, nurse_capacity) for i in 1:N_nurses]

    for _ in 1:num_individuals
        routes = [Route(nurse, depot_return_time) for nurse in nurses]
        # Distribuiamo i pazienti casualmente tra le rotte
        shuffled_patients = shuffle(patients)
        for (i, patient) in enumerate(shuffled_patients)
            route_index = rand(1:length(routes))  # Seleziona una rotta a caso
            push!(routes[route_index].patients, patient)
        end
        individual = Individual(routes)
        push!(population, individual)
    end
    return population
end



using Clustering

function cluster_pazienti(patients::Vector{Patient}, n_cluster::Int)
    data = hcat([p.x_coord for p in patients], [p.y_coord for p in patients])'
    result = kmeans(data, n_cluster) # K-MEANS!!
    # Raggruppa i pazienti nei cluster assegnati
    clusters = [Patient[] for _ in 1:n_cluster]
    for (i, label) in enumerate(result.assignments)
        push!(clusters[label], patients[i])
    end
    return clusters
end

function cluster_initialize_individual(patients::Vector{Patient},  N_nurses::Int, n::Int, depot_return_time::Float64, nurse_capacity::Float64)
    # Raggruppa i pazienti in cluster usando k-means
    clusters = cluster_pazienti(patients, n)
    nurses = [Nurse(i, nurse_capacity) for i in 1:N_nurses]
    routes = [Route(nurses[i], depot_return_time) for i in 1:N_nurses]
    # Assegna i pazienti ai rispettivi infermieri
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

function mixed_initialize_population(problem::HomeCareRoutingProblem, N_POP::Int, N_CLUSTERS::Int)
    cluster_pop = knn_initialize_population(problem, N_POP, N_CLUSTERS)
    random_individuals = random_initialize_population(problem, Int(N_POP/2))
    shuffle!(cluster_pop.individuals)
    println(length(cluster_pop.individuals))
    println(length(cluster_pop.individuals[Int(N_POP/2+1):end]))
    println(length(random_individuals))
    cluster_pop.individuals[Int(N_POP/2+1):end] .= random_individuals
    return cluster_pop
end