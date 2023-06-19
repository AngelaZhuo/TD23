function N_rep = CheckRepetitions(vector, max_reps)



for n=1:max_reps+1
    matrix(n,:)=vector(n:(end-max_reps)+n-1); 
end
    rep_vector=matrix(1,:)==sum(matrix,1)/(max_reps+1);
    
   N_rep=sum(rep_vector); 
%    keyboard
    

