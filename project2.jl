"""using Random

# Parametri
const NUM_NURSES = 5  # Numero massimo di infermiere
const NUM_PATIENTS = 10  # Numero di pazienti
const DEPOT = 0  # Punto di partenza e ritorno
const WORK_HOURS = 8 * 60  # 8 ore convertite in minuti

# Generazione casuale di dati (distanze e tempi di assistenza)
Random.seed!(42)
distances = rand(5:30, NUM_PATIENTS + 1, NUM_PATIENTS + 1)
time_required = rand(20:60, NUM_PATIENTS)  # Tempo richiesto per ogni paziente

# Simulazione delle finestre di disponibilità per i pazienti
availability_windows = [(rand(0:600), rand(601:1200)) for _ in 1:NUM_PATIENTS]

function evaluate(individual)
    total_time = fill(0, NUM_NURSES)
    routes = [Int[] for _ in 1:NUM_NURSES]
    arrival_time = fill(0, NUM_NURSES)
    
    for (patient, nurse) in enumerate(individual)
        if nurse != -1 && nurse <= NUM_NURSES
            travel_time = distances[DEPOT+1, patient+1] + distances[patient+1, DEPOT+1]
            window_start, window_end = availability_windows[patient]
            wait_time = max(0, window_start - arrival_time[nurse])
            
            if arrival_time[nurse] + travel_time + wait_time > window_end
                wait_time += (arrival_time[nurse] + travel_time - window_end)  # Penalità se arriva troppo tardi
            end
            
            total_time[nurse] += travel_time + wait_time + time_required[patient]
            push!(routes[nurse], patient)
            arrival_time[nurse] += travel_time + wait_time + time_required[patient]
        end
    end
    
    penalty = sum(max(0, t - WORK_HOURS) for t in total_time)
    used_nurses = count(!isempty, routes)
    
    return sum(total_time) + penalty + (used_nurses * 100)
end

function create_individual()
    assignment = fill(-1, NUM_PATIENTS)
    patients = shuffle(collect(1:NUM_PATIENTS))
    nurses = shuffle(collect(1:NUM_NURSES))
    
    for (i, p) in enumerate(patients)
        assignment[i] = nurses[(i - 1) % NUM_NURSES + 1]
    end
    return assignment
end

function cx_swap(ind1, ind2)
    size = length(ind1)
    a, b = sort(randperm(size)[1:2])
    ind1[a], ind2[b] = ind2[b], ind1[a]
    return ind1, ind2
end

function mut_shuffle(individual)
    patients = filter(x -> x != -1, individual)
    if length(patients) > 1
        a, b = randperm(length(patients))[1:2]
        patients[a], patients[b] = patients[b], patients[a]
        idx = 1
        for i in eachindex(individual)
            if individual[i] != -1
                individual[i] = patients[idx]
                idx += 1
            end
        end
    end
    return individual
end

function genetic_algorithm()
    pop = [create_individual() for _ in 1:50]
    NGEN = 100
    CXPB, MUTPB = 0.7, 0.2
    
    for _ in 1:NGEN
        offspring = deepcopy(pop)
        
        for i in 1:2:length(offspring)-1
            if rand() < CXPB
                cx_swap(offspring[i], offspring[i+1])
            end
        end
        
        for i in eachindex(offspring)
            if rand() < MUTPB
                mut_shuffle(offspring[i])
            end
        end
        
        fitnesses = [evaluate(ind) for ind in offspring]
        pop = offspring[sortperm(fitnesses)][1:50]
    end
    
    return pop[1]
end

best_solution = genetic_algorithm()
println("Migliore soluzione trovata:", best_solution)"""

using Random
using Plots

# Parametri di configurazione
const NUM_NURSES = 5  # Numero massimo di infermiere
const NUM_PATIENTS = 10  # Numero di pazienti
const DEPOT = 0  # Punto di partenza e ritorno
const WORK_HOURS = 8 * 60  # 8 ore convertite in minuti

