clear; close all;
%% dataset
ns = 20; 
x = linspace(0,1,ns)';
%y = @(x) sin(2*pi*x);
w2 = 0.5; w1 = 0.8;
y = @(x) w2*x + w1;
e = .2*randn(size(x));
t = y(x) + e;
gaussmf = @(x,params) (exp(-(x-params(2)).^2/(2*params(1))));

%% prior
M = 2;
alpha = .1;
beta = 1/.01;

MuPrior = zeros(1,M)'; SigmaPrior = alpha\eye(M);

phi = @(x)(bsxfun(@power,x,0:M-1)); % Phi function
phix = phi(x); % design matrix
%f1 = figure('units','normalized','outerposition',[0 0 1 1]);% f2 = figure('Position',[501 100 500 400]);
f1 = figure;% f2 = figure('Position',[501 100 500 400]);
pbaspect([1 1 1]);
%f3 = figure;


for i=1:length(t)
    clf;
    if i == 1
        x1 = -2:.005:2; x2 = x1;
        [X1,X2] = meshgrid(x1,x2);
        F = mvnpdf([X1(:) X2(:)],MuPrior',inv(SigmaPrior));
        F = reshape(F,length(x2),length(x1));
        %figure(f2); clf;
        subplot(1,4,1); surf(X1,X2,F,'Edgecolor','none');set(gca,'YDir','normal'); hold on; grid off;plot(w1,w2,'w+','LineWidth',1.5);
        W = mvnrnd(MuPrior',inv(SigmaPrior),10); pbaspect([1 1 1]); title('Prior'); 
        
        xx = linspace(0,1,100);
        yt = W(:,2)*xx + W(:,1);
        %figure(f1); clf;
        subplot(1,4,4); plot(xx,yt); hold on; grid off;plot(xx,y(xx),'r--','LineWidth',1); title('Predicted'); xlim([0 1]); ylim([0 2]);
        pbaspect([1 1 1]); pause;
    end
    
    if i ~= 1
        F = mvnpdf([X1(:) X2(:)],MuPost',inv(SigmaPost));
        F = reshape(F,length(x2),length(x1));
        %figure(f2); clf;
        subplot(1,4,1); surf(X1,X2,F,'Edgecolor','none'); set(gca,'YDir','normal'); hold on; grid off;plot(w1,w2,'w+','LineWidth',1.5);
        pbaspect([1 1 1]);title('Prior');
        %figure(f3); clf;
    end
    
    SigmaPost = SigmaPrior + beta*(phix(1:i,:)'*phix(1:i,:));
    MuPost = SigmaPost\(SigmaPrior\MuPrior + beta*phix(1:i,:)'*t(1:i));
    MuPrior = MuPost;

    W = mvnrnd(MuPost',inv(SigmaPost),10);
    
    xx = linspace(0,1,100);
    yt = W(:,2)*xx + W(:,1);
    %figure(f1); clf;
    subplot(1,4,4); plot(xx,yt); hold on; grid off;plot(xx,y(xx),'r--','LineWidth',1); hold on; grid off;plot(x(1:i),t(1:i),'o'); xlim([0 1]); ylim([0 2]);
    pbaspect([1 1 1]); title('Predicted');
    
    F = mvnpdf([X1(:) X2(:)],MuPost',inv(SigmaPost));
    F = reshape(F,length(x2),length(x1));
    %figure(f2); clf;
    subplot(1,4,3); surf(X1,X2,F,'Edgecolor','none'); set(gca,'YDir','normal'); hold on; grid off;plot(w1,w2,'w+','LineWidth',1.5); 
    pbaspect([1 1 1]);title('Posterior');
    %figure(f3); clf; 
    
    lkhd = [X1(:) X2(:)]*phix(i,:)'; lkhd = (sqrt(2*pi)*beta)\gaussmf(lkhd(:),[1 t(i)]);
    lkhd = reshape(lkhd,length(x2),length(x1));
    subplot(1,4,2); surf(X1,X2,lkhd,'Edgecolor','none'); set(gca,'YDir','normal'); hold on; grid off;plot(w1,w2,'r+','LineWidth',1.5);
    pbaspect([1 1 1]); title('Likelihood'); pause(0.5);
    
    if i == 1
        pause;
    end
end