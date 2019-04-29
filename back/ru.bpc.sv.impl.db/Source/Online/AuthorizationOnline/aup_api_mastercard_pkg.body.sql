create or replace package body aup_api_mastercard_pkg is

    function get_mastercard (
        i_auth_id                in com_api_type_pkg.t_long_id
    ) return aup_api_type_pkg.t_aup_mastercard_rec is
        l_aup_mastercard_rec     aup_api_type_pkg.t_aup_mastercard_rec;
    begin
        select
            auth_id
            , tech_id
            , iso_msg_type
            , trace
            , trms_datetime
            , time_mark
            , bitmap
            , sttl_date
            , acq_inst_bin
            , forw_inst_bin
            , host_id
            , eci
            , auth_code
            , resp_code
        into
            l_aup_mastercard_rec
        from (
            select
                auth_id
                , tech_id
                , iso_msg_type
                , trace
                , trms_datetime
                , time_mark
                , bitmap
                , sttl_date
                , acq_inst_bin
                , forw_inst_bin
                , host_id
                , eci
                , auth_code
                , resp_code
            from
                aup_mastercard
            where
                auth_id = i_auth_id
            order by
                iso_msg_type
        )
        where
            rownum = 1;
            
        return l_aup_mastercard_rec;
    exception
        when no_data_found then
            return null;
    end;
    
    function get_acquirer_bin (
        i_auth_id               in com_api_type_pkg.t_long_id
    ) return com_api_type_pkg.t_rrn is
        l_aup_mastercard_rec    aup_api_type_pkg.t_aup_mastercard_rec;
    begin
        l_aup_mastercard_rec := get_mastercard (
            i_auth_id  => i_auth_id
        );
        return l_aup_mastercard_rec.acq_inst_bin;
    end;

end;
/
