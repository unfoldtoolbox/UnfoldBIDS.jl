# Apply Unfold 

#function rununfold(eeg_df,formula=xy,channels=xy,[basisfunction=FIR | taus = [-0.3,1.] ,...)

"""

- removeTimeexpandedXs (true): Removes the timeexpanded designmatrix which significantly reduces the memory-consumption. This Xs is rarely needed, but can be recovered (look into the Unfold.load function)
"""
function runUnfold(dataDF, eventsDF, bfDict; channels::AbstractVector{<:Union{String, Integer}}=[], eventcolumn="event",removeTimeexpandedXs=true)
	subjects = unique(dataDF.subject)

	resultsDF = DataFrame()

	for sub in subjects

		# Get current subject
		raw = @subset(dataDF, :subject .== sub).data
		
		tmpData = pyconvert(Array,raw[1].get_data(picks=pylist(channels),units="uV"))
		
		tmpEvents = @subset(eventsDF, :subject .== sub)

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

function calculateGA(resultsDF)
	GA = @chain resultsDF begin
		# need to check which variables to use
		@by(:subject, :basisfunction, :estimate = mean(estimate))
	end
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