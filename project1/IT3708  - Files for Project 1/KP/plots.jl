using Plots

function plot_fitness_evolution(mean_fitness::Vector{Float64}, max_fitness::Vector{Float64}, min_fitness::Vector{Float64})
    # Creazione del grafico
    p = plot(1:length(mean_fitness), mean_fitness, label="Mean", lw=2, color=:blue, linestyle=:solid)  # Media
    plot!(p, 1:length(max_fitness), max_fitness, label="Maximum", lw=2, color=:green, linestyle=:solid)  # Massimo
    plot!(p, 1:length(min_fitness), min_fitness, label="Minimum", lw=2, color=:red, linestyle=:solid)  # Minimo
    xlabel!(p, "Iteration")  # Etichetta asse x
    ylabel!(p, "Fitness")  # Etichetta asse y
    title!(p, "Fitness Evolution")  # Titolo
    ylims!(p, 1, 300_000)
    display(p)  # Mostra il grafico finale
end
function plot_humming_distance(distance::Vector{Float64})
    p = plot(1:length(distance), distance, label="Distance", lw=2, color=:black, linestyle=:solid)  # Distance
    xlabel!(p, "Iteration")  # Etichetta asse x
    ylabel!(p, "Distance")  # Etichetta asse y
    title!(p, "Distance Evolution")  # Titolo
    display(p)  # Mostra il grafico finale
end