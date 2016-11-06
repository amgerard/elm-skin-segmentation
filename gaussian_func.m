function result=gaussian_func(x,c,sig)

result=exp(-mean(abs((x-ones(size(x,1),1)*c)).^2,2)/sig^2);

