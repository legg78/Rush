create table rul_name_part (
    id                      number(8)
  , format_id               number(4)
  , part_order              number(4)
  , base_value_type         varchar2(8)
  , base_value              varchar2(200)
  , transformation_type     varchar2(8)
  , transformation_mask     varchar2(200)
  , part_length             number(4)
  , pad_type                varchar2(8)
  , pad_string              varchar2(200)
  , check_part              number(1)
)
/
comment on table rul_name_part is 'Parts of entity name format'
/
comment on column rul_name_part.id is 'Indentifier'
/
comment on column rul_name_part.format_id is 'Format identifier'
/
comment on column rul_name_part.part_order is 'Order within format'
/
comment on column rul_name_part.base_value_type is 'Base value type'
/
comment on column rul_name_part.base_value is 'Base value or parameter name'
/
comment on column rul_name_part.transformation_type is 'Type of base value transformation'
/
comment on column rul_name_part.transformation_mask is 'Mask for value transformation'
/
comment on column rul_name_part.part_length is 'Resulting length of part'
/
comment on column rul_name_part.pad_type is 'Padding method'
/
comment on column rul_name_part.pad_string is 'Padding string'
/
comment on column rul_name_part.check_part is 'Checking part of name'
/
