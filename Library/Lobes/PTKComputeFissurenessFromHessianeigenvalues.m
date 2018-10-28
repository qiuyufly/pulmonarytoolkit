function results = PTKComputeFissurenessFromHessianeigenvalues(hessian_eigs_wrapper, voxel_size)
    % PTKComputeFissurenessFromHessianeigenvalues. Filter for detecting fissures.
    %
    %     PTKComputeFissurenessFromHessianeigenvalues computes a 
    %     fissureness filter based on Doel et al., 2012. "Pulmonary lobe
    %     segmentation from CT images using fissureness, airways, vessels and
    %     multilevel B-splines". The filter returns a value at each point which
    %     in some sense representes the probability of that point belonging to a
    %     fissure.
    %
    %     This function takes in a PTKWraper object which can either contain a nx6
    %     matrix containing the 3 Hessian matrix eigenvalues for each of n
    %     points, or it can be an ixjxkx3 matrix representing the 3 Hessian
    %     matrix eigenvalues for an image of dimension ixjxk.
    %
    %     The output is a single vesselness value for each input point.
    %
    %     See the PTKFissurenessHessianFactor plugin for example usage.
    %
    %     For more information, see
    %     [Doel et al., Pulmonary lobe segmentation from CT images using
    %     fissureness, airways, vessels and multilevel B-splines, 2012]
    %
    %     Licence
    %     -------
    %     Part of the TD Pulmonary Toolkit. https://github.com/tomdoel/pulmonarytoolkit
    %     Author: Tom Doel, 2012.  www.tomdoel.com
    %     Distributed under the GNU GPL v3 licence. Please see website for details.
    %

    % lam1 = smallest eigenvalue, lam3 = largest eigenvalue
    PTKfissureness_wrapper = PTKWrapper;
    MYfissureness_wrapper = PTKWrapper;

    % This allows us to compute the Fissureness in a vectorised or matrix-based way
    if ndims(hessian_eigs_wrapper.RawImage) == 2
        lam1 = hessian_eigs_wrapper.RawImage(:, 1); % smallest
        lam2 = hessian_eigs_wrapper.RawImage(:, 2);
        lam3 = hessian_eigs_wrapper.RawImage(:, 3); % biggest
    else
        lam1 = hessian_eigs_wrapper.RawImage(:,:,:,1); % smallest
        lam2 = hessian_eigs_wrapper.RawImage(:,:,:,2);
        lam3 = hessian_eigs_wrapper.RawImage(:,:,:,3); % biggest
    end
    
    % Suppress points with positive largest eigenvalue
    capital_gamma = (lam3 < 0);
    
    % Sheetness (Descoteaux et al, 2005)
    R_plane = abs(lam2./lam3);
    alpha = 0.5;
    F_plane = exp((-R_plane.^2)./(2*alpha^2));

    % Suppress signals from vessel walls
    R_wall = sqrt(lam1.^2 + lam2.^2);    
    w = 3; % soft threshold. Consider e.g. hessian_norm/2
    F_wall = exp((-abs(R_wall).^2)./(2*w^2));

    % Fissureness calculation
    PTKfissureness_wrapper.RawImage = 100*capital_gamma.*F_plane.*F_wall;

% Fstructure1=exp((-(lam3-50).^6)./(35.^6));
%     Fstructure1=255-Fstructure1;
%     Fstructure=Fstructure1.*(-lam3>=0);
%     Fsheet=1*exp((-(lam2.^6))./25.^6);
%     S_Fissure=Fstructure.*Fsheet;
%     % eliminate small plate like structure
%     
%     %     S_Fissure=eliminate_smallplate(S_Fissure1,L3x,L3y,L3z);
%     %     S_Fissure=(S_Fissure1<=0.1).*S_Fissure1;
%     % keyboard
%     F_Voxel_data=S_Fissure;
%     
%     %     if(options.BlackWhite)
%     %         Voxel_data(Lambda2 < 0)=0; Voxel_data(Lambda3 < 0)=0;
%     %     else
%     %         Voxel_data(Lambda2 > 0)=0; Voxel_data(Lambda3 > 0)=0;
%     %     end
%     
%     % Remove NaN values of fissure
%     F_Voxel_data(~isfinite(F_Voxel_data))=0;
%     
%     fissureness_wrapper.RawImage=F_Voxel_data;
    

 %   The fissureness Features
    Rsheet=abs(lam2)./abs(lam3);
    Rnoise=sqrt(lam1.^2+lam2.^2+lam3.^2);
    R1=exp((-Rsheet.^2)./(2.*0.5.^2));
    R2=exp((-Rnoise.^2)./(2.*5.^2));
    Fsheet=1.*exp((-Rsheet.^2)./(2.*0.5.^2)).*(1-exp((-Rnoise.^2)./(2.*5.^2)));
    F_Voxel_data=Fsheet.*(-lam3>=0);
    
    % Remove NaN values of fissure
    F_Voxel_data(~isfinite(F_Voxel_data))=0;
    
    MYfissureness_wrapper.RawImage = 100*F_Voxel_data;
    
    results = [];
    results.PTKfissureness_wrapper = PTKfissureness_wrapper;
    results.MYfissureness_wrapper = MYfissureness_wrapper;
end
