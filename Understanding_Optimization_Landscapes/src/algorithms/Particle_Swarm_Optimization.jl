using Random, Statistics
include("../fitness_function.jl")
include("../plotter.jl")
include("_initialization.jl")
include("_selection.jl")
include("_crossover.jl")
include("_mutation.jl")

# Definizione della struttura di una particella
mutable struct Particle
    position::Vector{Bool}      # Vettore binario che rappresenta la selezione delle caratteristiche
    velocity::Vector{Float64}   # Velocità in ogni dimensione
    best_position::Vector{Bool} # Migliore posizione trovata dalla particella
    best_fitness::Float64       # Valore di fitness della migliore posizione
end

# Funzione sigmoidea per la trasformazione della velocità in probabilità
sigmoid(x) = 1.0 / (1.0 + exp(-x))

function evaluate_fitness(particle::Particle, lookup_table)
    error, accuracy = fitness_function(Int.(particle.position), lookup_table)
    return error
end

# Inizializzazione delle particelle
function initialize_particles(num_particles::Int, dim::Int, lookup_table)
    particles = Particle[]
    for i in 1:num_particles
        position = rand(Bool, dim)
        velocity = randn(dim)  # Velocità iniziale casuale
        best_position = copy(position)
        # Viene valutato il fitness iniziale
        initial_fitness = evaluate_fitness(Particle(position, velocity, best_position, 0.0), lookup_table)
        push!(particles, Particle(position, velocity, best_position, initial_fitness))
    end
    return particles
end

# Aggiornamento della particella usando la formula standard di PSO adattata al binario
function update_particle!(particle::Particle, global_best::Vector{Bool}, w::Float64, c1::Float64, c2::Float64)
    dim = length(particle.position)
    for d in 1:dim
        r1 = rand()
        r2 = rand()
        # Aggiornamento della velocità
        particle.velocity[d] = w * particle.velocity[d] +
                                c1 * r1 * (particle.best_position[d] - particle.position[d]) +
                                c2 * r2 * (global_best[d] - particle.position[d])
        # Aggiornamento della posizione usando la funzione sigmoidea
        prob = sigmoid(particle.velocity[d])
        particle.position[d] = rand() < prob
    end
end

# Ciclo principale dell'algoritmo PSO
function particle_swarm_optimization(lookup_table, dim::Int, num_particles::Int,  max_iter::Int, w::Float64, c1::Float64, c2::Float64, global_optimum)
    mean_fitness = Float64[]
    minimum_fitness = Float64[]
    n_iteration_required_to_best_fiteness = +Inf

    particles = initialize_particles(num_particles, dim, lookup_table)
    
    # Inizializzazione del miglior globale
    global_best = particles[1].position
    global_best_fitness = evaluate_fitness(particles[1], lookup_table)
    
    for particle in particles
        fitness = evaluate_fitness(particle, lookup_table)
        if fitness > global_best_fitness
            global_best = copy(particle.position)
            global_best_fitness = fitness
            push!(mean_fitness, mean(fitness))
            push!(minimum_fitness, minimum(fitness))
        end
    end
    
    # Ciclo delle iterazioni
    for iter in 1:max_iter
        fitness_vector = Float64[]
        for particle in particles
            update_particle!(particle, global_best, w, c1, c2)
            fitness = evaluate_fitness(particle, lookup_table)
            # Aggiornamento del miglior personale della particella
            if fitness < particle.best_fitness
                particle.best_position = copy(particle.position)
                particle.best_fitness = fitness
            end
            # Aggiornamento del miglior globale se necessario
            if fitness < global_best_fitness
                global_best = copy(particle.position)
                global_best_fitness = fitness
            end

            push!(fitness_vector, fitness)
            push!(fitness_vector, fitness)
        end
        push!(mean_fitness, mean(fitness_vector))
        push!(minimum_fitness, minimum(fitness_vector))
        if global_optimum == global_best_fitness && n_iteration_required_to_best_fiteness == +Inf
            n_iteration_required_to_best_fiteness = iter
        end
    end
    
    plot_fitness_evolution(mean_fitness, minimum_fitness)
    return global_best_fitness, Int.(global_best), n_iteration_required_to_best_fiteness
end
