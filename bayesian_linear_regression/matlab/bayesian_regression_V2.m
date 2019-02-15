close all; clear;
N = 4; % number of components
ns = 20; % number of samples
nf = 101;
alpha = 0.001; beta = 1000;

x = linspace(-1+eps,1-eps,ns)';
a1 = 0.5; a2 = -0.8; a3 = 0.8; a4 = -0.2;
y = a4*x.^3+a3*x.^2+a2*x+a1;
mu = 0;    
e = normrnd(mu,0.02,size(x));
t = y + e;

% figure(1);
% leg1 = ['y = ',num2str(a1),'x + ',num2str(a2)];
% plot(x,y);
% hold on;
% leg2 = ['Data : $\mathcal{N}$(',num2str(mu),', ',num2str(1/beta),')'];
% scatter(x,t);
% legend(leg1,leg2,'Interpreter','latex');
% hold off;

% legend

% Initial iteration: N = 0
MuN = zeros([N,1]);
Sigma0 = (1/alpha)*eye(N); Sigma0i = inv(Sigma0);
SigmaNi = Sigma0i;

% Kernel function
phi = @(x,i) x^(i-1);

xx = linspace(-1,1,100);
k = 2;
for n = 1:k:ns
    w = mvnrnd(MuN',inv(SigmaNi),nf); pause(0.05);
    
    yt = w(:,4)*xx.^3 +  w(:,3)*xx.^2 + w(:,2)*xx + w(:,1);

%     subplot(1,2,1)
    plot(xx,yt); hold on; plot(x(1:k:n),t(1:k:n),'o'); axis square;
    hold off;
%     
%     subplot(1,2,2)
%     int = -100:10:100;
%     [W1,W2] = meshgrid(int);
%     F = mvnpdf([W1(:) W2(:)],MuN.',SigmaNi);
%     F = reshape(F,length(int),length(int));
% 
%     colormap(jet);
%     contourf(int,int,F,100,'edgecolor','none'); hold on;
%     axis('square')
%     xlabel('w_1'); ylabel('w_2'); 
% 
%     plot(w(:,1),w(:,2),'+'); axis square; % xlim([0 1]); ylim([0 1]);
%     hold off;
    
    P = 1:N; P = arrayfun(@(i) phi(x(n),i),P);
    
    SigmaNiPrior = SigmaNi;
    SigmaNi = SigmaNiPrior + beta*(P'*P);
    MuN = SigmaNi\(SigmaNiPrior*MuN + beta*P'*t(n));
end