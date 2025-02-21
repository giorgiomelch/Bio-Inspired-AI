using Plots
using Random

function plot_fitness_evolution(pop::Population)
    mean_fitness = pop.mean_fitness
    min_fitness = pop.min_fitness
    # Creazione del grafico
    p = plot(1:length(mean_fitness), mean_fitness, label="Mean", lw=2, color=:blue, linestyle=:solid)  # Media
    plot!(p, 1:length(min_fitness), min_fitness, label="Minimum", lw=2, color=:red, linestyle=:solid)  # Minimo
    xlabel!(p, "Iteration")  # Etichetta asse x
    ylabel!(p, "Fitness")  # Etichetta asse y
    title!(p, "Fitness Evolution")  # Titolo
    display(p)  # Mostra il grafico finale
end


function plot_routes(depot::Depot, routes::Vector{Route})
    colors = distinguishable_colors(length(routes))

    # Creazione del grafico
    p = scatter([depot.x_coord], [depot.y_coord], markershape=:circle, label="Depot", markersize=8, color=:black)

    all_patients = []
    for route in routes
        append!(all_patients, route.patients)
    end

    scatter!(p, [p.x_coord for p in all_patients], [p.y_coord for p in all_patients],
             markershape=:square, label="Patients", markersize=4, color=:black)

    for (i, route) in enumerate(routes)
        if !isempty(route.patients)
            route_x = [depot.x_coord; [p.x_coord for p in route.patients]; depot.x_coord]
            route_y = [depot.y_coord; [p.y_coord for p in route.patients]; depot.y_coord]
            plot!(p, route_x, route_y, lw=2, color=colors[i]) #label="Nurse $(route.nurse.id)",
        end
    end

    title!("Home Care Routing Solution")
    plot!(p, legend=false, grid=false)
    
    display(p)
end
