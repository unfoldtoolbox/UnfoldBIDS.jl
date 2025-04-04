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
# You can exchange this function through an arbitrary function (applying MNE processing as needed), as long as it takes the raw MNE data object and returns a pyconverted Julia Array containing the data stream. For example
# 
# ```julia
# function raw_to_filtered_data(raw; channels::AbstractVector{<:Union{String,Integer}}=[], l_freq=0.5, h_freq=45)
#
#   # Load data into memory
#   raw.load_data()
#
#   # Re-reference to mastoids and add Cz back in
#   UnfoldBIDS.PyMNE.add_reference_channels(raw, ref_channels=UnfoldBIDS.pylist(["Cz"]), copy=false)
#   raw.set_eeg_reference(ref_channels=UnfoldBIDS.pylist(["RM", "LM"]))
# 
#   # Filter data
#   raw.filter(l_freq, h_freq, picks="eeg")
#   
#   return UnfoldBIDS.pyconvert(Array, raw.get_data(picks=UnfoldBIDS.pylist(channels), units="uV"))
# end
# ```
# 
# However, including a preprocessing step right before fitting your model can often be a bottleneck in performance. If you think you will more likely only apply some preprocessing and then play around with the model, it's often more advisable to preprocess the raw objects in the dataframe before fitting.
#
# ```julia
# function ref_and_filter_data!(raw; l_freq=0.5, h_freq=45)
#   raw.load_data()
# 
#   # Re-reference to mastoids and add Cz back in
#   UnfoldBIDS.PyMNE.add_reference_channels(raw, ref_channels=UnfoldBIDS.pylist(["Cz"]), copy=false)
#   raw.set_eeg_reference(ref_channels=UnfoldBIDS.pylist(["RM", "LM"]))
# 
#   # Filter data
#   raw.filter(l_freq, h_freq, picks="eeg")
# 
# end
# 
# for row in eachrow(loaded_data_df)
#   ref_and_filter_data!(row.raw)
# end
# ```
