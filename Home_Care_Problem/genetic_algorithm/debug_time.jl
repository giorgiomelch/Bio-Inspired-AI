include("structs.jl")
include("parser.jl")
include("initialization.jl")
include("fitness_function.jl")
include("mutation.jl")
include("../plotter/plots.jl")
include("selection.jl")
include("crossover.jl")

function initialize_individual_from_ids(id_routes::Vector{Vector{Int64}}, patients::Vector{Patient}, 
    N_nurses::Int, depot_return_time::Float64, nurse_capacity::Float64)

    nurses = [Nurse(i, nurse_capacity) for i in 1:N_nurses]
    routes = [Route(nurses[i], depot_return_time) for i in 1:N_nurses]
    println(routes[1].is_back_before_return_time)
    println(routes[1].capacity_respected)
    println(routes[1].time_windows_respected)
    println(routes[1].feasible)
    # Assegna i pazienti alle rotte corrispondenti
    for (i, patient_ids) in enumerate(id_routes)
        routes[i].patients = [patients[j] for j in patient_ids]
    end

    return Individual(routes)
end

function init_pop_cheat(i_t, i)
    HCP_d = load_home_care_problem("/home/giorgiomelch/BI_AI/workspace/genetic-algorithm/Home_Care_Problem/test/test_"*string(i)*".json")
    
    individuals = Vector{Individual}()
    individual = initialize_individual_from_ids(i_t, HCP_d.patients, HCP_d.nbr_nurses, HCP_d.depot.return_time, HCP_d.nurse.capacity)
    individual.fitness = sum(calculate_route_time(route, HCP_d.travel_times) for route in individual.routes)
    for _ in 1:100
        push!(individuals, individual)
    end
    a= Population(individuals, 100, individual)
    update_population_fitness!(a, HCP_d)
    show_solution(a.individuals[1], HCP_d)
    plot_routes(HCP_d.depot, a.best_individual.routes)
    return a
end

i_t0 = Vector{Vector{Int64}}([
[55, 54, 53, 56, 58, 60, 59, 57],
[90, 87, 84, 85, 88, 89, 91],
[67, 65, 63, 62, 74, 72, 61, 64, 68, 66, 69],
Vector{Int64}(),
Vector{Int64}(),
[34, 33, 31, 35, 37, 38, 39, 36, 32],
Vector{Int64}(),
[20, 24, 25, 27, 29, 30, 28, 26, 23, 22, 21],
Vector{Int64}(),
Vector{Int64}(),
[81, 78, 76, 71, 70, 73, 77, 79, 80, 82, 83, 86],
[13, 17, 18, 19, 15, 16, 14, 12],
Vector{Int64}(),
Vector{Int64}(),
Vector{Int64}(),
[75, 2, 7, 8, 10, 11, 9, 6, 4, 3, 5],
Vector{Int64}(),
[43, 42, 41, 40, 44, 46, 45, 48, 51, 50, 52, 49, 47],
Vector{Int64}(),
[98, 96, 95, 94, 92, 93, 97, 100, 99, 1],
Vector{Int64}(),
Vector{Int64}(),
Vector{Int64}(),
Vector{Int64}(),
Vector{Int64}()])
    
i_t1 = Vector{Vector{Int64}}([[92, 62, 30, 28, 32, 50, 80],[33, 26, 27, 29, 31, 34, 94, 93, 96],[42, 39, 36, 38, 40, 41, 43, 35, 37],
    [2, 45, 5, 1, 3, 8, 46, 55],[82, 11, 9, 97, 75, 58],Vector{Int64}(),[88, 79, 6, 7, 4, 70, 100],
    [72, 44, 61, 68],[65, 64, 83, 99, 57, 66],[71, 67, 84, 51, 56, 91],[12, 14, 47, 15, 16, 10, 13, 17],
    Vector{Int64}(), Vector{Int64}(),Vector{Int64}(),Vector{Int64}(),[21, 19, 23, 18, 22, 49, 20, 25, 24],
    Vector{Int64}(), [69, 78, 73, 60],Vector{Int64}(),Vector{Int64}(),Vector{Int64}(),[90, 53, 98],Vector{Int64}(),[52, 86, 87, 59, 74],    [95, 85, 63, 76, 89, 48, 77]])
    
i_t2=Vector{Vector{Int64}}([[95, 92, 59, 5, 45, 82, 7, 48, 47, 36, 49, 46, 8, 84, 83, 18, 6, 96, 94, 13, 58],Vector{Int64}(),Vector{Int64}(),Vector{Int64}(),Vector{Int64}(),
[2, 57, 15, 42, 44, 38, 86, 16, 61, 85, 99, 98, 37, 87, 97, 43, 14, 100, 91, 93, 17, 60, 89],
[27, 69, 1, 30, 51, 33, 81, 65, 71, 9, 34, 78, 79, 29, 68, 3, 77, 50],Vector{Int64}(),Vector{Int64}(),Vector{Int64}(),Vector{Int64}(),
[21, 73, 72, 75, 23, 67, 39, 41, 22, 74, 56, 4, 55, 25, 54, 24, 80, 26],Vector{Int64}(),
[52, 88, 62, 19, 11, 64, 63, 90, 32, 66, 35, 20, 10, 70, 31],Vector{Int64}(),
[28, 76, 12, 40, 53],Vector{Int64}(),
Vector{Int64}(),Vector{Int64}(),Vector{Int64}(),Vector{Int64}(),Vector{Int64}(),Vector{Int64}()])

a = init_pop_cheat(i_t1, 1)
println(a.individuals[1].fitness)
println(a.individuals[1].feasible)

