### A Pluto.jl notebook ###
# v0.19.25

using Markdown
using InteractiveUtils

# ╔═╡ 5f67300e-03a3-11ee-39cf-239b4c1a9f06
begin
using Pkg
	Pkg.activate(mktempdir())
end

# ╔═╡ b587c45d-4d57-44f1-b8be-b0b3d9d5645a
Pkg.add("PlutoLinks")

# ╔═╡ dd1e4090-0083-4856-b2d1-75e39f0d5dfb
Pkg.add("Unfold")

# ╔═╡ de091ef2-e3d2-4866-bff0-9720bc697dc5
Pkg.add("UnfoldMakie")

# ╔═╡ f360e2fe-55bf-48bc-88fc-5cc30a7eda95
Pkg.add("WGLMakie")

# ╔═╡ 027cf8eb-f255-444c-91f2-763f510d3055
using PlutoLinks

# ╔═╡ 5d01b654-9a95-4994-87f7-86bcefc3e0f5
begin
	Pkg.develop(path="../")
		@revise using UnfoldBIDS
end


# ╔═╡ e769c86d-698e-41d7-af58-d22ef42476b9
using Unfold

# ╔═╡ b61b2986-bfcf-4b5b-a97b-eca8eaec55f5

# To look up the paths of all subjects and store in a Dataframe:
layout_df = bidsLayout("/store/data/8bit/derivatives/logs_added/")
# To load all data into memory/ one dataframe:           


# ╔═╡ 857995e5-a9f5-45dd-bfa9-b8a7116fded8
eeg_df = load_bids_eeg_data(layout_df)



# ╔═╡ fb5aeed9-9050-4625-b21c-088eafc205e8
begin
	# First define the path where **all** CSV files are stored, e.g.:
subPath ="/store/data/8bit/derivatives/logs_added/sub-%s/eeg/sub-%s_task-ContinuousVideoGamePlay_run-02_events.tsv"
# Then call
events = collectEvents(layout_df.subject, subPath; delimiter="\t");
end
# To run Unfold model:



# ╔═╡ f1026dd1-d46d-427e-b226-5d39bcbb145e


# ╔═╡ 0f5fa8d2-d244-491d-a8b6-459022ce6ff0
bfDict = Dict("MISSILE_HIT_ENEMY"=>(@formula(0~1),firbasis((-0.5,1),500)))

# ╔═╡ f98fb7f7-97fa-4066-a754-08d878bb14a4
resultsAll = runUnfold(eeg_df, events, bfDict; channels=1, eventcolumn="trial_type")

# ╔═╡ 7f1d2609-c771-4a9e-8cc4-b37794b4817e
plot_erp(resultsAll)

# ╔═╡ 24a268b0-cdb5-41f5-9528-a95d4539a94e
events.latency = events.onset .*500;

# ╔═╡ Cell order:
# ╠═5f67300e-03a3-11ee-39cf-239b4c1a9f06
# ╠═b587c45d-4d57-44f1-b8be-b0b3d9d5645a
# ╠═027cf8eb-f255-444c-91f2-763f510d3055
# ╠═5d01b654-9a95-4994-87f7-86bcefc3e0f5
# ╠═b61b2986-bfcf-4b5b-a97b-eca8eaec55f5
# ╠═857995e5-a9f5-45dd-bfa9-b8a7116fded8
# ╠═fb5aeed9-9050-4625-b21c-088eafc205e8
# ╠═dd1e4090-0083-4856-b2d1-75e39f0d5dfb
# ╠═f1026dd1-d46d-427e-b226-5d39bcbb145e
# ╠═e769c86d-698e-41d7-af58-d22ef42476b9
# ╠═0f5fa8d2-d244-491d-a8b6-459022ce6ff0
# ╠═f98fb7f7-97fa-4066-a754-08d878bb14a4
# ╠═de091ef2-e3d2-4866-bff0-9720bc697dc5
# ╠═f360e2fe-55bf-48bc-88fc-5cc30a7eda95
# ╠═7f1d2609-c771-4a9e-8cc4-b37794b4817e
# ╠═24a268b0-cdb5-41f5-9528-a95d4539a94e
