# UnFortran

[![Build Status](https://travis-ci.org/jagot/UnFortran.jl.svg?branch=master)](https://travis-ci.org/jagot/UnFortran.jl)

Small helper library to load records from unformatted Fortran files.

Usage example:

```julia
    using UnFortran
    fort_open("data.file") do file
        # Read a record consisting of an Integer(8) and a Real(4)
        read(file, Int64, Float32)
    end
```
