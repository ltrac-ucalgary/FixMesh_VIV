clear
clc
n = 300;
m = 125;
x1(n) = 0;
y1(m) = 0;
s = 0;
for i = -2:0.04:10
    s = s + 1;
    x1(s) = i;
end
s = 0;
for i = -2.5:0.04:2.5
    s = s + 1;
    y1(s) = i;
end
[X1,Y1] = meshgrid(x1,y1);
x2(length(x1)-1) = 0;
y2(length(y1)-1) = 0;
for i = 1:length(x1)-1
    x2(i) = (x1(i) + x1(i+1))/2;
end
for i = 1:length(y1)-1
    y2(i) = (y1(i) + y1(i+1))/2;
end
[X,Y] = meshgrid(x2,y2);
load('FlexMesh.mat')
load('Time.mat')
nT = length(Time);
fixMeshUx = cell(1,nT);
fixMeshUy = cell(1,nT);
fixMeshU = cell(1,nT);
fixMeshUx_4Anim = cell(1,nT);
fixMeshUy_4Anim = cell(1,nT);
fixMeshU_4Anim = cell(1,nT);
adptMeshX= cell(1,nT);
adptMeshY= cell(1,nT);
Ux = zeros(m,n);
Uy = zeros(m,n);
U = zeros(m,n);
Ux_4Anim = zeros(m+1,n+1);
Uy_4Anim = zeros(m+1,n+1);
U_4Anim = zeros(m+1,n+1);
starTime = 4000;
endTime = 5000;
for nt = starTime:endTime
    dY = flexMesh{nt}(3155,3) - flexMesh{1}(3155,3); 
    ux = scatteredInterpolant(flexMesh{nt}(:,2),flexMesh{nt}(:,3),flexMesh{nt}(:,4),'linear'); 
    uy = scatteredInterpolant(flexMesh{nt}(:,2),flexMesh{nt}(:,3),flexMesh{nt}(:,5),'linear'); 
    adptX = X;
    adptY = Y; 
    for i = 1:m
        for j = 1:n
            if (sqrt(((X(i,j)-0.02)^2)+((Y(i,j)-0.02)-dY)^2) >= 0.49999) && (sqrt(((X(i,j)+0.02)^2)+((Y(i,j)-0.02)-dY)^2) >= 0.49999) && (sqrt(((X(i,j)-0.02)^2)+((Y(i,j)+0.02)-dY)^2) >= 0.49999) && (sqrt(((X(i,j)+0.02)^2)+((Y(i,j)+0.02)-dY)^2) >= 0.49999)
                Ux(i,j) = ux(X(i,j),Y(i,j));
                Uy(i,j) = uy(X(i,j),Y(i,j));
                Ux_4Anim(i,j) = Ux(i,j);
                Uy_4Anim(i,j) = Uy(i,j);
            else
                if (sqrt(((X(i,j)-0.02)^2)+((Y(i,j)-0.02)-dY)^2) <= 0.50001) && (sqrt(((X(i,j)+0.02)^2)+((Y(i,j)-0.02)-dY)^2) <= 0.50001) && (sqrt(((X(i,j)-0.02)^2)+((Y(i,j)+0.02)-dY)^2) <= 0.50001) && (sqrt(((X(i,j)+0.02)^2)+((Y(i,j)+0.02)-dY)^2) <= 0.50001)
                    Ux(i,j) = NaN;
                    Uy(i,j) = NaN;
                    Ux_4Anim(i,j) = Ux(i,j);
                    Uy_4Anim(i,j) = Uy(i,j);
                else
                    if sqrt(((X(i,j)-0.02)^2)+((Y(i,j)-0.02)-dY)^2) >= 0.49999
                        circInt(1,1) = 0;
                    else
                        circInt(1,1) = 1;
                    end
                    if sqrt(((X(i,j)+0.02)^2)+((Y(i,j)-0.02)-dY)^2) >= 0.49999
                        circInt(1,2) = 0;
                    else
                        circInt(1,2) = 1;
                    end
                    if sqrt(((X(i,j)+0.02)^2)+((Y(i,j)+0.02)-dY)^2) >= 0.49999
                        circInt(1,3) = 0;
                    else
                        circInt(1,3) = 1;
                    end
                    if sqrt(((X(i,j)-0.02)^2)+((Y(i,j)+0.02)-dY)^2) >= 0.49999
                        circInt(1,4) = 0;
                    else
                        circInt(1,4) = 1;
                    end                    
                    xI = zeros(1,3);
                    yI = zeros(1,3);
                    s = 0;
                    for cirN = 1:4
                        cirNA = cirN + 1;
                        if circInt(1,cirN) == 0
                            s = s + 1;
                            if cirN == 1
                                xI(s) = X(i,j)-0.02;
                                yI(s) = Y(i,j)-0.02;
                            end
                            if cirN == 2
                                xI(s) = X(i,j)+0.02;
                                yI(s) = Y(i,j)-0.02;
                            end
                            if cirN == 3
                                xI(s) = X(i,j)+0.02;
                                yI(s) = Y(i,j)+0.02;
                            end
                            if cirN == 4
                                xI(s) = X(i,j)-0.02;
                                yI(s) = Y(i,j)+0.02;
                            end
                        end
                        if cirNA == 5
                            cirNA = 1;
                        end
                        if circInt(1,cirN) ~= circInt(1,cirNA)
                            s = s + 1;
                            if cirN == 1
                                if abs(sqrt(((X(i,j)-0.02)^2)+(((Y(i,j)-0.02)-dY)^2))-0.5) < 0.00001 || abs(sqrt(((X(i,j)+0.02)^2)+(((Y(i,j)-0.02)-dY)^2))-0.5) < 0.00001
                                    s = s - 1;
                                else
                                    xI(s) = sqrt((0.5^2)-(((Y(i,j)-0.02)-dY)^2));
                                    if xI(s) < (X(i,j)-0.02) || xI(s) > (X(i,j) + 0.02)
                                        xI(s) = -xI(s);
                                    end
                                    yI(s) = Y(i,j)-0.02;
                                end
                            end
                            if cirN == 2
                                if abs(sqrt(((X(i,j)+0.02)^2)+(((Y(i,j)-0.02)-dY)^2))-0.5) < 0.00001 || abs(sqrt(((X(i,j)+0.02)^2)+(((Y(i,j)+0.02)-dY)^2))-0.5) < 0.00001
                                    s = s - 1;
                                else
                                    xI(s) = X(i,j)+0.02;
                                    yI(s) = sqrt((0.5^2)-(X(i,j)+0.02)^2) + dY;
                                    if yI(s) < (Y(i,j)-0.02) || yI(s) > (Y(i,j)+0.02)
                                        yI(s) = -sqrt((0.5^2)-(X(i,j)+0.02)^2)+dY;
                                    end
                                end
                            end
                            if cirN == 3
                                if abs(sqrt(((X(i,j)+0.02)^2)+(((Y(i,j)+0.02)-dY)^2))-0.5) < 0.00001 || abs(sqrt(((X(i,j)-0.02)^2)+(((Y(i,j)+0.02)-dY)^2))-0.5) < 0.00001
                                    s = s - 1;
                                else
                                    xI(s) = sqrt((0.5^2)-(((Y(i,j)+0.02)-dY)^2));
                                    if xI(s) < (X(i,j)-0.02) || xI(s) > (X(i,j) + 0.02)
                                        xI(s) = -xI(s);
                                    end
                                    yI(s) = Y(i,j)+0.02;
                                end
                            end
                            if cirN == 4
                                if abs(sqrt(((X(i,j)-0.02)^2)+(((Y(i,j)+0.02)-dY)^2))-0.5) < 0.00001 || abs(sqrt(((X(i,j)-0.02)^2)+(((Y(i,j)-0.02)-dY)^2))-0.5) < 0.00001
                                    s = s - 1;
                                else
                                    xI(s) = X(i,j)-0.02;
                                    yI(s) = sqrt((0.5^2)-(X(i,j)-0.02)^2)+dY;
                                    if yI(s) < (Y(i,j)-0.02) || yI(s) > (Y(i,j)+0.02)
                                        yI(s) = -sqrt((0.5^2)-(X(i,j)-0.02)^2)+dY;
                                    end
                                end
                            end
                        end
                    end
                    polyMesh = polyshape(xI,yI);
                    [xNew,yNew] = centroid(polyMesh);
                    adptX(i,j) = xNew;
                    adptY(i,j) = yNew;
                    Ux(i,j) = ux(xNew,yNew);
                    Uy(i,j) = uy(xNew,yNew);
                    Ux_4Anim(i,j) = Ux(i,j);
                    Uy_4Anim(i,j) = Uy(i,j);

                end
            end
            U(i,j) = sqrt((Ux(i,j)^2)+(Uy(i,j)^2));
            U_4Anim(i,j) = U(i,j);
        end
    end
    fixMeshUx{nt} = Ux;
    fixMeshUy{nt} = Uy;
    fixMeshU{nt} = U;
    fixMeshUx_4Anim{nt} = Ux_4Anim;
    fixMeshUy_4Anim{nt} = Uy_4Anim;
    fixMeshU_4Anim{nt}  = U_4Anim;
    adptMeshX{nt} = adptX;
    adptMeshY{nt} = adptY;
