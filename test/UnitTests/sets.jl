# Unit Test for by default supported convex sets and their functions
using COSMO, Test, Random, LinearAlgebra

rng = Random.MersenneTwister(13131)

@testset "Convex Sets" begin
tol = 1e-4


    @testset "Create and project" begin

    # Zero Cone
    zset = COSMO.ZeroSet(10)
    x = randn(rng,10)
    COSMO.project!(view(x, 1:length(x)), zset)
    @test norm(x,Inf) == 0.

    # Positive Orthant R+
    nonnegatives = COSMO.Nonnegatives(10)
    x = randn(rng, 10)
    COSMO.project!(view(x, 1:length(x)), nonnegatives)
    @test minimum(x) >= 0.

    # Box
    l = -1 * ones(10)
    u = 1 * ones(10)
    box = COSMO.Box(l, u)
    box = COSMO.Box{Float64}(10)
    box.l .= l
    box.u .= u
    x = 100 * randn(rng, 10)
    COSMO.project!(view(x, 1:length(x)), box)
    @test minimum(x) >= -1. && maximum(x) <= 1.

    # Second Order (Lorentz) cones
    soc = COSMO.SecondOrderCone(10)
    x = 10 * randn(rng, 9)
    t = norm(x, 2) - 0.5
    x = [t; x]

    COSMO.project!(view(x, 1:length(x)), soc)
    @test norm(x[2:10], 2) <= x[1]

    # Positive Semidefinite cones
    psd = COSMO.PsdCone(16)
    X = Symmetric(randn(rng, 4, 4))
    X = X - 4 * Matrix(1.0I, 4, 4)
    x = vec(X)
    COSMO.project!(view(x, 1:length(x)), psd)
    @test minimum(eigen(reshape(x, 4, 4)).values) >= -1e-9

    C = COSMO.CompositeConvexSet([COSMO.ZeroSet(10), COSMO.Nonnegatives(10)])
    x = -rand(20)
    xs = COSMO.SplitVector(x, C)
    COSMO.project!(xs, C)
    @test norm(x, Inf) == 0.

    end


    @testset "in_dual Functions" begin

    # Dual of zero cone
    x = randn(rng, 10)
    convex_set = COSMO.ZeroSet(10)
    @test COSMO.in_dual(view(x, 1:length(x)), convex_set, tol)

    # Dual of Positive Orthant R+ (self-dual)
    xpos = rand(rng, 10)
    xneg = -rand(rng, 10)
    xzeros = zeros(10)
    convex_set = COSMO.Nonnegatives(10)
    @test COSMO.in_dual(view(xpos, 1:length(xpos)), convex_set, tol)
    @test !COSMO.in_dual(view(xneg,1:length(xneg)), convex_set, tol)
    @test COSMO.in_dual(view(xzeros,1:length(xzeros)), convex_set,tol)

    #TODO: Dual of Box [important!]

    # Dual of Second Order Cone (self-dual)
    tol = 1e-4
    x = randn(rng, 9)
    t = norm(x, 2)
    xpos = [t + 0.5; x]
    xneg = [t - 0.5; x]
    convex_set = COSMO.SecondOrderCone(10)
    @test COSMO.in_dual(view(xpos, 1:length(xpos)), convex_set, tol)
    @test !COSMO.in_dual(view(xneg, 1:length(xneg)), convex_set, tol)

    # Dual of Positive Semidefinite Cone (self-dual)
    tol = 1e-4
    X = Symmetric(randn(rng, 4, 4))
    Xpos = X + 4 * Matrix(1.0I, 4, 4)
    Xneg = X - 4 * Matrix(1.0I, 4, 4)
    xpos = vec(Xpos)
    xneg = vec(Xneg)
    convex_set = COSMO.PsdCone(16)
    @test COSMO.in_dual(view(xpos, 1:length(xpos)), convex_set, tol)
    @test !COSMO.in_dual(view(xneg, 1:length(xneg)), convex_set, tol)

    end

    @testset "inPolRec Functions" begin

    # Polar Recession cone of zero cone
    xpos = zeros(10)
    xneg = randn(rng, 10)
    convex_set = COSMO.ZeroSet(10)
    @test COSMO.in_recc(view(xpos, 1:length(xpos)), convex_set, tol)
    @test !COSMO.in_recc(view(xneg, 1:length(xneg)), convex_set, tol)

    # Polar Recession cone of Positive Orthant R+
    xpos = -rand(rng, 10)
    xneg = rand(rng, 10)
    convex_set = COSMO.Nonnegatives(10)
    @test COSMO.in_recc(view(xpos,1:length(xpos)), convex_set, tol)
    @test !COSMO.in_recc(view(xneg,1:length(xneg)), convex_set, tol)

    #TODO: Polar Recc of Box [important!]

    # Polar Recc of Second Order Cone
    tol = 1e-4
    x = randn(rng, 9)
    t = norm(x, 2)
    xpos = [-t - 0.5; x]
    xneg = [-t + 0.5; x]
    convex_set = COSMO.SecondOrderCone(10)
    @test COSMO.in_recc(view(xpos, 1:length(xpos)), convex_set, tol)
    @test !COSMO.in_recc(view(xneg, 1:length(xneg)), convex_set, tol)



    # Polar Recc of Positive Semidefinite Cone
    tol = 1e-4
    X = Symmetric(randn(rng, 4, 4))
    Xpos = X - 20 * Matrix(1.0I, 4, 4)
    Xneg = X + 4 * Matrix(1.0I, 4, 4)
    xpos = vec(Xpos)
    xneg = vec(Xneg)
    convex_set = COSMO.PsdCone(16)
    @test COSMO.in_recc(view(xpos, 1:length(xpos)), convex_set, tol)
    @test !COSMO.in_recc(view(xneg, 1:length(xneg)), convex_set, tol)

    end

end


nothing
