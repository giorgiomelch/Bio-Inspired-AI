using Plots

function plot_fitness_evolution(mean_fitness::Vector{Float64}, minimum_fitness::Vector{Float64})
    p = plot(1:length(mean_fitness), mean_fitness, label="Mean fitness", lw=2, color=:blue, linestyle=:solid)
    plot!(p, 1:length(minimum_fitness), minimum_fitness, label="Minimum fitness", lw=2, color=:green, linestyle=:solid)
    xlabel!(p, "Iteration")
    ylabel!(p, "Fitness")
    title!(p, "Fitness Evolution")
    display(p)
end

function plot_humming_distance_evolution(distance::Vector{Float64})
    p = plot(1:length(distance), distance, label="Hamming distance", lw=2, color=:grey, linestyle=:solid)
    xlabel!(p, "Iteration")
    ylabel!(p, "Hamming distance")
    title!(p, "Hamming distance Evolution")
    display(p)
end

function plot_NSGA2_population(errors::Vector{Float64}, n_feature_used::Vector{Int})
    p = plot(n_feature_used, errors, seriestype=:scatter, 
        xlabel="Number of features used", 
        ylabel="Error", 
        title="Distribution of the population", 
        legend=false, 
        markersize=5, 
        markercolor=:blue, 
        grid=true,
        ylim=(0, 1))
    display(p)
end