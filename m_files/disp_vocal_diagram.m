%:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::%
% Auteur : Leny vinceslas                                   %
% Date : 02/05/2013                                         %
% Place : Laboratoire de Phonetique et de Phonologie, Paris3%
%:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::%
%
%
%This function display the result of a formant analysis by drawing a vocal diagram.
%Inputs:
%   gravityCenter: matrix of the gravity center of each vowel to display
%   vowel2disp: cells of each vowel code to display
%   val2disp: cells of formant values of each vowel analysed
%   nominalValues: cells contening the nominal values of formants, formant
%   STD and tolerance
%   idx: index of the analysed vowels, matching nominalValues.idx
%   gender: speaker gender for each vowel, 1=male, 2=female
%   allMeasures: display all the measures 1 or 0
%   nasal: display the nasal 1 or 0
%   elipseSTD: elipse showing the 95% of the nominal values 1 or 0
%   elipseMeasure: elipse showing the STD of measured formants
%   x,y: data to be displayed on axis x and y
%   1=f1,2=f2,...,f5=f'2,f6=f2-f1;
%   code2sampa:corespondancy between vowel codes and sampa code
%
function disp_vocal_diagram(nameVowels,gravityCenter,vowel2disp,val2disp,nominalValues,idx,...
    gender,allMeasures,nasal,elipseSTD,elipseMeasure,x,y,code2sampa,meanf2prim,f2prim2disp,...
    reversAxes,isnasal,idxSpeaker)

%%%%%% inverser X / Y dans les plots !
%
%%%%%%%%%%%%%%%%% affichage dégradé couleur en fonction de la fréquence.


