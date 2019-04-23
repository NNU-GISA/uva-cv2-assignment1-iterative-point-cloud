function [BoW] = get_BoW(I, vocabulary, sampling_method, sift_descriptor, descriptor_type)
    % initialize BoW histogram
    vocabulary_size = size(vocabulary, 1);
    BoW = zeros(1, vocabulary_size);
    
    % extract features from the image
    [~, d] = extract_features(I, sampling_method, sift_descriptor, descriptor_type);
    d = double(d);
    num_d = size(d, 2);

    % create the Bag of Words histogram
    for i = 1:num_d
        current_d = d(:, i);
        
        % initialize best_d_idx and closest_distance for comparisons
        best_d_idx = -1;
        closest_distance = Inf;
        
        % compare the current feature to the vocabulary features to get the
        % closest match
        for j = 1:vocabulary_size
            current_vocab_d = vocabulary(j, :)';
            current_distance = norm(current_vocab_d - double(current_d));
            
            if current_distance < closest_distance
                % update best_d and closest_distance
                best_d_idx = j;
                closest_distance = current_distance;
            end
        end
        
        % update the BoW histogram
        BoW(best_d_idx) = BoW(best_d_idx) + 1;
    end
    
    % normalize the BoW histogram
    BoW = BoW/sum(sum(BoW));
end
