module PropaCNES

const DEFAULT_LIBRARY_PATH = Ref{String}()
""" 
    check_library()
Thorws an error if the path to the Propa library has not been set.
"""
check_library() = @assert isassigned(DEFAULT_LIBRARY_PATH) "You have to specify the path to the Propa dynamic library before using function in PropaCNES package. Use the `PropaCNES.set_library_path` function to do so"

"""
    set_library_path(path::AbstractString)
Set the path to the Propa library (.dll or .so) depending on the system
"""
set_library_path(path::AbstractString) = DEFAULT_LIBRARY_PATH[] = path

include("wrappers.jl")

export NWET 

function __init__()
end

end # module PropaCNES
