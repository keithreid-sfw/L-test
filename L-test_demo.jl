using DataFrames
using Distances
using HypothesisTests
using Plots
using Primes
using Test

# configuration

function get_base_n()
    base_n::Int64 = 34
    return base_n
end

function get_L()
    L::Float64    = 22.993
    return L
end

# model

function build_count_primes(primes::Vector{Int64})
    base_n                      = get_base_n()
    count_primes::Vector{Int64} = []
    for i in 2:base_n+1
        prime_count = sum([Int(isprime(x)) for x in 1:i])
        push!(count_primes, prime_count)
    end
    return count_primes
end

function build_primes(base_n::Int64)
    primes::Vector{Int64} = [prime(i) for i in 2:base_n+1]
    return primes
end

function build_xs_over_log_xs(base_n::Int64)
    xs_over_log_xs::Vector{Float64} = [x/log(x) for x in 2:base_n+1]
    return xs_over_log_xs
end

# view

function greet()
    println("\n\nHello and welcome to the L-test.")
    println("We use the Prime Counting function as a reference data set.")
end

# test

function test_build_count_primes()
    base_n       = get_base_n()
    primes       = build_primes(base_n)
    count_primes = build_count_primes(primes) 
    @test typeof(count_primes)    == Vector{Int64}
    @test typeof(count_primes[1]) == Int64
    @test length(count_primes)    == base_n
    println("passed build count")
end

function test_build_xs_over_log_xs()
    base_n         = get_base_n()
    xs_over_log_xs = build_xs_over_log_xs(base_n)
    @test typeof(xs_over_log_xs)    == Vector{Float64}
    @test typeof(xs_over_log_xs[1]) == Float64
    @test length(xs_over_log_xs)    == base_n
    for i in xs_over_log_xs
	@test isreal(i)
    end
    println("passed build xs over log xs")
end

function test_build_primes()
    base_n         = get_base_n()
    primes         = build_primes(base_n)
    @test typeof(primes) == Vector{Int64}
    @test primes[1]      == 3
    @test length(primes) == base_n
    println("passed build primes")
end

function demos_test()
    println("\n\n")
    test_build_primes()
    test_build_count_primes()
    test_build_xs_over_log_xs()
    println("passed all tests")
end

# control

function main_demo()
    base_n                          = get_base_n()
    primes                          = build_primes(base_n)
    count_primes                    = build_count_primes(primes) 
    xs_over_log_xs                  = build_xs_over_log_xs(base_n)
    gap                             = count_primes # ./(count_primes, xs_over_log_xs)
    estimates                       = ./(gap, 1:base_n)
    distances::Vector{Float64}      = []
    first = [1,gap[1]]
    for i in 1:length(gap)
	value         = gap[i]
	this_point    = [i,value]
	this_distance = euclidean(first, this_point)
	push!(distances, this_distance)
    end

    greet()
    L              = get_L()
   
    
    points_frame::DataFrame = DataFrame(x=1:base_n,y=gap,distance=distances,estimate=estimates)
    points_frame = sort!(points_frame,[:distance])
   

    y_positions = points_frame.y   
    odd_ys      = [x for x in enumerate(y_positions) if isodd(x[1])]
    even_ys     = [x for x in enumerate(y_positions) if iseven(x[1])]

   
   
    sorted_estimates   = points_frame.estimate   
    odd_estimates      = [x[2] for x in enumerate(sorted_estimates) if isodd(x[1])]
    even_estimates     = [x[2] for x in enumerate(sorted_estimates) if iseven(x[1])]
    p_even_odd         = pvalue(MannWhitneyUTest(odd_estimates, even_estimates))
    h_even_odd         = (-1)*log2(p_even_odd)
      
    #println("odd estimates:\n", odd_estimates)
    #println("even estimates:\n", even_estimates)
      
    println("You have ", base_n, " data points.")
    println("\nProbability that even and odd halves of the same number of Prime Counts are samples from same population:\n", p_even_odd)
    println("information derived from that probability:\n", h_even_odd)
    println("\nNote the p value is more than 0.5 because the are in reality chosen from the same set.")
    println("Note the information is low because they are not surpising in terms of each other.")
    println("Your null data has the following L-test score:\t", L)
 
    ones_claimed = 1
    comparator_L = 0
    while comparator_L < L && ones_claimed < (base_n ^ 3) 
        first_claim         = base_n + 1
        final_claim         = base_n + ones_claimed
        claim_xs            = first_claim:final_claim
	claim_estimates     = ./(1, claim_xs)
	if ones_claimed     > 0 
	    spoiled_evens   = append!(even_estimates, claim_estimates[end])
	else
	    spoiled_evens   = even_estimates
        end
        spoiled_p           = pvalue(MannWhitneyUTest(odd_estimates, spoiled_evens))
        spoiled_h           = (-1)*log2(spoiled_p)
	comparator_L        = (spoiled_h - p_even_odd) / p_even_odd 
        ones_claimed = ones_claimed + 1
	println("L:\t", L, "\tproferred comparator:\t", comparator_L)
        if comparator_L > L	
            #println("The Prime Counting Function starts with:\n", gap[1:3])
            #println("The Prime Counting Function ends with:\n", gap[end-3:end])
            println("That is the same amount of disinformation as claiming that after the Prime Counts up to your number of data points the following integers :\n", collect(claim_xs), "\nhave one prime each.")
            println("Which gives additional estimates thus:\t ", spoiled_evens)
            println("Spoiling evens with these gives a spoiled p of:\t", spoiled_p)
            println("Which is an absolute increase in disinformation of:\t", spoiled_h - h_even_odd)
            println("And a disinformation ratio of:\t", comparator_L)    
            my_graph = scatter([x[1] for x in odd_ys], [x[2] for x in odd_ys], legend=false)
            my_graph = scatter!([x[1] for x in even_ys],[x[2] for x in even_ys])
	    my_graph = scatter!(claim_xs, ones(ones_claimed))
	    display(my_graph)
        end
    end
   demos_test()
end


main_demo()
