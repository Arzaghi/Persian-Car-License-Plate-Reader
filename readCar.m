function textNumber = readCar(imagePath)    
    cropedPlate = CropPlate(imagePath);                                 %crop the plate of car
    foundedChar = SeparatePlate(cropedPlate);                           %separate each digit of plate
    [NumbersNetwork, AlphabetNetwork] = CreateNeuralNetwork;            %create neural network to convert image to text
    txt = '';                                       
    for i=1:foundedChar
        numPath = strcat('[',int2str(i), ']', '.png');
        if i~=3                        
            txt = strcat(txt , int2str(DetectNumber(numPath, NumbersNetwork)));        
        else
            x = DetectNumber(numPath, AlphabetNetwork);
            alphabet = '()';
            switch x
                case {1}
                    alphabet = '(B)';                
                case {2}
                    alphabet = '(D)';                
                case {3}
                    alphabet = '(GH)';                
                case {4}
                    alphabet = '(H)';                
                case {5}
                    alphabet = '(I)';                
                case {6}
                    alphabet = '(L)';                
                case {7}
                    alphabet = '(M)';                
                case {8}
                    alphabet = '(N)';                
                case {9}
                    alphabet = '(Sin)';                
                case {10}
                    alphabet = '(Saad)';                
                case {11}
                    alphabet = '(Vav)';
                case {12}
                    alphabet = '(Ta)';
            end
            txt = strcat(txt , alphabet);
        end
        delete(numPath);
    end
    textNumber = txt;    
end

function Result = CropPlate(imagePath)

    FoundedPlate = 0;
    OriginalImage = imread(imagePath);    
    OriginalImage = imresize(OriginalImage, [768, 1024]);
    GrayScaleImage = rgb2gray(OriginalImage) ;
    GrayScaleImage = edge(GrayScaleImage,'prewitt') ;
    GrayScaleImage = imdilate(GrayScaleImage, strel('Diamond', 1)) ;
    BlackWhiteImage = imfill(GrayScaleImage, 'Holes') ;       
    ImageRegions = regionprops(BlackWhiteImage, 'BoundingBox') ;
    RegionsCount = size(ImageRegions, 1) ;
    NumberOfFoundedPlate = 0 ;
    
    for Region = 1:RegionsCount
        RectangleOfChoice=ImageRegions(Region).BoundingBox;

        PlateStartX = fix(RectangleOfChoice(1));  if  PlateStartX == 0; PlateStartX = 1;  end
        PlateStartY = fix(RectangleOfChoice(2));  if  PlateStartY == 0; PlateStartY = 1;  end
        PlateWidth  = fix(RectangleOfChoice(3));  if  PlateWidth  == 0; PlateWidth  = 1;  end
        PlateHeight = fix(RectangleOfChoice(4));  if  PlateHeight == 0; PlateHeight = 1;  end
        RectangleOfPlate=[PlateStartX PlateStartY PlateWidth PlateHeight];
        
        if PlateWidth > 150 && PlateHeight > 40 && PlateWidth < 350 && PlateHeight < 120 && PlateWidth/PlateHeight >= 3.5 && PlateWidth/PlateHeight <= 8            
            TempCropOfImage=imcrop(BlackWhiteImage, RectangleOfPlate);
            NumberOfWhitePixelsInChoice = sum(sum(TempCropOfImage), 2);            
            if NumberOfWhitePixelsInChoice>((PlateWidth * PlateHeight) / 2.0)                
                Plate = imcrop(OriginalImage, RectangleOfPlate);
                NumberOfFoundedPlate = NumberOfFoundedPlate + 1;   
                FoundedPlate = FoundedPlate + 1;
                %imwrite(Plate, strcat('[', int2str(NumberOfFoundedPlate), ']', '.Jpg'), 'Jpg');
                Result = Plate;
            end
        end
    end   
end

function result = SeparatePlate(CropedPlate)    
    OriginalPlate = CropedPlate;    
    BlackWhiteImage = not(im2bw(OriginalPlate, graythresh(OriginalPlate)));    

    ImageRegions = regionprops(BlackWhiteImage, 'FilledImage') ;   
    RegionsCount = size(ImageRegions, 1) ;    
    FoundedCharacter = 0;
    
    for Region = 1:RegionsCount
        RectangleOfChoice=ImageRegions(Region).FilledImage;        
        [CharacterHeight CharacterWidth]=size(RectangleOfChoice);
        if (CharacterHeight>15 && CharacterHeight<100 && CharacterWidth>10 && CharacterWidth<100)       
            FoundedCharacter = FoundedCharacter + 1;
            imwrite(not(RectangleOfChoice), strcat('[',int2str(FoundedCharacter), ']', '.png'), 'png');                 
        end        
    end
    
    result = FoundedCharacter;
end

function [result1, result2] = CreateNeuralNetwork
    %create neural network for numbers
    setdemorandstream(491218382);                   		%set a number
    features= xlsread ('LearnData.xls', 'sheet1');          %read train inputs
    answers=  xlsread ('LearnData.xls', 'sheet2');    		%read train outputs

    net = patternnet(20);
    net.trainParam.showWindow = 0;
    [net, ~] = train(net,features,answers);
    result1 = net;
    
    %create neural network for alphabet
    setdemorandstream(491218382);                   		%set a number
    features= xlsread ('LearnData.xls', 'sheet3');          %read train inputs
    answers=  xlsread ('LearnData.xls', 'sheet4');    		%read train outputs

    net = patternnet(40);
    net.trainParam.showWindow = 0;
    [net, ~] = train(net,features,answers);
    result2 = net;
    
end

function number = DetectNumber(imagePath,net)
    im = imread(imagePath);             
    im = imresize(im,[100, 50]);
    features = zeros(500,1);
    for j = 1:20    
        for i = 1:25
             x = sum(sum(im((j-1)*5+1:j*5,(i-1)*2+1:i*2)));
             features((j-1)*25+i,1) = x/10;
        end
    end                
    [~, num] = max(sim(net, features));
    number = num;    
end