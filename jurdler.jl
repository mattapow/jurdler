include("solver.jl")

"""
Command line interface to jurdler solver.
After "julia jurdler.jl" the cli arguments are ordered as follows:

1) solution word - a five letter target word
2) first word - a five letter word as the first guess start
3) verbose - `y` or `n` whether or not to be verbose as it solves (what each guess is, other possible guesses and the remaining valid words)
4) alpha - the value of alpha in the Renyi divergence. Default is `1` for usual meausure of entropy. For alpha = infinity (i.e. minimise the maximum bin size) enter `-1`. For the frequency based method in Deedy, enter `-2`.
5) n_show - number of best possible guesses to show.

# Examples
```
julia jurdler.jl trait raise y -1 10
```
will solve for the word "trait" using "raise" as the start word. It will be verbose (y) and use a min-max entropy method (-1). At each guess it will also show the 10 best other guesses (NB: there may be a long list of equally good words).
"""
function jurdler(ARGS)
    if length(ARGS) == 0
        solve()
    elseif length(ARGS) == 1
        solve(; solution=ARGS[1])
    elseif length(ARGS) == 2
        first_guess = string(ARGS[2])
        solve(; solution=ARGS[1], first_guess=first_guess)
    elseif length(ARGS) == 3
        first_guess = string(ARGS[2])
        verbose = string(ARGS[3])
        verbose in ["yes", "Yes", "YES", "true", "True", "TRUE", "y", "Y"] ? verbose = true : verbose = false
        solve(; solution=ARGS[1], first_guess=first_guess, verbose=verbose)
    elseif length(ARGS) == 4
        first_guess = string(ARGS[2])
        verbose = string(ARGS[3])
        verbose in ["yes", "Yes", "YES", "true", "True", "TRUE", "y", "Y"] ? verbose = true : verbose = false
        α = parse(Int, ARGS[4])
        α == -1 ? α = Inf : α = α
        solve(; solution=ARGS[1], first_guess=first_guess, verbose=verbose, α=α)
    elseif length(ARGS) == 5
        first_guess = string(ARGS[2])
        verbose = string(ARGS[3])
        verbose in ["yes", "Yes", "YES", "true", "True", "TRUE", "y", "Y"] ? verbose = true : verbose = false
        α = parse(Int, ARGS[4])
        n_show = parse(Int, ARGS[5])
        α == -1 ? α = Inf : α = α
        solve(; solution=ARGS[1], first_guess=first_guess, verbose=verbose, α=α, n_show=n_show)
    else
        throw("Invalid number of inputs")
    end
end

jurdler(ARGS)
