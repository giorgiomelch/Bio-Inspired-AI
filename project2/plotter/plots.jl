using Plots
using Random

function plot_routes(depot, patients, routes)
    colors = distinguishable_colors(length(routes))
    
    # Creazione del grafico
    p = scatter([depot[:x]], [depot[:y]], markershape=:circle, label="Depot", markersize=15, color=:black)
    scatter!(p, [p[:x] for p in patients], [p[:y] for p in patients], markershape=:square, label="Patients", markersize=3, color=:black)
    
    for (i, route) in enumerate(routes)
        if !isempty(route)
            route_x = [depot[:x]; [patients[p][:x] for p in route]; depot[:x]]
            route_y = [depot[:y]; [patients[p][:y] for p in route]; depot[:y]]
            plot!(p, route_x, route_y, lw=2, label="Nurse $(i)", color=colors[i])
        end
    end
    
    # Impostazioni del grafico
    title!("Home Care Routing Solution")
    plot!(p, legend=:topright, axis=false, grid=false)
    
    # Mostra il grafico
    display(p)
end

# Esempio di dati
depot = Dict(:x => 0, :y => 0)
patients = [Dict(:x => rand(-10:10), :y => rand(-10:10)) for _ in 1:10]
routes = [[1, 3, 5], [2, 4, 6, 8], [7, 9, 10]]

# Plot delle rotte
plot_routes(depot, patients, routes)
