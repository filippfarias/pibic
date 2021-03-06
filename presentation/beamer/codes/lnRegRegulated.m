clear; close all; warning('off','all');

n = 10; 
x = linspace(0,1,n)';
y = @(x) sin(2*pi*x);
e = .2*randn(size(x));
t = y(x) + e;

Xp = linspace(x(1),x(end),200)';
figure;
style = ['scale=0.075\linewidth,'...
                       'legend style={nodes={scale=0.5, transform shape}},',...
                       ];

lnlambda = -[linspace(1e6,1e5,25), linspace(5e1,1,25+30), linspace(1,0,20)];

for i = 1:100
    M = n;
    plot(Xp,y(Xp),'-');hold on; plot(x,t,'o');
    phi = @(a)(bsxfun(@power,a,0:M-1));
    phix = phi(x);
    
    W = ((phix'*phix+exp(lnlambda(i))*eye(n))\phix')*t;
    
    hold on;
    phiXp = phi(Xp); Tp = phiXp*W;
    plot(Xp,Tp); axis([0 1 -1.5 1.5]); xlabel('x','Interpreter','latex');
    ylabel('y','Interpreter','latex');
    legend('Deterministic', 'Data', 'Predicted'); title(['$\ln \lambda =$ ',...
        num2str(lnlambda(i)),' $|$ $M =$ ',num2str(M)],'Interpreter','latex');
    hold off; pause(0.005);
    matlab2tikz([mfilename,'/',mfilename,'_','frame_',num2str(i),'.tex'],'width','0.075\linewidth',...
        'showInfo', false,'extraaxisoptions', style);
end
warning('on','all'); %print(mfilename,'-depsc');