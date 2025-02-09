struct Depot
    return_time::Float64
    x_coord::Int
    y_coord::Int
end

struct Patient
    id::Int
    demand::Float64          # demand strain
    care_time::Float64       # cure time
    start_time::Float64      # time window (start)
    end_time::Float64        # time window (end)
    x_coord::Int64           # The x-coordinate of the patient’s location (only needed for plot)
    y_coord::Int64           # The y-coordinate of the patient’s location (only needed for plot) 
end

struct Nurse
    id::Int
    capacity::Float64         # maximum strain the nurse can handle
end

struct Route
    nurse::Nurse
    patients::Vector{Patient}  # sequence of patients
    start_time::Float64        # departure time from the depot (fixed to 0)
    depot_return_time::Float64 # maximum time to return to the depot

    function Route(nurse::Nurse, depot_return_time::Float64)
        new(nurse, Vector{Patient}(), 0.0, depot_return_time)
    end
end

mutable struct Individual
    route::Route
    fitness::Float64
    is_valid::Bool
    function Individual(route::Route)
        new(route, 0.0, false)
    end
end

struct Population
    population::Vector{Individual}
    N_POP::Int
    best_individual::Individual
end

struct HomeCareRoutingProblem
    travel_times::Matrix{Float64} # travel times between patients
    depot::Depot
    patients::Vector{Patient}
    nurse::Nurse
    nbr_nurses::Int
end