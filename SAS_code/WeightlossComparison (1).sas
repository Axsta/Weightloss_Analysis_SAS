
/* importing the file */
proc import datafile= "/folders/myfolders/Data_082020/Weight_loss.xlsx"
out= wl0 dbms=xlsx replace;
run;

proc means data= wl0 n mean stddev min max maxdec=2 ;
run;


proc freq data= wl0;
run;

data wl1 (drop = i);
set wl0;
array wt{3} weight0 -weight2;

/* replacing the value 9999 with missing value  */
do i=1 to 3;
	if wt{i} = 9999 then wt{i} = .;
end;

/* calculating the difference between the weights for analysis */
wd1 = weight0 - weight1;
wd2 = weight0 - weight2;
wd12 = weight1 - weight2;
run;


proc means data= wl1;
var wd2 walk_steps;
run;


proc freq data = wl1;
table wd2 walk_steps;
run;


/* creating a permanent dataset */
libname projectd "/folders/myfolders/project";

data projectd.wl2;
set wl1;
length ws_group $7.;
length wd_group $17.;

/* grouping walk steps into 3 different categories */
if walk_steps < 5000 then ws_group = 'low';
else if walk_steps >= 5000 and walk_steps <= 10000 then ws_group = 'medium';
else if walk_steps > 10000 then ws_group = 'high';
else ws_group = 'missing';

/* grouping weight difference into 3 different categories */
if wd2 gt 5 then wd_group = 'high weight loss';
else if wd2 le 5 and wd2 gt 0 then wd_group = 'low weight loss';
else if wd2 ne . and wd2 le 0 then wd_group = 'no weight loss';
else wd_group = 'missing';

run;


proc freq data= projectd.wl2;
table ws_group * wd_group / norow nocol;
run;

