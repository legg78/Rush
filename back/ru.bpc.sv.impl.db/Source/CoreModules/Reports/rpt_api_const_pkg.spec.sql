create or replace package rpt_api_const_pkg is
/********************************************************* 
 *  Constants for report module  <br /> 
 *  Created by Fomichev A.(fomichev@bpcbt.com)  at 19.05.2010 <br /> 
 *  Last changed by $Author$ <br /> 
 *  $LastChangedDate::                           $ <br /> 
 *  Revision: $LastChangedRevision$ <br /> 
 *  Module: rpt_api_const_pkg  <br /> 
 *  @headcom 
 **********************************************************/ 
    REPORT_SOURCE_KEY            constant     com_api_type_pkg.t_dict_value := 'RPTS';
    REPORT_SOURCE_SIMPLE         constant     com_api_type_pkg.t_dict_value := 'RPTSSMPL';
    REPORT_SOURCE_XML            constant     com_api_type_pkg.t_dict_value := 'RPTSSXML';

    REPORT_STATUS_KEY            constant     com_api_type_pkg.t_dict_value := 'RPST';
    REPORT_STATUS_RUNNING        constant     com_api_type_pkg.t_dict_value := 'RPSTSRUN';
    REPORT_STATUS_GENERATED      constant     com_api_type_pkg.t_dict_value := 'RPSTSGEN';
    REPORT_STATUS_FAILED         constant     com_api_type_pkg.t_dict_value := 'RPSTFAIL';

    DOCUMENT_TYPE_IMAGE          constant     com_api_type_pkg.t_dict_value := 'DCMT0001';
    DOCUMENT_TYPE_REPORT         constant     com_api_type_pkg.t_dict_value := 'DCMT0002';
    DOCUMENT_TYPE_CREDIT         constant     com_api_type_pkg.t_dict_value := 'DCMT0003';
    DOCUMENT_TYPE_CUST_STTMT     constant     com_api_type_pkg.t_dict_value := 'DCMT0012';
    DOCUMENT_TYPE_LTY_STTMT      constant     com_api_type_pkg.t_dict_value := 'DCMT0013';
    DOCUMENT_TYPE_DPP_REPORT     constant     com_api_type_pkg.t_dict_value := 'DCMT0014';
    DOCUMENT_TYPE_ACC_STTMT      constant     com_api_type_pkg.t_dict_value := 'DCMT0015';

    FILE_TYPE_REPORT             constant     com_api_type_pkg.t_dict_value := 'FLTPREPT';

    MIME_TYPE_TEXT               constant     com_api_type_pkg.t_dict_value := 'MIMETEXT';
    MIME_TYPE_JPEG               constant     com_api_type_pkg.t_dict_value := 'MIMEJPEG';
    MIME_TYPE_PDF                constant     com_api_type_pkg.t_dict_value := 'MIMETPDF';

    JASPER_PROCESSOR             constant     com_api_type_pkg.t_dict_value := 'RPTPJSPR';
    XSLT_PROCESSOR               constant     com_api_type_pkg.t_dict_value := 'RPTPXSLT';

    CONTENT_TYPE_CUST_ORDER      constant     com_api_type_pkg.t_dict_value := 'DCCT0001';
    CONTENT_TYPE_CUST_SIGN       constant     com_api_type_pkg.t_dict_value := 'DCCT0002';
    CONTENT_TYPE_REG_LABEL       constant     com_api_type_pkg.t_dict_value := 'DCCT0003';
    CONTENT_TYPE_REG_SIGN        constant     com_api_type_pkg.t_dict_value := 'DCCT0004';
    CONTENT_TYPE_EXEC_LABEL      constant     com_api_type_pkg.t_dict_value := 'DCCT0005';
    CONTENT_TYPE_EXEC_SIGN       constant     com_api_type_pkg.t_dict_value := 'DCCT0006';
    --CONTENT_TYPE_PRINT_FORM      constant     com_api_type_pkg.t_dict_value := 'DCCT0007';
    CONTENT_TYPE_SUPERV_SIGN     constant     com_api_type_pkg.t_dict_value := 'DCCT0008';
    CONTENT_TYPE_PRINT_FORM      constant     com_api_type_pkg.t_dict_value := 'DCCT0010';
    CONTENT_TYPE_DSP_ATTCHT      constant     com_api_type_pkg.t_dict_value := 'DCCT0011';

    ENTITY_TYPE_DOCUMENT         constant     com_api_type_pkg.t_dict_value := 'ENTTDCMT';
    ENTITY_TYPE_CONTENT          constant     com_api_type_pkg.t_dict_value := 'ENTTDCCT';
    ENTITY_TYPE_REPORT           constant     com_api_type_pkg.t_dict_value := 'ENTTREPT';
    ENTITY_TYPE_TEMPLATE         constant     com_api_type_pkg.t_dict_value := 'ENTT0123';

    DATETIME_FORMAT              constant     com_api_type_pkg.t_name       := 'dd.mm.yyyy hh24:mi:ss';
    DATE_FORMAT                  constant     com_api_type_pkg.t_name       := 'dd.mm.yyyy';

    DOCUMENT_STATUS_KEY          constant     com_api_type_pkg.t_dict_value := 'DCST';
    DOCUMENT_STATUS_PREPARATION  constant     com_api_type_pkg.t_dict_value := 'DCSTPREP';
    DOCUMENT_STATUS_CREATED      constant     com_api_type_pkg.t_dict_value := 'DCSTCREA';

    ATTACHMENT_TYPE_OTHER_DSP    constant     com_api_type_pkg.t_dict_value := 'DSDT0007';

end;
/
