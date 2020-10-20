clear
clc
load('fxMesh.mat'); % This line adds the fix mesh. All velocity data will be mapped on this mesh. This mesh includes some points inside the cylinder at t = 0;
files = dir('*.csv'); % introducing where csv files are stored
nT = length(files);  % # of timesteps
% rawRawData = cell(1,numFiles);
flexMesh = cell(1,nT);
flexMesh1 = cell(1,nT);
fixMesh = cell(1,nT);
%before running give the # of physical cores to MATLAB
%You may run parpool('local') in the command line
parfor i = 1:nT
    flexMesh{i} = csvread(files(i).name,1,0);      
end
parfor n = 1:nT
    flexMesh{n}(:,8)=[];
    flexMesh{n}(:,5)=[];
    flexMesh{n}(:,2)=[];
end
% The following 2 loops put the csv files in order by time
% It is required as I want to calculate the rms between any time spans and
% plot u vs time graphs
A = zeros(nT,2);
for n  = 1:nT
    A(n,1) = n;
    A(n,2) = flexMesh{n}(1,1);
end
for n = 1:nT
    [M,I] = min(A(:,2));
    flexMesh1{n} = flexMesh{A(I,1)};
    A(I,:)=[];
end
flexMesh = flexMesh1;
clear A
clear flexMesh1;
[aN,~] = size(fixMeshCoor);
s = 0;
xQ(13303,1)=0;  % source of error (may)%
yQ(13303,1)=0;  % source of error (may)%
%The following loop limits the elements to the desired domain
for i = 1:aN
    if fixMeshCoor(i,1) >= -2.1 && fixMeshCoor(i,1) <= 10.2 && abs(fixMeshCoor(i,2)) <= 2.6
        s = s + 1;
        xQ(s,1) = fixMeshCoor(i,1);
        yQ(s,1) = fixMeshCoor(i,2);
    end
end
m = length(xQ);
Ux = zeros(m,1);
Uy = zeros(m,1);
U = zeros(m,1);
for n = 1:nT
    B = flexMesh{n};
    dY = flexMesh{n}(3155,3) - flexMesh{1}(3155,3); %This line captures the displacement
    ux = scatteredInterpolant(flexMesh{n}(:,2),flexMesh{n}(:,3),flexMesh{n}(:,4),'linear'); %other options: 'neares', 'natural', 'cubic'
    uy = scatteredInterpolant(flexMesh{n}(:,2),flexMesh{n}(:,3),flexMesh{n}(:,5),'linear'); %Matlab has a good tutorial on above methos: nearest: C0, linear:C1, natural:C1-C2, cubic:C2
%We need to make sure that the node that is receiving a velocity is not
%located inside the cylender. Because, we do not want matlab to assign a
%velocity value to this point at this time step. We put the velocity 0, so
%later we can identify this point. Note that we do not have a point with a
%velocity of 0 in the domain, as we are working cell centres.
    for i = 1:m
        if sqrt((xQ(i)^2)+(yQ(i)-dY)^2) >= 0.5
            Ux(i,1) = ux(xQ(i),yQ(i));
            Uy(i,1) = uy(xQ(i),yQ(i));
        else
            Ux(i,1) = NaN;
            Uy(i,1) = NaN;
        end
        U(i,1) = sqrt((Ux(i,1)^2)+(Uy(i,1)^2));
    end
    fixMesh{n} = [xQ yQ Ux Uy U];
end
nT = 5000; %to be fixed
Time = zeros(nT,1);
for n = 1:nT
    Time(n,1) = flexMesh{n}(1,1);
end

clear Ux;
clear Uy;
clear U;
%calculating RMS
m = 13303; %%%%%%%Tobe fixed

UMx = zeros(m,1);
UMy = zeros(m,1);
UM = zeros(m,1);
rmsX = zeros(m,1);
rmsY = zeros(m,1);
rms = zeros(m,1);
starTime = 1;
endTime = nT;
for i = 1:m
    nTStp = 0;
    for n = starTime:endTime
        dY = flexMesh{n}(3155,3) - flexMesh{1}(3155,3); %This line captures the displacement
        if sqrt((xQ(i)^2)+(yQ(i)-dY)^2) >= 0.5
            nTStp = nTStp + 1;
            UMx(i,1) = UMx(i,1) + fixMesh{n}(i,3);
            UMy(i,1) = UMy(i,1) + fixMesh{n}(i,4);
            UM(i,1)  = UM(i,1)  + fixMesh{n}(i,5);
        end
    end
    UMx(i,1) = UMx(i,1)/nTStp;
    UMy(i,1) = UMy(i,1)/nTStp;
    UM(i,1)  = UM(i,1)/nTStp;
    for n = 1:nT
        dY = flexMesh{n}(3155,3) - flexMesh{1}(3155,3); %This line captures the displacement
        if sqrt((xQ(i)^2)+(yQ(i)-dY)^2) >= 0.5
            rmsX(i,1) = rmsX(i,1) + (fixMesh{n}(i,3)-UMx(i,1))^2;
            rmsY(i,1) = rmsY(i,1) + (fixMesh{n}(i,4)-UMy(i,1))^2;
            rms(i,1)  = rms(i,1)  + (fixMesh{n}(i,5)-UM(i,1))^2;
        end
    end
    rmsX(i,1) = sqrt(rmsX(i,1)/nTStp); 
    rmsY(i,1) = sqrt(rmsY(i,1)/nTStp); 
    rms(i,1)  = sqrt(rms(i,1)/nTStp); 
end
MandRMS = [(1:m)' fixMesh{1}(:,1) fixMesh{1}(:,2) UMx UMy UM rmsX rmsY rms];
csvwrite('MRMS.csv', MandRMS)
% The locATION at which we want to graph the velocity over time: I
I  = 1345;
%Ux, Uy, or U
d = 3; % 1:Ux 2:Uy 3:U
U = zeros(nT,1);
for n = 1:nT
    U(n,1) = fixMesh{n}(I,2+d);
end
plot(Time,U)