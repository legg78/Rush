create or replace package rpt_api_type_pkg is
/************************************************************
 * Report types <br />
 * Created by Kopachev D.(kopachev@bpcbt.com) at 03.05.2012 <br />
 * Last changed by $Author$ <br />
 * $LastChangedDate::                           $ <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: rpt_api_type_pkg <br />
 * @headcom
 ************************************************************/
 
    type            t_template_rec is record (
        id                   com_api_type_pkg.t_short_id
        , seqnum             com_api_type_pkg.t_seqnum
        , report_id          com_api_type_pkg.t_short_id
        , lang               com_api_type_pkg.t_dict_value
        , text               clob
        , base64             clob
        , report_processor   com_api_type_pkg.t_dict_value
        , report_format      com_api_type_pkg.t_dict_value
        , start_date          date
        , end_date            date
    );
    type            t_template_tab is table of t_template_rec index by binary_integer;
    
    type            t_document_rec is record (
        id                   com_api_type_pkg.t_long_id
        , seqnum             com_api_type_pkg.t_seqnum
        , document_type      com_api_type_pkg.t_dict_value
        , document_number    com_api_type_pkg.t_name
        , document_date      date
        , entity_type        com_api_type_pkg.t_dict_value
        , object_id          com_api_type_pkg.t_long_id
        , report_id          com_api_type_pkg.t_short_id
        , template_id        com_api_type_pkg.t_short_id
        , file_name          com_api_type_pkg.t_name
        , mime_type          com_api_type_pkg.t_dict_value
        , save_path          com_api_type_pkg.t_full_desc
        , inst_id            com_api_type_pkg.t_tiny_id
        , start_date         date
        , end_date           date
        , status             com_api_type_pkg.t_dict_value
    );
    type            t_document_tab is table of t_document_rec index by binary_integer;

    type t_event_rec    is record (
        event_type            com_api_type_pkg.t_dict_value
      , entity_type           com_api_type_pkg.t_dict_value
      , object_id             com_api_type_pkg.t_long_id
      , split_hash            com_api_type_pkg.t_inst_id
      , eff_date              date 
      , event_object_id       com_api_type_pkg.t_long_id
      , inst_id               com_api_type_pkg.t_inst_id
      , document_id           com_api_type_pkg.t_long_id
      , document_number       com_api_type_pkg.t_name
      , document_type         com_api_type_pkg.t_dict_value
      , document_entity_type  com_api_type_pkg.t_dict_value
      , document_object_id    com_api_type_pkg.t_long_id
      , document_start_date   date
      , document_end_date     date
      , document_status       com_api_type_pkg.t_dict_value
    );
    type t_event_tab      is table of t_event_rec index by binary_integer;

end;
/
