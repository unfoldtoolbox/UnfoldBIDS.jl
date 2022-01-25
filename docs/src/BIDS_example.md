# Move the example code from unfold_bids.jl here
=> Add an Artifact of one 8-bit subject (maybe downsamples, less channels to save space) using Artifacts.jl (dont ask Bene, but explain it to him how it works ;-)).

TODO: Make one Subject into tar file (including BIDS structure)
    Usage: make tar.gz archive of data; upload to repo; make entry in Artifacts.toml with create_artifact, bind_artifact and artifact_hash

## Parameter setting
First we need to set some basic Parameter, like the path to our Data:
```julia

# the base bids folder, ...
loc = "../../../data/8bit/derivatives/logs_added";

# the subjects involved, ...
subs = ["001"];

# the tasks performed, ...
tasks = ["ContinuousVideoGamePlay"];

# the runs ...
runs = ["02"];

# as well as the file type used to store the eeg data, denoted by its file ending (without the dot)
fileEnding = "vhdr";
```


As well as which data we are actually interested in:

```julia
# Channel
# an empty array results in channels 1:63 being processed (the data channels in the dataset used 
# with this script originally)
# able to handle both integer indizes (for example produced by a range like 10:20;) as well as  
# channel name Strings like "Cz"
# (a mix like [1:4;"Fz";"Cz";63] works as well)
interesting_channels = ["Cz"];

# events that should be ignored due to e.g. low sample size
drop_events = ["STATUS","GAME OVER","GAME START"];

# basic time around an event used for epoching and default basis functions (in seconds)
tau = (-0.5, 1.0);
```

And lasty some plotting Parameters:
```julia
# what dataframe columns to use for the x and y axes of the ERP plots
basic_mapping = mapping(:colname_basis => "Time from Event (s)",:estimate => "Estimate (μV)");

# for a larger number of channels, laying out the plots gets incredibly slow, so only execute manually what you need
auto_render_cutoff = 3;
```
## Script work
Now we can start processing our data
```julia


results_r = DataFrame();
results_e = DataFrame();

positions = nothing;

# For now use all channels
# if isempty(interesting_channels) interesting_channels = [1:63;]; end;

# for s in subs
# for t in tasks
# for r in runs

#for testing purposes; also comment in/out the triple "end" at the end of the Using Unfold part
s = subs[1];
t = tasks[1];
r = runs[1];

# fun with bids
currentLoc = loc * "/sub-" * s * "/eeg/sub-" * s * "_task-" * t * "_run-" * r;

# -----------------------------------------------------------------------------------------------------------------
#  Formulas and Functions 1
# -----------------------------------------------------------------------------------------------------------------

bfDict = Dict{String,Tuple{FormulaTerm, Unfold.BasisFunction}}(
# define custom formulas and basisfunctions here, all events without one will later be
#  assigned a default (@formula( 0 ~ 1 ), firbasis(τ=(-0.4, .8), sfreq=raw.info["sfreq"], name=evt_name))

# examples
#"PLAYER_CRASH_ENEMY" => (@formula( 0 ~ 1 + HEALTH ),firbasis(τ=tau, sfreq=500, name="PLAYER_CRASH_ENEMY")),
#"PLAYER_CRASH_WALL" => (@formula( 0 ~ 1 + HEALTH), firbasis(τ=tau, sfreq=500, name="PLAYER_CRASH_WALL"))

);  #bfDict end

epochedFormulas = [
# define custom formulas for epoch-based analysis here; all events not present in a formula will later
#  be assigned a default term(0) ~ term(0) + term(evt_name)
# note that for code simplicity, all formulas should have at least two terms on the right side,
#  even if as in the given examples, one is 0

# examples
#@formula(0 ~ 0 + COLLECT_AMMO),
#@formula(0 ~ 0 + SHOOT_BUTTON)

];  #epochedFormulas end

# -----------------------------------------------------------------------------------------------------------------
#  Raw Data Processing
# -----------------------------------------------------------------------------------------------------------------

evts_set, evts, raw_data, sfreq = loadRaw(currentLoc, fileEnding, drop_events);

##
chan_types = Dict(:AMMO=>"misc",:HEALTH=>"misc",
                    :PLAYERX=>"misc", :PLAYERY=>"misc",
                    :WALLABOVE=>"misc",:WALLBELOW=>"misc",
                    :CLOSESTENEMY=>"misc",:CLOSESTSTAR=>"misc")

motage = "standard_1020"
##
interesting_channel_names, positions = populateRaw(raw_data, chan_types, montage, bfDict, epochedFormulas, interesting_channels)

#convert data to μV from Volt to undermine possible underflows in the later calculation
#raw_data does only contain the interesting_channels specified, so unless one specified a stim channel, this simple line is enough
raw_data .*= 10 ^ 6;

if positions === nothing
    global positions = positions_temp;
end

# -----------------------------------------------------------------------------------------------------------------
#  Formulas and Functions 2
# -----------------------------------------------------------------------------------------------------------------

addDefaultEventFormulas!(bfDict,epochedFormulas,evts_set,tau); # This should be changed into addDefaultEventformulas

```

