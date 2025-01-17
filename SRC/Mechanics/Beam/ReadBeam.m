%* *****************************************************************
%* - Function of STAPMAT in stiffness phase                        *
%*                                                                 *
%* - Purpose:                                                      *
%*     Read the element information of Beam                        *
%*                                                                 *
%* - Call procedures:                                              *
%*     ReadBeam.m - ReadMaterial()                                 *
%*     ReadBeam.m - ReadElements()                                 *
%*                                                                 *
%* - Called by :                                                   *
%*     ./BeamStiff.m                                               *
%*                                                                 *
%* - Programmed by:                                                *
%*     Yourself                                                    *
%*                                                                 *
%* *****************************************************************

function ReadBeam()

% Read Material information
ReadMaterial()

% Read Element information
ReadElements()

% the second time stamp
global cdata;
cdata.TIM(2,:) = clock;

end

% ----------------------- Functions -----------------------------------
% Read Material information
function ReadMaterial()

% Get global data
global cdata;
global sdata;

% Get file pointers
IIN = cdata.IIN;
IOUT = cdata.IOUT;

% Write Echo message here
if (cdata.NPAR(3) == 0) cdata.NPAR(3) = 1; end
fprintf(IOUT, '\n M A T E R I A L   D E F I N I T I O N\n');
fprintf(IOUT, '\n NUMBER OF DIFFERENT SETS OF MATERIAL\n');
fprintf(IOUT, ' AND CROSS-SECTIONAL  CONSTANTS  . . . .( NPAR(3) ) . . = %10d\n', cdata.NPAR(3));
fprintf(IOUT, '  SET NUMBER      YOUNG''S MODULUS     CROSS-SECTIONAL     POSSION-RATIO     DENSITY     DAMP\n');

% Read material message here
sdata.NUME = cdata.NPAR(2);
sdata.NUMMAT = cdata.NPAR(3);
NUMMAT = cdata.NPAR(3);         %材料种类数
sdata.E = zeros(NUMMAT, 1);     %杨氏模量
sdata.AREA = zeros(NUMMAT, 1);  %截面面积
sdata.NU = zeros(NUMMAT, 1);    %泊松比
sdata.RHO = zeros(NUMMAT, 1);   %密度
sdata.MU = zeros(NUMMAT, 1);    %结构阻尼

for I = 1:NUMMAT
    tmp = str2num(fgetl(IIN));
    N = round(tmp(1));
    sdata.E(N) = tmp(2);
    sdata.AREA(N) = tmp(3);
    sdata.NU(N) = tmp(4);
    sdata.RHO(N) = tmp(5);
    sdata.MU(N) = tmp(6);
    fprintf(IOUT, '%5d    %14.6e  %14.6e  %14.6e  %14.6e  %14.6e\n', N, tmp(2), tmp(3), tmp(4), tmp(5), tmp(6));
end

end

% Read elements information
function ReadElements()
% Get global data
global cdata;
global sdata;

% Get file pointer
IIN = cdata.IIN;
IOUT = cdata.IOUT;

% Write Echo message here
fprintf(IOUT, '\n\n E L E M E N T   I N F O R M A T I O N\n');
fprintf(IOUT, '\n      ELEMENT          NODE          NODE       MATERIAL\n');
fprintf(IOUT, '        NUMBER-N           I             J        SET NUMBER\n');

% Get Position data here
NUME = cdata.NPAR(2);
NNODE = sdata.NNODE;
NDOF = sdata.NDOF;
NODEOFELE = zeros(NNODE, NUME);
sdata.XYZ = zeros(NDOF*NNODE, NUME);
sdata.MATP = zeros(NUME, 1);     
sdata.LM = zeros(NDOF*NNODE, NUME);    
sdata.MHT = zeros(sdata.NEQ, 1);

X = sdata.X; Y = sdata.Y; Z = sdata.Z; ID = sdata.ID;
XYZ = sdata.XYZ; MATP = sdata.MATP; LM = sdata.LM;

for N = 1:NUME

%   The sequence of nodal ID 
    tmp = str2num(fgetl(IIN));
    I = round(tmp(2));
    J = round(tmp(3));
    MTYPE = round(tmp(4));

%   Save nodal ID for each element
    NODEOFELE(:,N) = [I ; J];

%   Save element information
    XYZ(1, N) = X(I);
    XYZ(2, N) = Y(I);
    XYZ(3, N) = Z(I);
    XYZ(4, N) = X(J);
    XYZ(5, N) = Y(J);
    XYZ(6, N) = Z(J);
    MATP(N) = MTYPE;

    fprintf(IOUT, '%10d      %10d    %10d       %5d\n', N, I, J, MTYPE);

%   Compute connectivity matrix
    LM(1, N) = ID(1, I);
    LM(4, N) = ID(1, J);
    LM(2, N) = ID(2, I);
    LM(5, N) = ID(2, J);
    LM(3, N) = ID(3, I);
    LM(6, N) = ID(3, J);

%   Updata column heights and bandwidth
    ColHt(LM(:, N))
end

sdata.XYZ = XYZ; sdata.MATP = MATP; sdata.LM = LM;

% Clear the memory of X, Y, Z
sdata.X = double(0);
sdata.Y = double(0);
sdata.Z = double(0);
end
