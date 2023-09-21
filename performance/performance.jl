include("solver.jl")

guesses = readdlm("../data/wordle-Ta.txt", '\\', String)
targets = readdlm("../data/wordle-La.txt", '\\', String)
for solution in targets
    for first_guess in guesses
        n_guess = solve(; solution=solution, first_guess=first_guess, verbose=n, α=-1)
        