end

UMx = zeros(m,n);
UMy = zeros(m,n);
UM = zeros(m,n);
rmsX = zeros(m,n);
rmsY = zeros(m,n);
rms = zeros(m,n);
UMx_4Anim = zeros(m+1,+1);
UMy_4Anim = zeros(m+1,n+1);
UM_4Anim = zeros(m+1,n+1);
rmsX_4Anim = zeros(m+1,n+1);
rmsY_4Anim = zeros(m+1,n+1);
rms_4Anim = zeros(m+1,n+1);
for i = 1:m
    for j = 1:n
        nTStp = 0;
        for nt = starTime:endTime
            dY = flexMesh{nt}(3155,3) - flexMesh{1}(3155,3); 
            if sqrt((X(i,j)^2)+(Y(i,j)-dY)^2) >= 0.5
                nTStp = nTStp + 1;
                UMx(i,j) = UMx(i,j) + fixMeshUx{nt}(i,j);
                UMy(i,j) = UMy(i,j) + fixMeshUy{nt}(i,j);
                UM(i,j)  = UM(i,j)  + fixMeshU{nt}(i,j);
            end
        end
        UMx(i,j) = UMx(i,j)/nTStp;
        UMy(i,j) = UMy(i,j)/nTStp;
        UM(i,j)  = UM(i,j)/nTStp;
        UMx_4Anim(i,j) = UMx(i,j);
        UMy_4Anim(i,j) = UMy(i,j);
        UM_4Anim(i,j) = UM(i,j);
        for nt = starTime:endTime
            dY = flexMesh{nt}(3155,3) - flexMesh{1}(3155,3);
            if sqrt((X(i,j)^2)+(Y(i,j)-dY)^2) >= 0.5
                rmsX(i,j) = rmsX(i,j) + ((fixMeshUx{nt}(i,j)^2)-(UMx(i,j)^2));
                rmsY(i,j) = rmsY(i,j) + ((fixMeshUy{nt}(i,j)^2)-(UMy(i,j)^2));
                rms(i,j)  = rms(i,j)  + (fixMeshU{nt}(i,j)^2-((UMx(i,j)^2)+(UMy(i,j)^2)));
            end
        end
        rmsX(i,j) = sqrt(rmsX(i,j)/nTStp);
        rmsY(i,j) = sqrt(rmsY(i,j)/nTStp);
        rms(i,j)  = sqrt(rms(i,j)/nTStp);
        rmsX_4Anim(i,j) = rmsX(i,j);
        rmsY_4Anim(i,j) = rmsY(i,j);
        rms_4Anim(i,j) = rms(i,j);
    end
end

