function []= fds( filename,  descriptors )
    %  This function will take filename and furior descriptors
    %     e.g fds('small_horse.smf', [5 10 20]);
    %  Spectral mesh compression using Fourier descriptors
    if nargin < 2
        error('At least two input arguments required.');
    end
    
    % plot original file
    plot_smf(filename);
    
    % read smf file
    [faces, vertex] = read_smf(filename);
    %prepare edge list from faces
    edgeList = [faces(:,[1 2]); faces(:,[2 3]); faces(:,[3 1])];
    vertex_num = size(vertex,1);
    
    % adjecency metrix
    adj_matrix = zeros(vertex_num,vertex_num);
    for i=1:size(edgeList,1)
        s = edgeList(i,1);
        v = edgeList(i,2);
        adj_matrix(s,v) = 1;
    end
    
    % Laplacian operator K
    K = zeros(vertex_num,vertex_num);
    for i=1:size(K,1)
        for j= 1:size(K,2)
            if(i==j)
                % degree of vertex
                K(i,j)= sum(adj_matrix(i,:));
            else if(adj_matrix(i,j)==1)
                    % if edge then -1
                    K(i,j)=-1;
                end
            end
        end
    end
    
    % eignvectors and eign values
    [V,D] = eig(K); % V eignvectors and D eignvalues
    d = diag(D);
    vertex_dash = transpose(V) * vertex;
    
    % sort by K value
    [d,I] = sort(d, 'ascend');
    
    %ploting
    for des = 1:length(descriptors)
        fig = figure;
        val = descriptors(des);
        fig.Name=strcat('With Fourier descriptor - ',int2str(val));
        X = V(:,1:val)*vertex_dash(1:val,:);
        F = faces;
        trimesh(F, X(:,1), X(:,2), X(:,3), 'EdgeColor', [0.3 0.3 0.3], 'FaceColor', [0.8 0.8 0.8], 'FaceLighting', 'phong');
        hold on;
    end
    
    
end


%{ 
read_smf and plot_smf has been taken from sample code provided by Prof. Richard Zhang
%}
function [F, X] = read_smf(filename)
    
    fid = fopen(filename, 'r');
    if fid == -1
        disp('ERROR: could not open file');
        F = 0;
        X = 0;
        return;
    end
    
    vnum = 1;
    fnum = 1;
    
    while (feof(fid) ~= 1)
        line = '';
        line = fgetl(fid);
        
        if length(line) > 0 & line(1) == 'v'
            dummy = sscanf(line, '%c %f %f %f');
            X(vnum, :) = dummy(2:4, :)';
            vnum = vnum + 1;
        elseif length(line) > 0 & (line(1) == 'f' | line(1) == 't')
            dummy = sscanf(line, '%c %f %f %f');
            F(fnum, :) = dummy(2:4, :)';
            fnum = fnum + 1;
        end
        
        % all other lines are ignored
    end
    
    fclose(fid);
end

% for ploting smf file
function [F, X] = plot_smf(smf_file, varargin)
    [dummy, argc] = size(varargin);
    
    [F, X] = read_smf(smf_file);
    
    %trimesh(F, X(:,1), X(:,2), X(:,3), 'EdgeColor', [0.3 0.3 0.3], 'FaceAlpha', 0.8, 'FaceColor', [0.8 0.8 0.8], 'FaceLighting', 'phong');
    trimesh(F, X(:,1), X(:,2), X(:,3), 'EdgeColor', [0.3 0.3 0.3], 'FaceColor', [0.8 0.8 0.8], 'FaceLighting', 'phong');
    
    hold on;
    
    %
    % perhaps some vertices need to be highlighted
    %
    if argc > 0  % vertex list specified
        vl = varargin{1};
        for i=1:length(vl)
            scatter3(X(vl, 1), X(vl, 2), X(vl, 3), 50, ones(length(vl),1)*[0 0 1], 'filled');
        end
    end
    
    hold off;
end