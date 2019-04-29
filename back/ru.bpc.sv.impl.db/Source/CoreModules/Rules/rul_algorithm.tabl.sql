create table rul_algorithm(
    id                  number(4)
  , algorithm           varchar2(8)
  , entry_point         varchar2(8)
  , proc_id             number(4)
)
/

comment on table rul_algorithm is 'Reference table with associations between algorithms and rule procedures'
/
comment on column rul_algorithm.id is 'Procedure algorithm identificator, primary key'
/
comment on column rul_algorithm.algorithm is 'Algorithm dictionary article'
/
comment on column rul_algorithm.entry_point is 'Algorithm entry point dictionary article. It allows to associate with one algorithm more than one procedures'
/
comment on column rul_algorithm.proc_id is 'Procedure identificator associated with the algorithm'
/

drop table rul_algorithm
/

create table rul_algorithm(
    id                  number(4)
  , seqnum              number(4)
  , algorithm           varchar2(8)
  , entry_point         varchar2(8)
  , proc_id             number(4)
)
/
comment on table rul_algorithm is 'Reference table with associations between algorithms and rule procedures'
/
comment on column rul_algorithm.id is 'Procedure algorithm identificator, primary key'
/
comment on column rul_algorithm.seqnum is 'Data version sequential number'
/
comment on column rul_algorithm.algorithm is 'Algorithm dictionary article'
/
comment on column rul_algorithm.entry_point is 'Algorithm entry point dictionary article. It allows to associate with one algorithm more than one procedures'
/
comment on column rul_algorithm.proc_id is 'Procedure identificator associated with the algorithm'
/