## Using Unfold to get ERPS
```julia

# regression-based analysis fits all ERPs at once
_, res_r = fit(UnfoldLinearModel, bfDict, evts, raw_data, eventcolumn="event");
res_r.channel = [interesting_channel_names[i] for i in res_r.channel];

# epoch-based analysis needs to fit every ERP separately and was therefore outsourced into the accompanying library
res_e = epochedFit(UnfoldLinearModel,epochedFormulas,evts,raw_data,tau,sfreq);
res_e.channel = [interesting_channel_names[i] for i in res_e.channel];

# allow later grouping by subject, task or run
insertcols!(res_r, ([:subject,:task,:run] .=> (s,t,r))...);
insertcols!(res_e, ([:subject,:task,:run] .=> (s,t,r))...);

# depending on changes in newer Julia versions, the globals here might no longer be necessary
global results_r = vcat(results_r,res_r,cols=:union);
global results_e = vcat(results_e,res_e,cols=:union);


# the triple "end" at the end of the Using Unfold part
# end #runs
# end #tasks
# end #subs

```

##  Filtering and grouping the results
```julia

# if covariates were used (Intercept is not the only term), group by term as well, don't compare with epoched results etc.
covariates_used = length(Set(results_r.term))>1;

# different names to keep the different steps around for exploration
# make a grouped DataFrame and ...
if covariates_used
    grouped_r = groupby(results_r,[:basisname,:colname_basis,:channel,:term]);
else
    grouped_r = groupby(results_r,[:basisname,:colname_basis,:channel]);
end
# take the mean over the estimates for each group, but keep the name the same instead of appending _mean to it
combined_r = combine(grouped_r,:estimate => mean => :estimate);

# repeat for epoch-based analysis results
grouped_e = groupby(results_e,[:term,:colname_basis,:channel]);
combined_e = combine(grouped_e,:estimate => mean => :estimate);

# compare both methods
if !covariates_used
    prepped_r = copy(combined_r);
    rename!(prepped_r,:basisname => :basisname_term);
    prepped_r[!,"Analysis Type"] .= :regression_based;

    prepped_e = copy(combined_e);
    rename!(prepped_e,:term => :basisname_term);
    prepped_e[!,"Analysis Type"] .= :epoch_based;

    prepped = vcat(prepped_r,prepped_e);
end
```

## Plotting the Results

```julia
# --> once the script is done, call fg_r, fg_e or fg in the Julia REPL to look at your results in a new window
#  (or the old window incase you already looked at something and didn't close it!)

if length(interesting_channels) <= auto_render_cutoff
    # regression-based ERPs, plot using terms and add legend in case of covariates
    if covariates_used
        fg_r = drawERPs(combined_r, basic_mapping, mapping(col = :basisname, color = :term, row=:channel), addLegend = true);
    else
        fg_r = drawERPs(combined_r, basic_mapping, mapping(col = :basisname, color = :basisname, row=:channel));
    end

    # epoch-based ERPs
    fg_e = drawERPs(combined_e, basic_mapping, mapping(col = :term, color = :term, row = :channel));

    # comparison
    if !covariates_used
        fg = drawERPs(prepped, basic_mapping, mapping(col = :basisname_term, color = Symbol("Analysis Type"), row = :channel),
            addLegend = true);
    end
end

# just "if false" makes the IDE complain
if true == false
    # only run needed lines manually if you want to save/load a plot or result etc.
    save("results_r_all.csv", results_r);
    save("results_e_all.csv", results_e);
    writedlm("positions.csv", positions);
    global results_r = DataFrame(load("results_r_all.csv"));
    global results_e = DataFrame(load("results_e_all.csv"));
    global positions = readdlm("positions.csv", Float64);
    save("output/Cz_epoched_allSubs.png", fg_e);
    save("output/Cz_compare_allSubs_short.png", fg);
    save("output/Cz_covariates_allSubs_short.png", fg_r);

    # manipulating the data into the shape needed for testing the topoplot beta
    combined_r_part = combined_r[combined_r.basisname .== "SHOOT_BUTTON", :];
    combined_r_part = combined_r_part[combined_r_part.colname_basis .== .28, :];
    fg_tr, _ = topoplot(combined_r_part.estimate,positions=positions);
    combined_e_part = combined_e[combined_e.term .== "SHOOT_BUTTON", :];
    combined_e_part = combined_e_part[combined_e_part.colname_basis .== 0, :];
    fg_te, _ = topoplot(combined_e_part.estimate,positions=positions);
    fg_test, _ = topoplot([1:63;],positions=positions);

    # for getting the complete data cut down after loading it from file
    combined_e = combined_e[combined_e.channel .== "Cz",:];
    results_r = results_r[results_r.channel .== "Cz",:];
    results_e = results_e[results_e.channel .== "Cz",:];

    # for ordering the epoched plot just as Cavanagh had
    # (at the point of writing this script, only alphabetical ordering was possible)
    nameDict = Dict(
        "PLAYER_CRASH_ENEMY" => "5: CRASH_ENEMY",
        "MISSILE_HIT_ENEMY" => "6: MISSILE_HIT",
        "COLLECT_STAR" => "2: COLLECT_STAR",
        "SHOOT_BUTTON" => "1: SHOOT_BUTTON",
        "PLAYER_CRASH_WALL" => "4: CRASH_WALL",
        "COLLECT_AMMO" => "3: COLLECT_AMMO"
    );
    combined_e.term = [nameDict[i] for i in combined_e.term];
    combined_r.basisname = [nameDict[i] for i in combined_r.basisname];
    prepped.basisname_term = [nameDict[i] for i in prepped.basisname_term];
end
```