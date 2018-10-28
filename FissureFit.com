fem de param;r;/hpc/yzha947/lung/GeometricModels/FittingLungs/Files/3d_fitting
fem de coor;r;/hpc/yzha947/lung/GeometricModels/FittingLungs/Files/versions;
fem def base;r;/hpc/yzha947/lung/UniversalFiles/Bases/BiCubic_Surface_Unit;



# Read fissure template
fem de node;r;h1335_FRC_LeftFissureTemplate;
fem de elem;r;h1335_FRC_LeftFissureTemplate;

# Read fissure data
#fem de data;r;h1335_FRC_LeftObliqueSample;
fem de data;r;h1335MaximumFissurePoint;
fem export data;h1335_FRC_LeftObliqueSample offset 500;
fem de xi;c closest;
fem li data error;

fem update field from geometry;       # Updates field 
fem de fiel;w;fissure;
fem def elem;d field;
fem de elem;w;fissure field;
fem de fit;r;fissure geometry;
fem fit

# Update fitted fissure mesh
fem update nodes;
fem list data error;

# The second fit
#fem fit
#fem update nodes;
#fem list data error;

# Export fitted fissure mesh
fem export node;h1335_FRC_LeftFissure as FittedLeftFissure offset 40000;
fem export elem;h1335_FRC_LeftFissure as FittedLeftFissure offset_elem 40000 ;

# Export fitted fissure mesh ipnode
fem def node;w;h1335_FRC_LeftFissureFitted

# Export fissure surface data points
$CONT_PTS_1=220;
$CONT_PTS_2=220;
fem group face allfaces as FACES
fem def xi;c contact_point faces FACES points $CONT_PTS_1 by $CONT_PTS_2 boundary
fem def data;c from_xi
fem def data;w;"surfaceData" as surfaceData
fem export data;"surfaceData" as surfaceData offset 140000

fem quit;
