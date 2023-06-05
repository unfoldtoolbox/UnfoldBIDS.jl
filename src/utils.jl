# Apply Unfold 

#function rununfold(eeg_df,formula=xy,channels=xy,[basisfunction=FIR | taus = [-0.3,1.] ,...)


function RunUnfold(DataDF, EventsDF, bfDict; channels::Union{Nothing, String, Integer}=nothing, eventcolumn="event")
	subjects = unique(DataDF.Subject)

	ResultsDF = DataFrame()

	for sub in subjects

		# Get current subject
		raw = @subset(DataDF, :Subject .== sub).Data
		if channels == nothing
			tmpData = pyconvert(Array,raw[1].get_data()).*10^6
		else
			tmpData = pyconvert(Array,raw[1].get_data(picks=channels)).*10^6
		end
		tmpEvents = @subset(EventsDF, :Subject .== sub)

		# Fit Model
		m = fit(UnfoldModel,bfDict,tmpEvents,tmpData, eventcolumn=eventcolumn);
		results = coeftable(m)

		results.Subject .= sub
		append!(ResultsDF, results)


	end
	return ResultsDF
end

#=
# Function to run unfold on epoched data
function RunUnfold(DataDF, EventsDF, formula, sfreq, τ = (-0.3,1.); channels::Union{Nothing, String, Integer}=nothing)

	
	# we have multi channel support
	# data_r = reshape(data,(1,:))
	# cut the data into epochs

	subjects = unique(DataDF.Subject)

	ResultsDF = DataFrame()

	for sub in Subjects

		# Get current subject
		raw = @subset(DataDF, :Subject .== sub).Data
		if channels == nothing
			tmpData = pyconvert(Array,raw[1].get_data()).*10^6
		else
			tmpData = pyconvert(Array,raw[1].get_data(picks=channels)).*10^6
		end

		# Get events
		tmpEvents = @subset(EventsDF, :Subject .== sub)

		# Cut data into epochs
		data_epochs,times = Unfold.epoch(data=tmpData,tbl=tmpEvents,τ=τ,sfreq=sfreq);
		
		# Fit Model
		m = fit(UnfoldModel,formula,tmpEvents,data_epochs,times);
		results = coeftable(m)

		results.Subject .= sub
		append!(ResultsDF, results)
	end
	return ResultsDF
end
=#