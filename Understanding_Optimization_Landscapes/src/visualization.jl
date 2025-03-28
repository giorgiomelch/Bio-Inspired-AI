using MultivariateStats
using Plots
include("lookup_table_manager.jl")

function plot_fitness_landscape_3d(fitness::Vector{Float64})
    N = length(fitness)
    n = round(Int, log2(N))

    # Genera tutte le possibili combinazioni da 1 a 2^n - 1
    binary_matrix = hcat([[parse(Int, string(i, base=2, pad=n)[j]) for j in 1:n] for i in 1:(2^n - 1)]...)
    
    # Trasponi la matrice per avere una riga per ogni combinazione
    binary_matrix = binary_matrix'
    # Applichiamo la PCA: convertiamo X a float e proiettiamo in 2D.
    pca_model = fit(PCA, binary_matrix; maxoutdim=2)
    pca_coords = MultivariateStats.transform(pca_model, binary_matrix)

    # Creiamo un grafico 3D: x e y sono le componenti PCA e z il fitness.
    scatter3d(pca_coords[:, 1], pca_coords[:, 2], fitness,
              marker_z = fitness,
              colorbar = true,
              xlabel = "PC1",
              ylabel = "PC2",
              zlabel = "Fitness Value",
              title = "Fitness Landscape - PCA",
              legend = false)
end

lookup_table = load_lookup_table("winequality-white.jls")
plot_fitness_landscape_3d(lookup_table)