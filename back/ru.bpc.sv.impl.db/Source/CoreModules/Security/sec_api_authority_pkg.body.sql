create or replace package body sec_api_authority_pkg is
/**********************************************************
 * API for certificate authority centers
 * Created by Kopachev D.(kopachev@bpcbt.com) at 18.06.2010
 * Last changed by $Author: krukov $ <br />
 * $LastChangedDate:: 2011-03-01 14:46:54 +0300#$ <br />
 * Revision: $LastChangedRevision: 8281 $ <br /> 
 * Module: sec_api_authority_pkg
 * @headcom
 **********************************************************/    

    function get_authority (
        i_id                    in com_api_type_pkg.t_tiny_id
    ) return sec_api_type_pkg.t_authority_rec is
        l_authority             sec_api_type_pkg.t_authority_rec;
    begin
        trc_log_pkg.debug (
            i_text          => 'Getting authority [#1]'
            , i_env_param1  => i_id
        );
        
        select
            id
            , seqnum
            , type
            , rid
        into
            l_authority
        from
            sec_authority_vw
        where
            id = i_id;
            
        return l_authority;
    exception
        when no_data_found then
            com_api_error_pkg.raise_error (
                i_error         => 'AUTHORITY_NOT_FOUND'
                , i_env_param1  => i_id
            );
    end;
    
    function get_authority (
        i_authority_type        in com_api_type_pkg.t_dict_value
    ) return sec_api_type_pkg.t_authority_rec is
        l_authority             sec_api_type_pkg.t_authority_rec;
    begin
        trc_log_pkg.debug (
            i_text          => 'Getting authority [#1]'
            , i_env_param1  => i_authority_type
        );

        select
            id
            , seqnum
            , type
            , rid
        into
            l_authority
        from
            sec_authority_vw
        where
            type = i_authority_type;

        return l_authority;
    exception
        when no_data_found then
            com_api_error_pkg.raise_error (
                i_error         => 'AUTHORITY_NOT_FOUND'
                , i_env_param1  => i_authority_type
            );
    end;

end;
/
