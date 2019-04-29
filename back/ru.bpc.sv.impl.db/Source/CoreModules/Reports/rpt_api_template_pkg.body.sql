create or replace package body rpt_api_template_pkg is
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
        , i_report_processor   in com_api_type_pkg.t_dict_value
        , i_mask_error         in com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE
    ) return rpt_api_type_pkg.t_template_rec is
        l_result               rpt_api_type_pkg.t_template_rec;
    begin
        select
            id
            , seqnum
            , report_id
            , lang
            , text
            , base64
            , report_processor
            , report_format
            , start_date
            , end_date 
        into
            l_result
        from (
            select
                id
                , seqnum
                , report_id
                , lang
                , text
                , base64
                , report_processor
                , report_format
                , start_date
                , end_date
            from
                rpt_template
            where
                report_id = i_report_id
                and (report_processor = i_report_processor or i_report_processor is null)
                and (com_api_sttl_day_pkg.get_sysdate >= start_date or start_date is null)
                and (com_api_sttl_day_pkg.get_sysdate <= end_date or end_date is null)
            order by
                start_date desc
            )
        where
            rownum = 1;
        
        return l_result;
    exception
        when no_data_found then
            if i_mask_error = com_api_type_pkg.TRUE then
                trc_log_pkg.debug(
                    i_text          => 'Report template not found [#1][#2]'
                    , i_env_param1  => i_report_id
                    , i_env_param2  => i_report_processor
                );
            
                return l_result;
            else
                com_api_error_pkg.raise_error (
                    i_error         => 'REPORT_TEMPLATE_NOT_FOUND'
                    , i_env_param1  => i_report_id
                );
            end if;
    end;

    procedure apply_xslt (
        i_report_id             in com_api_type_pkg.t_short_id
        , io_xml_source         in out clob
    ) is
        l_template_xslt         rpt_api_type_pkg.t_template_rec;
    begin
        l_template_xslt := 
            rpt_api_template_pkg.get_template(
                i_report_id           => i_report_id
                , i_report_processor  => rpt_api_const_pkg.XSLT_PROCESSOR
                , i_mask_error        => com_api_type_pkg.TRUE
            );
                
        if l_template_xslt.id is not null then
            trc_log_pkg.debug ('Transforming XML data using XSLT style sheets');
            --dbms_output.put_line('-l_xml_data-----------'||chr(13)||io_xml_source);
            --dbms_output.put_line('-l_template-----------'||chr(13)||l_template_xslt.text);
            --trc_log_pkg.debug('XML_s'||io_xml_source);
            --trc_log_pkg.debug('XSLT'||l_template_xslt.text);
            select
                com_api_const_pkg.XML_HEADER
                ||xmltransform (
                    xmlparse(document io_xml_source)
                    , xmltype(l_template_xslt.text)
                ).getclobval()
            into
                io_xml_source
            from
                dual;
                
            --dbms_output.put_line('-l_xml_source-after-xlt-'||chr(13)||io_xml_source);
            --trc_log_pkg.debug('XML'||io_xml_source);
            trc_log_pkg.debug ('Transforming XML data using XSLT style sheets - ok');
        else
            trc_log_pkg.debug ('Transforming XML data using XSLT style sheets - not required');
        end if;
    end;
	
	function logo_path_xml 
        return xmltype is
        l_logo_path xmltype;
    begin

        select xmlelement("logo_path", bn.filename) into l_logo_path 
          from rpt_report_banner rb, rpt_banner bn 
         where rb.report_id = rpt_api_run_pkg.get_g_report_id
           and rb.banner_id = bn.id;  
       
        return l_logo_path; 

    exception 
        when too_many_rows or no_data_found then 
            select xmlelement("logo_path", null) into l_logo_path from dual;
        
            return l_logo_path;      
    end logo_path_xml;

end;
/
