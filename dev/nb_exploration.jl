### A Pluto.jl notebook ###
# v0.19.22

using Markdown
using InteractiveUtils

# ╔═╡ 34796534-d391-11ed-2148-596724b1926d
begin
	using DataFrames
	#using DataFramesMeta
	using PyMNE
	#using Glob
end

# ╔═╡ 13d18ec9-4d2b-4184-91fd-20dc00b55604
bids_dir = "/store/data/MSc_EventDuration"

# ╔═╡ b69c0452-1330-46cf-aa2e-f01754151955
function bidsLayout(bidsPath::AbstractString; 
						derivative::Bool=true, 
						dFolder::String="",
						exFolder::String="raw", 
						task::Union{Nothing, AbstractString} = nothing, 
						run::Union{Nothing, AbstractString} = nothing)
	
	# Any files with these endings will be returned
    file_pattern = ["eeg", "set", "fif", "vhdr", "edf"]

	if task === nothing
		@warn "No task provided, will load all tasks!!"
	else
		file_pattern = push!(file_pattern, "task-"*task)
	end

	if run === nothing
		@warn "No run provided, will load all runs!!"
	else
		file_pattern = push!(file_pattern, "run-"*run)
	end
	
	# Exclude these folders when using raw data
	exclude = ["derivatives", exFolder]
	
    # Should a subfolder of derivatives be used?
	derivativeFolder = "derivatives/" * dFolder
	
	files_df = DataFrame(subject = [], file=[], path=[])  # Initialize an empty DataFrame to hold results

    for (root, dirs, files) in walkdir(bidsPath)
        for file in files
            if sum(occursin.(file_pattern, file)) >= 2 &&
                ((derivative && occursin(derivativeFolder, root)) ||
                (!derivative && !any(occursin.(exclude, root))))

				sub_string = match(r"sub-\d{3}", file)
				sub = last(sub_string.match, 3)
                push!(files_df, (sub, file, root))
            end
        end
    end
    return files_df
end

# ╔═╡ 65a11193-ab24-418c-b581-b6531e846e67
size(bidsLayout(bids_dir, dFolder="RS_replication/preprocessed/", task="Oddball"))

# ╔═╡ 54dd6513-36f0-4641-b2ec-287cb1430f42
begin
	ex = ["derivatives", "raw"]
	push!(ex)
end

# ╔═╡ 459804c2-ac68-4361-b69d-d38984c3728f
sub_df = bidsLayout(bids_dir, dFolder="RS_replication/preprocessed/", task="Oddball")

# ╔═╡ 2129d1f3-ea10-41ef-afe9-2855e50eee28
begin
	x = match(r"sub-\d{3}", sub_df[1,2])
	last(x.match, 3)
end

# ╔═╡ 9bc4052a-03b1-4687-a904-8b44ba6ecb3f
path_df = sub_df[1:2,:]

# ╔═╡ 106a7676-e6fc-443b-8bc0-24370aa95c69
for row in eachrow(path_df)
	@show row.path
end

# ╔═╡ cf467a22-d3e0-4ce8-8137-95486021718a
begin
	#function load_bids_eeg_data(bids_dir::AbstractString)
	    # Find all EEG data files in the BIDS directory
	
		
	    # Initialize an empty dataframe
	    eeg_df = DataFrame()
	
	    # Loop through each EEG data file
	    for row in eachrow(path_df)
			file_path = row.path *"/" * row.file
			
	        # Read in the EEG data as a dataframe using the appropriate reader
	        if endswith(file_path, ".edf")
	            eeg_data = PyMNE.io.read_raw_edf(file_path)
	        elseif endswith(file_path, ".vhdr")
	            eeg_data = PyMNE.io.read_raw_brainvision(file_path)
	        elseif endswith(file_path, ".fif")
	            eeg_data = PyMNE.io.read_raw_fif(file_path, verbose="ERROR")
			elseif endswith(file_path, ".set")
				eeg_data = PyMNE.io.read_raw_eeglab(file_path, verbose="ERROR")
			end
	
			#############
			# TODO: Append specific subject data to dataframe
			#############
			# Add the EEG data to the main dataframe, along with subject and task information
	        #subject_id, task_id = match(r"sub-(.+)_task-(.*)_eeg", basename(file_path)).captures
	        #eeg_data.subject_id .= subject_id
	        #eeg_data.task_id .= task_id
	        
			append!(eeg_df, eeg_data)
	    end
	
	    # Return the combined EEG data dataframe
	    #return eeg_df
	#end
end

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
PyMNE = "6c5003b2-cbe8-491c-a0d1-70088e6a0fd6"

[compat]
DataFrames = "~0.20.2"
PyMNE = "~0.1.2"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.8.3"
manifest_format = "2.0"
project_hash = "1f38c20b2179e83e0117e408ef7f5a166677dd74"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.CategoricalArrays]]
deps = ["Compat", "DataAPI", "Future", "JSON", "Missings", "Printf", "Reexport", "Statistics", "Unicode"]
git-tree-sha1 = "23d7324164c89638c18f6d7f90d972fa9c4fa9fb"
uuid = "324d7699-5711-5eae-9e2f-1d82baa6b597"
version = "0.7.7"

