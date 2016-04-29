function [  ] =  kmeans(x, k, initg)
    
    %  KMEANS clustering implementation 
    %  This is used for clustering of dataset in specifed number of cluster 
    %  x = dataset in n*2 matrix, 
    %  k = number of  clusters, 
    %  initg = initial clustering array of n elements.If not provided then
    %  random shuffling
    
    if nargin < 3
        initg = [];
    end   
    if nargin < 2
        error('At least two input arguments required.');
    end
    %x = dlmread('./kmeans_data/gauss_data_1.txt');
    scatter(x(:,1),x(:,2),'filled');
    figure; 
    n = size(x,1);
    
    if(isempty(initg)==0)
        % using initial clustring provided
      idx=[];
      cluster_size=[];
      for i= min(initg):max(initg)
        idx = [idx,find( initg==i )];
        cluster_size = [cluster_size,size(idx,1)];
      end
       xperm = x(idx,:);
       X_init = mat2cell(xperm,cluster_size,2); 
    else
       % random shuffling
        idx = randperm(n);
        xperm = x(idx,:);
        per_cluster = floor(n/k);
        cluster_size=[];
        for i=1:k-1
          cluster_size = [cluster_size,per_cluster];
        end
        rem = n-sum(cluster_size);
        cluster_size=[cluster_size,rem];
        X_init = mat2cell(xperm,cluster_size,2); 
    end
   
    % initial centroid allocation
    mu_init = centroid(X_init,k);
    % variable declartion to hold updated value
    mu_updated = zeros(1,k);

    % max of 100 iteration as stopping condition or centroid is not
    % changing in consecutive iteration
    num_of_iteration=100;
    while(num_of_iteration > 0 )
        % compute cost and update X
        X_updated = computeDistance(X_init,mu_init,k);
        % update cnetroid
        mu_updated = centroid(X_updated,k);
        % if no change in centroid then terminate
        if(isequal(mu_updated,mu_init))
            break;
        end
        mu_init = mu_updated;
        X_init= X_updated ;
        num_of_iteration = num_of_iteration-1;
    end
    
    % plot clusters
    for i =1:k
        if(size(X_updated{i,:})>0)
            scatter(X_updated{i,1}(:,1),X_updated{i,1}(:,2));
            hold on;
        end
    end
    
    
end
% Assign data to cluster based on distance.
function[X]= computeDistance(X_init,mu,K)
    X = cell(K,1);
    for m = 1: K
        for i = 1 : size(X_init{m,1},1)
            dist = inf;
            k=0;
            for j=1:K
                if(norm(X_init{m,1}(i,:)-mu(j,:)) < dist)
                    dist = norm(X_init{m,1}(i,:)-mu(j,:));
                    k=j;
                end
            end
            temp =X_init{m,1}(i,:);
            X{k,1} =[X{k,1};temp];
        end
    end
end

% computing centroid of each cluster
function[mu] = centroid(X,k)
    mu = zeros(k,2);
    for i=1:k
        if(size(X{i,:})>0)
            mu(i,1) = mean(X{i,1}(:,1));
            mu(i,2) = mean(X{i,1}(:,2));
        end
    end
end