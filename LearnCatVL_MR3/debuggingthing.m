nBacksPerImage = 1;
nPairs = 8;
nSingletons = 8;
nMiniBlocks = 4;
drawFromEachPerBlock = 2;
keepTrying = 1;
while keepTrying
    keepTrying = 0;
    
    sets_pair1 = (repmat(1:nPairs, 1, nBacksPerImage));
    sets_pair2 = (repmat(1:nPairs, 1, nBacksPerImage));
    sets_singletons = (repmat((nPairs+1):(nPairs+nSingletons), 1, nBacksPerImage));

    pair1order = [];
    pair2order = [];
    singletonorder = [];
    
    for block = 1:nMiniBlocks
        candidates = Shuffle(unique(sets_pair1));
        if length(candidates) < drawFromEachPerBlock
            keepTrying = 1;
            break;
        end
        pair1order = [pair1order; candidates(1:drawFromEachPerBlock)];
        for idx = 1:drawFromEachPerBlock
            indices = find(sets_pair1 == candidates(idx));
            sets_pair1(indices(1)) = [];
        end
    end
    
    for block = 1:nMiniBlocks
        candidates = Shuffle(unique(sets_pair2));
        [C,IA,IB] = intersect(candidates, pair1order(block,:));
        candidates(IA) = [];
        if length(candidates) < drawFromEachPerBlock
            keepTrying = 1;
            break;
        end
        pair2order = [pair2order; candidates(1:drawFromEachPerBlock)];
        for idx = 1:drawFromEachPerBlock
            indices = find(sets_pair2 == candidates(idx));
            sets_pair2(indices(1)) = [];
        end
    end
    
    for block = 1:nMiniBlocks
        candidates = Shuffle(unique(sets_singletons));
        if length(candidates) < drawFromEachPerBlock
            keepTrying = 1;
            break;
        end
        singletonorder = [singletonorder; candidates(1:drawFromEachPerBlock)];
        for idx = 1:drawFromEachPerBlock
            indices = find(sets_singletons == candidates(idx));
            sets_singletons(indices(1)) = [];
        end
    end
    
end

pair1order_Cat = [];
    pair2order_Cat = [];
    singletonorder_Cat = [];
keepTrying = 1;
while keepTrying
    keepTrying = 0;
    
    sets_pair1_Cat = (repmat(1:nPairs, 1, nBacksPerImage));
    sets_pair2_Cat = (repmat(1:nPairs, 1, nBacksPerImage));
    sets_singletons_Cat = (repmat((nPairs+1):(nPairs+nSingletons), 1, nBacksPerImage));
    drawFromEachPerBlock = length(sets_pair1_Cat)/nMiniBlocks; % assuming length(sets_pair1) == length(sets_singletons)
    pair1order_Cat = [];
    pair2order_Cat = [];
    singletonorder_Cat = [];
    for block = 1:nMiniBlocks
        candidates = Shuffle(unique(sets_pair1_Cat));
        if length(candidates) < drawFromEachPerBlock
            keepTrying = 1;
            break;
        end
        pair1order_Cat = [pair1order_Cat; candidates(1:drawFromEachPerBlock)];
        for idx = 1:drawFromEachPerBlock
            indices = find(sets_pair1_Cat == candidates(idx));
            sets_pair1_Cat(indices(1)) = [];
        end
    end
    for block = 1:nMiniBlocks
        candidates = Shuffle(unique(sets_pair2_Cat));
        [C,IA,IB] = intersect(candidates, pair1order_Cat(block,:));
        candidates(IA) = [];
        if length(candidates) < drawFromEachPerBlock
            keepTrying = 1;
            break;
        end
        pair2order_Cat = [pair2order_Cat; candidates(1:drawFromEachPerBlock)];
        for idx = 1:drawFromEachPerBlock
            indices = find(sets_pair2_Cat == candidates(idx));
            sets_pair2_Cat(indices(1)) = [];
        end
    end
    for block = 1:nMiniBlocks
        candidates = Shuffle(unique(sets_singletons_Cat));
        if length(candidates) < drawFromEachPerBlock
            keepTrying = 1;
            break;
        end
        singletonorder_Cat = [singletonorder_Cat; candidates(1:drawFromEachPerBlock)];
        for idx = 1:drawFromEachPerBlock
            indices = find(sets_singletons_Cat == candidates(idx));
            sets_singletons_Cat(indices(1)) = [];
        end
    end
end

training_trials = []; 



        
%         
%     
%     for block = 1:nMiniBlocks
%         if ~(length(sets_pair1(((block-1)*drawFromEachPerBlock+1):(block*drawFromEachPerBlock))) == ...
%                 length(unique(sets_pair1(((block-1)*drawFromEachPerBlock+1):(block*drawFromEachPerBlock)))))
%             keepTrying = 1;
%             sets_pair1 = Shuffle(sets_pair1);
%             break;
%         end
%         if ~(length(sets_pair2(((block-1)*drawFromEachPerBlock+1):(block*drawFromEachPerBlock))) == ...
%                 length(unique(sets_pair2(((block-1)*drawFromEachPerBlock+1):(block*drawFromEachPerBlock)))))
%             keepTrying = 1;
%             sets_pair2 = Shuffle(sets_pair2);
%             break;
%         end
%         if ~isempty(intersect(sets_pair1(((block-1)*drawFromEachPerBlock+1):(block*drawFromEachPerBlock)), ...
%                 sets_pair2(((block-1)*drawFromEachPerBlock+1):(block*drawFromEachPerBlock))))
%             keepTrying = 1;
%             sets_pair2 = Shuffle(sets_pair2);
%             break;
%         end
%     end
% end