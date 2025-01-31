function mutation_max_n_genes!(curr_pop::Matrix{Bool}, mutation_probability::Float64, n::Int64)
    num_rows, num_cols = size(curr_pop)
    # Per ogni genitore nella popolazione
    for i in 1:num_rows
        gene_to_mutate = randperm(num_cols)[1:n]  # Seleziona n geni casuali
        # Applica la mutazione con la probabilità specificata
        for j in eachindex(gene_to_mutate)
            if rand() < mutation_probability
                curr_pop[i, gene_to_mutate[j]] = !curr_pop[i, gene_to_mutate[j]]  # Inverte il valore del gene
            end
        end
    end
end