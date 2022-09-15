alphabet = "abcdefghijklmnopqrstuvwxyz"
function dict_alphabet(; value=0)
    alphabet_dict = Dict{Char,Number}()
    for character in alphabet
        alphabet_dict[character] = value
    end
    return alphabet_dict
end
dict_alphabet_zeros = dict_alphabet()

"""find the word with the best entropy"""
function try_word(dictionary, targets; α=1, verbose::Bool=true, n_show::Int=5)
    if length(targets) <= 2
        return targets[1]
    end

    # dict of words containing their expected entropy
    best_guess = Dict("1" => -Inf64)
    if verbose && n_show > 1
        for i in 2:n_show
            best_guess[string(i)] = -Inf64
        end
    end

    target_frequencies = nothing
    if α == -2
        target_frequencies = get_target_frequencies(targets)
    end

    for guess in dictionary
        if α >= -1
            guess_score = entropy(guess, targets; α=α)
        elseif α == -2
            guess_score = frequency_score(guess, target_frequencies)
        end

        (min_val, min_key) = findmin(best_guess)
        if guess_score > min_val
            delete!(best_guess, min_key)
            best_guess[guess] = guess_score
        end
    end
    if verbose
        best_guess_sort = sort(collect(best_guess), by=x -> x[2], rev=true)
        println("Best guesses: ")
        for (word, val) in best_guess_sort
            println("\t$word ($val)")
        end
        println("")
    end
    return findmax(best_guess)[2]
end

"""Return  with probability of each letter in each position"""
function get_target_frequencies(targets)
    freqs = Vector(undef, 5)
    for i in 1:5
        freqs[i] = copy(dict_alphabet_zeros)
    end

    for word in targets
        for (position, character) in zip(freqs, word)
            position[character] += 1
        end
    end

    n_targets = length(targets)
    for position in freqs
        for character in alphabet
            position[character] /= n_targets
        end
    end
    return freqs
end

"Based on Deedy, a simple and fast frequency-based heuristic.
p(letter in each position) + 0.5 p(letter not in this position)"
function frequency_score(guess, target_frequencies)
    score = 0.0
    for (i, character) in enumerate(guess)
        score += target_frequencies[i][character]
    end

    for (i, character) in enumerate(guess)
        for j in 1:5
            if i != j
                score += 0.5 * target_frequencies[i][character]
            end
        end
    end

    return score
end

"Get the Renyi entropy gained by guessing this guess against the remaining words."
function entropy(guess::String, words::Array{String}; α::Number=1)
    # get colour frequencies
    colourings = Dict{Vector{Int},Float64}()
    # normalise frequencies by using normalised increment
    step = 1 / length(words)
    for word in words
        match = get_match(guess, word)
        if haskey(colourings, match)
            colourings[match] += step
        else
            colourings[match] = step
        end
    end

    # compute entropy of this guess
    entropy = 0.0
    if α == 1
        for (_, v) in colourings
            entropy -= v * log2(v)
        end
    elseif α == Inf
        entropy -= maximum(values(colourings))
    else
        for (_, v) in colourings
            entropy += v^α
        end
        entropy = log2(entropy) / (1 - α)
    end
    return entropy
end

function target_filter(guess, match, targets)
    valid_targets = is_valid(targets, match, guess)
    return targets[valid_targets]
end


"Is this word valid with a given match (colouring) and match word?"
function is_valid(word::String, match, match_word)
    # words without exact matches 2 are invalid
    for (i, char_match) in enumerate(match)
        if char_match == 2 && word[i] != match_word[i]
            return false
        end
    end

    # count the occurances of available characters
    match_dict = Dict{Char,Int8}()
    for (i, char) in enumerate(match_word)
        if match[i] == 2 || match[i] == 0
            continue
        elseif haskey(match_dict, char)
            match_dict[char] += 1
        else
            match_dict[char] = 1
        end
    end

    word_bad_match = collect(match_word)[match.==0]
    # for each character of the guess
    for (i, char) in enumerate(word)
        # if the character is in the bad list
        if char in word_bad_match && match[i] == 0
            # check if available to play
            if haskey(match_dict, char) && match_dict[char] > 0
                match_dict[char] -= 1
                # otherwise invalid word
            else
                return false
            end
        end
    end

    # words without all partial matches 1 are invalid
    partial_chars = collect(match_word)[match.==1]
    for char in partial_chars
        if !(char in word)
            return false
        end
    end

    # partial matches cannot be in correct spot
    partial_positions = match .== 1
    for (i, is_par_char) in enumerate(partial_positions)
        if is_par_char && word[i] == match_word[i]
            return false
        end
    end
    return true
end

"Which of the guesses are valid given the colours (match) of the match word?"
function is_valid(guesses::Array{String}, match, match_word)
    valid = ones(Bool, length(guesses))
    for (j, word) in enumerate(guesses)
        valid[j] = is_valid(word, match, match_word)
    end
    return valid
end

function user_match()
    print("Enter matches:")
    line = readline()
    colours = parse.(Int, split(line, " "))
    valid_cols = [0, 1, 2]
    for col in colours
        @assert (col in valid_cols) "Colour must be 0 (grey), 1 (yellow) or 2 (green)"
    end
    @assert (length(colours) == 5) "Must give 5 colours."
    return colours
end

function get_unique_count(word)
    unique_count = Dict{Char,Int8}()
    for (i, char) in enumerate(word)
        if haskey(unique_count, char)
            unique_count[char] += 1
        else
            unique_count[char] = 1
        end
    end
    return unique_count
end

function get_match(guess, solution)
    match = zeros(Int64, 5)
    unique_count = get_unique_count(solution)
    for (i, (char, char_soln)) in enumerate(zip(guess, solution))
        if char == char_soln
            match[i] = 2
            unique_count[char] -= 1
        end
    end
    for (i, char) in enumerate(guess)
        if match[i] != 2 && haskey(unique_count, char)
            in_soln = char in solution
            available = unique_count[char] >= 1
            if in_soln && available
                match[i] = 1
                unique_count[char] -= 1
            else
                match[i] = 0
            end
        end
    end
    return match
end
