function [Factor_Result1,Factor_Result2] = Cal_Factor_Every(data,Var_startIndex,weight1,weight2,name,p,o,q,numfactors)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ��̬parameters���Լ�����Ht&Rt
% ����ǲ��ö�̬��parameters����parameters����ÿ�����ݵ�ǰ9��������
% Ht��Rt�����Լ����㷽ʽ��
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
numfactors=3;
if isempty(p)
    p=1;
end
if isempty(o)
    o=0;
end
if isempty(q)
    q=1;
end
if isempty(Var_startIndex)
    Var_startIndex=2349;
end

[Var_lens,Var_cols]=size(data); %
k=Var_cols;
if ~isempty(numfactors) && numfactors>k    
    error('numfactors����ά����');
end
% new data 
newData=[];
for i=260:Var_lens
   for j=1: Var_cols
       tempData=data(i-259:i,j);
        Cov_PF=cov(tempData);  
        mu=mean(tempData);
        epsilon=bsxfun(@minus,tempData(end,:,:),mu);
        newData(i-259,j)=epsilon;
   end
end
% save Factor Result
Equity_Factor_PARAMETERS=[];
ht=[];
for i=Var_startIndex:Var_lens
    index=i-Var_startIndex+1; 
       
    mData=newData(index+261*5:index+261*8,:);
    m_new2=newData(i-520:i-259,:);
   [PARAMETERS,HT,W,PC]= o_mvgarch(mData,numfactors,p,o,q);
    Equity_Factor_PARAMETERS(:,:,index)=PARAMETERS;
    paraW=[];
    paraA=[];
    paraB=[];
    for i2=1:numfactors;
        paraW(i2)=PARAMETERS((i2-1)*3+1);
        paraA(i2)=PARAMETERS((i2-1)*3+2);
        paraB(i2)=PARAMETERS((i2-1)*3+3);
    end
    paraW=paraW';
    paraA=paraA';
    paraB=paraB';
     [w, pc] = pca(m_new2,'outer');

    weights = w(:,1:numfactors);	
   
   errors=[];
   for t=1:262
    F = pc(t,1:numfactors);
    erros=bsxfun(@minus,m_new2(t,:)',weights*F');
    errors(t,:)=erros';
   end
   H_omega=cov(errors);
    omega=diag(H_omega,0);   
    omega=diag(omega);
    omega=omega-weights*paraW*paraW'*weights';
    Ht=cov(F);
    ht=diag(Ht,0);
    
    ft=F(end,:,:);
    ft=ft';
    
    htsub1=bsxfun(@times,paraA,ft.^2);

    htsub2=bsxfun(@times,paraB,ht);

    ht1=bsxfun(@plus,paraW,htsub1);
 
    ht1=bsxfun(@plus,ht1,htsub2);
    Ht1=diag(ht1);
 
    H_Factor=weights * Ht1 * weights' + omega;   
    Factor_Result1(index)=sqrt(weight1'*H_Factor*weight1);
    if ~isempty(weight2)
        Factor_Result2(index)=sqrt(weight2'*H_Factor*weight2);
    end
   disp(i);
end 
% save Factor Result 
save(strcat('../modelResults/',name,'_Factor',num2str(p),num2str(o),num2str(q),'_PARAMETERS'),'Equity_Factor_PARAMETERS');
% ���������ļ�
if ~isempty(weight2)
    save(strcat('../Result/',name,'_Factor',num2str(p),num2str(o),num2str(q),'_Every_Defensive'),'Factor_Result1');
    save(strcat('../Result/',name,'_Factor',num2str(p),num2str(o),num2str(q),'_Every_Offensive'),'Factor_Result2');   
else
    save(strcat('../Result/',name,'_Factor',num2str(p),num2str(o),num2str(q),'_Every'),'Factor_Result1');
end


