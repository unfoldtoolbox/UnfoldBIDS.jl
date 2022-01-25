# misc functions, e.g. discoverNecessaryChannels, epochedFIt, pickChannels, makeBasicFormulasAndFunctions
# Rene Todo: Rename makeBasicFormulasAndFunctions => addDefaultEventformulas? 

####################################################################################################

# extends the given basis function dictionary and formula array by respective
# matching elements for events not yet found there
function addDefaultEventformulas!(bfDict,epochedFormulas,evts_set,tau=(-0.4, 0.8))
    for e in evts_set
        if !haskey(bfDict,e)
            bfDict[e] = (term(0) ~ term(1),firbasis(τ=tau, sfreq=500, name=e));
        end

        if findfirst(x -> term(e) in x.rhs, epochedFormulas) === nothing
            push!(epochedFormulas, term(0) ~ term(0) + term(e));
        end
    end
    return nothing
end

####################################################################################################

# converts the given interesting_channels to separate arrays of names and indizes according to the given ch_names
function pickChannels(ch_names,interesting_channels)
    interesting_channel_names = [];
    interesting_channel_indizes = [];
    for c in interesting_channels
        if typeof(c) == String
            if (index = findfirst(x -> x==c, ch_names)) !== nothing
                push!(interesting_channel_names,c);
                push!(interesting_channel_indizes,index);
            else
                @warn c * " was not a valid channel name, skipping it.";
            end
        elseif typeof(c) == Int64
            push!(interesting_channel_indizes,c);
            push!(interesting_channel_names,ch_names[c]);
        else
            @warn c * " was not a valid channel name, skipping it.";
        end
    end
    return interesting_channel_indizes, interesting_channel_names
end

####################################################################################################

# add stim channels to necessary_channels that are mentioned in bfDict or epochedFormulas
function discoverNecessaryChannels(bfDict,epochedFormulas,evts_set)
    necessary_channels = [];
    for bf in bfDict
        for term in bf[2][1].rhs # the right hand side of the formula stored for this entry in the basis function Dict
            if typeof(term) != ConstantTerm{Int64}
                push!(necessary_channels,String(term.sym));
            end
        end
    end
    for ef in epochedFormulas
        for term in ef.rhs # the right hand side of this formula
            if typeof(term) != ConstantTerm{Int64} && String(term.sym) ∉ evts_set
                push!(necessary_channels,String(term.sym));
            end
        end
    end
    return necessary_channels;
end

####################################################################################################

# a wrapper for calling unfolds fit method on each of the given formulas and corresponding events
function epochedFit(model,epochedFormulas,evts,raw_data,tau,sfreq)
    res_e = DataFrame();
    for e in epochedFormulas
        evts_part = evts[∈(e.rhs).(term.(evts.event)), :];
        data_epochs, times = Unfold.epoch(data=raw_data, tbl=evts_part, τ=tau, sfreq=sfreq);
        _, res_e_part = fit(model, e, evts_part, data_epochs, times);
        res_e = vcat(res_e,res_e_part,cols=:union);
    end
    return res_e
end

####################################################################################################

# draws the ERPs given by erp_data using AlgebraOfGraphics and GLMakie
# passing true to addLegend will add a horizontal legend to the bottom of the plot layout
# passing a tuple of integers to plot_resolution will redefine the size of the plot
function drawERPs(erp_data, basic_mapping, custom_mapping; addLegend = false, plot_resolution = (1200,400))
    mapped_data = data(erp_data) * basic_mapping * custom_mapping;

    # As there is currently very little documentation on this kind of customization, this line was left in the script for reference
    # fg, a = draw(xy * visual(Lines);figure = (resolution = (1200,800),Legend = (tellwidth=false,tellheight=true,),));

    fg = Figure(resolution = plot_resolution,);
    a = draw!(fg, mapped_data * visual(Lines));

    # add a legend below the plots if needed, to better make use of horizontal space for plots
    if addLegend legend!(fg[end+1,1:end],a,orientation=:horizontal) end;
    
    # add a vertical zero line for easier referencing, as well as cleaner x-axis ticks
    for ax in a
        vlines!(ax.axis,[0], color = :black)
        ax.axis.xticks = -.25:.5:.75
    end
    return fg
end