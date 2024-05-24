"""
    NWET(lat, lon)
Compute the wet term of refraction co-index as per ITU-R P.453.

# Arguments
- `lat`: Latitude of the target point in degrees between -90 and +90
- `lon`: Longitude of the target point in degrees between -360 and +360
"""
function NWET(lat::Real, lon::Real)
    # Check that the propa library path has been specified
    check_library()
    return ccall(("NWET", DEFAULT_LIBRARY_PATH[]), Cdouble, (Cdouble, Cdouble), lat, lon)
end

"""
    rain_height(lat, lon)
Compute the rain height in Km as per ITU-R P. 839-4

# Arguments
- `lat`: Latitude of the target point in degrees between -90 and +90
- `lon`: Longitude of the target point in degrees between -360 and +360
"""
function rain_height(lat::Real, lon::Real)
    # Check that the propa library path has been specified
    check_library()
    return ccall(("rain_height", DEFAULT_LIBRARY_PATH[]), Cdouble, (Cdouble, Cdouble), lat, lon)
end

"""
    rain_probability(lat, lon)
Compute the rain height [Km] as per ITU-R P. 839-4

# Arguments
- `lat`: Latitude of the target point in degrees between -90 and +90
- `lon`: Longitude of the target point in degrees between -360 and +360
"""
function rain_probability(lat::Real, lon::Real)
    # Check that the propa library path has been specified
    check_library()
    return ccall(("rain_probability", DEFAULT_LIBRARY_PATH[]), Cdouble, (Cdouble, Cdouble), lat, lon)
end

"""
    rain_intensity(lat, lon, unavailability)
Compute the rain intensity [mm/h] exceeded for a certaing percentage `unavailability` of time as per ITU-R P. 839-4

# Arguments
- `lat`: Latitude of the target point in degrees between -90 and +90
- `lon`: Longitude of the target point in degrees between -360 and +360
- `unavailability`: Target Unavailability [%]. Defaults to 0.01%
"""
function rain_intensity(lat::Real, lon::Real, unavailability::Real = 0.01)
    # Check that the propa library path has been specified
    check_library()
    return ccall(("rain_intensity", DEFAULT_LIBRARY_PATH[]), Cdouble, (Cdouble, Cdouble, Cdouble), lat, lon, unavailability)
end

"""
    rain_attenuation(lat, lon, unavailability; kwargs...)
Compute the rain attenuation [dB] exceeded for a certaing percentage `unavailability` of time as per ITU-R P. 612-12

# Arguments
- `lat`: Latitude of the target point in degrees between -90 and +90.
- `lon`: Longitude of the target point in degrees between -360 and +360. Used to compute rain intensity (`R001`) and rain height (`h_r`) automatically
- `unavailability`: Target Unavailability [%]. Defaults to 0.01%

# Keyword Arguments
- `frequency` or `f`: Frequency [GHz] to be used for the computation. Can not be higher than 55 [GHz]
- `elevation` or `el`: Target elevation [degrees] to be used for the computation.
- `h_s` or `hₛ`: Station height [Km] to be used for the computation. Defaults to 0.
- `h_r` or `hᵣ`: Rain height [Km] to be used for the computation. Defaults to `rain_height(lat, lon)`
- `R001`: Rain intensity [mm/h] to be used for the computation. Defaults to `rain_intensity(lat, lon, 0.01)`
- `polarization_angle`: Tilt angle [degrees] of the electric field polarization w.r.t. horizontal polarization. Defaults to 45, corresponding to a circularly polarized field.
"""
function rain_attenuation(lat::Real, lon::Real, unavailability::Real; f = nothing, frequency = f, el = nothing, elevation = el, h_s = 0, hₛ = h_s, h_r = rain_height(lat, lon), hᵣ = h_r, R001 = rain_intensity(lat, lon, 0.01), tilt_angle = 45)
    # Check that the propa library path has been specified
    check_library()
    # As specified in P.618-14, if we have a rain height lower than the station height, we simply returns 0.0 as attenuation
    hᵣ <= hₛ && return 0.0
    @assert frequency !== nothing && frequency <= 55 "You have to provide a frequency <= 55 [GHz] using either the kwarg `f` or `frequency`"
    @assert elevation !== nothing "You have to provide a elevation [degrees] using either the kwarg `el` or `elevation`"
    unavailability >= 0.001 && unavailability <= 5 || @warn "The rain attenuation results are only valid according to ITU P618 when the unavailability is between 0.001% and 5%. You provided $(unavailability)%"
    return ccall(("rain_attenuation", DEFAULT_LIBRARY_PATH[]), Cdouble, (Cdouble, Cdouble, Cdouble, Cdouble, Cdouble, Cdouble, Cdouble, Cdouble), lat, frequency, deg2rad(elevation), unavailability, hₛ, hᵣ, R001, tilt_angle)
end