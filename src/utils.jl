# Apply Unfold 

#function rununfold(eeg_df,formula=xy,channels=xy,[basisfunction=FIR | taus = [-0.3,1.] ,...)


function runUnfold(dataDF, eventsDF, bfDict; channels::Union{Nothing, String, Integer}=nothing, eventcolumn="event")
	subjects = unique(dataDF.subject)

	resultsDF = DataFrame()

	for sub in subjects

		# Get current subject
		raw = @subset(dataDF, :subject .== sub).data
		if channels == nothing
			tmpData = pyconvert(Array,raw[1].get_data(units="uV"))
		else
			tmpData = pyconvert(Array,raw[1].get_data(picks=channels,units="uV"))
		end
		tmpEvents = @subset(eventsDF, :subject .== sub)

		# Fit Model
		m = fit(UnfoldModel,bfDict,tmpEvents,tmpData, eventcolumn=eventcolumn);
		results = coeftable(m)

		results.subject .= sub
		append!(resultsDF, results)


	end
	return resultsDF
end

#=
# Function to run unfold on epoched data
function runUnfold(DataDF, EventsDF, formula, sfreq, τ = (-0.3,1.); channels::Union{Nothing, String, Integer}=nothing)

	
	# we have multi channel support
	# data_r = reshape(data,(1,:))
	# cut the data into epochs

	subjects = unique(DataDF.subject)

	resultsDF = DataFrame()

	for sub in subjects

		# Get current subject
		raw = @subset(DataDF, :subject .== sub)data
		if channels == nothing
			tmpData = pyconvert(Array,raw[1].get_data()).*10^6
		else
			tmpData = pyconvert(Array,raw[1].get_data(picks=channels)).*10^6
		end

		# Get events
		tmpEvents = @subset(EventsDF, :subject .== sub)

		# Cut data into epochs
		data_epochs,times = Unfold.epoch(data=tmpData,tbl=tmpEvents,τ=τ,sfreq=sfreq);
		
		# Fit Model
		m = fit(UnfoldModel,formula,tmpEvents,data_epochs,times);
		results = coeftable(m)

		results.subject .= sub
		append!(resultsDF, results)
	end
	return resultsDF
end
=#