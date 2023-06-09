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
Pkg.add(["UnfoldMakie","WGLMakie","PythonCall","ProfileCanvas","Unfold","PlutoLinks","DataFrames","DataFramesMeta"])

# ╔═╡ 027cf8eb-f255-444c-91f2-763f510d3055
using PlutoLinks

# ╔═╡ 5d01b654-9a95-4994-87f7-86bcefc3e0f5
# ╠═╡ show_logs = false
begin
	Pkg.develop(path="../")
		@revise using UnfoldBIDS
end


# ╔═╡ ef08b6f8-d592-47a4-b262-9c3521391559
using Statistics

# ╔═╡ d23372c2-21b4-4c41-8207-fb4a9c8ed4ca
using DataFramesMeta,DataFrames,PythonCall,Unfold,ProfileCanvas,WGLMakie,UnfoldMakie

# ╔═╡ b61b2986-bfcf-4b5b-a97b-eca8eaec55f5

# To look up the paths of all subjects and store in a Dataframe:
layout_df = bidsLayout("/store/data/8bit/derivatives/logs_added/")
# To load all data into memory/ one dataframe:           


# ╔═╡ 857995e5-a9f5-45dd-bfa9-b8a7116fded8
# ╠═╡ show_logs = false
eeg_df = load_bids_eeg_data(layout_df)

# ╔═╡ fb5aeed9-9050-4625-b21c-088eafc205e8
begin
	# First define the path where **all** CSV files are stored, e.g.:
subPath ="/store/data/8bit/derivatives/logs_added/sub-%s/eeg/sub-%s_task-ContinuousVideoGamePlay_run-02_events.tsv"
# Then call
events = collectEvents(layout_df.subject, subPath; delimiter="\t");
end
# To run Unfold model:



# ╔═╡ 07cb1442-8e60-4492-b1c9-a59f3641e1ec
pylist(["A","b"])

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
d = Dict(:HEALTH => 0.4:0.1:1,
		:CLOSESTENEMY=>0:0.1:1)
	
effectsAll = combine(groupby(resultsAll,:subject),:model=>(x-> effects(d,x[1]))=>AsTable)
	
	effectsAvg = groupby(effectsAll,[:time,keys(d)...])|>x-> combine(x,:yhat=>mean=>:yhat) 
plot_erp(effectsAvg;mapping=(;color=first(keys(d))),extra=(;categoricalColor=false))
end

# ╔═╡ 755fa9d3-d68e-4e69-96a4-f50b3dbfdc70


# ╔═╡ Cell order:
# ╠═5f67300e-03a3-11ee-39cf-239b4c1a9f06
# ╠═027cf8eb-f255-444c-91f2-763f510d3055
# ╠═4358e394-3636-48ab-93ed-97a646e90312
# ╠═5d01b654-9a95-4994-87f7-86bcefc3e0f5
# ╠═b61b2986-bfcf-4b5b-a97b-eca8eaec55f5
# ╠═857995e5-a9f5-45dd-bfa9-b8a7116fded8
# ╠═fb5aeed9-9050-4625-b21c-088eafc205e8
# ╠═f98fb7f7-97fa-4066-a754-08d878bb14a4
# ╠═07cb1442-8e60-4492-b1c9-a59f3641e1ec
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
# ╠═ef08b6f8-d592-47a4-b262-9c3521391559
# ╠═755fa9d3-d68e-4e69-96a4-f50b3dbfdc70
# ╠═d23372c2-21b4-4c41-8207-fb4a9c8ed4ca
