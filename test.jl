using Test
include("solver.jl")
include("utils.jl")

@testset "Basic usage" begin
    @testset "simple cases" begin
        @test solve(; solution="alpha", first_guess="alpha", verbose=false) == 1
        @test solve(; solution="lusty", first_guess="salet", verbose=false) == 2
        @test solve(; solution="slate", first_guess="salet", verbose=false) == 3
        @test isa(solve(; solution="large", first_guess="small", verbose=false), Int)
        @test isa(solve(; solution="baker", first_guess="soare", verbose=false), Int)
        @test isa(solve(; solution="alpha", first_guess="soare", verbose=false), Int)
    end

    @testset "repeat letter cases" begin
        @test isa(solve(; solution="belie", first_guess="salet", verbose=false), Int)
        @test isa(solve(; solution="alpha", first_guess="salet", verbose=false), Int)
        @test isa(solve(; solution="apply", first_guess="salet", verbose=false), Int)
        @test isa(solve(; solution="belle", first_guess="salet", verbose=false), Int)
        @test isa(solve(; solution="belly", first_guess="salet", verbose=false), Int)
        @test isa(solve(; solution="sheep", first_guess="zesty", verbose=false), Int)
        @test isa(solve(; solution="gooey", first_guess="reast", verbose=false), Int)
        @test isa(solve(; solution="aping", first_guess="soare", verbose=false), Int)
    end
end

@testset "utils" begin
    @testset "get_match" begin
        @test get_match("aaaaa", "dbcsd") == [0, 0, 0, 0, 0]
        @test get_match("aaaaa", "ababb") == [2, 0, 2, 0, 0]
        @test get_match("aabbb", "bbbac") == [1, 0, 2, 1, 1]
        @test get_match("alpha", "pasta") == [1, 0, 1, 0, 2]
        @test get_match("slate", "salet") == [2, 1, 1, 1, 1]
        @test get_match("small", "large") == [0, 0, 1, 1, 0]
        @test get_match("sitar", "gooey") == [0, 0, 0, 0, 0]
        @test get_match("reast", "gooey") == [0, 1, 0, 0, 0]
        @test get_match("scope", "gooey") == [0, 0, 2, 0, 1]
        @test get_match("abort", "slate") == [1, 0, 0, 0, 1]
        @test get_match("aging", "aping") == [2, 0, 2, 2, 2]
        @test get_match("onion", "union") == [0, 2, 2, 2, 2]
        @test get_match("talar", "baker") == [0, 2, 0, 0, 2]
        @test get_match("tweep", "baker") == [0, 0, 0, 2, 0]
    end

    @testset "is_valid false" begin
        @test is_valid("blame", [2, 2, 2, 2, 2], "salet") == false
        @test is_valid("blame", [0, 0, 2, 1, 2], "crane") == false
        @test is_valid("blame", [0, 0, 2, 0, 1], "crane") == false
        @test is_valid("scope", [0, 0, 2, 0, 1], "gooey") == false
    end

    @testset "is_valid anagram" begin
        @test is_valid("salet", [2, 1, 1, 1, 1], "slate") == true
    end

    @testset "is_valid partial match false" begin
        @test is_valid("aging", [2, 0, 2, 2, 2], "aging") == false
        @test is_valid("union", [0, 2, 2, 2, 2], "union") == false
        @test is_valid("later", [0, 0, 0, 2, 0], "tweep") == false
    end

    @testset "is_valid partial match true" begin
        @test is_valid("blame", [0, 0, 2, 0, 2], "crane") == true
        @test is_valid("large", [0, 0, 1, 1, 0], "small") == true
        @test is_valid("sitar", [0, 0, 0, 0, 0], "gooey") == true
        @test is_valid("scope", [0, 0, 2, 1, 0], "gooey") == true
        @test is_valid("acute", [0, 0, 1, 2, 2], "slate") == true
        @test is_valid("onion", [0, 2, 2, 2, 2], "union") == true
        @test is_valid("baker", [0, 2, 0, 0, 2], "talar") == true
    end

    @testset "get_target_frequencies" begin
        freqs = get_target_frequencies(["apple", "grape"])
        @test freqs[1]['a'] == 0.5
        @test freqs[5]['e'] == 1
    end
end
