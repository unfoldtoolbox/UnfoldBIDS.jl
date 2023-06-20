### A Pluto.jl notebook ###
# v0.19.25

using Markdown
using InteractiveUtils

# ╔═╡ 5f67300e-03a3-11ee-39cf-239b4c1a9f06
begin
using Pkg
	Pkg.activate(mktempdir())
end

# ╔═╡ 4358e394-3636-48ab-93ed-97a646e90312
# ╠═╡ show_logs = false
begin
	Pkg.develop(path="../")
	Pkg.add(url="https://github.com/unfoldtoolbox/Unfold.jl",rev="main")
Pkg.add(["PyMNE","UnfoldMakie","CairoMakie","PythonCall","ProfileCanvas","PlutoLinks","DataFrames","DataFramesMeta"])

	
end


# ╔═╡ 7f8f723b-6836-44cd-a51a-d745d66dfcee
Pkg.add("StatsModels")

# ╔═╡ d23372c2-21b4-4c41-8207-fb4a9c8ed4ca
using DataFramesMeta,DataFrames,PythonCall,ProfileCanvas,CairoMakie,UnfoldMakie,PyMNE

# ╔═╡ af3cf7b1-379f-4ca7-a438-bde9c2d1cd86
using PlutoLinks

# ╔═╡ 9ad8d4c2-1e54-4805-9206-74d77b1c9d5f
begin
@revise using Unfold
@revise using UnfoldBIDS
end

# ╔═╡ 915c3aeb-5006-4e7f-8f4e-4fa2cb565813
using StatsModels

# ╔═╡ ef08b6f8-d592-47a4-b262-9c3521391559
using Statistics

# ╔═╡ 2d7d83ed-5ccd-49c6-99ee-99b813ffcd79
pwd()

# ╔═╡ 4c715957-ba38-489f-8940-cd2be4fafe8c


# ╔═╡ b61b2986-bfcf-4b5b-a97b-eca8eaec55f5

# To look up the paths of all subjects and store in a Dataframe:
layout_df = bidsLayout("/store/data/8bit/derivatives/logs_added/")
# To load all data into memory/ one dataframe:           


# ╔═╡ 857995e5-a9f5-45dd-bfa9-b8a7116fded8
# ╠═╡ show_logs = false
eeg_df = load_bids_eeg_data(layout_df)

# ╔═╡ 30551c33-3476-42a5-87a6-8587eb4b5abd
PyMNE.mne.io

# ╔═╡ fb5aeed9-9050-4625-b21c-088eafc205e8
begin
	# First define the path where **all** CSV files are stored, e.g.:
subPath ="/store/data/8bit/derivatives/logs_added/sub-%s/eeg/sub-%s_task-ContinuousVideoGamePlay_run-02_events.tsv"
# Then call
events = collectEvents(layout_df.subject, subPath; delimiter="\t");
end
# To run Unfold model:



# ╔═╡ 24a268b0-cdb5-41f5-9528-a95d4539a94e


# ╔═╡ 6aa74df2-c5b9-4f73-8f29-221affb7df11
function add_covariates(df)
	df = DataFrame(df)
	s = df.subject[1]
	raw = eeg_df.data[findfirst(eeg_df.subject .== s)]
	
	
	for iv = pyconvert(Vector,raw.info["ch_names"])[end-7:end]
		
		dat = pyconvert(Array,raw.get_data(picks=iv))
		
		df[!,iv] = dat[1,df.sample]
	end
	
	return df
end

# ╔═╡ 36b26293-0cab-4153-9dd4-a32990734307
begin
gps= groupby(subset!(events,:sample=>x->x.>0),:subject)
events_tuned = combine(gps,add_covariates;threads=false)
	eeg_df.data_resampled = deepcopy(eeg_df.data)
for k  = eachindex(eeg_df.data)
	eeg_df.data_resampled[k].resample(100)
end
	events_tuned.sample = events_tuned.sample./5
	events_tuned.latency = events_tuned.sample;
end

# ╔═╡ fae8d9a0-ada9-44f0-9d6b-cc139b2f5c23
first(events_tuned,5)

# ╔═╡ 0f5fa8d2-d244-491d-a8b6-459022ce6ff0
bfDict = Dict(
	"MISSILE_HIT_ENEMY"=>(@formula(0~1+spl(CLOSESTENEMY,5)),firbasis((-0.5,1),500)),
	"PLAYER_CRASH_ENEMY"=>(@formula(0~1+spl(HEALTH,5)),firbasis((-0.5,1),500))
)

# ╔═╡ f98fb7f7-97fa-4066-a754-08d878bb14a4
resultsAll = runUnfold(eeg_df, events_tuned, bfDict; channels=["Cz"], eventcolumn="trial_type")

# ╔═╡ 2c467a7c-3861-420a-bac1-a23643913250
names(events_tuned)

# ╔═╡ 23c95a6d-44e8-462f-afdc-ab75c7392f17
unique(events_tuned.trial_type)

# ╔═╡ 825f359d-1f78-4ef1-9a88-17006672dec0
hist(events_tuned.CLOSESTENEMY)