# Generazione casuale di dati (distanze e tempi di assistenza)
Random.seed!(rand(1:10000))  # Cambia il seed ad ogni esecuzione

# Distanze casuali tra il deposito e i pazienti, e tra i pazienti tra loro
distances = rand(5:30, NUM_PATIENTS + 1, NUM_PATIENTS + 1)

# Tempi di assistenza casuali per ciascun paziente
time_required = rand(20:60, NUM_PATIENTS)  # Tempo richiesto per ogni paziente
 
# Simulazione delle finestre di disponibilità per i pazienti
availability_windows = [(rand(0:600), rand(601:1200)) for _ in 1:NUM_PATIENTS]

# Funzione per valutare la qualità di una soluzione
function evaluate(individual)
    total_time = fill(0, NUM_NURSES)  # Tempo totale di lavoro per ogni infermiera
    travel_time_total = 0  # Tempo totale di viaggio (da minimizzare)
    routes = [Int[] for _ in 1:NUM_NURSES]  # Lista di pazienti assegnati per infermiera
    arrival_time = fill(0, NUM_NURSES)  # Orario di arrivo per ogni infermiera
    
    # Assegnazione dei pazienti alle infermiere
    for (patient, nurse) in enumerate(individual)
        if nurse != -1 && nurse <= NUM_NURSES  # Verifica se l'infermiera è valida
            travel_time = distances[DEPOT+1, patient+1] + distances[patient+1, DEPOT+1]  # Tempo di viaggio
            window_start, window_end = availability_windows[patient]  # Finestra temporale per il paziente
            wait_time = max(0, window_start - arrival_time[nurse])  # Tempo di attesa (se necessario)
            
            # Penalità se l'infermiera arriva troppo tardi
            if arrival_time[nurse] + wait_time > window_end
                wait_time += (arrival_time[nurse] + wait_time - window_end)  
            end
            
            # Aggiungi il tempo di assistenza (solo tempo di lavoro, senza il viaggio)
            total_time[nurse] += time_required[patient]  # Solo il tempo di assistenza
            travel_time_total += travel_time  # Somma il tempo di viaggio totale
            push!(routes[nurse], patient)  # Aggiungi il paziente al percorso dell'infermiera
            arrival_time[nurse] += time_required[patient] + wait_time  # Nuovo orario di arrivo (senza il viaggio)
        end
    end
    
    # Penalità per superamento delle ore di lavoro
    penalty = sum(max(0, t - WORK_HOURS) for t in total_time)
    used_nurses = count(!isempty, routes)  # Numero di infermiere effettivamente utilizzate
    
    # Funzione obiettivo finale: minimizza il tempo di lavoro delle infermiere e il tempo di viaggio
    return sum(total_time) + penalty + (used_nurses * 100) + travel_time_total  # Minimizziamo il totale del tempo di viaggio
end


# Funzione per creare una soluzione casuale
function create_individual()
    # Assegna i pazienti casualmente alle infermiere
    assignment = shuffle(collect(1:NUM_NURSES))[mod1.(collect(1:NUM_PATIENTS), NUM_NURSES)]
    return assignment
end

# Funzione di crossover per scambiare pazienti tra due soluzioni
function cx_swap(ind1, ind2)
    size = length(ind1)
    a, b = sort(randperm(size)[1:2])  # Seleziona due indici casuali
    ind1[a], ind2[b] = ind2[b], ind1[a]  # Scambia i pazienti tra le soluzioni
    return ind1, ind2
end

# Funzione di mutazione per mescolare le assegnazioni dei pazienti
function mut_shuffle(individual)
    patients = shuffle(filter(x -> x != -1, individual))  # Rimescola i pazienti
    idx = 1
    for i in eachindex(individual)
        if individual[i] != -1
            individual[i] = patients[idx]  # Riassegna i pazienti
            idx += 1
        end
    end
    return individual
end

