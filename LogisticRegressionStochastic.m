fileNameTrain = 'citeseer.train.ltc.svm';
fileNameTest = 'citeseer.test.ltc.svm';
dir = 'Users/daniel/Documents/MATLAB/+SearchEnginesHW5/+Data/';
fileLocationTrain = strcat(dir,fileNameTrain);
fileLocationTest = strcat(dir,fileNameTest);



%Import database
fprintf('loading training data...\n');
[Xtrain,Ytrain] = SearchEnginesHW5.readLabeledSparseMatrix (fileLocationTrain);
fprintf('loading testing data...\n');
[Xtest,Ytest] = SearchEnginesHW5.readLabeledSparseMatrix (fileLocationTest);
fprintf('data loaded\n\n');

Xtrain = [ones(size(Xtrain,1),1) Xtrain];
Xtest = [ones(size(Xtest,1),1) Xtest];


Ytrain_temp = zeros(size(Ytrain));
Ytrain_temp(Ytrain==1) = 1;
Ytrain = Ytrain_temp;

Ytest_temp = zeros(size(Ytest));
Ytest_temp(Ytest==1) = 1;
Ytest = Ytest_temp;



%TRAINING
alpha = 0.01;
C = 0.001;
FV_dimension = size(Xtrain,2);
w = zeros(1, FV_dimension);
lastValue = 0;
convPrecision = 0.01;

breakLoop=false;
T = 0;
while true
    
    randIndex = randperm(size(Xtrain,1));
    shuffledXtrain = Xtrain(randIndex,:);
    shuffledYtrain = Ytrain(randIndex);
    
    
    for i=1:size(shuffledXtrain,1)
        
        currentX = shuffledXtrain(i,:);
        currentY = shuffledYtrain(i);
        
        p = 1 / (1 + exp(-dot(currentX,w)) );
        w = w + alpha*( (currentY - p)*currentX - C*w ); 
        
        if mod(i,1500) ==0
            P = 1 + exp(-Xtrain*w');
            P = bsxfun(@rdivide,1,P);

            LossFunction = bsxfun(@times,Ytrain,log(P)) + bsxfun(@times,(1-Ytrain),log(1-P));
            LossFunction = sum(LossFunction);

            currentValue = LossFunction - 0.5*C*sum(dot(w,w));

            %Adaptative learning
            %if T > 0
            %   alpha = alpha * power(abs((lastValue - currentValue)/currentValue), 0.00005);
            %end
            
            convValue = abs(lastValue - currentValue);
            lastValue = currentValue;
            %fprintf('%f\n', currentValue);
            fprintf('%f %f\n', convValue, currentValue);
            
            T = T + 1;
            
            if convValue <= convPrecision
                breakLoop = true;
                break;
            end
        end
        
    end 
    
    
    if breakLoop
        break;
    end
    
end

%TESTING
Pred_lr = sign(Xtest*w');
Pred_lr(Pred_lr==-1)=0;

a = sum((Pred_lr==0).*(Ytest==0));
b = sum((Pred_lr==1).*(Ytest==0));
c = sum((Pred_lr==0).*(Ytest==1));
d = sum((Pred_lr==1).*(Ytest==1));

precision = d / (d + b);
recall = d / (c + d);
accuracy = (a + d) / (a + b + c + d);

fprintf('%i \n', T);
fprintf('P:%.3f, R:%.3f, A:%.3f \n', precision, recall, accuracy);


