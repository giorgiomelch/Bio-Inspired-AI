function evaluate_population(pop::Matrix{Bool})
    n, m = size(pop)
    fitness_values = zeros(n)
    for i in 1:n
        # Convertire il bitstring da Bool a Stringa binaria
        bitstring = join(pop[i, :] .|> Int)  # Converti ogni Bool in Int e poi unisci in una stringa
        decimal_value = parse(Int, bitstring; base=2)  # Converti la stringa in un numero decimale

        max_value = 2^m - 1  # Valore massimo possibile con m bit
        scaled_value = (decimal_value / max_value) * 128  # Scala il valore nell'intervallo [0, 128]
        println(scaled_value)

        fitness_values[i] = sin(scaled_value) 
    end
    return fitness_values
end