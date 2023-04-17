
%% 一、预备函数
% 1.unique()取出唯一值
% 2.find()：找出满足给定条件的行索引
% 3.length()求矩阵长度
% 4.data(h,l)取出h行l列的数据，':'代表全部行(列)
% 5.时间加减法：t2 = t1 + calmonths(a)表示t2为t1加上a个月
% 6.矩阵合并A = [B C] or [B;C]，空格为行合并，分号为换行符号(列合并)
% 7.回归函数：regress(Y,X)；ones(h,l)建立h行l列全为1的矩阵；size()求矩阵/表等的大小
% 8.[b bint r rint stats]：b为回归所得系数；bint为系数区间估计；r/rint为残差及其区间估计；stats统计信息R2等
% 9.datestr()时间类型转字符串；datatime()将字符串转换为日期

%% 二、rolling regression 估计 Beta_TCCA
load TCCA_facotr_data.mat
load reg_data.mat
load rawdata.mat

PERMNO_axis = unique(rawdata.PERMNO);          %取出股票轴

TCCA_factor_all = [];

% Step 1：对股票做循环
for i = 1:length(PERMNO_axis)
    
    % 1.1取出当前股票的所有数据
    index_PER = find(reg_data.PERMNO == PERMNO_axis(i));
    PER_data = reg_data(index_PER,:);                         
    % 1.2取出当前股票时间轴
    date_axis = unique(PER_data.YM);

    % Step 2：对当前股票做monthly的时间循环
    TCCA_factor =[];
    for j = 1:length(date_axis)-11 
        % 2.1取出该股一年间的数据
        index_PER_data =find(PER_data.YM >= date_axis(j) & PER_data.YM <= date_axis(j+11));  
        PER_date_data = PER_data(index_PER_data,:);
        
        % 2.2取出对应的factor数据
        date_TCCA = date_axis(j+11)+calmonths(1);
        index_TCCA = find(TCCAfactordata.YM == date_TCCA);    
        TCCA_data = TCCAfactordata(index_TCCA,:);
        
        % 2.3 regress
        if length(TCCA_data.factor) == length(PER_date_data.RE)   %股票时间数据长度必须与当期factor长度相等
            Y = [PER_date_data.RE];                               %因变量
            X = [PER_date_data.MKT TCCA_data.factor];             %自变量
            [b bint r rint stats] = regress(Y,[ones(size(Y)),X]);
            TCCA_factor = [TCCA_factor;PERMNO_axis(i) datestr(date_TCCA,'yyyy-mm') b(3)];
        end

    end
    TCCA_factor_all = [TCCA_factor_all;TCCA_factor];

end
TCCA_factor_all  % TTCA的Beta————perfect reproduction