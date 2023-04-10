# Apply Unfold 

#function rununfold(eeg_df,formula=xy,channels=xy,[basisfunction=FIR | taus = [-0.3,1.] ,...)


#=
lm = []
resultsAll = DataFrame()

for row in eachrow(eeg_df)
    data = pyconvert(AbstractArray,row.data.get_data())
    data = data.*1e6

    lmSub = fit(UnfoldModel,design_lm,eventsList[ix],data)

    resOne = coeftable(lmSub)
    resOne.subject .= subject
    append!(resultsAll,resOne)
    append!(lm,[lmSub])
end
=#