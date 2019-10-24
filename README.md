# Persian Car License Plate Reader
A tiny hobby MATLAB project for reading Iranian car license plates

## Usage
This file is written and tested using MATLAB 2012b

```matlab
imgPath = 'Cars\1.jpg';
plate = readCar(imgPath);
```

This process start to learn an *Artificial Neural Network* using train set we provided in an excel file, And then use the learnt Neural Network to identify plate numbers.
you can save the learnt Neural Network and use it again without restart the whole learning process

