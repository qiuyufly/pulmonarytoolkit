function exportGaussField(filename,coordinates,field,direction)
ipnode_FID=fopen(filename, 'wt');
fprintf(ipnode_FID,['Group name: gauss_points\n']);
fprintf(ipnode_FID,'#Fields=3\n');
fprintf(ipnode_FID,' 1) coordinates, coordinate, rectangular cartesian, #Components=3\n');
fprintf(ipnode_FID,' x.  Value index=1, #Derivatives=0\n');
fprintf(ipnode_FID,' y.  Value index=2, #Derivatives=0\n');
fprintf(ipnode_FID,' z.  Value index=3, #Derivatives=0\n');
fprintf(ipnode_FID,' 2) direction, field, rectangular cartesian, #Components=3\n');
fprintf(ipnode_FID,' x.  Value index=4, #Derivatives=0\n');
fprintf(ipnode_FID,' y.  Value index=5, #Derivatives=0\n');
fprintf(ipnode_FID,' z.  Value index=6, #Derivatives=0\n');
fprintf(ipnode_FID,' 3) yg, field, rectangular cartesian, #Components=1\n');
fprintf(ipnode_FID,' 1.  Value index= 7, #Derivatives=0\n');

for j=1:size(coordinates,1)%-1
    fprintf(ipnode_FID,'Node: %d\n',j);
    fprintf(ipnode_FID,'%15.8f  %15.8f  %15.8f\n',coordinates(j,1),coordinates(j,2),coordinates(j,3));
    fprintf(ipnode_FID,'%15.8f  %15.8f  %15.8f\n',direction(j,1),direction(j,2),direction(j,3));
    fprintf(ipnode_FID,'%15.8f\n',field(j));
end
fclose(ipnode_FID);
end