[[deps.Compat]]
deps = ["Base64", "Dates", "DelimitedFiles", "Distributed", "InteractiveUtils", "LibGit2", "Libdl", "LinearAlgebra", "Markdown", "Mmap", "Pkg", "Printf", "REPL", "Random", "SHA", "Serialization", "SharedArrays", "Sockets", "SparseArrays", "Statistics", "Test", "UUIDs", "Unicode"]
git-tree-sha1 = "550e3f8a429fd2f8a9da59f1589c5e268ddc97b3"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "3.46.1"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "0.5.2+0"

[[deps.Conda]]
deps = ["Downloads", "JSON", "VersionParsing"]
git-tree-sha1 = "e32a90da027ca45d84678b826fffd3110bb3fc90"
uuid = "8f4d0f93-b110-5947-807f-2305c1781a2d"
version = "1.8.0"

[[deps.DataAPI]]
git-tree-sha1 = "e8119c1a33d267e16108be441a287a6981ba1630"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.14.0"

[[deps.DataFrames]]
deps = ["CategoricalArrays", "Compat", "DataAPI", "Future", "InvertedIndices", "IteratorInterfaceExtensions", "Missings", "PooledArrays", "Printf", "REPL", "Reexport", "SortingAlgorithms", "Statistics", "TableTraits", "Tables", "Unicode"]
git-tree-sha1 = "7d5bf815cc0b30253e3486e8ce2b93bf9d0faff6"
uuid = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
version = "0.20.2"

[[deps.DataStructures]]
deps = ["InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "88d48e133e6d3dd68183309877eac74393daa7eb"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.17.20"

[[deps.DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.DelimitedFiles]]
deps = ["Mmap"]
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"

[[deps.Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.InvertedIndices]]
git-tree-sha1 = "82aec7a3dd64f4d9584659dc0b62ef7db2ef3e19"
uuid = "41ab1584-1d38-5bbf-9106-f11c6c58b48f"
version = "1.2.0"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "81690084b6198a2e1da36fcfda16eeca9f9f24e4"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.1"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.3"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "7.84.0+0"

[[deps.LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.10.2+0"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.LinearAlgebra]]
deps = ["Libdl", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "42324d08725e200c23d4dfb549e0d5d89dede2d2"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.10"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.0+0"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "f8c673ccc215eb50fcadb285f522420e29e69e1c"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "0.4.5"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2022.2.1"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.20+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[deps.Parsers]]
deps = ["Dates", "Test"]
git-tree-sha1 = "0c16b3179190d3046c073440d94172cfc3bb0553"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "0.3.12"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.8.0"

[[deps.PooledArrays]]
deps = ["DataAPI"]
git-tree-sha1 = "b1333d4eced1826e15adbdf01a4ecaccca9d353c"
uuid = "2dfb63ee-cc39-5dd5-95bd-886bf059d720"
version = "0.5.3"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.PyCall]]
deps = ["Conda", "Dates", "Libdl", "LinearAlgebra", "MacroTools", "Serialization", "VersionParsing"]
git-tree-sha1 = "62f417f6ad727987c755549e9cd88c46578da562"
uuid = "438e738f-606a-5dbb-bf0a-cddfbfd45ab0"
version = "1.95.1"

[[deps.PyMNE]]
deps = ["PyCall"]
git-tree-sha1 = "b3caa6ea95490974465487d54fc1e62a094bad8e"
uuid = "6c5003b2-cbe8-491c-a0d1-70088e6a0fd6"
version = "0.1.2"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.Reexport]]
deps = ["Pkg"]
git-tree-sha1 = "7b1d07f411bc8ddb7977ec7f377b97b158514fe0"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "0.2.0"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "f6cb12bae7c2ecff6c4986f28defff8741747a9b"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "0.3.2"

[[deps.SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.0"

[[deps.TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[deps.Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "OrderedCollections", "TableTraits", "Test"]
git-tree-sha1 = "c79322d36826aa2f4fd8ecfa96ddb47b174ac78d"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.10.0"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.1"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.VersionParsing]]
git-tree-sha1 = "58d6e80b4ee071f5efd07fda82cb9fbe17200868"
uuid = "81def892-9a0e-5fdd-b105-ffc91e053289"
version = "1.3.0"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.12+3"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl", "OpenBLAS_jll"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.1.1+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.48.0+0"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+0"
"""

# ╔═╡ Cell order:
# ╠═34796534-d391-11ed-2148-596724b1926d
# ╠═13d18ec9-4d2b-4184-91fd-20dc00b55604
# ╠═b69c0452-1330-46cf-aa2e-f01754151955
# ╠═65a11193-ab24-418c-b581-b6531e846e67
# ╠═54dd6513-36f0-4641-b2ec-287cb1430f42
# ╠═459804c2-ac68-4361-b69d-d38984c3728f
# ╠═2129d1f3-ea10-41ef-afe9-2855e50eee28
# ╠═9bc4052a-03b1-4687-a904-8b44ba6ecb3f
# ╠═106a7676-e6fc-443b-8bc0-24370aa95c69
# ╠═cf467a22-d3e0-4ce8-8137-95486021718a
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
