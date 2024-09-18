using UnfoldBIDS
using Test
using DataFrames

@testset "UnfoldBIDS.get_info!" begin
    # Write your tests here.

    # Tests for get_info
    files_df = DataFrame(Sub=[], Ses=[], Task=[], Run=[], File=[])
    
    # Test case 1: All fields present
    file1 = "sub-01_ses-02_task-rest_run-01_bold.vhdr"
    files_df = UnfoldBIDS.get_info!(files_df, file1)
    @test isequal(files_df[1, :], DataFrame(Sub = "01", Ses = "02", Task = "rest", Run = "01", File = file1)[1,:])

    # Test case 2: Missing run
    file2 = "sub-03_ses-04_task-taskname_bold.vhdr"
    files_df = UnfoldBIDS.get_info!(files_df, file2)
    @test isequal(files_df[2, :], DataFrame(Sub = "03", Ses = "04", Task = "taskname", Run = missing, File = file2)[1,:])

    # Test case 3: Missing session and run
    file3 = "sub-05_task-taskname_bold.vhdr"
    files_df = UnfoldBIDS.get_info!(files_df, file3)
    @test isequal(files_df[3, :], DataFrame(Sub = "05", Ses = missing, Task = "taskname", Run = missing, File = file3)[1,:])

    # Test case 4: Missing task and run
    file4 = "sub-06_ses-07_bold.vhdr"
    files_df = UnfoldBIDS.get_info!(files_df, file4)
    @test isequal(files_df[4, :], DataFrame(Sub = "06", Ses = "07", Task = missing, Run = missing, File = file4)[1,:])

    # Test case 5: Only subject
    file5 = "sub-08_bold.vhdr"
    files_df = UnfoldBIDS.get_info!(files_df, file5)
    @test isequal(files_df[5, :], DataFrame(Sub = "08", Ses = missing, Task = missing, Run = missing, File = file5)[1,:])

    # Test case 6: No matching pattern
    file6 = "no_pattern_here.vhdr"
    files_df = UnfoldBIDS.get_info!(files_df, file6)
    @test isequal(files_df[6, :], DataFrame(Sub = missing, Ses = missing, Task = missing, Run = missing, File = file6)[1,:])
end
