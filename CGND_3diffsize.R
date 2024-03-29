##################################################################################
# CGND_3diffsize: Circular Generalized neighbor design for block of three 
# different sizes (K1,k2 and k3)

# Algorithm from paper:

# Khadija Noreen, Muhammad Sajid Rashid, Farrukh Shehzad, Mahmood Ul Hassan, Zahra Noreen, Talha Omer and 
# Rashid Ahmed (2021). Algorithms to Obtain Generalized Neighbor Designs in 
# Minimal Circular Blocks. 
# Coded by Noreen et al., 2020-2021 
# Version 1.3.0  (2021-06-30)
#################################################################################




#################################################################################
# Selection of i group of size K1 from adjusted A. The set of remaining
# (Unselected) elements are saved in object B2. 
#################################################################################

grouping1<-function(A,k,v,i){
  bs<-c()
  z=0;f=1
  A1=A
  while(f<=i){
    
    for(y in 1:5000){
      com<-sample(A1,k)
      cs<-sum(com)
      if(cs%%v==0){
        bs<-rbind(bs,com)
        A1<-A1[!A1 %in% com]
        z<-z+1
        f=f+1
      }
      if(z==i) break
    }
    if(z<i) {bs<-c();z=0;f=1;A1=A}  
  }
  list(B1=bs,B2=A1)
}

#################################################################################
# Selection of i group of size K1 from adjusted A and selection of required 
# number of groups of size K2 from B2. The set of remaining (Unselected) 
# elements are saved in B3.
#################################################################################

grouping2<-function(A,k,v,i,sk2){
  bs1<-c()
  j=i+sk2
  z=0;f=1
  A1=A
  while(f<=j){
    s<-grouping1(A1,k[1],v,i)
    A2<-s$B2
    z=i;f=f+i
    for(y in 1:2000){
      com<-sample(A2,k[2])
      cs<-sum(com)
      if(cs%%v==0){
        bs1<-rbind(bs1,com)
        A2<-A2[!A2 %in% com]
        z<-z+1
        f=f+1
      }
      if(z==j) break
    }
    
    
    if(z<j) {bs1<-c();z=0;f=1;A1=A}  
    
  }
  
  list(B1=s$B1,B2=bs1,B3=A2)
}

#################################################################################
# Selection of i group of size K1 from adjusted A, selection of required number
# of groups of size K2 from B2 and division of required number of groups of size
# K3 from B3.
#################################################################################
grouping3<-function(A,k,v,i,sk2,sk3){
  bs1<-c()
  j=i+sk2+sk3
  z=0;f=1
  A1=A
  while(f<=j){
    s<-grouping2(A1,k,v,i,sk2)
    A3<-s$B3
    z=i+sk2;f=f+i+sk2
    for(y in 1:1000){
      com<-sample(A3,k[3])
      cs<-sum(com)
      if(cs%%v==0){
        bs1<-rbind(bs1,com)
        A3<-A3[!A3 %in% com]
        z<-z+1
        f=f+1
      }
      if(z==j) break
    }
    if(z<j) {bs1<-c();z=0;f=1;A1=A}  
  }
  
  gs1<-t(apply(s$B1,1,sort))
  gs1<-cbind(gs1,rowSums(gs1),rowSums(gs1)/v)
  rownames(gs1)<-paste("G",1:i, sep="")
  colnames(gs1)<-c(paste(1:k[1], sep=""),"sum" ,"sum/v")
  
  gs2<-t(apply(s$B2,1,sort))
  gs2<-cbind(gs2,rowSums(gs2),rowSums(gs2)/v)
  rownames(gs2)<-paste("G",(i+1):(i+sk2), sep="")
  colnames(gs2)<-c(paste(1:k[2], sep=""),"sum" ,"sum/v")
  
  
  gs3<-t(apply(bs1,1,sort))
  gs3<-cbind(gs3,rowSums(gs3),rowSums(gs3)/v)
  rownames(gs3)<-paste("G",(i+sk2+1):(i+sk2+sk3), sep="")
  colnames(gs3)<-c(paste(1:k[3], sep=""),"sum" ,"sum/v")
  
  
  fs1<-t(apply(s$B1,1,sort))
  fs1<-delmin(fs1)
  rownames(fs1)<-paste("S",1:i, sep="")
  colnames(fs1)<-rep("",(k[1])-1)
  
  fs2<-t(apply(s$B2,1,sort))
  fs2<-delmin(fs2)
  rownames(fs2)<-paste("S",(i+1):(i+sk2), sep="")
  colnames(fs2)<-rep("",(k[2])-1)
  
  
  fs3<-t(apply(bs1,1,sort))
  fs3<-delmin(fs3)
  rownames(fs3)<-paste("S",(i+sk2+1):(i+sk2+sk3), sep="")
  colnames(fs3)<-rep("",(k[3]-1))
  
  
  list(B1=fs1,B2=fs2,B3=fs3,B4=list(gs1,gs2,gs3),B5=A3)
}


