create or replace package body cst_api_document_pkg is

procedure add_document (
    io_document_id     in out  com_api_type_pkg.t_long_id
  , o_seqnum              out  com_api_type_pkg.t_seqnum
  , i_content_type     in      com_api_type_pkg.t_dict_value
  , i_document_type    in      com_api_type_pkg.t_dict_value
  , i_entity_type      in      com_api_type_pkg.t_dict_value
  , i_object_id        in      com_api_type_pkg.t_long_id
  , i_report_id        in      com_api_type_pkg.t_short_id     default null
  , i_template_id      in      com_api_type_pkg.t_short_id     default null
  , i_file_name        in      com_api_type_pkg.t_name         default null
  , i_mime_type        in      com_api_type_pkg.t_dict_value   default null
  , i_save_path        in      com_api_type_pkg.t_full_desc    default null
  , i_document_date    in      date                            default null
  , i_document_number  in      com_api_type_pkg.t_name         default null
  , i_inst_id          in      com_api_type_pkg.t_inst_id
  , i_param_map        in      com_param_map_tpt               
) is
    l_param_tab                com_api_type_pkg.t_param_tab;
    l_document_id              com_api_type_pkg.t_long_id;
    l_seqnum                   com_api_type_pkg.t_seqnum;
    l_employee_name            com_api_type_pkg.t_name;
    l_employee_position        com_api_type_pkg.t_name;
begin
    null;
end add_document;

function get_document_block(
    i_operation_id     in      com_api_type_pkg.t_long_id
  , i_transaction_id   in      com_api_type_pkg.t_long_id
) return com_api_type_pkg.t_lob_data
is
    l_purpose_id               com_api_type_pkg.t_long_id;
    l_payment_order_id         com_api_type_pkg.t_long_id;
    l_result                   com_api_type_pkg.t_lob_data;
begin

    select o.payment_order_id
         , x.purpose_id
      into l_payment_order_id
         , l_purpose_id
      from opr_operation o
         , pmo_order x
     where o.payment_order_id = x.id
       and o.id               = i_operation_id;

    select xmlelement("document"
             , xmlelement("document_id",     to_char(min(z.id), 'FM999999999999999990'))
             , xmlelement("document_type",   min(z.document_type))
             , xmlelement("document_number", min(z.document_number))
             , xmlelement("document_date",   to_char(min(z.document_date), com_api_const_pkg.XML_DATETIME_FORMAT))
           ).getclobval()
      into l_result 
      from rpt_document z
     where z.entity_type = acc_api_const_pkg.ENTITY_TYPE_TRANSACTION
       and z.object_id   = i_transaction_id;
    
    return l_result;
end get_document_block;

end cst_api_document_pkg;
/
