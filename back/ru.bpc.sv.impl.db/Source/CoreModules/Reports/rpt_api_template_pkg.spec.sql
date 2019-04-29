create or replace package rpt_api_template_pkg is
/************************************************************
 * API for report template <br />
 * Created by Kopachev D.(kopachev@bpcbt.com) at 03.05.2012 <br />
 * Last changed by $Author$ <br />
 * $LastChangedDate::                           $ <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: rpt_api_template_pkg <br />
 * @headcom
 ************************************************************/
  
    function get_template (
        i_report_id            in com_api_type_pkg.t_short_id
        , i_report_processor   in com_api_type_pkg.t_dict_value := null
        , i_mask_error         in com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE
    ) return rpt_api_type_pkg.t_template_rec;

    procedure apply_xslt (
        i_report_id             in com_api_type_pkg.t_short_id
        , io_xml_source         in out clob
    );
	
    function logo_path_xml return xmltype;	

end;
/
