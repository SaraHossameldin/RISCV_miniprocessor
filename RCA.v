module RCA #(parameter n=32)
(
   input [n-1:0] a,
   input cin,
   input[n-1:0]b,
   output cout,
   output [n-1:0] sum);
   wire [n:0] carry;
   
   assign carry[0]=cin;

   genvar i;
   generate for(i=0;i<n;i=i+1)
   begin: FA_Block
    full_adder mena(.a(a[i]),.b(b[i]),.cin(carry[i]),.cout(carry[i+1]),.sum(sum[i]));
   end
   endgenerate 
   assign cout=carry[n];
endmodule
