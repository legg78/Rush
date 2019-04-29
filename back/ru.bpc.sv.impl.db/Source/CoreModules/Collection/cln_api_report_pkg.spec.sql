create or replace package cln_api_report_pkg
/*********************************************************
*  Collectors reports <br />
*  Created by Nick (shalnov@bpcbt.com)  at 09.11.2018 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: cln_api_report_pkg <br />
*  @headcom
**********************************************************/
as
    procedure collector_performance(
        o_xml                  out clob
      , i_start_date        in     date                          default null
      , i_end_date          in     date                          default null
      , i_lang              in     com_api_type_pkg.t_dict_value default null
    );

    procedure collector_activities(
        o_xml                  out clob
      , i_start_date        in     date                          default null
      , i_lang              in     com_api_type_pkg.t_dict_value default null
    );
end;
/
