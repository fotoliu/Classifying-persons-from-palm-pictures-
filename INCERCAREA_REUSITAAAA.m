clc
close all
clearvars

lista=dir("D:\anul4 sem1\proiect_ai\baza_de_date_initiale\*.jpg");

for i=1:length(lista)
    im=imread([lista(i).folder,'\',lista(i).name]); % se citeste fiecare imag in parte
 
im=double(im);
im(1635:end,:,:)=60; % in zona aia era un colt de mapa care era luat ca facand parte
%din acelasi cluster ca mana
figure(i),subplot(2,2,1),imshow(uint8(im))
R=im(:,:,1);
G=im(:,:,2);
B=im(:,:,3);

P=[R(:),G(:),B(:)]; % un vector care contine toate planurile (R,G,B)
indx=kmeans(P,2); % am aplicat kmeans pt toate planurile la un loc si i-am spus 
% sa imi gaseasca 2 clustere (2-ul a fost ales arbitrar pentru ca poza a
% fost facuta pe un fundal negru), pe care le a gasit in functie de culoari

im1=reshape(indx,[size(im,1),size(im,2)]);%am creeat o imagine din etichetele
%puse de kmeans
%urmeaza colorarea obiectului de interes mana cu alb 1L si a fundalului cu
%negru 0L
im2=zeros(size(im1));
for i1=1:size(im,1)
    for j=1:size(im,2)

        if im1(i1,j)==im1(357,843) %o valoare la care se afla palma la fiecare
            % dintre poze
            im2(i1,j)=1;
        
        end

    end
end


subplot(2,2,2),imshow(im2),title(['mana nr ',num2str(i)])
% se va afisa imaginea cu numarul mainii ca titlu
% fiecare nr al mainii din primele 5 imagini reprezinta o mana diferita
% pt numele persoanelor vezi folderul din linkul de sus




[A,B]=bwboundaries(im2,'noholes');

contur=A{B(350,950)}; % 350,950 alta valoare la care stim sigur ca avem mana
% in fiecare poza
Y=contur(:,1);
X=contur(:,2);
C=X+1i*Y;
subplot(2,2,3),plot(C),axis('ij') % afisam conturul calculat
F=fft(C); % calculul TFD
F_interp(:,i)=resample(F,6000,length(F)); % pt ca compartatia sa fie eficienta
% s-a interpolat fiecare transformata la valoarea de 6000
F_interp(1,i)=0; %normalizarea (pt a elimina componenta continua)
Ampl=F_interp(:,i); %extragerea descriptorilor de contur 
Ampl=abs(Ampl);
subplot(2,2,4),bar(Ampl(1:10)) % afisarea primilor 10 descriptori de contur
end



% facem testarea

lista1=dir("C:\Users\vicri\OneDrive\Desktop\proiect_ai\testare\*.jpg");

for i=1:length(lista1)
    im=imread([lista1(i).folder,'\',lista1(i).name]);
    


figure(i+5),

im=double(im);
im(1635:end,:,:)=60;

subplot(2,2,1),imshow(uint8(im)),title(['mana test nr ',num2str(i)])
R=im(:,:,1);
G=im(:,:,2);
B=im(:,:,3);
P=[R(:),G(:),B(:)]; % un vector care contine toate planurile (rgb)
indx=kmeans(P,2); % am aplicat kmeans pt toate planurile la un loc si i-am spus 
% sa imi gaseasca 2 clustere (2-ul a fost ales arbitrar pentru ca poza a
% fost facuta pe un fundal negru 
im1=reshape(indx,[size(im,1),size(im,2)]); % am construit noua imagine pe 
%baza etichetelor obtinute
im2=zeros(size(im1));
for i1=1:size(im,1)
    for j=1:size(im,2)

        if im1(i1,j)==im1(357,843)
            im2(i1,j)=1;
        
        end

    end
end


subplot(2,2,2),imshow(im2),axis('image')
[A,B]=bwboundaries(im2,'noholes');
contur=A{B(350,950)};
Y=contur(:,1);
X=contur(:,2);
C=X+1i*Y;
subplot(2,2,3),plot(C),axis('ij')
F=fft(C); % calculul TFD
F_interp1(:,i)=resample(F,6000,length(F));
F_interp1(1,i)=0; %normalizarea (pt a elimina componenta continua)
Ampl=F_interp1(:,i); %extragerea descriptorilor de contur 
Ampl=abs(Ampl);
 % afisarea primilor N descriptori de contur
    for i1=1:length(lista)
        sad(i1,i)=sum(abs(F_interp1(:,i)-F_interp(:,i1)));
    end
    subplot(2,2,3),plot(C),axis('ij'),title(['mana aceasta seamna cel mai mult cu mana nr ',num2str(find(sad(:,i)==min(sad(:,i))))])
    % in linia de cod de mai sus se afiseaza conturul impreuna cu estimarea
    % agloritmului legata de mana de care este mai apropiata de cea de test
    subplot(2,2,4),bar(Ampl(1:10))
end

% se observa ca chiar daca poza nr 5 si poza test nr 1 sunt facute una dupa
% alta fara a schimba pozitia mainii diferenta dintre cele 2 transformate
% fourier este comparabila cu celelate maini, nicidecum apropiata de zero