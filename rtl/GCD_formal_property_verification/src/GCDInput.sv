typedef enum {low, med, high} SumSize; 

class GCDInput; 

rand integer a_in;
rand integer b_in;
//constraint max_size  {a_in <= 500;  0<=b_in && b_in <= 504;}
constraint max_size {a_in <= 500; b_in >= 0; a_in+b_in==500;} 
endclass

class GCDInputSegmented;
rand integer a_in;
rand integer b_in;
rand SumSize mysize;

constraint max_size
{
 (mysize==low)  -> a_in+b_in inside {[0:500]};
 (mysize==med)  -> a_in+b_in inside {[501:1000]};
 (mysize==high) -> a_in+b_in >= 1001;
}
endclass