gravityCenter(:,5)=cell2mat(meanf2prim');
%gravityCenter(:,5)=cell2mat(meanf2prim');
%val2disp=[val2disp f2prim'];
for k=1:length(val2disp)
val2disp{k}(:,5)=round(cell2mat(f2prim2disp{k}));
end
color=[1 0 0;0 1 1;1 0 1;1 .843 0;0 1 0;...
    0 0 1;0 0 0;1 .647 0;.557 .557 .22;...
    .698 .133 .133;.821 .821 .821]	;
colorCount=1;
markers=['+';'x';'o';'*';'s';'d';'^';'v';'<';'>';'p';'h';'.'];
  
switch x
    case 1
        x1=1;
        x2=1;
        xFminusF=0;
        xLabel='F1';
    case 2
        x1=2;
        x2=1;
        xFminusF=0;
        xLabel='F2';
    case 3
        x1=3;
        x2=1;
        xFminusF=0;
        xLabel='F3';
    case 4
        x1=4;
        x2=1;
        xFminusF=0;
        xLabel='F4';    
    case 5
        x1=5;
        x2=1;
        xFminusF=0;
        xLabel='F''2';
    case 6
        x1=2;
        x2=1;
        xFminusF=1;
        xLabel='F2-F1';
    case 7 
        x1=3;
        x2=1;
        xFminusF=1;
        xLabel='F3-F1';
    case 8
        x1=3;
        x2=2;
        xFminusF=1;
        xLabel='F3-F2';
end

switch y
    case 1
        y1=1;
        y2=1;
        yFminusF=0;
        yLabel='F1';
    case 2
        y1=2;
        y2=1;
        yFminusF=0;
        yLabel='F2';
    case 3
        y1=3;
        y2=1;
        yFminusF=0;
        yLabel='F3';
    case 4
        y1=4;
        y2=1;
        yFminusF=0;
        yLabel='F4';
    case 5
        y1=5;
        y2=1;
        yFminusF=0;
        yLabel='F''2';        
    case 6
        y1=2;
        y2=1;
        yFminusF=1;
        yLabel='F2-F1';
    case 7 
        y1=3;
        y2=1;
        yFminusF=1;
        yLabel='F3-F1';
    case 8
        y1=3;
        y2=2;
        yFminusF=1;
        yLabel='F3-F2';
end


% Look for the idx of the vowel, empty if nasal or unknown name
for k=1:length(nameVowels)
    IDX=find(strcmp(nominalValues.idx,nameVowels(k)),1);
    if isempty(IDX) IDX=NaN; end
       idx(k)=IDX;
end
        
 XgravityCenter=gravityCenter(:,x1)-xFminusF*gravityCenter(:,x2);
 for j=1:size(gravityCenter,1)
        Xval2disp{j}=val2disp{j}(:,x1)-xFminusF*val2disp{j}(:,x2); 
        
             if (~isnan(idx(j)) && ~xFminusF && x1~=5) 
                Xtolerence(j)=nominalValues.tolerence{gender(j)}(idx(j),x1);
                Xformants(j)=nominalValues.formants{gender(j)}(idx(j),x1)';
            else
                Xtolerence(j)=NaN;
                Xformants(j)=NaN;
             end       
 end

 YgravityCenter=gravityCenter(:,y1)-yFminusF*gravityCenter(:,y2);
 for j=1:size(gravityCenter,1)
        Yval2disp{j}=val2disp{j}(:,y1)-yFminusF*val2disp{j}(:,y2); 
        
        if (~isnan(idx(j)) && ~yFminusF && y1~=5)
                Ytolerence(j)=nominalValues.tolerence{gender(j)}(idx(j),y1);
                Yformants(j)=nominalValues.formants{gender(j)}(idx(j),y1);
        else
                Ytolerence(j)=NaN;
                Yformants(j)=NaN;
        end    
 end 
        
for j=1:length(vowel2disp)
sampaIDX =strcmp(code2sampa(1,:),vowel2disp{j});
if sum(sampaIDX)==0
    vowel2dispSampa{j}=vowel2disp{j};
else
    vowel2dispSampa{j}=code2sampa{2,sampaIDX};
end
sampaIDX=[];
end

% generate colors 
%/!\/!\ The function mapminmax bugs in some version of matlab /!\/!\
Ycolors=(mapminmax(YgravityCenter',0.1,0.9))';
Xcolors=(mapminmax(XgravityCenter',0.1,0.9))';
color=[ones(length(Xcolors),1)*.2 Xcolors Ycolors];

% For each vowel disp the following
for j=1:size(gravityCenter,1)    

    hold on; grid on;
    %if ~isnan(idx(j))
    if ~isnasal(j)
        plot(XgravityCenter(j),YgravityCenter(j),'w+');
        text(XgravityCenter(j),YgravityCenter(j), vowel2dispSampa{j},'color',single(color(j,:)),...
        'FontWeight','bold','FontSize',18,'HorizontalAlignment','center','clipping','on',...
    'FontName','Ipa-sams Uclphon1 SILSophiaL');

        if allMeasures
            for k=1:numel(Xval2disp{j})
            plot(Xval2disp{j}(k),Yval2disp{j}(k),markers(mod(idxSpeaker{j}(k),numel(markers))),'color',roundn(color(j,:),-4));
            k=k+1;
            end
        end
        if elipseSTD 
            std2ellipse(Xtolerence(j),Ytolerence(j)...
            ,0,Xformants(j),Yformants(j),color(j,:));
        end
        if elipseMeasure
            if size(val2disp{j},1)>1
            [e]=points2ellipse(Xval2disp{j},Yval2disp{j});
            plot(e(1,:),e(2,:),'-.','color',color(j,:),'LineWidth',1.5);
            end
        end
        colorCount=colorCount+1;
    elseif nasal
        plot(XgravityCenter(j),YgravityCenter(j),'w+');
%         text(XgravityCenter(j),YgravityCenter(j), vowel2dispSampa{j},'color',color(end,:),...
%         'FontWeight','bold','FontSize',18,'HorizontalAlignment','center','clipping','on',...
%         'FontName','Ipa-sams Uclphon1 SILSophiaL');
        text(XgravityCenter(j),YgravityCenter(j), vowel2dispSampa{j},'color',color(j,:),...
        'FontWeight','bold','FontSize',18,'HorizontalAlignment','center','clipping','on',...
        'FontName','Ipa-sams Uclphon1 SILSophiaL');
        if allMeasures
            for k=1:numel(Xval2disp{j})
            plot(Xval2disp{j}(k),Yval2disp{j}(k),markers(mod(idxSpeaker{j}(k),numel(markers))),'color',roundn(color(j,:),-4));
            k=k+1;
            end
            %plot(Xval2disp{j},Yval2disp{j},'+','color',color(j,:));
        end

        if elipseSTD
            std2ellipse(Xtolerence(j),Ytolerence(j)...
            ,0,Xformants(j),Yformants(j),color(j,:));
        end
        if elipseMeasure
            if size(val2disp{j},1)>1
            [e]=points2ellipse(Xval2disp{j},Yval2disp{j});
            plot(e(1,:),e(2,:),'-.','color',color(j,:),'LineWidth',1.5);
            %plot(e(1,:),e(2,:),'-.','color',color(colorCount,:),'LineWidth',1.5);
            end
        end
        colorCount=colorCount+1;%%%%%%%%
    end
    
    if reversAxes(1)==1
        set(gca,'XDir','rev')
    end
    
    if reversAxes(2)==1
         set(gca,'YDir','rev')
    end
    
    set(gca, 'YAxisLocation', 'right');
    set(gca, 'XAxisLocation', 'top');
    set(get(gca,'YLabel'),'String',[yLabel '       Frequency (Hz)']);
    set(get(gca,'XLabel'),'String',[xLabel '       Frequency (Hz)']);
    hold off
end
end
% end