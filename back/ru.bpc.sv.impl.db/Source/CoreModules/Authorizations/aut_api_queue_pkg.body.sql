create or replace package body aut_api_queue_pkg is
/************************************************************
* Store-And-Forward mechanism works with queues of authorizations for sending into external networks<br />
* Created by Mashonkin V.(mashonkin@bpcbt.com)  at 29.01.2014  <br />
* Last changed by $Author: mashonkin $  <br />
* $LastChangedDate:: 2014-01-29 19:32:51 +0400#$ <br />
* Revision: $LastChangedRevision: 10879 $ <br />
* Module: AUT_API_QUEUE_PKG <br />
* @headcom
************************************************************/

    -- put new transaction into queue
    procedure put_aut_queue (
        i_auth_id                   in com_api_type_pkg.t_long_id
        , i_host_id                 in com_api_type_pkg.t_tiny_id
        , i_channel_id              in com_api_type_pkg.t_short_id default null
        , i_is_advice_needed        in com_api_type_pkg.t_boolean  default com_api_type_pkg.false
        , i_is_reversal_needed      in com_api_type_pkg.t_boolean  default com_api_type_pkg.false
        , i_max_send_count          in com_api_type_pkg.t_short_id default aut_api_queue_pkg.C_MAX_SEND_COUNT
        , i_description             in com_api_type_pkg.t_text     default null
    ) is
        wrong_parameters EXCEPTION;
        l_auth_id com_api_type_pkg.t_long_id;
    begin

        if i_is_advice_needed not in (com_api_type_pkg.true, com_api_type_pkg.false)
           or i_is_reversal_needed not in (com_api_type_pkg.true, com_api_type_pkg.false)
           or i_max_send_count <= 0
        then
            raise wrong_parameters;
        end if;

        select id into l_auth_id
          from aut_auth
         where id = i_auth_id;

        insert into aut_queue (
            auth_id
            , host_id
            , channel_id
            , is_advice_needed
            , is_reversal_needed
            , send_count
            , max_send_count
            , send_status
        ) values (
            i_auth_id
            , i_host_id
            , i_channel_id
            , i_is_advice_needed
            , i_is_reversal_needed
            , 0
            , i_max_send_count
            , aut_api_queue_pkg.C_NEED_SENDING
        );

        insert into aut_queue_log (
            id
            , auth_id
            , host_id
            , channel_id
            , is_advice_needed
            , is_reversal_needed
            , send_count
            , max_send_count
            , send_status
            , log_date
            , description
        ) values (
            aut_queue_log_seq.nextval
            , i_auth_id
            , i_host_id
            , i_channel_id
            , i_is_advice_needed
            , i_is_reversal_needed
            , 0
            , i_max_send_count
            , aut_api_queue_pkg.C_NEED_SENDING
            , systimestamp
            , trim(i_description)
        );
    exception
        when wrong_parameters then
            com_api_error_pkg.raise_error (
                i_error         => 'INCORRECT_PARAM_VALUE_DATA_TYPE'
                , i_env_param1  => i_auth_id
            );

        when no_data_found then
            com_api_error_pkg.raise_error (
                i_error         => 'AUTH_NOT_FOUND'
                , i_env_param1  => i_auth_id
            );
    end put_aut_queue;

    -- changes transaction parameters in queue
    procedure change_aut_queue (
        i_auth_id                   in com_api_type_pkg.t_long_id
        , i_host_id                 in com_api_type_pkg.t_tiny_id
        , i_channel_id              in com_api_type_pkg.t_short_id   default null
        , i_is_advice_needed        in com_api_type_pkg.t_boolean    default null
        , i_is_reversal_needed      in com_api_type_pkg.t_boolean    default null
        , i_send_count              in com_api_type_pkg.t_short_id   default null
        , i_send_status             in com_api_type_pkg.t_dict_value default null
        , i_description             in com_api_type_pkg.t_text       default null
    ) is
        wrong_status EXCEPTION;
        l_auth_id    com_api_type_pkg.t_long_id;
    begin

        select id into l_auth_id
          from aut_auth
         where id = i_auth_id;

        select auth_id into l_auth_id
          from aut_queue
         where auth_id = i_auth_id
           and host_id = i_host_id
           and nvl(channel_id, -1) = nvl(i_channel_id, -1);

        if trim(i_send_status) is not null
           and upper(trim(i_send_status)) not in (
                aut_api_queue_pkg.C_NEED_SENDING
                , aut_api_queue_pkg.C_SENDED_SUCCESS
                , aut_api_queue_pkg.C_SENDING_FAILED
                , aut_api_queue_pkg.C_SENDED_AWAITS_CONFIRM)
        then
            raise wrong_status;
        end if;

        update aut_queue
           set is_advice_needed    = nvl(i_is_advice_needed,   is_advice_needed)
            , is_reversal_needed   = nvl(i_is_reversal_needed, is_reversal_needed)
            , send_count           = nvl(i_send_count,         send_count)
            --, max_send_count       = nvl(i_max_send_count,     max_send_count)
            , send_status          = nvl(upper(trim(i_send_status)), send_status)
        where auth_id = i_auth_id
          and host_id = i_host_id
          and nvl(channel_id, -1) = nvl(i_channel_id, -1);

        insert into aut_queue_log (
            id
            , auth_id
            , host_id
            , channel_id
            , is_advice_needed
            , is_reversal_needed
            , send_count
            , send_status
            , log_date
            , description
        ) values (
            aut_queue_log_seq.nextval
            , i_auth_id
            , i_host_id
            , i_channel_id
            , i_is_advice_needed
            , i_is_reversal_needed
            , i_send_count
            , i_send_status
            , systimestamp
            , trim(i_description)
        );
    exception
        when wrong_status then
            com_api_error_pkg.raise_error (
                i_error      => 'UNKNOWN_AUT_QUEUE_STATUS'
              , i_env_param1 => upper(trim(i_send_status))
            );
        when no_data_found then
            com_api_error_pkg.raise_error (
                i_error         => 'AUTH_NOT_FOUND'
                , i_env_param1  => i_auth_id
            );
    end change_aut_queue;

    -- read transaction parameters from queue
    procedure get_aut_queue (
        i_auth_id                   in com_api_type_pkg.t_long_id
        , i_host_id                 in com_api_type_pkg.t_tiny_id
        , i_channel_id              in com_api_type_pkg.t_short_id   default null
        , o_is_advice_needed        out com_api_type_pkg.t_boolean
        , o_is_reversal_needed      out com_api_type_pkg.t_boolean
        , o_send_count              out com_api_type_pkg.t_short_id
        , o_max_send_count          out com_api_type_pkg.t_short_id
        , o_send_status             out com_api_type_pkg.t_dict_value
    ) is
    begin
        select
            is_advice_needed
            , is_reversal_needed
            , send_count
            , max_send_count
            , send_status
         into
            o_is_advice_needed
            , o_is_reversal_needed
            , o_send_count
            , o_max_send_count
            , o_send_status
         from aut_queue
        where auth_id = i_auth_id
          and host_id = i_host_id
          and nvl(channel_id, -1) = nvl(i_channel_id, -1);
    exception
        when no_data_found then
            com_api_error_pkg.raise_error (
                i_error         => 'AUTH_NOT_FOUND'
                , i_env_param1  => i_auth_id
            );
    end get_aut_queue;

    -- read count of transaction by send status
    function get_aut_queue_cnt (
        i_send_status   in com_api_type_pkg.t_dict_value
        , i_host_id     in com_api_type_pkg.t_tiny_id
        , i_channel_id  in com_api_type_pkg.t_short_id
    ) return com_api_type_pkg.t_long_id
    is
        wrong_status EXCEPTION;
        l_aut_queue_cnt com_api_type_pkg.t_count := 0;
    begin
        if trim(i_send_status) is not null
           and upper(trim(i_send_status)) not in (
                aut_api_queue_pkg.C_NEED_SENDING
                , aut_api_queue_pkg.C_SENDED_SUCCESS
                , aut_api_queue_pkg.C_SENDING_FAILED
                , aut_api_queue_pkg.C_SENDED_AWAITS_CONFIRM)
        then
            raise wrong_status;
        end if;

        select count(a.auth_id)
          into l_aut_queue_cnt
          from aut_queue a
         where a.send_status = i_send_status
           and a.host_id     = i_host_id
           and a.channel_id  = i_channel_id;

        return l_aut_queue_cnt;
    exception
        when wrong_status then
            com_api_error_pkg.raise_error (
                i_error      => 'UNKNOWN_AUT_QUEUE_STATUS'
              , i_env_param1 => upper(trim(i_send_status))
            );
    end get_aut_queue_cnt;

begin
    null;
end aut_api_queue_pkg;
/

