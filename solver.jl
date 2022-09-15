using DelimitedFiles
include("utils.jl")

function solve(; solution=nothing, first_guess=nothing, verbose=true, α=1, n_show=3)
    # read in dictionary words
    guesses = readdlm("data/wordle-Ta.txt", '\\', String)
    targets = readdlm("data/wordle-La.txt", '\\', String)
    dictionary = vcat(copy(targets), guesses)
    guessed = []

    @assert typeof(first_guess) in [String, typeof(nothing)] "Incorrect input type"
    if typeof(first_guess) == String
        @assert length(first_guess) == 5 "First guess must be 5 letters."
        @assert (first_guess in dictionary) "First guess not in dictionary."
    end
    first_guess === nothing ? hot_start = false : hot_start = true
    solution === nothing ? interactive = true : interactive = false
    if !interactive
        @assert (solution in targets) "Solution word not in target dictionary."
    else
        println("""
\n====Interactive mode.====
Enter colour matches (0, 1 or 2) in one line with spaces.
Colour must be 0 (grey), 1 (yellow) or 2 (green).
E.G. 0 1 0 0 2 + enter\n""")
    end

    i = 0
    colour = nothing
    guess = nothing
    while colour != [2, 2, 2, 2, 2]
        i += 1
        length(targets) <= 0 && throw("No words left.")
        if length(targets) == 1
            guess = targets[1]
            break
        end
        if i == 1 && hot_start
            guess = first_guess
        else
            new_guess = try_word(dictionary, targets; α=α, verbose=verbose, n_show=n_show)
            if new_guess == guess
                throw("Same guess $guess twice in a row.")
            end
            guess = new_guess
        end
        verbose && println("Guess $i: $guess")
        if interactive
            colour = user_match()
        else
            colour = get_match(guess, solution)
        end
        targets = target_filter(guess, colour, targets)
        verbose && println("Remaining words: $(length(targets))\n")
        verbose && println("Remaining words: $targets\n")

        i == 50 && throw("Reached $i guesses. Something's wrong.")
    end

    !interactive && @assert guess == solution "Wrong answer found"
    println("Success, the answer on guess $i is $guess.")
    return i
end
