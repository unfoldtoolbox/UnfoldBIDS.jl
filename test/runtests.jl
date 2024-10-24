using Unfold, UnfoldBIDS
using LazyArtifacts
using Test
using DataFrames
using Logging

###
@testset "UnfoldBIDS.extract_subject_id!" begin
    # Write your tests here.

    # Tests for extract_subject_id
    files_df = DataFrame(Sub=[], Ses=[], Task=[], Run=[], File=[])
    
    # Test case 1: All fields present
    file1 = "sub-01_ses-02_task-rest_run-01_bold.vhdr"
    files_df = UnfoldBIDS.extract_subject_id!(files_df, file1)
    @test isequal(files_df[1, :], DataFrame(Sub = "01", Ses = "02", Task = "rest", Run = "01", File = file1)[1,:])

    # Test case 2: Missing run
    file2 = "sub-03_ses-04_task-taskname_bold.vhdr"
    files_df = UnfoldBIDS.extract_subject_id!(files_df, file2)
    @test isequal(files_df[2, :], DataFrame(Sub = "03", Ses = "04", Task = "taskname", Run = missing, File = file2)[1,:])

    # Test case 3: Missing session and run
    file3 = "sub-05_task-taskname_bold.vhdr"
    files_df = UnfoldBIDS.extract_subject_id!(files_df, file3)
    @test isequal(files_df[3, :], DataFrame(Sub = "05", Ses = missing, Task = "taskname", Run = missing, File = file3)[1,:])

    # Test case 4: Missing task and run
    file4 = "sub-06_ses-07_bold.vhdr"
    files_df = UnfoldBIDS.extract_subject_id!(files_df, file4)
    @test isequal(files_df[4, :], DataFrame(Sub = "06", Ses = "07", Task = missing, Run = missing, File = file4)[1,:])

    # Test case 5: Only subject
    file5 = "sub-08_bold.vhdr"
    files_df = UnfoldBIDS.extract_subject_id!(files_df, file5)
    @test isequal(files_df[5, :], DataFrame(Sub = "08", Ses = missing, Task = missing, Run = missing, File = file5)[1,:])

    # Test case 6: No matching pattern
    file6 = "no_pattern_here.vhdr"
    files_df = UnfoldBIDS.extract_subject_id!(files_df, file6)
    @test isequal(files_df[6, :], DataFrame(Sub = missing, Ses = missing, Task = missing, Run = missing, File = file6)[1,:])
end

### Find paths

# Create a temporary directory and files for testing
function setup_temp_directory()
    temp_dir = mktempdir()

    # Create some files with different patterns and endings
    open(joinpath(temp_dir, "file1.txt"), "w") do f
        write(f, "Sample text file 1")
    end
    open(joinpath(temp_dir, "file2.log"), "w") do f
        write(f, "Log file content")
    end
    open(joinpath(temp_dir, ".hidden.txt"), "w") do f
       write(f, "Hidden file content")
    end

    # Create a subdirectory
    sub_dir = joinpath(temp_dir, "subdir")
    mkdir(sub_dir)
    open(joinpath(sub_dir, "file3.txt"), "w") do f
        write(f, "Sample text file 3")
    end

    # Create a hidden directory with files
    hidden_dir = joinpath(temp_dir, ".hidden_subdir")
    mkdir(hidden_dir)
    open(joinpath(hidden_dir, "file4.txt"), "w") do f
        write(f, "This file should be ignored")
    end

    return temp_dir
end

@testset "UnfoldBIDS.list_all_paths tests" begin
    # Setup
    temp_dir = setup_temp_directory()

    # Test 1: Simple file ending and pattern match
    result = collect(UnfoldBIDS.list_all_paths(temp_dir, ".txt", "file1"))
	@test length(result) == 1
    @test result[1] == joinpath(temp_dir, "file1.txt")

    # Test 2: Directory traversal with file ending ".txt"
    result = collect(UnfoldBIDS.list_all_paths(temp_dir, ".txt", ""))
	@test length(result) == 2 # file1.txt and subdir/file3.txt
    @test joinpath(temp_dir, "file1.txt") in result
    @test joinpath(temp_dir, "subdir", "file3.txt") in result

    # Test 3: Hidden files/directories should be ignored
    result = collect(UnfoldBIDS.list_all_paths(temp_dir, ".txt", ""; exclude=nothing))
	@test length(result) == 2 # should not include hidden files

    # Test 4: Exclude certain directories
    result = collect(UnfoldBIDS.list_all_paths(temp_dir, ".txt", ""; exclude=["subdir"]))
	@test length(result) == 1 # Only file1.txt should be listed, subdir excluded
    @test joinpath(temp_dir, "file1.txt") in result

    # Test 5: No matches
    result = collect(UnfoldBIDS.list_all_paths(temp_dir, ".md", ""))
	 @test length(result) == 0 # No markdown files present
end

### UnfoldBIDS.check_df

# Test cases
@testset "UnfoldBIDS.check_df tests" begin
    # Test 1: Multiple sessions, should trigger a warning
    files_df = DataFrame(ses = ["ses1", "ses2"], task = ["task1", "task1"], run = ["run1", "run1"])
    @test_logs (:warn,) begin
    	  UnfoldBIDS.check_df(files_df, nothing, "task1", "run1")
    end
    
    # Test 2: No session provided but only one unique session, should not trigger a warning
    files_df = DataFrame(ses = ["ses1"], task = ["task1"], run = ["run1"])
    @test_logs begin
        UnfoldBIDS.check_df(files_df, nothing, "task1", "run1")
    end

    # Test 3: Multiple tasks, should trigger a warning
    files_df = DataFrame(ses = ["ses1", "ses1"], task = ["task1", "task2"], run = ["run1", "run1"])
    @test_logs (:warn,) begin
        UnfoldBIDS.check_df(files_df, "ses1", nothing, "run1")
    end

    # Test 4: Multiple runs, should trigger a warning
    files_df = DataFrame(ses = ["ses1", "ses1"], task = ["task1", "task1"], run = ["run1", "run2"])
    @test_logs (:warn,) begin
        UnfoldBIDS.check_df(files_df, "ses1", "task1", nothing)
    end

    # Test 5: No warning when ses, task, and run are provided and have single unique values
    files_df = DataFrame(ses = ["ses1", "ses1"], task = ["task1", "task1"], run = ["run1", "run1"])
    @test_logs begin
        UnfoldBIDS.check_df(files_df, "ses1", "task1", "run1")
    end
    
    # Test 6: Handling missing values in ses, task, and run fields (no warnings)
    files_df = DataFrame(ses = [missing, missing], task = [missing, missing], run = [missing, missing])
    @test_logs begin
        UnfoldBIDS.check_df(files_df, nothing, nothing, nothing)
    end
end


## Test run_unfold
# This only tests if unold runs without error/ warning
@testset "UnfoldBIDS.run_unfold tests" begin
    data_path = artifact"sample_BIDS"
    layout = bids_layout(data_path, derivatives=false)

    data_df = load_bids_eeg_data(layout)

    basisfunction = firbasis(τ=(-0.2,.8),sfreq=1024)
    f  = @formula 0~1
    bfDict = ["stimulus"=>(f,basisfunction)]
    UnfoldBIDS.rename_to_latency(data_df, :sample) # add :latency collumn in events;
    
    @test_logs begin
        run_unfold(data_df, bfDict; verbose = false, eventcolumn="trial_type");
    end
end