# ╔═╡ 7b7666d8-c96c-478f-8b42-662c5be089c4
events_tuned.HEALTH

# ╔═╡ beac3088-f5e5-4113-8d81-5feddb6ffcfa
begin
d = [Dict(:HEALTH => 0.1:0.1:1),
	Dict(:CLOSESTENEMY=>0:0.1:1)]
function calc_effects(x)
	
eff =	allowmissing!.(effects.(d,Ref(x[1])))
for (ix,e) in enumerate(eff)
	
	varname = first(keys(d[ix]))
	@show varname
	e.key .= varname
	rename!(e,varname => "value")
end
return vcat(eff...)
end
effectsAll = combine(groupby(resultsAll,:subject),:model=>(x->
calc_effects(x)) =>AsTable, threads=false)	
	


end


# ╔═╡ 219de3c7-ac52-447c-a1c9-fb3796826f9b
effectsAvg = groupby(effectsAll,[:time,:key,:value])|>x-> combine(x,:yhat=>(x->mean(skipmissing(x)))=>:yhat) 

# ╔═╡ 7414c096-481d-4f5e-9f68-677c1311f3a7
first(effectsAvg,5)

# ╔═╡ d6288fb8-50c2-42de-a02e-d101a49e4be1
begin
	effectClose = dropmissing(effectsAvg)|>x->subset(x,:key=>y->y.==:CLOSESTENEMY)
f = plot_erp(effectClose;mapping=(;color=:value),extra=(;categoricalColor=false),layout=(;colorbar=true))
	ax = current_axis()
	h = vspan!(ax,0.045,0.08;color=:lightgray)
	translate!(h,Point3(0,0,-1))
	xlims!(ax,-0.05,0.2)
	ax.ylabel = "rERP [µV]"
	ax.xlabel = "time [s]"
	#delete!(f.content[3]) # remove the text label
	f.content[2].label[] = "relative enemy distance"
	f
	
	#f
	
end

# ╔═╡ 7df14017-0c7e-4074-970e-d8c78efd6d2d
save("test.svg",f)

# ╔═╡ ad6cd9aa-0128-48c1-b24d-7c5f5c3170b0

#plot_erp(dropmissing(effectsAll)|>x->subset(x,:key=>y->y.==:CLOSESTENEMY,:time=>x->x .>-0.2 .&& x .< 0.3);mapping=(;color=:value,group=:value,layout=:subject),extra=(;categoricalColor=false),layout=(;colorbar=true))


# ╔═╡ d1d7f311-78d2-45b9-9555-57ae97d8fc6a


# ╔═╡ Cell order:
# ╠═5f67300e-03a3-11ee-39cf-239b4c1a9f06
# ╠═4358e394-3636-48ab-93ed-97a646e90312
# ╠═9ad8d4c2-1e54-4805-9206-74d77b1c9d5f
# ╠═d23372c2-21b4-4c41-8207-fb4a9c8ed4ca
# ╠═af3cf7b1-379f-4ca7-a438-bde9c2d1cd86
# ╠═2d7d83ed-5ccd-49c6-99ee-99b813ffcd79
# ╠═4c715957-ba38-489f-8940-cd2be4fafe8c
# ╠═b61b2986-bfcf-4b5b-a97b-eca8eaec55f5
# ╠═857995e5-a9f5-45dd-bfa9-b8a7116fded8
# ╠═30551c33-3476-42a5-87a6-8587eb4b5abd
# ╠═fb5aeed9-9050-4625-b21c-088eafc205e8
# ╠═f98fb7f7-97fa-4066-a754-08d878bb14a4
# ╠═36b26293-0cab-4153-9dd4-a32990734307
# ╠═24a268b0-cdb5-41f5-9528-a95d4539a94e
# ╠═fae8d9a0-ada9-44f0-9d6b-cc139b2f5c23
# ╠═6aa74df2-c5b9-4f73-8f29-221affb7df11
# ╠═0f5fa8d2-d244-491d-a8b6-459022ce6ff0
# ╠═2c467a7c-3861-420a-bac1-a23643913250
# ╠═23c95a6d-44e8-462f-afdc-ab75c7392f17
# ╠═825f359d-1f78-4ef1-9a88-17006672dec0
# ╠═7b7666d8-c96c-478f-8b42-662c5be089c4
# ╠═beac3088-f5e5-4113-8d81-5feddb6ffcfa
# ╠═219de3c7-ac52-447c-a1c9-fb3796826f9b
# ╠═7414c096-481d-4f5e-9f68-677c1311f3a7
# ╠═d6288fb8-50c2-42de-a02e-d101a49e4be1
# ╠═7df14017-0c7e-4074-970e-d8c78efd6d2d
# ╠═ad6cd9aa-0128-48c1-b24d-7c5f5c3170b0
# ╠═d1d7f311-78d2-45b9-9555-57ae97d8fc6a
# ╠═915c3aeb-5006-4e7f-8f4e-4fa2cb565813
# ╠═7f8f723b-6836-44cd-a51a-d745d66dfcee
# ╠═ef08b6f8-d592-47a4-b262-9c3521391559
