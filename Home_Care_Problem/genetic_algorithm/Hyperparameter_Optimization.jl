include("structs.jl")
include("parser.jl")
include("genetic_algorithm.jl")
include("initialization.jl")
include("fitness_function.jl")
include("selection.jl")
include("crossover.jl")
include("mutation.jl")
include("../plotter/plots.jl")
include("debug_time.jl")
using GaussianProcesses
using Random

# Funzione obiettivo per il tuning bayesiano
function objective(params)
    N_POP, POP_REPLACEMENT, TOURNAMENT_SIZE, N_GEN_SWAP_MUTATION, N_GEN_INVERSION, N_GEN_SHIFT = params
    N_POP = round(Int, N_POP)
    TOURNAMENT_SIZE = round(Int, TOURNAMENT_SIZE)
    N_GEN_SWAP_MUTATION = round(Int64, N_GEN_SWAP_MUTATION)
    N_GEN_INVERSION = round(Int64, N_GEN_INVERSION)
    N_GEN_SHIFT = round(Int64, N_GEN_SHIFT)
    
    # Chiamare il genetic_algorithm con i parametri specificati
    fitness = genetic_algorithm(problem, N_POP, POP_REPLACEMENT, 1000, TOURNAMENT_SIZE, N_GEN_SWAP_MUTATION, N_GEN_INVERSION, N_GEN_SHIFT)
    return fitness
end

# Inizializzazione della variabile problema
problem = load_home_care_problem("/home/giorgiomelch/BI_AI/workspace/genetic-algorithm/Home_Care_Problem/data/train_"* string(data_train_nbr) *".json")


# Definizione dello spazio degli iperparametri
lower_bounds = [50, 0.5, 2, 0.05, 0.05, 0.05]   # Bassi valori
upper_bounds = [200, 1.0, 10, 0.2, 0.15, 0.15] # Alti valori

# Creare un processo gaussiano
gp = GP(
    lower_bounds,     # Limiti inferiori per gli iperparametri
    upper_bounds,     # Limiti superiori per gli iperparametri
    kernel = SEKernel()  # Kernel di tipo SE (Square Exponential)
)

# Funzione di acquisizione (Expected Improvement)
function acquisition_function(gp, x)
    # Funzione di acquisizione, come Expected Improvement
    mean, var = predict(gp, x)
    return mean - 2 * sqrt(var)
end

# Algoritmo Bayesiano di Ottimizzazione
function bayesian_optimization(num_iterations::Int)
    # Inizializza il processo gaussiano
    for i in 1:num_iterations
        # Selezionare un punto da esplorare usando la funzione di acquisizione
        best_point = optimize(acquisition_function, gp)
        best_params = best_point.x  # Parametri ottimali suggeriti
        
        # Calcolare il valore della funzione obiettivo per il punto selezionato
        fitness = objective(best_params)
        
        # Aggiornare il processo gaussiano con il nuovo dato
        push!(gp, best_params, fitness)
        
        # Stampa dei progressi
        println("Iterazione: ", i, " - Parametri ottimizzati: ", best_params, " - Fitness: ", fitness)
    end
end

# Avviare l'ottimizzazione bayesiana
bayesian_optimization(10)
