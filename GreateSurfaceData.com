fem de param;r;/hpc/yzha947/lung/PCAFiles/DataGeneration
fem de coor;r;/hpc/yzha947/lung/PCAFiles/versions;
fem de base;r;/hpc/yzha947/lung/PCAFiles/BiCubic_Surface_Unit;

#####  Left oblique fissure
# fem de node;r;PCA_LLL;
fem de node;r;Left_pca;
fem de elem;r;template_LOfissure;

# Generate surface data points
fem group face allfaces as FACES
fem def xi;c contact_points faces FACES points 150 by 150 boundary
fem def data;c from_xi

fem def data;w;PCA_LOfissureData as pca_LOfissureData;
#fem export data;H5977pca_LOfissureData as pca_LOfissureData offset 10000;

####   Right horizontal fissure
#fem de node;r;PCA_RML;
fem de node;r;Right_pca;
fem de elem;r;template_RHfissure;

# Generate surface data points
fem group face allfaces as FACES
fem def xi;c contact_points faces FACES points 150 by 150 boundary
fem def data;c from_xi

fem def data;w;PCA_RHfissureData as pca_RHfissureData;
#fem export data;H5977pca_RHfissureData as pca_RHfissureData offset 200000;

####   Right oblique fissure
#fem de node;r;PCA_RLL;
fem de node;r;Right_pca;
fem de elem;r;template_ROfissure;


# Generate surface data points
fem group face allfaces as FACES
fem def xi;c contact_points faces FACES points 150 by 150 boundary
fem def data;c from_xi

fem def data;w;PCA_ROfissureData as pca_ROfissureData;
#fem export data;H5977pca_ROfissureData as pca_ROfissureData offset 300000;
 
fem quit;

