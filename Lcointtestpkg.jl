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
    base_n::Int64               = get_base_n()
    count_primes::Vector{Int64} = []
    for i in 2:base_n+1
	prime_count::Int64 = sum([Int(isprime(x)) for x in 1:i])
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

function draw_my_graph(odd_ys::Vector{Tuple{Int64,Int64}},
	              even_ys::Vector{Tuple{Int64,Int64}},
		     claim_xs::Vector{Int64},
                 ones_claimed::Int64) 
    my_graph = scatter([x[1] for x in odd_ys], [x[2] for x in odd_ys], legend=false)
    my_graph = scatter!([x[1] for x in even_ys],[x[2] for x in even_ys])
    my_graph = scatter!(claim_xs, ones(ones_claimed))
    display(my_graph)
end


function greet(base_n::Int64, p_even_odd::Float64, h_even_odd::Float64, L::Float64)
    println("\nHello and welcome to the L-test.")
    println("We use the Prime Counting function as a reference data set.")
    println("You have ", base_n, " data points.")
    println("The graph is that many numbers, and the count of how many primes they cover each.")
    println("Even and odd number counts are not quite the same but they go up in a messy way like hospital data.")
    println("\nProbability that even and odd Prime Counts from ", base_n, " are samples from same population:\n", p_even_odd)
    println("\nInformation derived from that probability:\n", h_even_odd)
    println("\nNote the p value is more than 0.5 because the are in reality chosen from the same set.")
    println("Note the information is low because they are not surpising in terms of each other.")
    println("Your null data has the following L-test score:\t", L)
end

function report_finding(ones_claimed::Int64,
       	                   spoiled_p::Float64,
		           spoiled_h::Float64,
		          h_even_odd::Float64,
		        comparator_L::Float64)
    println("\nTo get the same false difference between odd and even we need\t", ones_claimed, "\tfalse counts of 1 integer.")
    println("Spoiling evens with these gives a spoiled p of:\t\t", spoiled_p)
    println("Which is an absolute increase in disinformation of:\t", spoiled_h - h_even_odd)
    println("And a prime count disinformation ratio of:\t\t", comparator_L)    
   end

# test

function test_build_count_primes()
    base_n::Int64                = get_base_n()
    primes::Vector{Int64}        = build_primes(base_n)
    count_primes  = build_count_primes(primes) 
    @test typeof(count_primes)    == Vector{Int64}
    @test typeof(count_primes[1]) == Int64
    @test length(count_primes)    == base_n
    println("passed build count")
end

function test_build_primes()
    base_n          = get_base_n()
    primes          = build_primes(base_n)
    @test typeof(primes) == Vector{Int64}
    @test primes[1]      == 3
    @test length(primes) == base_n
    println("passed build primes")
end

function Ltest_tests()
    println("\n\n")
    test_build_primes()
    println("passed all tests")
end

# control

function Ltest()
    base_n::Int64                   = get_base_n()
    primes::Vector{Int64}           = build_primes(base_n)
    count_primes::Vector{Int64}     = build_count_primes(primes)
    estimates                       = ./(count_primes, 1:base_n)
    distances::Vector{Float64}      = []
    first = [1,count_primes[1]]
    for i in 1:length(count_primes)
	value         = count_primes[i]
	this_point    = [i,value]
	this_distance = euclidean(first, this_point)
	push!(distances, this_distance)
    end

    L::Float64                          = get_L()
    points_frame::DataFrame             = DataFrame(x=1:base_n,
						    y=count_primes,
			                     distance=distances,
					     estimate=estimates)
    points_frame                        = sort!(points_frame,[:distance])
    y_positions::Vector{Int64}          = points_frame.y   
    odd_ys::Vector{Tuple{Int64,Int64}}  = [x for x in enumerate(y_positions) if isodd(x[1])]
    even_ys::Vector{Tuple{Int64,Int64}} = [x for x in enumerate(y_positions) if iseven(x[1])]   
    sorted_estimates::Vector{Float64}   = points_frame.estimate   
    odd_estimates::Vector{Float64}      = [x[2] for x in enumerate(sorted_estimates) if isodd(x[1])]
    even_estimates::Vector{Float64}     = [x[2] for x in enumerate(sorted_estimates) if iseven(x[1])]
    p_even_odd::Float64                 = pvalue(MannWhitneyUTest(odd_estimates, even_estimates))
    h_even_odd::Float64                 = (-1)*log2(p_even_odd)
    greet(base_n, p_even_odd, h_even_odd, L) 
    ones_claimed::Int64   = 1
    comparator_L::Float64 = 0
    while comparator_L <= L 
        first_claim::Int64               = base_n + 1
        final_claim::Int64               = base_n + ones_claimed
	claim_xs::Vector{Int64}          = first_claim:final_claim
	claim_estimates::Vector{Float64} = ./(1, claim_xs)
	if ones_claimed     > 0 
	    spoiled_evens::Vector{Float64}   = append!(even_estimates, claim_estimates[end])
	else
	    spoiled_evens                    = even_estimates
        end
        spoiled_p::Float64    = pvalue(MannWhitneyUTest(odd_estimates, spoiled_evens))
        spoiled_h::Float64    = (-1)*log2(spoiled_p)
	comparator_L          = (spoiled_h - h_even_odd) / h_even_odd 
        ones_claimed          = ones_claimed + 1
        if comparator_L > L
            report_finding(ones_claimed, spoiled_p, spoiled_h, h_even_odd, comparator_L)
	    draw_my_graph(odd_ys, even_ys, claim_xs, ones_claimed)
	    return ones_claimed
        end
    end
end


Ltest()
Ltest_tests()
