clear; close all; warning('off','all'); %Wmod = [];

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

for M = 1:100
    plot(Xp,y(Xp),'-');hold on; plot(x,t,'o');
    phi = @(a)(bsxfun(@power,a,0:M-1));
    phix = phi(x);
    
    W = ((phix'*phix)\phix')*t;
    
    hold on; %Wmod = [Wmod; log(norm(W))];
    phiXp = phi(Xp); Tp = phiXp*W;
    plot(Xp,Tp); axis([0 1 -1.5 1.5]); xlabel('x','Interpreter','latex'); ylabel('y','Interpreter','latex');
    legend('Deterministic', 'Data', 'Predicted'); title(['$M=$ ',num2str(M)],'Interpreter','latex');
    hold off; %pause(0.1);
    matlab2tikz([mfilename,'/',mfilename,'_','frame_',num2str(M),'.tex'],'width','0.075\linewidth',...
        'showInfo', false,'extraaxisoptions', style);

end
%warning('on','all'); print(mfilename,'-depsc');
% style = ['scale=\fwidth,'...
%                        'legend style={nodes={scale=0.5, transform shape}},',...
%                        ];
% matlab2tikz([mfilename,'.tex'],'width','\fwidth',...
%     'showInfo', false,'extraaxisoptions', style); close all;
% figure; semilogy([0:M-1]',Wmod); xlabel('M','Interpreter','latex'); ylabel('\bf ||w_{ML}||'); grid on;
% warning('on','all'); print([mfilename,'-Wmod'],'-depsc');
% matlab2tikz([mfilename,'-Wmod','.tex'],'width','\fwidth',...
%     'showInfo',false,'extraaxisoptions',style);