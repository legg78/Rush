create table frp_matrix (
    id          number(4)
  , seqnum      number(4)
  , inst_id     number(4)
  , x_scale     varchar2(200)
  , y_scale     varchar2(200)
  , matrix_type varchar2(8) )
/

comment on table frp_matrix is 'Two-dimensions arrays.'
/

comment on column frp_matrix.id is 'Primary key.'
/

comment on column frp_matrix.seqnum is 'Sequential number of data record version.'
/

comment on column frp_matrix.inst_id is 'Institution identifier.'
/

comment on column frp_matrix.x_scale is 'Authorization attribute name using for X-scale.'
/

comment on column frp_matrix.y_scale is 'Authorization attribute name using for Y-scale.'
/

comment on column frp_matrix.matrix_type is 'Matrix type. Describing type of returning values (risk score or boolean value). '
/

