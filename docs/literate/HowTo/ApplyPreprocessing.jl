# # Apply MNE preprocessing

# When using `run_unfold` on your BIDS dataset it is usually assumed that your data is already preprocessed (or you want to have a look at the raw data). However, you also have the option to apply some further processing to your data.
# This is done by providing a custom function as `extract_data` keyword to `run_unfold`.
# 
# I.e. `run_unfold(dataDF, bfDict; extract_data = your_custom_function)` 
#
# By default `raw_to_data` is used.  
# 
# ```julia
# function raw_to_data(raw; channels::AbstractVector{<:Union{String,Integer}}=[])
#   return pyconvert(Array, raw.get_data(picks=pylist(channels), units="uV"))
# end
# ```
# 
# You can exchange this function through an arbitrary function (applying MNE processing as needed), as long as it takes the raw MNE data object and returns a pyconverted Julia Array containing the data stream.