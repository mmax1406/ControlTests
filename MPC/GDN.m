function [sol] = GDN(f, limitsTest, x0, amplitude, epsilon)

% Protections on dimensions
if size(x0,2)==1
    x0 = x0';
end

% Get the possible gradient directions
directions = generateNodeCombinations(size(x0,2));
directions = directions(1:end-1,:)./vecnorm(directions(1:end-1,:),2,2); % The last one is the point itself
combinations = x0 + amplitude*directions;

% Init the first direction
bestDirIndex = findBestDir(f, combinations, x0, limitsTest);

while (abs(f(x0 + amplitude*directions(bestDirIndex,:)) - f(x0)) > epsilon) 
    
    if(f(x0 + amplitude*directions(bestDirIndex,:)) < f(x0))
        x0 = x0 + amplitude*directions(bestDirIndex,:);
    else
        temp = findBestDir(f, x0 + amplitude*directions, x0, limitsTest);
        if isnan(temp)
            break % Exit if no direction was found
        end
        % If vectors are parallel than half the amplitude size
        if all(directions(temp,:) == directions(bestDirIndex,:))...
                || all(directions(temp,:) == -1 * directions(bestDirIndex,:))
            amplitude = amplitude/2;
        end
        bestDirIndex = temp;
    end
    if isnan(temp)
        break % Exit if no direction was found
    end
end

sol = x0;

function bestDirIndex = findBestDir(f, combinations, x0, limitsTest)
    % Testing whats the best gradient direction
    cost = inf;
    f0 = f(x0);
    
    for ii=1:size(combinations,1)
        if limitsTest(combinations(ii,:))
            if f(combinations(ii,:))-f0 < cost
                cost = f(combinations(ii,:))-f0;
                bestDirIndex = ii;
            end
        else
            continue
        end       
    end

end

function combinations = generateNodeCombinations(depth)
    % Recursion to get all the possible gradient direction vectors
    % Initialize an empty cell array to store combinations
    combinations = zeros(1,depth);

    % Generate all possible combinations recursively
    generateCombinationsRecursive(1, depth, []);

    function generateCombinationsRecursive(currentDepth, targetDepth, currentCombination)
        if currentDepth > targetDepth
            % If reached the target depth, add the current combination to the list
            combinations(end+1,:) = currentCombination;
        else
            % Generate combinations recursively for left and right children
            generateCombinationsRecursive(currentDepth + 1, targetDepth, [currentCombination, 1]);
            generateCombinationsRecursive(currentDepth + 1, targetDepth, [currentCombination, -1]);
            generateCombinationsRecursive(currentDepth + 1, targetDepth, [currentCombination, 0]);
        end
    end

    combinations = combinations(2:end,:);
end
end




