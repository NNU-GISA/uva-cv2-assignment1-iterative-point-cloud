function [BoW] = get_BoW(A_normal, vocabulary)
    % initialize BoW histogram
    vocabulary_size = size(vocabulary, 1);
    BoW = zeros(1, vocabulary_size);
    
    num_A = size(A_normal, 1);

    % create the Bag of Words histogram
    for i = 1:num_A
        current_A = A_normal(i, :);
        
        % initialize best_A_idx and closest_distance for comparisons
        best_A_idx = -1;
        closest_distance = Inf;
        
        % compare the current feature to the vocabulary features to get the
        % closest match
        for j = 1:vocabulary_size
            current_vocab_d = vocabulary(j, :)';
            current_distance = norm(current_vocab_d - double(current_A));
            
            if current_distance < closest_distance
                % update best_d and closest_distance
                best_A_idx = j;
                closest_distance = current_distance;
            end
        end
        
        % update the BoW histogram
        BoW(best_A_idx) = BoW(best_A_idx) + 1;
    end
    
    % normalize the BoW histogram
    BoW = BoW/sum(sum(BoW));
end
