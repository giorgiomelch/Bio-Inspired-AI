using Plots

function plot_fitness_evolution(mean_fitness::Vector{Float64}, max_fitness::Vector{Float64})
    p = plot(1:length(mean_fitness), mean_fitness, label="Mean accuracy", lw=2, color=:blue, linestyle=:solid)
    plot!(p, 1:length(max_fitness), max_fitness, label="Maximum accuracy", lw=2, color=:green, linestyle=:solid)
    xlabel!(p, "Iteration")
    ylabel!(p, "Fitness")
    title!(p, "Fitness Evolution")
    display(p)
end

function plot_NSGA2_population(fitness::Vector{Float64}, n_feature_used::Vector{Int})
    p = plot(n_feature_used, fitness, seriestype=:scatter, 
        xlabel="Numero di Feature Usate", 
        ylabel="Fitness (Accuratezza)", 
        title="Distribuzione della Popolazione", 
        legend=false, 
        markersize=5, 
        markercolor=:blue, 
        grid=true,
        ylim=(0, 1))
    display(p)
end