[row,col]=size(A);
h1335_FRC_LeftOblique=zeros(512,512,735);
for i=1:row
    h1335_FRC_LeftOblique((512-A(i,2)),A(i,1),A(i,3))=1;
end
    