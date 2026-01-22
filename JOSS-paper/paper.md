---
title: 'UnfoldBIDS.jl: Streamlining regression ERP Analysis of BIDS-Compliant EEG Data in Julia'
tags:
  - Julia
  - EEG
  - ERPs
  - evoked potentials
  - neuroimaging
  - Brain Imaging Data Structure
  - time-series
  - regression ERPs
authors:
  - name: René Skukies
    orcid: 0000-0002-4124-4584  
    equal-contrib: false
    affiliation: "1, 2"
  - name: Benedikt V. Ehinger
    orcid:  0000-0002-6276-3332
    equal-contrib: false
    affiliation: "1, 2"
affiliations:
  - name: Institute for Visualisation and Interactive Systems, University of Stuttgart, Germany
    index: 1
  - name: Stuttgart Center for Simulation Science, University of Stuttgart, Germany
    index: 2
date: 22 January 2026
bibliography: paper.bib
---

# UnfoldBIDS.jl

The analysis of complex naturalistic neuroscientific experiments requires new advanced analysis methods. A prominent tool gaining more popularity is the regression-based event-related potential (rERP) framework (@smith.kutas_2015; @smith.kutas_2015a), enabling single-trial analyses of EEG data with flexible modeling of covariates and overlap correction. The frameworks increasing popularity can in part be ascribed to the creation of various analysis-packages (e.g. Unfold.jl[@ehinger.alday_2025], LIMO[], mTRF[], Eelbrain[]), lowering the barrier to entry for researchers across disciplines.

Parallel to methodological advances, the Brain Imaging Data Structure (BIDS; @gorgolewski.etal_2016a; @pernet.etal_2019) has facilitated open sharing of large neuroscientific datasets. By establishing consistent file naming conventions and hierarchical folder structures, BIDS ensures that datasets are both human- and machine-readable, enabling efficient data querying, automated processing pipelines, and seamless integration across tools.

Combining these two aspects, the UnfoldBIDS.jl package provides a coherent interface to seamlessly analyse BIDS structured datasets using @rerp models as implemented in Unfold.jl. Moreover, it sits well within the Unfold framework (Figure 1) and is compatible with the MNE-BIDS-pipeline (@gramfort.etal_2013a; @larson.etal_2024).

figure(
    ,
  caption: [UnfoldBIDS.jl overview. Bold arrows indicate direct functionality. Dashed arrows indicate easy combination with other Unfold toolboxes and/ or future functionality for UnfoldBIDS.jl.]
)

## Package summary
UnfoldBIDS.jl integrates loading and processing of BIDS-compliant datasets with the Unfold.jl package into a single, cohesive tool, enabling streamlined rERP analysis of BIDS-compliant data. This simplifies the otherwise cumbersome and potentially error-prone task of writing scripts to load subject data iteratively, reducing it to just a few lines of code.

For researchers not relying on a list of subject ID’s to look up subject-specific data, the default approach recursively walks through the entire directory, adding file paths that match a specific pattern. In contrast to this, UnfoldBIDS.jl makes use of the Continuables.jl package to quickly search for suitable file paths, speeding up file searches even in large datasets with hundreds of subjects. 

Before analysis, researchers often need to inspect metadata or verify data integrity. UnfoldBIDS.jl supports this by first loading all file paths and subject-level metadata into a tidy data frame, allowing users to inspect and filter datasets prior to EEG data loading and processing. In summary, UnfoldBIDS.jl provides a convenient interface for processing BIDS-compliant EEG data in the Julia programming language.

## Comparison to existing packages
There are currently no existing julia packages combining rERP analysis on BIDS datasets. As of March 2025 (XXX update), the Julia programming language offers two packages specifically designed to handle BIDS structured data: [BIDSTools.jl](https://github.com/TRIImaging/BIDSTools.jl) and [BIDS.jl](https://github.com/Telepathy-Lab/BIDS.jl). However, BIDSTools.jl was last updated in 2020 and provides minimal documentation, while BIDS.jl was last updated in 2023 and lacks any documentation. Consequently, we consider neither package a valid option for handling BIDS dataset in the Julia programming language.

Beyond Julia, prominent EEG processing toolboxes such as EEGLAB in Matlab and MNE in Python support BIDS datasets and integrate with rERP toolboxes (e.g., Unfold or LIMO for EEGLAB, Eelbrain for MNE). However, these require extensive custom scripting to link BIDS data with rERP models, undermining reproducibility and increasing the risk of errors. Notably, the MNE-BIDS-pipeline enables automated preprocessing of EEG data. UnfoldBIDS.jl is designed to complement, not replace, such pipelines, allowing researchers to use established preprocessing workflows and then seamlessly transition to rERP modeling.

## Functionality
### Load and analyse data
Users can perform a full rERP analysis across all subjects with just three commands:

1. `bids_layout()` — constructs a tidy data frame of all BIDS-compliant files and metadata.
2. `load_bids_eeg_data()` — loads EEG data and metadata into a structured format.
3. `run_unfold()` — fits the rERP model using the specified design formula.

The resulting data frame structure enables easy inspection, filtering, and subset analysis (e.g., by condition, subject, or task type), enhancing transparency and reproducibility.

### Pre-processing using MNE

By default, UnfoldBIDS.jl assumes users have already preprocessed their data. However, researchers often want to quickly inspect raw data or different processing parameters. Here, UnfoldBIDS.jl offers a preprocessing hook, allowing for the integration of arbitrary MNE preprocessing functions like filtering or resampling (Gramfort et al., 2013; Larson et al., 2024).

## Summary

UnfoldBIDS.jl bridges a critical gap in the neuroimaging tool-chain by enabling efficient, reproducible, and scalable rERP analysis of BIDS-compliant EEG data within the Julia ecosystem. By combining the benefits of the rERP framework with the standardization of BIDS and the performance of Julia, it empowers researchers to conduct rigorous, transparent, and automated analyses.