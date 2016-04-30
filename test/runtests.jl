using UnFortran
using Base.Test


filename = joinpath(mktempdir(), "test")
v = (1,2,3,1pi)
m,n = 5,4
a = rand(m,n)

fort_open(filename, "w") do file
    write(file, v...)
    write(file, m, n)
    write(file, a)
end

fort_open(filename) do file
    @test (read(file, Int64, Int64, Int64, Float64)...) == v
    mi,ni = read(file, Int64, Int64)
    @test (mi,ni) == (m,n)
    ai = Array(Float64, m, n)
    read!(file, ai)
    @test ai == a
end

# Test reading record of wrong size
fort_open(filename) do file
    @test_throws ErrorException read(file, Int64)
end
