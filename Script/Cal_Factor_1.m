function [Factor_Result1,Factor_Result2] = Cal_Factor_1(data,Var_startIndex,weight1,weight2,name,p,o,q,numfactors)
% Cal_Factor_1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% �̶�parameters
% ����ǲ��ù̶���parameters����1-9���log price�����parameters�����������ù̶��Ĳ�������
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
% 1
% new data 
newData=[];
for i=260:Var_lens
   for j=1: Var_cols
       tempData=data(i-259:i,j);
        mu=mean(tempData);
        epsilon=bsxfun(@minus,tempData(end,:,:),mu);
        newData(i-259,j)=epsilon;
   end
end
[PARAMETERS,HT,W,PC]= o_mvgarch(newData,numfactors,p,o,q);

paraW=[];
paraA=[];
paraB=[];
for i=1:numfactors;
    paraW(i)=PARAMETERS((i-1)*3+1);
    paraA(i)=PARAMETERS((i-1)*3+2);
    paraB(i)=PARAMETERS((i-1)*3+3);
end
paraW=paraW';
paraA=paraA';
paraB=paraB';
 
%2
for i=Var_startIndex:Var_lens
    index=i-Var_startIndex+1;  
   
    m_new2=newData(i-520:i-259,:);
    
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
end 
% ���������ļ�
if ~isempty(weight2)
    save(strcat('../Result/',name,'_Factor',num2str(p),num2str(o),num2str(q),'_1_Defensive'),'Factor_Result1');
    save(strcat('../Result/',name,'_Factor',num2str(p),num2str(o),num2str(q),'_1_Offensive'),'Factor_Result2');   
else
    save(strcat('../Result/',name,'_Factor',num2str(p),num2str(o),num2str(q),'_1'),'Factor_Result1');
end
