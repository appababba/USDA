function [labels] = dbscan(data, eps, MinPts)

% inputs: matrix of size (N x D) where N is number of points and d is dimensionality.
% eps:    the max distance to consider for the neighborhoor
% minPts: The minimum number of points needed to form a dense region. 

% output: A vector of size (N x 1) containing the cluster ID for each point
% 0 indicates a noise point

    N = size(data, 1);
    labels = zeros(N, 1); % -1 = noise or unlabeled, 0 = unvisited,  1+ = cluster ID
    cluster_id = 0;

    % calculate dist between every pair of points, stores in D
    D = pdist2(data, data); % pairwise distance

% iterate through every data point
    for i = 1:N
        if labels(i) ~= 0
            continue;
        end

% find i's neighborhood based on epsilon parameter
% returns indices where i's neighbors are
        neighbors_idx = find(D(i, :) <= eps);

% check size of neighbors_idx against minpts to determine if i is a core point
        if length(neighbors_idx) < MinPts
            % not enough neighbors, mark as noise temporarily.
            labels(i) = -1;
        else
            % we can start a new cluster
            cluster_id = cluster_id + 1;
            labels(i) = cluster_id;

%  expand cluster
            
 % initialize seed set(list of neighbors excluding core point i)
            seed_set = neighbors_idx(neighbors_idx ~= i); 

            k = 1;
            while k <= length(seed_set) % set grows dynamically as new core points are found 
                current_point_idx = seed_set(k); % get index of next point to be processed

% check if point is already clustered
                if labels(current_point_idx) > 0
                    k = k + 1; % if point is already clustered skio it
                    continue;
                end
                
                % current_point_idx is a neighbor of initial core point that started the cluster
                % current_point_idx is officially in the cluster, could be a border point or a core point
                labels(current_point_idx) = cluster_id;
                
                % check if new point is a core point
                current_neighbors_idx = find(D(current_point_idx, :) <= eps);

                %if a neighbor is a core point the cluster must expand further to include its neighbors
                % iterate through all neighbors of newly found core point current_point_idx
                if length(current_neighbors_idx) >= MinPts
                    % If it's a core point, add its neighbors to the seed set
                    % (only those that are unvisited or marked as noise)
                    for n_idx = current_neighbors_idx
                        if labels(n_idx) <= 0 % unvisited (0) or noise (-1)
                            % change noise points (-1) to border points (cluster_id)
                            % Add unvisited points (0) to the seed set
                            if labels(n_idx) == 0
                                seed_set(end+1) = n_idx; % Add to seed_set so the while loop will process it next
                            end
                            labels(n_idx) = cluster_id; % not added to seed_set because a border point isn't dense enough 
                        end
                    end
                end
                k = k + 1; % incremented to move to next point in seed_set
                %while loop continues until every point in seed_set is processed
            end
        end
    end
    
    % find all points that are still labeled as -1 and all points remaining are declared noise points
    labels(labels == -1) = 0;
end
