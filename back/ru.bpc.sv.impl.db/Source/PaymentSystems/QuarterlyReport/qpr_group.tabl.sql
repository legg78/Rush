  create table qpr_group
   (	id  number(16) not null,
	group_name varchar2(50 byte),
	group_desc varchar2(240 byte),
	id_parent number(4,0)
   )
/
comment on table qpr_group  is 'Parameters groups for VISA and MC quarter reports'
/
comment on column qpr_group.id is 'Identifier'
/
comment on column qpr_group.group_name is 'Group name'
/
comment on column qpr_group.group_desc is 'Group description'
/
comment on column qpr_group.id_parent is 'Parent group ID'
/
alter table qpr_group add (priority number(8))
/
comment on column qpr_group.priority is 'Group priority'
/
alter table qpr_group add ( mc_rep_col_1_name varchar2(200) )
/
alter table qpr_group add ( mc_rep_col_2_name varchar2(200) )
/
alter table qpr_group add ( mc_rep_col_3_name varchar2(200) )
/
comment on column qpr_group.mc_rep_col_1_name is 'Mastercard querterly report 1st column name'
/
comment on column qpr_group.mc_rep_col_2_name is 'Mastercard querterly report 2nd column name'
/
comment on column qpr_group.mc_rep_col_3_name is 'Mastercard querterly report 3rd column name'
/
alter table qpr_group add mc_rep_col_4_name varchar2(200)
/
comment on column qpr_group.mc_rep_col_4_name is 'Mastercard quarterly report 4rd column name'
/
