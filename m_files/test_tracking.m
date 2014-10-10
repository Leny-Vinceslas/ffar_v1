function [finalTracks buff3]=test_tracking(formants, tres,disp)
%Formants tracking

%clear all;%close all;
%load('formants_u.mat');
%formants=flipud(formants);
disp=0;
for way=1:2
 if way==2 formants=flipud(formants);  end
    
 suppLine(1)=abs(diff([formants(1,1); formants(2,1)],1))>200;
 suppLine(2)=abs(diff([formants(1,2); formants(2,2)],1))>400; 
 suppLine(3)=abs(diff([formants(1,3); formants(2,3)],1))>800; 
 
 if suppLine(1)||suppLine(2)||suppLine(3)
 
     formants(1,:)=[];
     tres(1)=[];
     
 end
for k=1:size(formants,2)
    if disp
     figure(4)
   subplot(2,2,way)
    plot(formants,'.')
    hold on
    end
    
   candidat=1;
   naan=1;
   while naan && candidat<=size(formants,2)
       
       if isnan(formants(1,k))
           candidat=candidat+1;
           naan=1;
       else
            naan=0;
            tracks{way}(1,k)=formants(1,k);
            candX=1;
            candY=k;
            if disp
            plot(candX,formants(candX,candY),'or');
            end
            for j=1:size(formants,1)-1

                [r,c,V] = findnearest(formants(candX,candY),formants(j+1,:),0);
                if length(V)>1
                    V=formants(j+1,k);
                    c=k;
                    %disp('aaaaaaa')
                end
                candX=j+1;
                candY=c;
                tracks{way}(j+1,k)=V;   
                if disp
                plot(candX,formants(candX,candY),'or');
                end
            end
                stat{way}(k)= mean(diff(tracks{way}(:,k)));
       end   
   end
end



[x,y]=find(diff(tracks{way}',1)'==0);
if ~isempty(y)
colomn=unique(y);
for j=length(colomn):-1:1
    
        [g badtracks]=max([abs(stat{way}(colomn(j))) abs(stat{way}(colomn(j)+1))]);
        badtracks=colomn(j)+badtracks-1;
        tracks{way}(:,badtracks)=[];
  
end
end
if disp
plot(tracks{way},'go');
hold off
end
end

tracks{2}=flipud(tracks{2}); 
l=max(size(tracks{1},1),size(tracks{2},1));
c=max(size(tracks{1},2),size(tracks{2},2));
buff3=ones(l,1)*NaN;
buff3(1:length(tres))=tres;
buff{1}=NaN*ones(l,c);
buff{2}=buff{1};
buff{2}(1:size(tracks{2},1),1:size(tracks{2},2))=tracks{2};
buff{1}(1:size(tracks{1},1),1:size(tracks{1},2))=tracks{1};
finalTracks=union(buff{1}',buff{2}','rows')';

if size(finalTracks,2)>4
finalStat= mean(diff(finalTracks,1),1);
[x,y]=find(diff(finalTracks',1)'==0);
if ~isempty(y)
colomn=unique(y);
for j=length(colomn):-1:1
    
        [g badtracks]=max([abs(finalStat(colomn(j))) abs(finalStat(colomn(j)+1))]);
        badtracks=colomn(j)+badtracks-1;
        finalTracks(:,badtracks)=[];
  
end
end
end

while size(finalTracks,2)<=size(finalTracks,1)
    finalTracks(:,end+1)=ones(size(finalTracks,1),1)*NaN;
     tres(end+1)=NaN;
end

if disp
    figure(4)
   subplot(2,2,3)
    %formants=flipud(formants);
    %hold on
    plot(finalTracks,'*');
    %hold off
    pause
end
 
end

