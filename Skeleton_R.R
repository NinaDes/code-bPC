Skeleton_R <- function(data,   # data
                       alpha,  # pvalue for CI test
                       p){     # num of permutation in dcov.test
  
  n = ncol(data)
  G = diag(x = -1, nrow = n, ncol = n)+1 # graph matrix with 0 on the diagonal
  
  sepstep = list()  # I create the separation list
  
  check = hash()
  
  for(i in 1:n)
  {
    sepstep[[i]]  = list()    
    
  }
  
  
  for (N in 0:n) # for each N = dimension subset to be taken
  {
    
    if(N!=0)
    {
      G_old = G
      print(N)

        for (i in 1:n) # for each node i
        {    
          print(i)
          ad = adiac_D(G_old, i)   # I look for the adjacent (double arrow)  OUTPUT: POSITION
          
          n_ad = length(ad)
          
          if((n_ad-1)>=N) # if card of adj > N
          {
            for ( j in 1:n_ad) # for each node adjac to i
              # if n_ad = 0, then n_ad -1 is NEVER  > N, so I don't enter here 
            {
              if(n_ad==2)
              {
                sub = c(ad[3-j]) # because if combn(8, 1) return: 1, 2, 3, 4, 5, 6, 7, 8
                sub = as.matrix(sub)
              }
              else
              {
                sub = combn(c(ad[-c(which(ad==ad[j]))]), N) # all the subset of dimension N of the different POSITION of nodes
              }
              k = 1
              while(k<=ncol(sub) && G[i, ad[j]]==1 ) # while there are other subset to investigate for c.i. AND I still haven't found a subset for which i is indip to adj[j] given subset
              {
                
                a = c(i, ad[j])
                a = sort(a)
                a = paste(a, collapse="_")
                
                b = sort(sub[1:N, k])
                b = paste(b, collapse="_")
                
                long = paste(a, b, sep='x')
                
                if( is.numeric(check[[long]]) == F )
                {
                
                dep = condIndepTestBr(x= data[,i], y= data[,ad[j]], z = data[, sub[1:N , k] ], p = p)
                print(paste('I test', i , 'and', ad[j], 'given',sub[1:N , k]))
                print(paste('p value =',dep))
                
                
                
                  if (dep > alpha) # if pval > alpha, I DON'T refuse H0 => i and adj[j] are c.i.
                  {
                    G[i, ad[j]] = 0
                    G[ad[j], i] = 0
                    sepstep[[i]][[ad[j]]] = sub[1:N,k]
                    sepstep[[ad[j]]][[i]] = sub[1:N,k]              
                  }
                check[[long]]=dep  
                }
                k = k+1
              } # chiude while
              
            } # chiude for ( j in 1:n_ad) 
          } # chiude if((n_ad-1)>=N)  
        } # chiude for (i in 1:n)
    
      

      
    } # chiude if N!=0
    
    else
    {
      print(N)
      for ( i in 1:n)
      {
        print(i)
        ad = adiac_D(G, i)   # I look for the adjacent (double arrow)  OUTPUT: POSITION
        
        n_ad = length(ad)
        
        if((n_ad-1)>=N) # if card of adj > N
        {
          for ( j in 1:n_ad) # for each node adjac to i
            # if n_ad = 0, then n_ad -1 is NEVER  > N, so I don't enter here 
          {
            
            a = c(i, ad[j])
            a = sort(a)
            a = paste(a, collapse="_")
            
            b = NULL
            b = paste(b, collapse="_")
            
            long = paste(a, b, sep='x')
            
            if( is.numeric(check[[long]]) == F )
            {
            
            
            # test = gaussCItest(x = i, y = ad[j], S = NULL, suffStat = suffst )
            dep = IndepTestBr(x = data[,i], y = data[, ad[j]], p = p)
            
              if (dep > alpha) # if pval > alpha, I DON'T refuse H0 => i and adj[j] are c.i.
              {
                G[i, ad[j]] = 0
                G[ad[j], i] = 0
                sepstep[[i]][[ad[j]]] = -1 # it's a  default value because it will never exist a variable in the -1 position
                sepstep[[ad[j]]][[i]] = -1 # it's a  default value because it will never exist a variable in the -1 position
                
              }
            check[[long]]=dep  
            }
            
          }
        }  
      }
      
    }
    
  }
  
  Sk = list(sepstep = sepstep, G = G, pval = check)
  Sk
  
  
  
}

