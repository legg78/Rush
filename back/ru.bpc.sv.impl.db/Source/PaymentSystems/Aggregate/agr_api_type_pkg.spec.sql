create or replace package agr_api_type_pkg is

type t_field_rec      is record (
    f_name      com_api_type_pkg.t_name
  , f_type      com_api_type_pkg.t_byte_char
  , f_format    com_api_type_pkg.t_name
  , f_position  com_api_type_pkg.t_tiny_id
  , f_id        com_api_type_pkg.t_long_id
  , f_table     com_api_type_pkg.t_name
);
type    t_field_tab          is table of t_field_rec index by binary_integer;

type field_value_record      is record
    (   field_no                number,
        field_value             varchar2(1000)
    );

    type field_values_table is table of field_value_record index by binary_integer;

end;
/
 