using Plots

function plot_fitness_evolution(mean_fitness::Vector{Float64}, minimum_fitness::Vector{Float64}, title_string)
    p = plot(1:length(mean_fitness), mean_fitness, label="Mean fitness", lw=2, color=:blue, linestyle=:solid)
    plot!(p, 1:length(minimum_fitness), minimum_fitness, label="Minimum fitness", lw=2, color=:green, linestyle=:solid)
    xlabel!(p, "Iteration")
    ylabel!(p, "Fitness")
    title!(p, title_string*" - Fitness Evolution")
    display(p)
end

function plot_humming_distance_evolution(distance::Vector{Float64}, title_string)
    p = plot(1:length(distance), distance, label="Hamming distance", lw=2, color=:grey, linestyle=:solid)
    xlabel!(p, "Iteration")
    ylabel!(p, "Hamming distance")
    title!(p, title_string*" - Hamming distance Evolution")
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
        xlim=(0, 16),
        ylim=(0, 1))
    display(p)
end

function plot_pareto_evolution(survivors_per_iteration)
    plot()
    colors = palette(:heat, length(survivors_per_iteration))

    for (i, (fitness, features)) in enumerate(survivors_per_iteration)
        label = (i % 5 == 0) ? "Gen $i" : ""  
        scatter!(features, fitness, label=label, color=colors[i], markersize=3, alpha=0.6)
    end
    xlabel!("Number of features used")
    ylabel!("Error")
    xlims!(0, 16)
    ylims!(0, 1)
    title!("Population Evolution over time")
    display(plot!())
end
