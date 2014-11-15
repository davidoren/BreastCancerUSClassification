function [u,c,visconst,viscolor,err,it] = multiseg(h,W,lambda,maxit,tol)
%multiphase grayscale segmentation algorithm
%INPUT:
%h: input image
%W: number of regions
%lambda: data fidelity parameter
%maxit: %upper bound on iterations. try 150 or so
%tol: stop when change in regions is smaller than tol.  try 10 or so
%try W = 2, lambda=.05, h not too big of an image...
%OUTPUT:
%u: segmented regions
%c: average intensities in each region
%visconst: visualize c in each region
%viscolor: false color visualization
%err: change in primal variable
%it: number of iterations out of maxit

%load image or get from input
[M,N] = size(h);

%set parameters
mu = 1*ones(1,W); %length penalty parameters (best left at 1)
lam = lambda*mu/W/sqrt(M*N); %data fidelity parameters
stop = 0; %set to one when done

%define discrete gradient D
[D,DT,E,ET] = define_discrete_gradient(M,N);

%vectorize h
hv = reshape(h,M*N,1); %(note k = (J-1)*M + I)
m = M*N;

%define linear term and region constants
c = min(hv) + (max(hv)-min(hv))*(0:(1/(W-1)):1);
fv = (repmat(hv,1,W)-repmat(c,m,1)).^2*diag(lam);

%initialization of regions (primal vars), constants, data and dual vars
[~,fMind] = min(fv,[],2);
uv_new = zeros(M*N,W);
uv_new((1:m)' + (fMind-1)*m) = 1;
c = hv'*uv_new./(sum(uv_new,1)+sqrt(eps));
fv = (repmat(hv,1,W)-repmat(c,m,1)).^2*diag(lam);
pv_new = zeros(size(D,1),W);
pv_old = pv_new;

%algorithm parameter selection
fac = 1; %fudge factor may affect rate of convergence
step = .995/(sqrt(8*W));
a = fac*step;
del = step/fac;

%iterate
it = 1;
while (it <= maxit && ~stop)
    %it
    %track old values
    pv_older = pv_old;
    uv_old = uv_new;
    pv_old = pv_new;
    
    %primal step
    u_stuff = uv_old - a*DT*(2*pv_old-pv_older) - a*fv;
    uv_new = projl1p(u_stuff',1)'; %project onto nonnegative l1-ball
    
    %dual step
    step = pv_old + del*D*uv_new;
    pv_new = step./(E*max(sqrt(ET*step.^2)./mu(ones(M*N,1),:),1)); %project onto unit ball in E* norm
    
    %update constants and fv
    c = hv'*uv_new./(sum(uv_new,1)+sqrt(eps));
    fv = (repmat(hv,1,W)-repmat(c,m,1)).^2*diag(lam);
    
    %is stuff changing
    dut = abs(uv_new - uv_old);
    err = sum(dut(:))
    if (err < tol && it > 10) %do at least 10 its, then stop if err < tol
        stop = 1;
    end
    
    it = it + 1;
end
it = it - 1;

%visualization of result
%choose max instead of thresholding
[~,Mi] = max(uv_new,[],2);
uv = zeros(M*N,W);
uv((1:M*N)' + (Mi-1)*M*N) = 1;
visconst = reshape(sum(uv.*repmat(c,m,1),2),M,N);
%reshape uv_new into images of regions u
u = reshape(uv,M,N,W);
%false color visualization
colors = .7*(0:1/(W-1):1)';
temp = reshape(uv*colors,M,N);
viscolor = abs(hsv2rgb(temp,ones(size(h)),h/max(hv)));
viscolor = viscolor/max(viscolor(:));

    function [D,DT,E,ET] = define_discrete_gradient(M,N)
        %define gradient as edge-node adjacency matrix
        [J,I] = meshgrid(1:N,1:M);        
        hnodes = (1:M*N)';
        Dex = 1:M*(N-1);
        hex = M*(N-1);
        Dedge(1:hex) = 1:hex;
        Dnode(1:hex) = hnodes(Dex+M);
        Ds(1:hex) = 1;
        Dedge(hex+1:2*hex) = 1:hex;
        Dnode(hex+1:2*hex) = hnodes(Dex);
        Ds(hex+1:2*hex) = -1;
        Dey = reshape((J(1:end-1,:)-1)*M+I(1:end-1,:),(M-1)*N,1);
        hey = (M-1)*N;
        Dedge(2*hex+1:2*hex+hey) = hex+1:hex+hey;
        Dnode(2*hex+1:2*hex+hey) = hnodes(Dey+1);
        Ds(2*hex+1:2*hex+hey) = 1;
        Dedge(2*hex+hey+1:2*hex+2*hey) = hex+1:hex+hey;
        Dnode(2*hex+hey+1:2*hex+2*hey) = hnodes(Dey);
        Ds(2*hex+hey+1:2*hex+2*hey) = -1;
        D = sparse(Dedge,Dnode,Ds,hex+hey,M*N); %includes also nodes without edges (if any)
        DT = D';
        E = (D==-1);
        ET = E';
        %edges = 2*M*N - M - N;       
    end

    function z = projl1p(sz,a)
        %orthogonal projection of one or more vectors onto nonnegative face of l1 a-ball
        %sz = matrix with columns to be projected
        %a = ball radius
        %version 3: removed superfluous sort
        [len,vecs] = size(sz);
        
        %length 1 special case
        if (len==1)
            z = a*ones(1,vecs);
            return
        end
        
        %initializations
        C = zeros(1,vecs);
        rind = (1:len)'; %column vector of row indices
        cind = (1:vecs); %row vector of column indices
        Row = rind(rind,ones(1,vecs)); %matrix of row indices
        Col = cind(ones(len,1),cind); %matrix of column indices
        z = zeros(len,vecs);
        
        %sort down the columns
        [sz,SI] = sort(sz,1); %also keep track of sorting indices
        SI = SI + len*(Col-1);
        
        %build cumsum matrix (value of sum from current row to end in that column)
        S = cumsum(sz(end:-1:1,:));
        S = S(end:-1:1,:);
        
        %set km and kM (these are actually row indices, different for each column)
        km = ones(1,vecs);
        kM = len*ones(1,vecs);
        k = km;
        
        %either km is strict lower bound or column is done
        %project onto planes at km=1 threshold (all columns active)
        thr = (S(1,:)-a)/len;
        p = sz - thr(ones(len,1),cind);
        
        %if >= 0 then column no longer active
        Y = min(p,[],1)<0;
        
        %if column done already then set kM = km
        kM(~Y) = km(~Y);
        
        %bisect to find threshold k
        act = sum(Y);
        while ( act > 0 )
            %bisect (ceil to integer)
            k(Y) = ceil((kM(Y)+km(Y))/2);
            
            %get indices
            ind = len*(cind(Y)-1)+k(Y);
            
            %check condition for each active column
            C(Y) = sz(ind)-(S(ind)-a)./(len-k(Y)+1)<0;
            
            %if negatives, increase km, othersise decrease kM
            km(Y&C) = k(Y&C);
            kM(Y&~C) = k(Y&~C);
            
            %column done if kM = km + 1 (update Y and act)
            Y(Y) = kM(Y)-km(Y)-1~=0;
            act = sum(Y);
        end
        
        %apply threshold kM to sz
        ind = len*(cind-1)+kM;
        thr = (S(ind)-a)./(len-kM+1);
        p = sz - thr(ones(len,1),cind);
        p = p.*(Row >= kM(ones(len,1),cind)); %threshold
        
        %return z
        z(SI) = p;
    end
end