#######################################################################
# Obtaing set(s) of shifts by deleting smallest value of each group
#######################################################################

delmin<-function(z){
  fs<-c()
  n<-nrow(z)
  c<-ncol(z)-1
  for(i in 1:n){
    z1<-z[i,]
    z2<-z1[z1!=min(z1)]
    fs<-rbind(fs,z2)
  }
  return(fs)
}


#################################################################################
# Selection of adjusted A and the set(s) of shifts to obtain Circular Generalized 
# neighbor design for three different block size.
##################################################################################

# D=1: Minimal CGNDs in which v/2 unordered pairs do not appear
# D=2: Minimal CGNDs in which 3v/2 unordered pairs do not appear 
#   K: Vector of three different block sizes
#   i: Number of sets of shifts for K1
# Sk2: Number of sets of shifts for K2
# Sk3: Number of sets of shifts for K3


CGND_3diffsize<-function(k,i,D,sk2,sk3){
  if(length(k)>3 | length(k)<3){stop("length(k)=3")}
  if(any(k<=2)!=0) stop("k=Block size: Each block size must be greater than 2")
  if(i<=0) stop("i=must be a positive integer")
  if(k[1]<k[2] | k[2]<k[3] |  k[1]<k[3]  ) stop("k1>K2>K3")

  setClass( "stat_test", representation("list"))
  
  setMethod("show", "stat_test", function(object) {
    row <- paste(rep("=", 52), collapse = "")
    cat(row, "\n")
cat("Following are required sets of shifts to obtain the 
minimal CGND for", "v=" ,object[[5]][1], ",","k1=",object[[5]][2],
",","k2=",object[[5]][3],"and","k3=",object[[5]][4],"\n")
    row <- paste(rep("=", 52), collapse = "")
    cat(row, "\n")
    print(object[[1]])
    cat("\n")
    print(object[[2]])
    cat("\n")
    print(object[[3]])
  })
  

if(D==1 & sk2==1 & sk3==1){  
    v=2*i*k[1]+2*k[2]+2*k[3]+2 ; m=(v-2)/2
    
if(m%%4==0){
      A<-1:m
      A1<-grouping3(A,k,v,i,sk2,sk3)
      A2<-c(v,k);names(A2)<-c("V","K1","K2","K3")
      x<-list(S1=A1$B1,S2=A1$B2,S3=A1$B3,G=A1$B4,R=A2,A=A)
    }
    
if(m%%4==3){
      A<-c(1:((3*m-1)/4),((3*m+7)/4),((3*m+11)/4):m, (5*(m+1)/4))
      A1<-grouping3(A,k,v,i,sk2,sk3)
      A2<-c(v,k);names(A2)<-c("V","K1","K2","K3")
      x<-list(S1=A1$B1,S2=A1$B2,S3=A1$B3,G=A1$B4,R=A2,A=A)
    }
    
if(m%%4==1 | m%%4==2){return("The minimal CGNDs in which v/2 unordered pair cannot be constructed for V=2ik1+2k2+2k3+2 and k1,k2 k3 block sizes")}
}  
   
  
  if(D==2 & sk2==1 & sk3==1){
    v= 2*i*k[1]+2*k[2]+2*k[3]+4 
    m<-(v-2)/2
    
    if(m%%4==0){
      A=c(1:(m/2),((m+4)/2),((m+6)/2):(m-1),((3*m+2)/2))
      A1<-grouping3(A,k,v,i,sk2,sk3)
      A2<-c(v,k);names(A2)<-c("V","K1","K2","K3")
      x<-list(S1=A1$B1,S2=A1$B2,S3=A1$B3,G=A1$B4,R=A2,A=A)

    }
    
    if(m%%4==1){
      A=c(1:((3*m+1)/4),((3*m+9)/4),((3*m+13)/4):(m-1),((5*m+3)/4))
      A1<-grouping3(A,k,v,i,sk2,sk3)
      A2<-c(v,k);names(A2)<-c("V","K1","K2","K3")
      x<-list(S1=A1$B1,S2=A1$B2,S3=A1$B3,G=A1$B4,R=A2,A=A)
    }
    
    if(m%%4==2){
      A=c(2:(m-2),m,(2*m+1))
      A1<-grouping3(A,k,v,i,sk2,sk3)
      A2<-c(v,k);names(A2)<-c("V","K1","K2","K3")
      x<-list(S1=A1$B1,S2=A1$B2,S3=A1$B3,G=A1$B4,R=A2,A=A)
    }
    
    if(m%%4==3){
      A=c(1:((m+1)/4),((m+9)/4),((m+13)/4):(m-2), m, ((7*m+3)/4))
      A1<-grouping3(A,k,v,i,sk2,sk3)
      A2<-c(v,k);names(A2)<-c("V","K1","K2","K3")
      x<-list(S1=A1$B1,S2=A1$B2,S3=A1$B3,G=A1$B4,R=A2,A=A)
    }
}   
    
 
if(D==1 & sk2==2 & sk3==2){  
  v=2*i*k[1]+4*k[2]+4*k[3]+2 ; m=(v-2)/2
  
  if(m%%4==0){
    A<-1:m
    A1<-grouping3(A,k,v,i,sk2,sk3)
    A2<-c(v,k);names(A2)<-c("V","K1","K2","K3")
    x<-list(S1=A1$B1,S2=A1$B2,S3=A1$B3,G=A1$B4,R=A2,A=A)
  }
  
  if(m%%4==3){
    A<-c(1:((3*m-1)/4),((3*m+7)/4),((3*m+11)/4):m, (5*(m+1)/4))
    A1<-grouping3(A,k,v,i,sk2,sk3)
    A2<-c(v,k);names(A2)<-c("V","K1","K2","K3")
    x<-list(S1=A1$B1,S2=A1$B2,S3=A1$B3,G=A1$B4,R=A2,A=A)
  }
  
  if(m%%4==1 | m%%4==2){return("The minimal CGNDs in which v/2 unordered pair cannot be constructed for V=2ik1+4k2+4k3+2 and k1,k2 k3 block sizes")}
}  


if(D==2 & sk2==2 & sk3==2){
  v= 2*i*k[1]+4*k[2]+4*k[3]+4  ;m<-(v-2)/2
  
  if(m%%4==0){
    A=c(1:(m/2),((m+4)/2),((m+6)/2):(m-1),((3*m+2)/2))
    A1<-grouping3(A,k,v,i,sk2,sk3)
    A2<-c(v,k);names(A2)<-c("V","K1","K2","K3")
    x<-list(S1=A1$B1,S2=A1$B2,S3=A1$B3,G=A1$B4,R=A2,A=A)
    
  }
  
  if(m%%4==1){
    A=c(1:((3*m+1)/4),((3*m+9)/4),((3*m+13)/4):(m-1),((5*m+3)/4))
    A1<-grouping3(A,k,v,i,sk2,sk3)
    A2<-c(v,k);names(A2)<-c("V","K1","K2","K3")
    x<-list(S1=A1$B1,S2=A1$B2,S3=A1$B3,G=A1$B4,R=A2,A=A)
  }
  
  if(m%%4==2){
    A=c(2:(m-2),m,(2*m+1))
    A1<-grouping3(A,k,v,i,sk2,sk3)
    A2<-c(v,k);names(A2)<-c("V","K1","K2","K3")
    x<-list(S1=A1$B1,S2=A1$B2,S3=A1$B3,G=A1$B4,R=A2,A=A)
  }
  
  if(m%%4==3){
    A=c(1:((m+1)/4),((m+9)/4),((m+13)/4):(m-2), m, ((7*m+3)/4))
    A1<-grouping3(A,k,v,i,sk2,sk3)
    A2<-c(v,k);names(A2)<-c("V","K1","K2","K3")
    x<-list(S1=A1$B1,S2=A1$B2,S3=A1$B3,G=A1$B4,R=A2,A=A)
  }
} 

  
  if(D==1 & sk2==1 & sk3==2){  
    v=2*i*k[1]+2*k[2]+4*k[3]+2 ; m=(v-2)/2
    
    if(m%%4==0){
      A<-1:m
      A1<-grouping3(A,k,v,i,sk2,sk3)
      A2<-c(v,k);names(A2)<-c("V","K1","K2","K3")
      x<-list(S1=A1$B1,S2=A1$B2,S3=A1$B3,G=A1$B4,R=A2,A=A)
    }
    
    if(m%%4==3){
      A<-c(1:((3*m-1)/4),((3*m+7)/4),((3*m+11)/4):m, (5*(m+1)/4))
      A1<-grouping3(A,k,v,i,sk2,sk3)
      A2<-c(v,k);names(A2)<-c("V","K1","K2","K3")
      x<-list(S1=A1$B1,S2=A1$B2,S3=A1$B3,G=A1$B4,R=A2,A=A)
    }
    
    if(m%%4==1 | m%%4==2){return("The minimal CGNDs in which v/2 unordered pair cannot be constructed for V=2ik1+2k2+4k3+2 and k1,k2 k3 block sizes")}
  }  
  
  
  if(D==2 & sk2==1 & sk3==2){
    v= 2*i*k[1]+2*k[2]+4*k[3]+4  ;m<-(v-2)/2
    
    if(m%%4==0){
      A=c(1:(m/2),((m+4)/2),((m+6)/2):(m-1),((3*m+2)/2))
      A1<-grouping3(A,k,v,i,sk2,sk3)
      A2<-c(v,k);names(A2)<-c("V","K1","K2","K3")
      x<-list(S1=A1$B1,S2=A1$B2,S3=A1$B3,G=A1$B4,R=A2,A=A)
      
    }
    
    if(m%%4==1){
      A=c(1:((3*m+1)/4),((3*m+9)/4),((3*m+13)/4):(m-1),((5*m+3)/4))
      A1<-grouping3(A,k,v,i,sk2,sk3)
      A2<-c(v,k);names(A2)<-c("V","K1","K2","K3")
      x<-list(S1=A1$B1,S2=A1$B2,S3=A1$B3,G=A1$B4,R=A2,A=A)
    }
    
    if(m%%4==2){
      A=c(2:(m-2),m,(2*m+1))
      A1<-grouping3(A,k,v,i,sk2,sk3)
      A2<-c(v,k);names(A2)<-c("V","K1","K2","K3")
      x<-list(S1=A1$B1,S2=A1$B2,S3=A1$B3,G=A1$B4,R=A2,A=A)
    }
    
    if(m%%4==3){
      A=c(1:((m+1)/4),((m+9)/4),((m+13)/4):(m-2), m, ((7*m+3)/4))
      A1<-grouping3(A,k,v,i,sk2,sk3)
      A2<-c(v,k);names(A2)<-c("V","K1","K2","K3")
      x<-list(S1=A1$B1,S2=A1$B2,S3=A1$B3,G=A1$B4,R=A2,A=A)
    }
  } 
  
  if(D==1 & sk2==2 & sk3==1){  
    v=2*i*k[1]+4*k[2]+2*k[3]+2 ; m=(v-2)/2
    
    if(m%%4==0){
      A<-1:m
      A1<-grouping3(A,k,v,i,sk2,sk3)
      A2<-c(v,k);names(A2)<-c("V","K1","K2","K3")
      x<-list(S1=A1$B1,S2=A1$B2,S3=A1$B3,G=A1$B4,R=A2,A=A)
    }
    
    if(m%%4==3){
      A<-c(1:((3*m-1)/4),((3*m+7)/4),((3*m+11)/4):m, (5*(m+1)/4))
      A1<-grouping3(A,k,v,i,sk2,sk3)
      A2<-c(v,k);names(A2)<-c("V","K1","K2","K3")
      x<-list(S1=A1$B1,S2=A1$B2,S3=A1$B3,G=A1$B4,R=A2,A=A)
    }
    
    if(m%%4==1 | m%%4==2){return("The minimal CGNDs in which v/2 unordered pair cannot be constructed for V=2ik1+4k2+2k3+2 and k1,k2 k3 block sizes")}
  }  
  
  
  if(D==2 & sk2==2 & sk3==1){
    v= 2*i*k[1]+4*k[2]+2*k[3]+4  ;m<-(v-2)/2
    
    if(m%%4==0){
      A=c(1:(m/2),((m+4)/2),((m+6)/2):(m-1),((3*m+2)/2))
      A1<-grouping3(A,k,v,i,sk2,sk3)
      A2<-c(v,k);names(A2)<-c("V","K1","K2","K3")
      x<-list(S1=A1$B1,S2=A1$B2,S3=A1$B3,G=A1$B4,R=A2,A=A)
      
    }
    
    if(m%%4==1){
      A=c(1:((3*m+1)/4),((3*m+9)/4),((3*m+13)/4):(m-1),((5*m+3)/4))
      A1<-grouping3(A,k,v,i,sk2,sk3)
      A2<-c(v,k);names(A2)<-c("V","K1","K2","K3")
      x<-list(S1=A1$B1,S2=A1$B2,S3=A1$B3,G=A1$B4,R=A2,A=A)
    }
    
    if(m%%4==2){
      A=c(2:(m-2),m,(2*m+1))
      A1<-grouping3(A,k,v,i,sk2,sk3)
      A2<-c(v,k);names(A2)<-c("V","K1","K2","K3")
      x<-list(S1=A1$B1,S2=A1$B2,S3=A1$B3,G=A1$B4,R=A2,A=A)
    }
    
    if(m%%4==3){
      A=c(1:((m+1)/4),((m+9)/4),((m+13)/4):(m-2), m, ((7*m+3)/4))
      A1<-grouping3(A,k,v,i,sk2,sk3)
      A2<-c(v,k);names(A2)<-c("V","K1","K2","K3")
      x<-list(S1=A1$B1,S2=A1$B2,S3=A1$B3,G=A1$B4,R=A2,A=A)
    }
    
  } 
new("stat_test", x)  
}



###############################################################################
# Examples: Using CGND_3diffsize function to obtain the set(s) of shifts
# for construction of circular Generalized neighbor design for block of 
# three different sizes (k1, K2 and k3)
###############################################################################



# Example#1
CGND_3diffsize(k=c(12,7,4),i=5,D=1,sk2=1,sk3=1)

#Example#2
CGND_3diffsize(k=c(8,5,4),i=6,D=2,sk2=1,sk3=1)

#Example#3
CGND_3diffsize(k=c(11,8,4),i=5,D=1,sk2=2,sk3=2)


#Example#4
CGND_3diffsize(k=c(9,7,6),i=3,D=2,sk2=2,sk3=2)


#Example#5
CGND_3diffsize(k=c(8,6,4),i=5,D=2,sk2=1,sk3=2)


#Example#6
CGND_3diffsize(k=c(14,7,4),i=6,D=2,sk2=2,sk3=1)















