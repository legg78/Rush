create or replace package sec_api_authority_pkg  is
/**********************************************************
 * API for certificate authority centers
 * Created by Kopachev D.(kopachev@bpcbt.com) at 18.06.2010
 * Last changed by $Author: krukov $ <br />
 * $LastChangedDate:: 2011-03-01 14:46:54 +0300#$ <br />
 * Revision: $LastChangedRevision: 8281 $ <br /> 
 * Module: sec_api_authority_pkg
 * @headcom
 **********************************************************/    

/*
 * Getting authority
 * @param i_id - Authority identifier
 */
    function get_authority (
        i_id                    in com_api_type_pkg.t_tiny_id
    ) return sec_api_type_pkg.t_authority_rec;

/*
 * Getting authority
 * @param i_authority_type - Authority type
 */    
    function get_authority (
        i_authority_type        in com_api_type_pkg.t_dict_value
    ) return sec_api_type_pkg.t_authority_rec;

end;
/
