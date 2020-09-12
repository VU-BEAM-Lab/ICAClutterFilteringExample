% Copyright 2020 Jaime Tierney


% Licensed under the Apache License, Version 2.0 (the "License");

% you may not use this file except in compliance with the License.

% You may obtain a copy of the license at


% http://www.apache.org/licenses/LICENSE-2.0


% Unless required by applicable law or agreed to in writing, software

% distributed under the License is distributed on an "AS IS" BASIS,

% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

% See the License for the specific language governing permissions and 

% limitations under the License.


% This script demonstrates how to implement the adaptive ICA spatiotemporal
% clutter filtering proposed in [1]. This script uses a maximum likelihood
% approach (i.e., infomax) to perform ICA [2].
%
% [1] Tierney, Jaime, et al. "Independent Component-Based Spatiotemporal 
% Clutter Filtering for Slow Flow Ultrasound." IEEE Transactions on 
% Medical Imaging 39.5 (2019): 1472-1482.
% 
% [2] Kolenda, T. (Author), Sigurdsson, S. (Author), Winther, O. (Author),
% Hansen, L. K. (Author), & Larsen, J. (Author). (2002). DTU:Toolbox. 
% Computer programme, ISP Group, Informatics and Mathematical 
% Modelling, Tehcnical University of Denmark. 
% http://isp.imm.dtu.dk/toolbox/

% clear work space
clear all; close all;

% provide path to icaML 
addpath icaML\

% provide additional params
N = 20; % fixed noise cutoff
svdTissueThresh = 2; % threshold for computing adaptive PC tissue cutoff
smoothingFlag = 1; % flag to perform smoothing - set to desired lateral  
                   % size of 2D median filter

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% load in the data
load exampleData.mat

% use pre-saved rng settings to reproduce exact example figures
rng(rngparams)
         
% reshape data to casorati matrix and use real
[axdim,latdim,tdim] = size(data);
s = reshape(data,axdim*latdim,tdim);
s = real(s);
            
% transpose to compute ICA on spatial eigenvectors
s = s';  

% perform standard SVD
[U,lambda,Vsvd] = svd(s',0);

% compute adaptive PC tissue cutoff
svPCs = 20*log10(diag(lambda));
svPCs = svPCs-max(svPCs);
tmp = abs(gradient(svPCs(1:N)));
svdAdapTissueCut = find(tmp(2:end)<=svdTissueThresh,1)+1;

% compute adaptive svd PD image
pdAdapSVD=sum(abs(reshape(U(:,svdAdapTissueCut:N)*...
    lambda(svdAdapTissueCut:N,svdAdapTissueCut:N)*...
    Vsvd(:,svdAdapTissueCut:N)',axdim,latdim,tdim)).^2,3);

% perform ICA 
[X,A,V,params.ICAll,params.ICAinfo]=icaML(s,N,[],1);
V=V(:,1:N);
        
% sort ICs by NXC of pd recons
rhoICs = zeros(N,1);
pdAllICs = sum(reshape((A*X)',axdim,latdim,N).^2,3);
for k=1:N
    tmp1 = sum(reshape((A(:,k)*X(k,:))',axdim,latdim,N).^2,3);
    rhoICs(k) = sum(tmp1(:).*pdAllICs(:))/sqrt(sum(tmp1(:).^2)*sum(pdAllICs(:).^2));
end
[rhoICs,idx] = sort(rhoICs,'descend');
A = A(:,idx);
X = X(idx,:);

% adaptively select blood ICs using K-means
kidx = kmeans(rhoICs,3,'MaxIter',100);
bidx = find(kidx==kidx(end));

% compute adaptive ICA PD image
pdAdap = sum(abs(reshape((V(:,svdAdapTissueCut:end)*...
    A(svdAdapTissueCut:end,bidx)*X(bidx,:))',axdim,latdim,tdim)).^2,3);

% apply post-processing smoothing
if smoothingFlag > 0
    fsizelat=smoothingFlag;
    fsizeax = round(fsizelat*pitch/(c/2/fs));
    pdAdapSVD = medfilt2(pdAdapSVD,[fsizeax,fsizelat]);
    pdAdap = medfilt2(pdAdap,[fsizeax,fsizelat]);
    % crop out artifact from median filtering at corners
    pdAdapSVD = pdAdapSVD(31:end-30,:);
    pdAdap = pdAdap(31:end-30,:);
    depths = depths(31:end-30);
end

% make figures
pdAdapSVD = 10*log10(pdAdapSVD);
pdAdap = 10*log10(pdAdap);
figure(1);
set(gcf,'color','w');
imagesc(l*100,depths*100,pdAdapSVD-max(pdAdapSVD(:)),[-20,0]);
colormap hot, axis image, colorbar
print('pdAdapSVD.png','-dpng');
figure(2);
set(gcf,'color','w');
imagesc(l*100,depths*100,pdAdap-max(pdAdap(:)),[-20,0]);
colormap hot, axis image, colorbar
print('pdAdapICA.png','-dpng');
 