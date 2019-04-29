create table frp_matrix_value (
    id           number(8)
  , seqnum       number(4)
  , matrix_id    number(4)
  , x_value      varchar2(200)
  , y_value      varchar2(200)
  , matrix_value varchar2(200))
/

comment on table frp_matrix_value is 'Matrix values.'
/

comment on column frp_matrix_value.id is 'Primary key.'
/

comment on column frp_matrix_value.seqnum is 'Sequential number of data record version.'
/

comment on column frp_matrix_value.matrix_id is 'Reference to matrix.'
/

comment on column frp_matrix_value.x_value is 'X-scale value.'
/

comment on column frp_matrix_value.y_value is 'Y-scale value.'
/

comment on column frp_matrix_value.matrix_value is 'Matrix value.'
/