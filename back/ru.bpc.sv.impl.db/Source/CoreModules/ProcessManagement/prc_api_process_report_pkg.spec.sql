create or replace package prc_api_process_report_pkg is
/*********************************************************************
 * The API for process report <br />
 * Created by Kopachev D.(kopachev@bpc.ru)  at 22.12.2011 <br />
 * Last changed by $Author: khougaev $ <br />
 * $LastChangedDate:: 2011-09-22 12:50:29 +0400#$ <br />
 * Revision: $LastChangedRevision: 12555 $ <br />
 * Module: PRC_API_PROCESS_REPORT_PKG <br />
 * @headcom
 ********************************************************************/
procedure run_report (
    o_xml                    out clob
  , i_lang                in     com_api_type_pkg.t_dict_value
  , i_entity_type         in     com_api_type_pkg.t_dict_value
  , i_object_id           in     com_api_type_pkg.t_long_id
  , i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_end_time            in     date
);

end;
/
