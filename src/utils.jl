# Apply Unfold 

#function rununfold(eeg_df,formula=xy,channels=xy,[basisfunction=FIR | taus = [-0.3,1.] ,...)

#=
"""

- removeTimeexpandedXs (true): Removes the timeexpanded designmatrix which significantly reduces the memory-consumption. This Xs is rarely needed, but can be recovered (look into the Unfold.load function)

extractData (function) - specify the function that translate the MNE Raw object to an data array. Default is `rawToData` which uses get_data and allows to pick `channels` - see @Ref(`rawToData`). The optional kw- arguments (e.g. channels) need to be specified directly in the `runUnfold` function as kw-args
"""
=#
function runUnfold(dataDF, eventsDF, bfDict; eventcolumn="event",removeTimeexpandedXs=true, extractData = rawToData,kwargs...)
	subjects = unique(dataDF.subject)

	resultsDF = DataFrame()

	for sub in subjects

		# Get current subject
		raw = @subset(dataDF, :subject .== sub).data
		
		tmpEvents = @subset(eventsDF, :subject .== sub)

		tmpData = extractData(raw[1],tmpEvents;kwargs...)
		

		# Fit Model
		m = fit(UnfoldModel,bfDict,tmpEvents,tmpData; eventcolumn=eventcolumn);

		if removeTimeexpandedXs && (m isa UnfoldLinearModelContinuousTime || m isa UnfoldLinearModelContinuousTime)
			m = typeof(m)(m.design, Unfold.DesignMatrix(designmatrix(m).formulas, missing, designmatrix(m).events), m.modelfit)
		end
		results = DataFrame(:subject => sub, :model => m)
		
		append!(resultsDF, results)


	end
	return resultsDF
end

# Function to run Preprocessing functions on data
function rawToData(raw,tmpEvents;channels::AbstractVector{<:Union{String, Integer}}=[])
	return pyconvert(Array,raw.get_data(picks=pylist(channels),units="uV"))
end

# Calculate Grand average; this is likely a TODO
# Commented this out for now as this might go into UnfoldStats; R.S. 18/01/24
#=
function calculateGA(resultsDF; channels=:false)
	GA = @chain resultsDF begin
		# TODO: check if this works
		if channels
			@subset(:channel .== channels)
		end
		# need to check which variables to use
		@by([:basisname,:coefname,:time, :channel], :estimate = mean(estimate))
	end

    
end
=#

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
