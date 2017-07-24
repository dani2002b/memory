  close all; clc; clear;
    

    if exist('serialEEG','var')
        fclose(serialEEG);
    end
    %clear;
    
    serialEEG = serial('/dev/cu.usbmodem1411', 'BaudRate', 921600);
     %serialEEG = serial('COM21', 'BaudRate', 2000000);    
   

    serialEEG.ReadAsyncMode = 'continuous';
    serialEEG.InputBufferSize = 140000;
    global dataEEG;
    global EEGMatrix;
    global initialTimer;
    global lastProcessedIndex;
    global indexesOfImage;
    global erps;
    global erpsCounter;
    global classOfImage;
    global b;
    global a;
    global zi;
    global graphic;
    global roi;
    global roiTime;
    fs = 1666;
    fc = 60;
     [b,a] = butter(2,fc/(fs/2));
        zi = [];
    
    roiTime = [-0.1, 0.5];
    roi = ceil(roiTime*fs);    
    
    classOfImage = [];
    indexesOfImage = [];
    erps = [];
    erpsCounter = 1;
    lastProcessedIndex =1;
    EEGMatrix = [];
    initialTimer = 0;
    dataEEG=[];
    fopen(serialEEG);
   
    clear top;
    top.sp = [3 1];
    top.h = [.25 .75/2 .75/2];
    top.c(1).sp = [1 2]; 
    top.c(1).w = [0.25 0.75];
    top.c(2).sp = [1 2];
    top.c(2).w = [0.5 0.5];
    top.c(3).sp = [1 2];
    top.c(3).w = [0.5 0.5];
    top.c(1).c(2).sp = [6 1];
   
    global p;
    %make portable position handles
    p = [];
    p.image               = 1;
    p.predictionOutcome   = 8;
    p.eeg                 = 2:7;
    p.erp                 = 8:11;
    p.h = subsubplot(top);
    

    graphic = [];
    graphic.h11 = p.h( p.eeg(1) );
    graphic.h12 = p.h( p.eeg(2) );
    graphic.h21 = p.h( p.eeg(3) );
    graphic.h22 = p.h( p.eeg(4) );
    graphic.h31 = p.h( p.eeg(5) );
    graphic.h32 = p.h( p.eeg(6) );
    graphic.imageHandle = p.h( p.image );
    graphic.imageLabel = p.h( p.erp(1) );


    graphic.timeForGraph = linspace(roiTime(1),roiTime(2),-roi(1)+roi(2)+1);
    %first iteration, create the graphics
    subplot(  p.h( p.eeg(1) ));
    p.h( p.eeg(1) ) = plot(graphic.timeForGraph, zeros(1,length(graphic.timeForGraph)));
    %title('First channel');
    
    subplot(  p.h( p.eeg(2) ));
    p.h( p.eeg(2) ) = plot(graphic.timeForGraph, zeros(1,length(graphic.timeForGraph)));
    %title('Second channel');       
    
    subplot(  p.h( p.eeg(3) ));
    p.h( p.eeg(3) ) = plot(graphic.timeForGraph, zeros(1,length(graphic.timeForGraph)));
    %title(graphic.ax21, 'Third channel');
    
    subplot(  p.h( p.eeg(4) ));
    p.h( p.eeg(4) ) = plot(graphic.timeForGraph, zeros(1,length(graphic.timeForGraph)));
    %title(graphic.ax22, 'Fourth channel'); 
    
    subplot(  p.h( p.eeg(5) ));
    p.h( p.eeg(5) ) = plot(graphic.timeForGraph, zeros(1,length(graphic.timeForGraph)));
    %title(graphic.ax31, 'Fifth channel');
    
    lengthOfSixth = fs+100+1;
    
    subplot(  p.h( p.eeg(6) ));
    p.h( p.eeg(6) ) = plot(linspace(-100/fs, 1,lengthOfSixth), zeros(1,lengthOfSixth));
    %title(graphic.ax32, 'Sixth channel');   
    
    
    %figure('Position', [100 100 622 622]);
    global faceimg;
    global sceneimg;
    faceimg = imread('face.jpg');
    sceneimg = imread('scene.jpg');
    subplot( p.h( p.image ) );
    trainingimg = imread('training.jpg');
    p.h( p.image ) = image(trainingimg);

    set(gca, 'XTick', []);
    set(gca, 'YTick', []);
  
    
    global t
    t = timer('TimerFcn', @(x,y)getSerialDataHandler(serialEEG, dataEEG), 'Period',  0.1);
    set(t,'ExecutionMode','fixedRate');
    start(t);