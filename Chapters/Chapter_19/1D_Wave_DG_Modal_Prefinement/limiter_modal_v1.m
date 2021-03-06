%---------------------------------------------------------------------%
%This function computes the LGL grid and elements.
%Written by F.X. Giraldo on 10/2003
%           Department of Applied Mathematics
%           Naval Postgraduate School 
%           Monterey, CA 93943-5216
%---------------------------------------------------------------------%
function [limit_element,qp] = limiter_modal(qp,nelem,ngl,nq,L,Ls,dx,xmu)

%Initialize
limit_element=zeros(nelem,1);
dx_p=dx^(ngl/2);
tol=1;

%Integrate Flux Terms
for ie=1:nelem
   iel=ie-1;
   ier=ie;
   if (ie == 1) 
      iel=nelem;
   end 
   ie;
   icheck=1;
   
   ibeg=1; iend=ngl;
   iterations=0;
   while icheck >= tol
       
       iterations=iterations + 1;
       
       %Interpolate F (via q) onto element side/interface/edges
       q_l=0; q_r=0;
       for i=1:ngl
           q_l=q_l + Ls(i,2)*qp(i,iel);
           q_r=q_r + Ls(i,1)*qp(i,ier);
       end

       %Compute Average Q at Integration Points
       q_average=0;
       for k=1:nq
          q_k=0;
          for j=1:ngl
              q_k=q_k + L(j,k)*qp(j,ie);
          end
          q_average=q_average + q_k/nq;
       end %l

       %icheck=abs(q_r - q_l)/(q_average);
       %icheck=abs(q_r - q_l);
       icheck=abs(q_r - q_l)/(dx_p);
       %limit_element(ie)=icheck;
       if icheck >= tol
           limit=1;
       else
           limit=0;
       end

       if iterations == 1
           limit_element(ie)=limit;
       end
       
       limit;
       
       %Limit Solution
       if limit == 1 
        for i=1:ibeg
            weight(i)=1;
        end
        for i=ibeg+1:iend
            %weight(i)=1.0 - ((i-ibeg)/(iend-ibeg))^2.5;
            %weight(i)=1.0 - ((i-ibeg)/(iend-ibeg))^iend;
            weight(i)=1.0 - ((i-ibeg)/(iend-ibeg))^(iend+1);
        end
        for i=iend+1:ngl
            weight(i)=0;
        end
        qp(:,ie)= weight(:).*qp(:,ie);
        iend=iend - 1;
        iend_min=round(ngl/2);
        %iend_min=2;
        %iend=max(iend_min,1);
        if iend == iend_min
            icheck = 0;
        end
       end %if
       
   end %while
   
end %ie
