set N;
param x{n in N};
param y{n in N};

param d{n1 in N, n2 in N} := round(sqrt( (x[n1] - x[n2])**2 + (y[n1] - y[n2])**2) + 0.5);

param i;

param num := sum{n1 in N} 1;

param r{n in N};

param c;

var v{N}, binary;
var a{N,N}, binary;
var u{N};

maximize cost: sum{n in N} r[n] * v[n];
s.t. one_per_node{n1 in N}: sum{n2 in N} a[n1,n2] = sum{n2 in N} a[n2,n1];
s.t. no_loops{n1 in N}: sum{n2 in N} a[n1,n2] <= 1;
s.t. initial: sum{n in N} a[i,n] = 1;
s.t. max_cost: sum{n1 in N, n2 in N} a[n1,n2]*d[n1,n2] <= c;
s.t. used_node{n1 in N}: v[n1] = sum{n2 in N} a[n1,n2];


s.t. mtz1: u[i] = 1;
s.t. mtz2{n in N}: u[n] <= num;
s.t. mtz3{n in N}: u[n] >= (if n == i then 1 else 2);
#s.t. mtz4{n1 in N, n2 in N}: a[n1,n2]*u[n2] >=  if n2 == i then a[n1,n2] else a[n1,n2]*(u[n1]+1)
#s.t. mtz4{n1 in N, n2 in N}: u[n1] - u[n2] + 1 <= (num - 1)*(1 - a[n1,n2]);
s.t. mtz4{n1 in N, n2 in N}: (if n1 == i or n2 == i then 0 else (u[n1] - u[n2] + 1)) <= (if n1 == i or n2 == i then 0 else (num - 1)*(1 - a[n1,n2]));

#s.t. no_subtour: sum{n1 in N, n2 in N} a[n1,n2] = sum{n in N}(v[n]);
end;