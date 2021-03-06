clear; close all; warning('off','all');

n = 20; 
x = linspace(0,1,n)';
y = @(x) sin(2*pi*x);
e = .2*randn(size(x));
t = y(x) + e;

Xp = linspace(x(1),x(end),200)';
figure;

for M = 1:20
    plot(Xp,y(Xp),'-');hold on; plot(x,t,'o');
    phi = @(a)(bsxfun(@power,a,0:M-1));
    phix = phi(x);
    
    W = ((phix'*phix)\phix')*t;
    
    hold on;
    phiXp = phi(Xp); Tp = phiXp*W;
    plot(Xp,Tp); axis([0 1 -1.5 1.5]); xlabel('x','Interpreter','latex'); ylabel('y','Interpreter','latex');
    legend('Deterministic', 'Data', 'Predicted'); hold off; pause(0.5);
end
warning('on','all'); print(mfilename,'-depsc');