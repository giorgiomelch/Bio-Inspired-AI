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
    for _ in 1:1
        push!(individuals, individual)
    end
    a= Population(individuals, 1, individual)
    update_population_fitness!(a, HCP_d)
    #plot_routes(HCP_d.depot, a.best_individual.routes)
    funz_print_all_info_ind(a, HCP_d)
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
    
i_t1 = Vector{Vector{Int64}}([[2, 45, 3, 5, 8, 6, 7, 46, 4, 1, 100],
[85, 63, 51, 84, 56, 66],
[82, 12, 14, 11, 9, 10, 13, 17],
[69, 53, 98],
[29, 27, 26, 30, 28, 32, 31, 34, 50, 80],
[33, 76, 89, 48, 21, 25, 24],
[39, 36, 40, 37, 35, 43, 70],
[90],
[64, 99, 57, 59, 74, 58],
[65, 52, 86, 87, 97, 75, 77],
[42, 44, 38, 41, 72, 54],
[15, 16, 47, 78, 55],
[],
[],
[],
[],
[92, 95, 62, 67, 71, 94, 93, 96],
[81, 61, 68],
[],
[],
[88, 79, 73, 60],
[83, 19, 23, 18, 22, 49, 20, 91],
[],
[],
[]])
    
i_t2=Vector{Vector{Int64}}([[52, 18, 45, 46, 8, 83, 60, 5, 84, 17, 91, 85, 98, 100, 37, 93, 96, 89],
[],
[],
[],
[],
[],
[95, 92, 42, 15, 14, 38, 86, 44, 16, 61, 99, 59, 87, 2, 57, 43, 97, 94, 6, 13, 58],
[],
[21, 73, 72, 39, 67, 23, 56, 75, 22, 41, 74, 4, 55, 25, 24, 54, 26],
[],
[],
[],
[],
[],
[],
[],
[],
[],
[27, 31, 88, 62, 11, 64, 36, 49, 19, 47, 48, 82, 7, 10, 63, 90, 32, 66, 20, 70],
[69, 1, 30, 51, 33, 71, 65, 9, 81, 79, 29, 78, 35, 34, 3, 68, 80, 77, 50],
[],
[],
[],
[],
[28, 76, 12, 40, 53]])

a = init_pop_cheat(i_t0, 0)
println(a.individuals[1].fitness)
println(a.individuals[1].feasible)

