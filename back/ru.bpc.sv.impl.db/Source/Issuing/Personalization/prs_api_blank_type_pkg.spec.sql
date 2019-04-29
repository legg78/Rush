create or replace package prs_api_blank_type_pkg is
/************************************************************
 * API for blank type <br />
 * Created by Kopachev D.(kopachev@bpcbt.com) at 10.12.2010 <br />
 * Last changed by $Author: kopachev $ <br />
 * $LastChangedDate:: 2011-10-28 17:01:09 +0400#$ <br />
 * Revision: $LastChangedRevision: 13428 $ <br />
 * Module: prs_api_blank_type_pkg <br />
 * @headcom
 ************************************************************/

/*
 * Bulk mark blank type active
 * @param  i_blank_type_tab  - Batch type identifier
 */
    procedure mark_blank_type (
        i_blank_type_tab         in com_api_type_pkg.t_number_tab
    );
    
    function get_blank_type_name (
        i_id                     in com_api_type_pkg.t_tiny_id
        , i_lang                 in com_api_type_pkg.t_dict_value := null
    ) return com_api_type_pkg.t_name;

end;
/