# Funzione per eseguire l'algoritmo genetico
function genetic_algorithm()
    pop = [create_individual() for _ in 1:50]  # Popolazione iniziale di soluzioni
    NGEN = 200  # Numero di generazioni
    CXPB, MUTPB = 0.8, 0.4  # Probabilità di crossover e mutazione
    
    best_fitness = Inf  # Fitness migliore iniziale (valore più alto possibile)
    best_solution = nothing  # Soluzione migliore iniziale
    
    for gen in 1:NGEN
        offspring = deepcopy(pop)  # Crea una copia della popolazione
        
        # Crossover: scambia soluzioni tra coppie di individui
        for i in 1:2:length(offspring)-1
            if rand() < CXPB
                cx_swap(offspring[i], offspring[i+1])
            end
        end
        
        # Mutazione: modifica casualmente alcune soluzioni
        for i in eachindex(offspring)
            if rand() < MUTPB
                mut_shuffle(offspring[i])
            end
        end
        
        # Valutazione delle soluzioni
        fitnesses = [evaluate(ind) for ind in offspring]
        
        # Se troviamo una soluzione migliore, aggiorniamo
        best_idx = argmin(fitnesses)
        if fitnesses[best_idx] < best_fitness
            best_fitness = fitnesses[best_idx]
            best_solution = offspring[best_idx]
        end
        
        # Seleziona le migliori 50 soluzioni per la prossima generazione
        pop = offspring[sortperm(fitnesses)][1:50]
        
        # Mostriamo il miglior fitness di ogni generazione
        println("Generazione $gen: Migliore fitness = $best_fitness")
    end
    
    return best_solution  # Restituisci la migliore soluzione trovata
end

# Funzione per tracciare i percorsi sul grafico
function plot_routes(best_solution)
    # Coordinate casuali per i pazienti
    coordinates = [(rand(0:100), rand(0:100)) for _ in 1:NUM_PATIENTS]
    depot = (rand(0:100), rand(0:100))  # Unico deposito

    # Crea un grafico scatter per i percorsi
    scatter_plot = scatter()

    # Aggiungi il deposito al grafico senza etichetta
    scatter!(scatter_plot, depot[1], depot[2], color=:blue, markersize=6, label="")
    
    # Aggiungi i pazienti al grafico
    for i in 1:NUM_PATIENTS
        if i == 1
            scatter!(scatter_plot, coordinates[i][1], coordinates[i][2], label="Paziente", color=:red, markersize=6)
        else
            scatter!(scatter_plot, coordinates[i][1], coordinates[i][2], color=:red, markersize=6)
        end
        
        # Aggiungi il numero del paziente sopra il punto
        annotate!(coordinates[i][1], coordinates[i][2] + 2, text("Paziente $i", :black, 8))
    end
    
    # Colori distinti per ciascuna infermiera
    infermiere_colors = [:green, :purple, :orange, :cyan, :magenta]
    
    # Disegna i percorsi per ogni infermiera
    for nurse in 1:NUM_NURSES
        route = []
        push!(route, depot)  # Inizia dal deposito
        for (patient, assigned_nurse) in enumerate(best_solution)
            if assigned_nurse == nurse
                push!(route, coordinates[patient])  # Aggiungi paziente al percorso
            end
        end
        push!(route, depot)  # Torna al deposito
        
        # Traccia il percorso dell'infermiera
        for i in 1:length(route)-1
            plot!(scatter_plot, [route[i][1], route[i+1][1]], [route[i][2], route[i+1][2]], 
                  color=infermiere_colors[nurse], linewidth=2)
        end
    end
    
    # Impostazioni finali del grafico
    xlabel!("X")
    ylabel!("Y")
    title!("Percorsi delle Infermiere e Pazienti")
    
    # Disabilita completamente la legenda
    scatter_plot = scatter_plot |> (p -> plot!(p, legend=false))
    
    return scatter_plot
end

# Eseguiamo l'algoritmo genetico per trovare la migliore soluzione
best_solution = genetic_algorithm()
println("Migliore soluzione trovata:", best_solution)

# Visualizziamo i percorsi delle infermiere
display(plot_routes(best_solution))  # Usando display per forzare la visualizzazione
