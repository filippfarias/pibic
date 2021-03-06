clear; close all;
mkdir([mfilename,'/']);
%% figure colors
% the standard gauss plot, using the nonlinear dataset
% Philipp Hennig, 11 Dec 2012
dgr = [239,125,45]/255-20/255; % color [0,125,122]
dre = [119,154,171]/255-50/255; % color [130,0,0]
lightdgr = [1,1,1] - 0.5 * ([1,1,1] - dgr);
lightdre = [1,1,1] - 0.5 * ([1,1,1] - dre);
dgr2white = bsxfun(@minus,[1,1,1],bsxfun(@times,(linspace(0,.6,2024)').^0.5,[1,1,1]-dgr));
dre2white = bsxfun(@minus,[1,1,1],bsxfun(@times,(linspace(0,.6,2024)').^0.5,[1,1,1]-dre));

GaussDensity = @(y,m,v)(bsxfun(@rdivide,exp(-0.5*...
    bsxfun(@rdivide,bsxfun(@minus,y,m').^2,v'))./sqrt(2*pi),sqrt(v')));

fr = 30; % # frames
% %mov(fr) = struct('cdata',[],'colormap',[]);

%% data generation
% ns = 20; X = linspace(-4,4,ns)';
% %Y = @(X) 10*sin(.2*pi*X);
% w2 = 2.5; w1 = 0.8;
% Y = @(X) w2*X + w1;
% 
% sigma = 4;
% e = sigma*randn(size(X));
% T = Y(X) + e;

load('data.mat');
N = length(T); % gives T,X,sigma

%% prior on w
F = 13; % number of features
phi = @(a)(exp(-0.5 * bsxfun(@minus,a,[-6:1:6]).^2));
mu = zeros(F,1);
Sigma = eye(F); % p(w) = N(µ, Σ)

%% prior on f(x)
n = 300; x = linspace(-6,6,n)'; % ‘test’ points
phix = phi(x); % features of x
m = phix * mu;
kxx = phix * Sigma * phix'; % p(fx) = N(m, kxx)
s = bsxfun(@plus,m,chol(kxx + 1.0e-5 * eye(n))' * randn(n,3)); % samples from prior
stdpi = sqrt(diag(kxx)); % marginal stddev, for plotting prior

%% plot

s1 = GPanimation(n,fr);
s2 = GPanimation(n,fr);
s3 = GPanimation(n,fr);

%kxx = k(x,x); % kernel function (enter your favorite here)
V = kxx;
L = chol(V + 1.0e-5 * eye(size(V))); % jitter for numerical stability
y = linspace(-15,20,n)';
P = GaussDensity(y,m,diag(V+eps)); colormap(dgr2white);

set(gcf,...
        'PaperPosition',.3*[0 0 16 9],...
        'PaperSize',.3*[16 9]);
for f = 1:fr
    clf; hold on
    imagesc(x,y,P);

    plot(x,max(min(m,20),-15),'-','Color',dgr,'LineWidth',0.7);
    plot(x,max(min(m + 2 * sqrt(diag(V)),20),-15),'-','Color',lightdgr,'LineWidth',.5);
    plot(x,max(min(m - 2 * sqrt(diag(V)),20),-15),'-','Color',lightdgr,'LineWidth',.5);
    plot(x,phi(x),'-','Color',0.3*ones(3,1));
    plot(x,m + L' * s1(:,f),'--','Color',dgr);
    plot(x,m + L' * s2(:,f),'--','Color',dgr);
    plot(x,m + L' * s3(:,f),'--','Color',dgr);
    xlim([-6,6]);
    ylim([-4,5]);
    drawnow; 
    %pause(0.02)
    %mov(f) = getframe(gcf);
    print([mfilename,'/',mfilename,'_','prior_','frame_',num2str(f)],'-painters','-dpdf');
end
% %save([mfilename,'prior'],'mov');
%% prior on Y = fX + e
phiX = phi(X); % features of data
M = phiX * mu;
kXX = phiX * Sigma * phiX'; % p(fX) = N(M, kXX)
G = kXX + sigma^2 * eye(N); % p(T) = N(M, kXX + σ²I)
R = chol(G); % most expensive step: O(N³)
kxX = phix * Sigma * phiX'; % cov(fx, fX) = kxX
A = kxX / R; % pre-compute for re-use
mpost = m + A * (R' \ (T-M)); % p(fx ∣ T ) = N(m + kxX(kXX + σ²I)^{−1} (T − M),
vpost = kxx - A * A'; % kxx − kxX(kXX + σ²I)^{−1}kXx)
%spost = bsxfun(@plus,mpost,chol(vpost + 1.0e-5 * eye(n))' * randn(n,3)); % samples
stdpo = sqrt(diag(vpost)); % marginal stddev, for plotting

%close all;
L = chol(vpost + 1.0e-5 * eye(size(vpost))); % jitter for numerical stability
y = linspace(-15,20,n)';
P = GaussDensity(y,mpost,diag(vpost+eps)); colormap(dre2white);
for f = 1:fr
    clf; hold on
    imagesc(x,y,P);

    plot(x,max(min(mpost,20),-15),'-','Color',dre,'LineWidth',0.7); hold on;
    plot(x,max(min(mpost + 2 * stdpo,20),-15),'-','Color',lightdre,'LineWidth',.5); hold on;
    plot(x,max(min(mpost - 2 * stdpo,20),-15),'-','Color',lightdre,'LineWidth',.5); hold on;
    plot(x,mpost + L' * s1(:,f),'--','Color',dre);
    plot(x,mpost + L' * s2(:,f),'--','Color',dre);
    plot(x,mpost + L' * s3(:,f),'--','Color',dre);
    plot(X,T,'bo');
    xlim([-6,6]);
    ylim([-15,20]);
    drawnow; 
   print([mfilename,'/',mfilename,'_','post_','frame_',num2str(f)],'-painters','-dpdf');
    %pause(0.02)
    %mov(f) = getframe(gcf);
end
% save([mfilename,'post'],'mov');