% Compute the self-similarity join of a given time series A
% Yan Zhu 03/09/2016 modified by Chin-Chia Michael Yeh 03/10/2016
%
% [matrixProfile, matrixProfileIndex] = stompSelf(A, subLen)
% Output:
%     matrixProfile: matrix porfile of the self-join (vector)
%     matrixProfileIndex: matrix porfile index of the self-join (vector)
% Input:
%     A: input time series (vector)
%     subLen: interested subsequence length (scalar)
%
% Yan Zhu, Zachary Zimmerman, Nader Shakibay Senobari, Chin-Chia Michael Yeh, Gareth Funning,
% Abdullah Mueen, Philip Brisk and Eamonn Keogh, "Matrix Profile II: Exploiting a Novel 
% Algorithm and GPUs to break the one Hundred Million Barrier for Time Series Motifs and 
% Joins," ICDM 2016, http://www.cs.ucr.edu/~eamonn/MatrixProfile.html
%

function [matrixProfile, profileIndex] = stompSelf(data, subLen)
%% set trivial match exclusion zone
excZone = round(subLen/2);

%% check input

if subLen < 4
    error('Error: Subsequence length must be at least 4');
end
if length(data) == size(data, 2)
    data = data';
end

%% check skip position
proLen = length(data) - subLen + 1;
skipLoc = false(proLen, 1);
for i = 1:proLen
    if any(isnan(data(i:i+subLen-1))) || any(isinf(data(i:i+subLen-1)))
        skipLoc(i) = true;
    end
end
data(isnan(data)) = 0;
data(isinf(data)) = 0;

%% initialization
matrixProfile = zeros(proLen, 1);
profileIndex = zeros(proLen, 1);
[dataFreq, dataLen, dataMean, dataSig] = fastFindNNPre(data, subLen);

%% compute the matrix profile
pickedIdx = 1:proLen;
distProfile=zeros(proLen,1);
lastProduct=zeros(proLen,1);
for i = 1:proLen
    % compute the distance profile
    idx = pickedIdx(i);
    query = data(idx:idx+subLen-1);
    if i==1
        [distProfile(:), lastProduct(:), querySum, query2Sum, querySig] = ...
            fastFindNN(dataFreq, query, dataLen, subLen, dataMean, dataSig);
        distProfile(:) = real(distProfile);
        firstProduct=lastProduct;
    else
        querySum = querySum-dropVal+query(subLen);
        query2Sum = query2Sum-dropVal^2+query(subLen)^2;
        queryMean=querySum/subLen;
        querySig2 = query2Sum/subLen-queryMean^2;
        querySig = sqrt(querySig2);
        lastProduct(2:dataLen-subLen+1) = lastProduct(1:dataLen-subLen) - ...
            data(1:dataLen-subLen)*dropVal + data(subLen+1:dataLen)*query(subLen);
        lastProduct(1)=firstProduct(idx);
        distProfile(:) = 2*(subLen - ...
            (lastProduct-subLen*dataMean*queryMean)./(dataSig*querySig));
        distProfile(:) = real(distProfile);
    end
    dropVal=query(1);
    
    % apply exclusion zone
    excZoneStart = max(1, idx-excZone);
    excZoneEnd = min(proLen, idx+excZone);
    distProfile(excZoneStart:excZoneEnd) = inf;
    distProfile(dataSig<eps) = inf;
    if skipLoc(i) || (querySig < eps)
        distProfile = inf(size(distProfile));
    end
    distProfile(skipLoc) = inf;
    
    % figure out and store the neareest neighbor
    if i == 1
        matrixProfile = inf(proLen, 1);
        profileIndex = inf(proLen, 1);
    end
    updatePos = distProfile < matrixProfile;
    profileIndex(updatePos) = idx;
    matrixProfile(updatePos) = distProfile(updatePos);
end
matrixProfile = sqrt(matrixProfile);
matrixProfile(skipLoc) = inf;
profileIndex(skipLoc) = inf;

%% The following two functions are modified from the code provided in the following URL
%  http://www.cs.unm.edu/~mueen/FastestSimilaritySearch.html
function [dataFreq, dataLen, dataMean, dataSig] = fastFindNNPre(data, subLen)
% compute stats about data
dataLen = length(data);
data(dataLen+1:2*dataLen) = 0;
dataFreq = fft(data);
dataCum = cumsum(data);
data2Cum =  cumsum(data.^2);
data2Sum = data2Cum(subLen:dataLen)-[0;data2Cum(1:dataLen-subLen)];
dataSum = dataCum(subLen:dataLen)-[0;dataCum(1:dataLen-subLen)];
dataMean = dataSum./subLen;
dataSig2 = (data2Sum./subLen)-(dataMean.^2);
dataSig = sqrt(dataSig2);

function [distProfile, lastProduct, querySum, query2Sum, querySig] = ...
    fastFindNN(dataFreq, query, dataLen, subLen, dataMean, dataSig)
% proprocess query for fft
query = query(end:-1:1);
query(subLen+1:2*dataLen) = 0;

% compute the product
queryFreq = fft(query);
productFreq = dataFreq.*queryFreq;
product = ifft(productFreq);

% compute the stats about query
querySum = sum(query);
query2Sum = sum(query.^2);
queryMean=querySum/subLen;
querySig2 = query2Sum/subLen-queryMean^2;
querySig = sqrt(querySig2);

% compute the distance profile
distProfile = 2*(subLen-(product(subLen:dataLen)-subLen*dataMean*queryMean)./...
    (dataSig*querySig));
lastProduct=real(product(subLen:dataLen));