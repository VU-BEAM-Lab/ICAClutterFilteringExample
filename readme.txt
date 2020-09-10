This example code demonstrates how the adaptive ICA approach was implemented in the following work:

[1] Tierney, Jaime, et al. "Independent Component-Based Spatiotemporal Clutter Filtering for Slow Flow Ultrasound." IEEE Transactions on Medical Imaging 39.5 (2019): 1472-1482.

This folder includes an example script (exampleCode.m) that loads in example data (exampleData.mat) and performs adaptive SVD and adaptive ICA, computes power Doppler, and makes figures. The following variables are included in the example data:

data -> simulated beamformed analytic IQ data containing tissue+blood+noise in the format DepthxBeamxTime, the blood vessel is centered at 2cm and has 30 degree beam to flow angle with 1mm/s peak parabolic flow (more details in [1])
f0 -> center frequency (Hz)
fs -> sampling frequency (Hz)
prf -> pulse repetition frequency (Hz)
c -> sound speed (m/s)
pitch -> transducer pitch (m)
depths -> depths corresponding to the first dimension of the data variable in meters
l -> lateral position corresponding to the second dimension of the data variable in meters
rngparams -> random number generator settings used to ensure consistent output from k-means clustering

This script uses an ICA infomax approach using publicly available ICA code that can be downloaded here:

http://bsp.teithe.gr/members/downloads/DTUToolbox.html

The 'Maximum likelihood (Infomax) - icaML' is what is necessary to download for running the example script.

Please cite both the above referenced paper [1] and toolbox when using these materials.
