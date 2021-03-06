using AutoDiffSource
using Base.Test

# check basic use
@δ f(x, y) = (x + y) * y
@test checkdiff(f, δf, 2., 3.)

# check numerical constants
@δ function f2(x, y::AbstractFloat)
    z = 2.5x - y^2
    z / y
end
@test checkdiff(f2, δf2, 2., 3.)

# test broadcast
@δ f3(x) = sum(abs.(x))
@test checkdiff(f3, δf3, rand(5)-0.5)

# test multi argument functions and reuse
@δ f4(x, y) =  x * y, x - y
@δ function f5(x)
    (a, b) = f4(x, x+3)
    a * x + 4b
end
@test checkdiff(f5, δf5, rand()-0.5)

# test external constants
const f6_const = rand(5)
@δ f6(x) = sum(f6_const .* x)
@test checkdiff(f6, δf6, rand(5))

# (scalar, scalar), (scalar, const), (const, scalar)
for o in [:+, :-, :*, :/, :^]
    t = gensym(o)
    δt = Symbol("δ$t")
    @eval @δ $t(x, y) = $o(x, y)
    @eval @test checkdiff($t, $δt, rand(), rand())
    t = gensym(o)
    δt = Symbol("δ$t")
    @eval @δ $t(x) = $o(x, 2.)
    @eval @test checkdiff($t, $δt, rand())
    t = gensym(o)
    δt = Symbol("δ$t")
    @eval @δ $t(x) = $o(2., x)
    @eval @test checkdiff($t, $δt, rand())
end

# (scalar)
for o in [:abs, :sum, :sqrt, :exp, :log, :-]
    t = gensym(o)
    δt = Symbol("δ$t")
    @eval @δ $t(x) = $o(x)
    @eval @test checkdiff($t, $δt, rand())
end

# (vector, vector), (matrix, matrix), (const, *), (*, const)
# (vector, matrix), (matrix, vector), (vector, scalar), (matrix, scalar), (scalar, vector), (scalar, matrix)
for o in [:.+, :.-, :.*, :./, :.^]
    t = gensym(o)
    δt = Symbol("δ$t")
    @eval @δ $t(x, y) = sum($o(x, y))
    @eval @test checkdiff($t, $δt, rand(5), rand(5))
    @eval @test checkdiff($t, $δt, rand(3, 2), rand(3, 2))

    t = gensym(o)
    δt = Symbol("δ$t")
    @eval @δ $t(x) = sum($o(x, 3.))
    @eval @test checkdiff($t, $δt, rand())
    @eval @test checkdiff($t, $δt, rand(5))
    @eval @test checkdiff($t, $δt, rand(3, 2))

    t = gensym(o)
    δt = Symbol("δ$t")
    @eval @δ $t(x) = sum($o(3., x))
    @eval @test checkdiff($t, $δt, rand())
    @eval @test checkdiff($t, $δt, rand(5))
    @eval @test checkdiff($t, $δt, rand(3, 2))

    t = gensym(o)
    δt = Symbol("δ$t")
    @eval @δ $t(x, y) = sum($o(x, y))
    @eval @test checkdiff($t, $δt, rand(3), rand(3, 2))
    @eval @test checkdiff($t, $δt, rand(3, 2), rand(3))
    @eval @test checkdiff($t, $δt, rand(5), rand())
    @eval @test checkdiff($t, $δt, rand(3, 2), rand())
    @eval @test checkdiff($t, $δt, rand(), rand(5))
    @eval @test checkdiff($t, $δt, rand(), rand(3, 2))
end

# (vector), (matrix)
for o in [:abs, :sqrt, :exp, :log]
    t = gensym(o)
    δt = Symbol("δ$t")
    @eval @δ $t(x) = sum($o.(x))
    @eval @test checkdiff($t, $δt, rand(5))
    @eval @test checkdiff($t, $δt, rand(3, 2))
end

# (vector, scalar), (matrix, scalar), (scalar, vector), (scalar, matrix), (const, *), (*, const)
for o in [:+, :-, :*]
    t = gensym(o)
    δt = Symbol("δ$t")
    @eval @δ $t(x, y) = sum($o(x, y))
    @eval @test checkdiff($t, $δt, rand(5), rand())
    @eval @test checkdiff($t, $δt, rand(3, 2), rand())
    @eval @test checkdiff($t, $δt, rand(), rand(5))
    @eval @test checkdiff($t, $δt, rand(), rand(3, 2))

    t = gensym(o)
    δt = Symbol("δ$t")
    @eval @δ $t(x) = sum($o(x, 4.))
    @eval @test checkdiff($t, $δt, rand(5))
    @eval @test checkdiff($t, $δt, rand(3, 2))

    t = gensym(o)
    δt = Symbol("δ$t")
    @eval @δ $t(x) = sum($o(5., x))
    @eval @test checkdiff($t, $δt, rand(5))
    @eval @test checkdiff($t, $δt, rand(3, 2))
end

# (vector, scalar), (matrix, scalar), (*, const)
for o in [:/]
    t = gensym(o)
    δt = Symbol("δ$t")
    @eval @δ $t(x, y) = sum($o(x, y))
    @eval @test checkdiff($t, $δt, rand(5), rand())
    @eval @test checkdiff($t, $δt, rand(3, 2), rand())

    t = gensym(o)
    δt = Symbol("δ$t")
    @eval @δ $t(x) = sum($o(x, 5.))
    @eval @test checkdiff($t, $δt, rand(5))
    @eval @test checkdiff($t, $δt, rand(3, 2))
end
