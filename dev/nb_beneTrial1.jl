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
Pkg.add(["UnfoldMakie","WGLMakie","PythonCall","ProfileCanvas","Unfold","PlutoLinks","DataFrames","DataFramesMeta"])

# ╔═╡ 027cf8eb-f255-444c-91f2-763f510d3055
using PlutoLinks

# ╔═╡ 5d01b654-9a95-4994-87f7-86bcefc3e0f5
begin
	Pkg.develop(path="../")
		@revise using UnfoldBIDS
end


# ╔═╡ d23372c2-21b4-4c41-8207-fb4a9c8ed4ca
using DataFramesMeta,DataFrames,PythonCall,Unfold,ProfileCanvas,WGLMakie,UnfoldMakie

# ╔═╡ b587c45d-4d57-44f1-b8be-b0b3d9d5645a


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



# ╔═╡ e91785c6-15fa-41ca-bc32-ac90855f0f52


# ╔═╡ fae8d9a0-ada9-44f0-9d6b-cc139b2f5c23


# ╔═╡ a309375d-50ee-44fa-bd2c-6c04715d83ca
gps= groupby(subset!(events,:sample=>x->x.>0),:subject);


# ╔═╡ 6aa74df2-c5b9-4f73-8f29-221affb7df11
function add_covariates!(df)
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
events_tuned = transform!(gps,AsTable(:)=> x->(add_covariates!(x)) => AsTable(:);threads=false)

# ╔═╡ 0518658e-8dba-466d-9029-ab59c1a0243f
pyconvert(Vector,eeg_df.data[1].info["ch_names"])[end-7:end]

# ╔═╡ 0f5fa8d2-d244-491d-a8b6-459022ce6ff0
bfDict = Dict("MISSILE_HIT_ENEMY"=>(@formula(0~1),firbasis((-0.5,1),500)))

# ╔═╡ f98fb7f7-97fa-4066-a754-08d878bb14a4
resultsAll = runUnfold(eeg_df, events, bfDict; channels=1, eventcolumn="trial_type")

# ╔═╡ beac3088-f5e5-4113-8d81-5feddb6ffcfa


# ╔═╡ e769c86d-698e-41d7-af58-d22ef42476b9


# ╔═╡ 66c41ec0-99d7-4a68-9140-3cd7a966dc58


# ╔═╡ 72b4daf0-045c-4918-aab8-439a320894d9


# ╔═╡ de091ef2-e3d2-4866-bff0-9720bc697dc5


# ╔═╡ f360e2fe-55bf-48bc-88fc-5cc30a7eda95


# ╔═╡ 7f1d2609-c771-4a9e-8cc4-b37794b4817e
plot_erp(resultsAll;mapping=(;color=:subject))

# ╔═╡ 24a268b0-cdb5-41f5-9528-a95d4539a94e
events.latency = events.onset .*500;

# ╔═╡ Cell order:
# ╠═5f67300e-03a3-11ee-39cf-239b4c1a9f06
# ╠═b587c45d-4d57-44f1-b8be-b0b3d9d5645a
# ╠═027cf8eb-f255-444c-91f2-763f510d3055
# ╠═4358e394-3636-48ab-93ed-97a646e90312
# ╠═5d01b654-9a95-4994-87f7-86bcefc3e0f5
# ╠═b61b2986-bfcf-4b5b-a97b-eca8eaec55f5
# ╠═857995e5-a9f5-45dd-bfa9-b8a7116fded8
# ╠═fb5aeed9-9050-4625-b21c-088eafc205e8
# ╠═f98fb7f7-97fa-4066-a754-08d878bb14a4
# ╠═e91785c6-15fa-41ca-bc32-ac90855f0f52
# ╠═36b26293-0cab-4153-9dd4-a32990734307
# ╠═fae8d9a0-ada9-44f0-9d6b-cc139b2f5c23
# ╠═a309375d-50ee-44fa-bd2c-6c04715d83ca
# ╠═6aa74df2-c5b9-4f73-8f29-221affb7df11
# ╠═0518658e-8dba-466d-9029-ab59c1a0243f
# ╠═0f5fa8d2-d244-491d-a8b6-459022ce6ff0
# ╠═beac3088-f5e5-4113-8d81-5feddb6ffcfa
# ╠═d23372c2-21b4-4c41-8207-fb4a9c8ed4ca
# ╠═e769c86d-698e-41d7-af58-d22ef42476b9
# ╠═66c41ec0-99d7-4a68-9140-3cd7a966dc58
# ╠═72b4daf0-045c-4918-aab8-439a320894d9
# ╠═de091ef2-e3d2-4866-bff0-9720bc697dc5
# ╠═f360e2fe-55bf-48bc-88fc-5cc30a7eda95
# ╠═7f1d2609-c771-4a9e-8cc4-b37794b4817e
# ╠═24a268b0-cdb5-41f5-9528-a95d4539a94e
