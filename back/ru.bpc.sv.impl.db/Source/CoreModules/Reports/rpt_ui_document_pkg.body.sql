create or replace package body rpt_ui_document_pkg as
procedure show_document(
    o_xml               out     clob
  , i_object_id         in      com_api_type_pkg.t_long_id
) is
begin
    rpt_api_document_pkg.show_document(
        o_xml       => o_xml
      , i_object_id => i_object_id
    );
end show_document;

end;
/
