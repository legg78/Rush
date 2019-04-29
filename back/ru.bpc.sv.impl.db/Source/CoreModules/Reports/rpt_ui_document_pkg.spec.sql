create or replace package rpt_ui_document_pkg as
procedure show_document(
    o_xml               out     clob
  , i_object_id         in      com_api_type_pkg.t_long_id
);
end;
/
