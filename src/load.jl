# all functions relating to loading
#
# => rename process to load

# L178 populate ... => in own helper function.

####################################################################################################

# i.set file loading
function loadRawSet(currentLoc,fileEnding,drop_events)
    # .set files were only tested in the early stages of development, but should work as well as .vhdr
    raw = PyMNE.io.read_raw_eeglab(currentLoc * "_eeg."*fileEnding, preload=true);
    sfreq = raw.info["sfreq"];
    evts_set = filter(x -> x ∉ drop_events,collect(Set(a["description"] for a in raw.annotations)));
    evts = DataFrame();
    for a in annotations
        row_frame = DataFrame(:latency => floor(Int, a["onset"] * sfreq), :event => a["description"]);
        append!(evts,row_frame);
    end
    return raw,evts_set,evts,sfreq
end

####################################################################################################

# .vhdr file loading
function loadRawVhdr(currentLoc,fileEnding,drop_events)
    raw = PyMNE.io.read_raw_brainvision(currentLoc * "_eeg."*fileEnding, preload = true);
    # the data saved by mne-bids in .vhdr format had the correct event names stored extra
    evts_tsv = DataFrame(load(currentLoc*"_events.tsv"));
    evts_set = filter(x -> x ∉ drop_events,collect(Set(evts_tsv.trial_type)));
    sfreq = raw.info["sfreq"];
    evts = DataFrame();
    for (i,a) in enumerate(raw.annotations)
        if !(evts_tsv[i,"trial_type"] in drop_events)
            row_frame = DataFrame(:latency => floor(Int, a["onset"] * sfreq), :event => evts_tsv[i,"trial_type"]);
            append!(evts,row_frame);
        end
    end
    return raw,evts_set,evts,sfreq
end

####################################################################################################

function loadRaw(currentLoc,fileEnding, drop_events)

    if fileEnding == "set"
        # EEGLab data
        raw,evts_set,evts,sfreq = loadRawSet(currentLoc,fileEnding,drop_events);

    elseif fileEnding == "vhdr"
        # Brainvision data
        raw,evts_set,evts,sfreq = loadRawVhdr(currentLoc,fileEnding,drop_events);

    else
        # Other data, not tested so far!
        print("This file ending was not tested with this script, you might have to add support for it.");
        raw = PyMNE.io.load(currentLoc * "_eeg."*fileEnding, preload = true);
        evts_set = collect(Set(a["description"] for a in raw.annotations));
        sfreq = raw.info["sfreq"];
        evts = DataFrame();
        for a in raw.annotations
            row_frame = DataFrame(:latency => floor(Int, a["onset"] * sfreq), :event => a["description"]);
            append!(evts,row_frame);
        end
    end
    return evts_set, evts, raw, sfreq
end 

function populateRaw(raw, chan_types::Dict, montage::String, bfDict, epochedFormulas, interesting_channels, evts_set, evts)
    # copied from the test for topoplot of UnfoldMakie
    #-------------------------------------------------------------------------------------------------
    raw.set_channel_types(chan_types)
    raw.set_montage(montage)
    layout_from_raw = PyMNE.channels.make_eeg_layout(get_info(raw))
    positions = layout_from_raw.pos
    ix = sortperm(positions[:,2])
    positions = positions[ix,:]
    #-------------------------------------------------------------------------------------------------
    # end of the copied part

    necessary_channels = discoverNecessaryChannels(bfDict,epochedFormulas,evts_set);

    interesting_channel_indizes, interesting_channel_names = pickChannels(raw.ch_names,interesting_channels);
    necessary_channel_indizes, necessary_channel_names = pickChannels(raw.ch_names,necessary_channels);

    # after adding interesting/necessary channels from all sources, remove duplicates
    # unique! preserves the order of elements, so both arrays are kept parallel respectively
    unique!(interesting_channel_names);
    unique!(interesting_channel_indizes);
    unique!(necessary_channel_indizes);
    unique!(necessary_channel_names);

    # only load the needed raw data
    #!!! switch to zero-indexing as get_data is just wrapped python code !!!
    data = raw.get_data(picks = vcat(interesting_channel_indizes,necessary_channel_indizes) .-1);

    # populate the evts DataFrame with additional values needed for fitting
    evts_additions = DataFrame();
    skip_channels = length(interesting_channel_indizes);
    # namedtupleiterator was noted as an efficient way to access dataframe rows for just reading
    for evt in Tables.namedtupleiterator(evts)
        row_frame = DataFrame(vcat(
            # add one-hot encoding for the epoch-based analysis
            [Symbol(e) => evt.event == e ? 1 : 0 for e in evts_set],
            # add the values for any stim channels specified as covariates to each event
            [Symbol(n) => data[skip_channels + i,evt.latency] for (i,n) in enumerate(necessary_channel_names)]
        ));
        append!(evts_additions,row_frame);
    end
    evts = hcat(evts,evts_additions);

    # get rid of uninteresting but needed data for further processing
    data = data[1:length(interesting_channel_indizes),:];

    raw.close();

    return interesting_channel_names, positions
end