clc;
clear;

%%
stock=table2array(readtable("주식자료.xlsx"));
st5=stock(:,4:end);

Rtn_st5=log(st5(2:end,:))-log(st5(1:end-1,:));

%% 1-1 각 주식에 1년 투자했을 때 기대수익률과 Volatility
Rst1_1=zeros(5,2);

for i=1:1:5
    mu=mean(Rtn_st5(:,i));  
    sigma=std(Rtn_st5(:,i));  
    Rst1_1(i,1)=(mu-(sigma^2)/2)*252;
    Rst1_1(i,2)=sigma*sqrt(252);
end

Rst1_1

% 기대수익률, Volatility
% SK하이닉스: 0.057629499287402 , 0.712799934302223
% 현대차: -0.583211229438453, 0.632921186129714
% LG화학: 0.621491447362059, 0.711288055089292
% 신한지주: -0.142403385574709, 0.505927098259309
% POSCO: -0.231447342914641, 0.623167526667060

%% 1-2 Equally Weighted Portfolio 기대수익률과 Volatility
E_wgt=ones(5,1)*0.2;

Rtn_EWP=Rtn_st5*E_wgt;

Rst1_2E=zeros(1,2);

mu_EW=mean(Rtn_EWP);
sigma_EW=std(Rtn_EWP);

Rst1_2E(1,1)=(mu_EW-(sigma_EW^2)/2)*252;
Rst1_2E(1,2)=sigma_EW*sqrt(252);

Rst1_2E

% 기대수익률: 0.080344780368278
% Volatility: 0.374051825369632

%% Value Weighted Portfolio 기대수익률과 Volatility
Mrk_Cap = [621714; 213668; 361433; 147038; 166091];
V_wgt=Mrk_Cap/sum(Mrk_Cap);

Rtn_VWP=Rtn_st5*V_wgt;

Rst1_2V=zeros(1,2);

mu_VW=mean(Rtn_VWP);
sigma_VW=std(Rtn_VWP);

Rst1_2V(1,1)=(mu_VW-(sigma_VW^2)/2)*252;
Rst1_2V(1,2)=sigma_VW*sqrt(252);

Rst1_2V

% 기대수익률: 0.192707781027106
% Volatility: 0.412913327414191

%% 1-3 1억원을 위의 5개의 주식에 동일 가중치로 포트폴리오를 구성할 경우 
% 4주의 99% VaR를 두 가지 방식 (시뮬레이션 이용, 주식수익률의 Normal 가정 이용)으로 계산
% 시뮬레이션

NS=1000;
NT=21;

Rst1_3=zeros(NT+1,NS);
Rst1_3(1,:)=1;
rng(20174784)

for i=1:NS
    Rst1_3(2:end,i)=cumprod(Rtn_EWP(randi(207,21,1),1)+1);
end

prctile(Rst1_3(end,:),[1 5 95 99])
% EWP 4주 99% VaR: 24027931원

%%
%주식수익률의 Normal 가정
ER_4W_EWP=(mean(Rtn_EWP)-std(Rtn_EWP)^2/2)*252;

Var_RTN=cov(Rtn_st5);
Var_EWP=E_wgt'*Var_RTN*E_wgt;

VaR_4W_99_EWP=sqrt(Var_EWP)*sqrt(21)*norminv(0.99)
% EWP 4주 99% VaR: 25119779원

%% 1-4 1억원을 위의 5개의 주식에 가치 가중치로 포트폴리오를 구성할 경우 
% 4주의 99% VaR를 두 가지 방식 (시뮬레이션 이용, 주식수익률의 Normal 가정 이용)으로 계산
% 시뮬레이션
NS=1000;
NT=21;

Rst1_4=zeros(NT+1,NS);
Rst1_4(1,:)=1;
rng(20174784)

for i=1:NS
    Rst1_4(2:end,i)=cumprod(Rtn_VWP(randi(207,21,1),1)+1);
end

prctile(Rst1_4(end,:),[1 5 95 99])
% VWP 4주 99% VaR: 24226125원

%%
%주식수익률의 Normal 가정
ER_4W_VWP=(mean(Rtn_VWP)-std(Rtn_VWP)^2/2)*252;

Var_RTN=cov(Rtn_st5);
Var_VWP=V_wgt'*Var_RTN*V_wgt;

VaR_4W_99_VWP=sqrt(Var_VWP)*sqrt(21)*norminv(0.99)
% VWP 4주 99% VaR: 27729557원

%% 2 가장 위험이 작은 포트폴리오를 추천하라.
% 1) 포트폴리오(1년) 기대수익률은 6% 이상이다.
% 2) Short-Seling(공매도)는 존재하지 않는다.

% 1-1 중 기대 수익률이 6% 이상 인 것 (Volatility): LG화학 (0.711288055089292)
% 1-2 EWP 기대수익률이 6%이상, Volatility: 0.374051825369632
% 1-2 VWP 기대수익률이 6%이상, Volatility: 0.412913327414191
% 위의 과정 중에서는 EWP가 위험성이 가장 낮은 것으로 나타났다. 

rng(20174784)
random=rand(5,10000);
rand_wgt=zeros(5,10000);
for i=1:1:10000
	for j=1:1:5
	rand_wgt(j,i)=random(j,i)/sum(random(:,i));
	end
end

Rtn_MWP=Rtn_st5*rand_wgt;

Rst2=zeros(10000,2);

mu_MW=mean(Rtn_MWP);
sigma_MW=std(Rtn_MWP);

for i=1:10000
    Rst2(i,1)=(mu_MW(1,i)-(sigma_MW(1,i)^2)/2)*252;
    Rst2(i,2)=sigma_MW(1,i)*sqrt(252);
end

%%
Rst2_1=Rst2(Rst2(:,1)>=0.06,:);

min_vol=min(Rst2_1(:,2));
% Volatility=0.364341539093270

[i,j]=find(Rst2(:,2)==min_vol)
% 원래 데이터의 8819번째 행에서 위험이 가장 작은 포트폴리오가 나타난다.

Rst2(i,:)
%기대수익률:0.075546152020839, Volatility:0.364341539093270

rand_wgt(:,i)
% SK하이닉스: 0.222338327902989
% 현대차: 0.172833224524742
% LG화학: 0.168295174538500
% 신한지주: 0.346041120137474
% POSCO: 0.090492152896295
% 위의 가중치로 포트폴리오가 구성되었을 때,
% 기대 수익률이 6%이상을 만족하는 가장 위험이 작은 포트폴리오이다. 








