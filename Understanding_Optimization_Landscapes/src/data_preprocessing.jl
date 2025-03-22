using CSV, DataFrames

# Percorso del file
student_performance_data_path = joinpath(@__DIR__, "..", "data", "Student_performance_data.csv")

# Leggi il dataset
df = CSV.read(student_performance_data_path, DataFrame)
println(df[end, :GradeClass])
# Converti l'ultima riga della colonna "GradeClass" in intero
df[end, :GradeClass] = Int64(round(df[end, :GradeClass]))

# Salva il file modificato
output_path = joinpath(@__DIR__, "..", "data", "Student_performance_data_modified.csv")
CSV.write(output_path, df)

println("File modificato salvato con successo in: ", output_path)
