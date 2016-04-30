module UnFortran

type FortIOStream
    s::IOStream
end

FortIOStream(args...) = FortIOStream(IOStream(args...))

fort_open(args...) = FortIOStream(open(args...))

function fort_open(f::Function, args...)
    open(args...) do file
        f(FortIOStream(file))
    end
end

import Base.close
close(file::FortIOStream) = close(f.s)

function read_record(f::Function, file::FortIOStream, expect_bytes)
    nbytes = read(file.s, Int32)
    nbytes == expect_bytes || error("Record size does not agree with types requested")
    r = f(file)
    nbytes == read(file.s, Int32) || error("Record size check failed")
    r
end

function write_record(f::Function, file::FortIOStream, nbytes::Integer)
    write(file.s, convert(Int32, nbytes))
    f(file)
    write(file.s, convert(Int32, nbytes))
end

record_size(args...) = reduce(+, 0, [sizeof(a) for a in args])

import Base.read, Base.read!
function read(file::FortIOStream, args...)
    read_record(file, record_size(args...)) do file
        [read(file.s, a) for a in args]
    end
end

function read!{T,N}(file::FortIOStream, a::AbstractArray{T,N})
    ni = length(a)
    read_record(file, ni*sizeof(T)) do file
        for i = 1:ni
            a[i] = read(file.s, T)
        end
    end
    a
end

import Base.write
function write(file::FortIOStream, args...)
    write_record(file, record_size(args...)) do file
        for a in args
            write(file.s, a)
        end
    end
end

function write{T,N}(file::FortIOStream, a::AbstractArray{T,N})
    ni = length(a)
    write_record(file, ni*sizeof(T)) do file
        for i = 1:ni
            write(file.s, a[i])
        end
    end
end

export fort_open, close, read, read!, write

end # module
