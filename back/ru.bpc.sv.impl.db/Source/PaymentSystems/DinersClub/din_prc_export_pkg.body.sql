create or replace package body din_prc_export_pkg as
/*********************************************************
*  API for Diners Club exporting of financial messages (outgoing clearing) <br />
*  Created by Alalykin A.(alalykin@bpcbt.com) at 02.05.2016 <br />
*  Last changed by $Author: alalykin $ <br />
*  $LastChangedDate:: 2016-05-02 18:08:00 +0300#$ <br />
*  Revision: $LastChangedRevision: 1 $ <br />
*  Module: DIN_PRC_EXPORT_PKG <br />
*  @headcom
**********************************************************/

BULK_LIMIT       constant com_api_type_pkg.t_count := 100;

/*
 * It return next recap number because in according to specification the sending (originating)
 * institution will number recaps sequentially by receiving (destination) institution code.
 */
function get_next_recap_number(
    i_sending_institution      in            din_api_type_pkg.t_institution_code
  , i_receiving_institution    in            din_api_type_pkg.t_institution_code
) return din_api_type_pkg.t_recap_number
is
    l_recap_number             com_api_type_pkg.t_tiny_id;
begin
    begin
        select distinct
               first_value(recap_number) over (order by recap_date desc, recap_number desc) + 1
          into l_recap_number
          from din_recap r
         where r.sending_institution   = i_sending_institution
           and r.receiving_institution = i_receiving_institution;

        if l_recap_number >= din_api_const_pkg.MAX_RECAP_NUMBER then
            l_recap_number := 1;
        end if;
    exception
        when no_data_found then
            l_recap_number := 1;
    end;

    trc_log_pkg.debug(
        i_text       => lower($$PLSQL_UNIT) || '.get_next_recap_number() = [#1]'
      , i_env_param1 => l_recap_number
    );

    return l_recap_number;
end get_next_recap_number;

procedure add_recap_header(
    i_file_rec                 in            din_api_type_pkg.t_file_rec
  , i_fin_rec                  in            din_api_type_pkg.t_fin_message_rec
  , o_recap_rec                   out        din_api_type_pkg.t_recap_rec
) is
    LOG_PREFIX        constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.add_recap_header';
    l_line                     com_api_type_pkg.t_text;
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || ' << i_file_rec.id [#1], i_fin_rec.id [#2]'
      , i_env_param1 => i_file_rec.id
      , i_env_param2 => i_fin_rec.id
    );

    o_recap_rec.id                         := din_recap_seq.nextval;
    o_recap_rec.file_id                    := i_file_rec.id;
    o_recap_rec.inst_id                    := i_fin_rec.inst_id;
    o_recap_rec.sending_institution        := i_fin_rec.sending_institution;
    o_recap_rec.receiving_institution      := i_fin_rec.receiving_institution;
    o_recap_rec.recap_number               :=
        get_next_recap_number(
            i_sending_institution   => i_fin_rec.sending_institution
          , i_receiving_institution => i_fin_rec.receiving_institution
        );
    o_recap_rec.currency                   := i_fin_rec.oper_currency;
    o_recap_rec.recap_date                 := i_file_rec.file_date;
    o_recap_rec.credit_count               := 0;
    o_recap_rec.credit_amount              := 0;
    o_recap_rec.debit_count                := 0;
    o_recap_rec.debit_amount               := 0;
    o_recap_rec.program_transaction_amount := i_fin_rec.program_transaction_amount;
    o_recap_rec.net_amount                 := 0;
    o_recap_rec.alt_currency               := i_fin_rec.alt_currency;
    o_recap_rec.alt_rate_type              := i_fin_rec.alt_rate_type;
    o_recap_rec.alt_gross_amount           := null;
    o_recap_rec.alt_net_amount             := null;
    o_recap_rec.new_recap_number           := null; -- this field is not empty for incoming clearing
    o_recap_rec.proc_date                  := i_file_rec.file_date;
    o_recap_rec.sttl_date                  := i_file_rec.file_date;
    o_recap_rec.is_rejected                := null; -- reserved

    l_line := din_api_const_pkg.TRANSACTION_CODE_OUTGOING  || din_api_const_pkg.DELIMITER
           || din_api_const_pkg.FUNCTION_CODE_RECAP_HEADER || din_api_const_pkg.DELIMITER
           || o_recap_rec.sending_institution              || din_api_const_pkg.DELIMITER
           || to_char(o_recap_rec.recap_number, din_api_const_pkg.NUMBER_3DIGITS_FORMAT)
                                                           || din_api_const_pkg.DELIMITER
           || o_recap_rec.receiving_institution            || din_api_const_pkg.DELIMITER
           || com_api_currency_pkg.get_currency_name(i_curr_code => o_recap_rec.currency)
                                                           || din_api_const_pkg.DELIMITER
           || to_char(o_recap_rec.recap_date, din_api_const_pkg.REVERSE_DATE_FORMAT) -- RCPDT
    ;
    if l_line is not null then
        prc_api_file_pkg.put_line(
            i_sess_file_id => i_file_rec.id
          , i_raw_data     => l_line
        );
        o_recap_rec.record_number := prc_api_file_pkg.get_record_number(
                                         i_sess_file_id => i_file_rec.id
                                     );
    end if;

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || ' >> o_recap_rec = {id [#1], record_number [#2]}'
      , i_env_param1 => o_recap_rec.id
      , i_env_param2 => o_recap_rec.record_number
    );
end add_recap_header;

procedure add_recap_trailer(
    io_recap_rec               in out nocopy din_api_type_pkg.t_recap_rec
) is
    LOG_PREFIX                      constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.add_recap_trailer';
    l_line                                   com_api_type_pkg.t_text;
    l_rate                                   number;
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || ' << io_recap_rec = {id [#1], file_id [#2]}'
      , i_env_param1 => io_recap_rec.id
      , i_env_param2 => io_recap_rec.file_id
    );

    io_recap_rec.net_amount := (io_recap_rec.debit_amount - io_recap_rec.credit_amount)
                             * (1 - io_recap_rec.program_transaction_amount / 100);

    if io_recap_rec.alt_currency is not null then
        begin
            l_rate:=
                com_api_rate_pkg.get_rate(
                    i_src_currency    => io_recap_rec.currency
                  , i_dst_currency    => io_recap_rec.alt_currency
                  , i_rate_type       => io_recap_rec.alt_rate_type
                  , i_inst_id         => io_recap_rec.inst_id
                  , i_eff_date        => io_recap_rec.recap_date
                  , i_conversion_type => com_api_const_pkg.CONVERSION_TYPE_BUYING
                  , i_mask_exception  => com_api_type_pkg.FALSE
                );
        exception
            when others then
                com_api_error_pkg.raise_error(
                    i_error      => 'DIN_ALT_CURRENCY_RATE_ERROR'
                  , i_env_param1 => io_recap_rec.currency
                  , i_env_param2 => io_recap_rec.alt_currency
                  , i_env_param3 => io_recap_rec.alt_rate_type
                  , i_env_param4 => io_recap_rec.inst_id
                  , i_env_param5 => io_recap_rec.recap_date
                );
        end;
        io_recap_rec.alt_net_amount   := l_rate * io_recap_rec.net_amount;
        io_recap_rec.alt_gross_amount := l_rate * (io_recap_rec.debit_amount - io_recap_rec.credit_amount);
    end if;

    l_line := din_api_const_pkg.TRANSACTION_CODE_OUTGOING   || din_api_const_pkg.DELIMITER
           || din_api_const_pkg.FUNCTION_CODE_RECAP_TRAILER || din_api_const_pkg.DELIMITER
           || io_recap_rec.sending_institution              || din_api_const_pkg.DELIMITER
           || to_char(io_recap_rec.recap_number, din_api_const_pkg.NUMBER_3DIGITS_FORMAT)
                                                            || din_api_const_pkg.DELIMITER
           || io_recap_rec.receiving_institution            || din_api_const_pkg.DELIMITER
           || io_recap_rec.credit_count                     || din_api_const_pkg.DELIMITER
           || com_api_currency_pkg.get_amount_str(
                  i_amount         => io_recap_rec.credit_amount
                , i_curr_code      => io_recap_rec.currency
                , i_mask_curr_code => com_api_type_pkg.TRUE
                , i_format_mask    => din_api_const_pkg.AMOUNT_FORMAT
                , i_mask_error     => com_api_type_pkg.FALSE
              )                                             || din_api_const_pkg.DELIMITER
           || io_recap_rec.debit_count                      || din_api_const_pkg.DELIMITER
           || com_api_currency_pkg.get_amount_str(
                  i_amount         => io_recap_rec.debit_amount
                , i_curr_code      => io_recap_rec.currency
                , i_mask_curr_code => com_api_type_pkg.TRUE
                , i_format_mask    => din_api_const_pkg.AMOUNT_FORMAT
                , i_mask_error     => com_api_type_pkg.FALSE
              )                                             || din_api_const_pkg.DELIMITER
           || to_char(io_recap_rec.program_transaction_amount
                    , din_api_const_pkg.PROGRAM_TRNSC_AMOUNT_FORMAT)
                                                            || din_api_const_pkg.DELIMITER
           || com_api_currency_pkg.get_amount_str(
                  i_amount         => io_recap_rec.net_amount
                , i_curr_code      => io_recap_rec.currency
                , i_mask_curr_code => com_api_type_pkg.TRUE
                , i_format_mask    => din_api_const_pkg.AMOUNT_FORMAT
                , i_mask_error     => com_api_type_pkg.FALSE
              )                                             || din_api_const_pkg.DELIMITER
           || com_api_currency_pkg.get_currency_name(i_curr_code => io_recap_rec.alt_currency)
                                                            || din_api_const_pkg.DELIMITER
           || com_api_currency_pkg.get_amount_str(
                  i_amount         => io_recap_rec.alt_gross_amount
                , i_curr_code      => io_recap_rec.alt_currency
                , i_mask_curr_code => com_api_type_pkg.TRUE
                , i_format_mask    => din_api_const_pkg.AMOUNT_FORMAT
                , i_mask_error     => com_api_type_pkg.FALSE
              )                                             || din_api_const_pkg.DELIMITER
           || com_api_currency_pkg.get_amount_str(
                  i_amount         => io_recap_rec.alt_net_amount
                , i_curr_code      => io_recap_rec.alt_currency
                , i_mask_curr_code => com_api_type_pkg.TRUE
                , i_format_mask    => din_api_const_pkg.AMOUNT_FORMAT
                , i_mask_error     => com_api_type_pkg.FALSE
              )
    ;
    if l_line is not null then
        prc_api_file_pkg.put_line(
            i_sess_file_id => io_recap_rec.file_id
          , i_raw_data     => l_line
        );
        io_recap_rec.record_number := prc_api_file_pkg.get_record_number(
                                          i_sess_file_id => io_recap_rec.file_id
                                      );
    end if;

    din_api_fin_message_pkg.save_recap(
        i_recap_rec => io_recap_rec
    );

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || ' >> io_recap_rec = {id [#1], record_number [#2]}'
      , i_env_param1 => io_recap_rec.id
      , i_env_param2 => io_recap_rec.record_number
    );
end add_recap_trailer;

procedure add_batch_header(
    i_recap_rec                in            din_api_type_pkg.t_recap_rec
  , i_batch_number             in            din_api_type_pkg.t_batch_number
  , o_batch_rec                   out        din_api_type_pkg.t_batch_rec
) is
    LOG_PREFIX        constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.add_batch_header';
    l_line                     com_api_type_pkg.t_text;
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || ' << i_recap_rec = {id [#1], file_id [#2]}, i_batch_number [#3]'
      , i_env_param1 => i_recap_rec.id
      , i_env_param2 => i_recap_rec.file_id
      , i_env_param3 => i_batch_number
    );
    o_batch_rec.id                     := din_batch_seq.nextval;
    o_batch_rec.recap_id               := i_recap_rec.id;
    o_batch_rec.batch_number           := i_batch_number;
    o_batch_rec.sending_institution    := i_recap_rec.sending_institution;
    o_batch_rec.receiving_institution  := i_recap_rec.receiving_institution;
    o_batch_rec.credit_count           := 0;
    o_batch_rec.credit_amount          := 0;
    o_batch_rec.debit_count            := 0;
    o_batch_rec.debit_amount           := 0;
    o_batch_rec.is_rejected            := null; -- reserved

    l_line := din_api_const_pkg.TRANSACTION_CODE_OUTGOING  || din_api_const_pkg.DELIMITER
           || din_api_const_pkg.FUNCTION_CODE_BATCH_HEADER || din_api_const_pkg.DELIMITER
           || i_recap_rec.sending_institution              || din_api_const_pkg.DELIMITER
           || to_char(i_recap_rec.recap_number, din_api_const_pkg.NUMBER_3DIGITS_FORMAT)
                                                           || din_api_const_pkg.DELIMITER
           || i_recap_rec.receiving_institution            || din_api_const_pkg.DELIMITER
           || to_char(o_batch_rec.batch_number, din_api_const_pkg.NUMBER_3DIGITS_FORMAT)
                                                           || din_api_const_pkg.DELIMITER
           || to_char(i_recap_rec.recap_date, din_api_const_pkg.REVERSE_DATE_FORMAT)
    ;
    if l_line is not null then
        prc_api_file_pkg.put_line(
            i_sess_file_id => i_recap_rec.file_id
          , i_raw_data     => l_line
        );
        o_batch_rec.record_number := prc_api_file_pkg.get_record_number(
                                         i_sess_file_id => i_recap_rec.file_id
                                     );
    end if;

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || ' >> o_batch_rec.record_number [#1]'
      , i_env_param1 => o_batch_rec.record_number
    );
end add_batch_header;

procedure add_batch_trailer(
    io_batch_rec               in out nocopy din_api_type_pkg.t_batch_rec
  , io_recap_rec               in out nocopy din_api_type_pkg.t_recap_rec
) is
    LOG_PREFIX                      constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.add_batch_trailer';
    l_line                                   com_api_type_pkg.t_text;
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || ' << io_batch_rec.batch_number [#3], io_recap_rec = {id [#1], file_id [#2]}'
      , i_env_param1 => io_recap_rec.id
      , i_env_param2 => io_recap_rec.file_id
      , i_env_param3 => io_batch_rec.batch_number
    );
    l_line := din_api_const_pkg.TRANSACTION_CODE_OUTGOING   || din_api_const_pkg.DELIMITER
           || din_api_const_pkg.FUNCTION_CODE_BATCH_TRAILER || din_api_const_pkg.DELIMITER
           || io_recap_rec.sending_institution              || din_api_const_pkg.DELIMITER
           || to_char(io_recap_rec.recap_number, din_api_const_pkg.NUMBER_3DIGITS_FORMAT)
                                                            || din_api_const_pkg.DELIMITER
           || io_recap_rec.receiving_institution            || din_api_const_pkg.DELIMITER
           || to_char(io_batch_rec.batch_number, din_api_const_pkg.NUMBER_3DIGITS_FORMAT)
                                                            || din_api_const_pkg.DELIMITER
           || io_batch_rec.credit_count                     || din_api_const_pkg.DELIMITER
           || com_api_currency_pkg.get_amount_str(
                  i_amount         => io_batch_rec.credit_amount
                , i_curr_code      => io_recap_rec.currency
                , i_mask_curr_code => com_api_type_pkg.TRUE
                , i_format_mask    => din_api_const_pkg.AMOUNT_FORMAT
                , i_mask_error     => com_api_type_pkg.FALSE
              )                                             || din_api_const_pkg.DELIMITER
           || io_batch_rec.debit_count                      || din_api_const_pkg.DELIMITER
           || com_api_currency_pkg.get_amount_str(
                  i_amount         => io_batch_rec.debit_amount
                , i_curr_code      => io_recap_rec.currency
                , i_mask_curr_code => com_api_type_pkg.TRUE
                , i_format_mask    => din_api_const_pkg.AMOUNT_FORMAT
                , i_mask_error     => com_api_type_pkg.FALSE
              )
    ;
    if l_line is not null then
        prc_api_file_pkg.put_line(
            i_sess_file_id => io_recap_rec.file_id
          , i_raw_data     => l_line
        );
        io_batch_rec.record_number := prc_api_file_pkg.get_record_number(
                                          i_sess_file_id => io_recap_rec.file_id
                                      );
    end if;

    din_api_fin_message_pkg.save_batch(
        i_batch_rec => io_batch_rec
    );

    -- Update totals for the parrent recap
    io_recap_rec.credit_count  := io_recap_rec.credit_count  + io_batch_rec.credit_count;
    io_recap_rec.credit_amount := io_recap_rec.credit_amount + io_batch_rec.credit_amount;
    io_recap_rec.debit_count   := io_recap_rec.debit_count   + io_batch_rec.debit_count;
    io_recap_rec.debit_amount  := io_recap_rec.debit_amount  + io_batch_rec.debit_amount;

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || ' >> io_batch_rec.record_number [#1]'
      , i_env_param1 => io_batch_rec.record_number
    );
end add_batch_trailer;

procedure add_fin_message(
    io_fin_rec                 in out nocopy din_api_type_pkg.t_fin_message_rec
  , i_recap_number             in            din_api_type_pkg.t_recap_number
  , io_batch_rec               in out nocopy din_api_type_pkg.t_batch_rec
) is
    l_line                                   com_api_type_pkg.t_text;
begin
    io_fin_rec.batch_id := io_batch_rec.id;

    l_line := din_api_const_pkg.TRANSACTION_CODE_OUTGOING    || din_api_const_pkg.DELIMITER
           || din_api_const_pkg.FUNCTION_CODE_DETAIL_MESSAGE || din_api_const_pkg.DELIMITER
           || io_batch_rec.sending_institution               || din_api_const_pkg.DELIMITER
           || to_char(i_recap_number, din_api_const_pkg.NUMBER_3DIGITS_FORMAT)
                                                             || din_api_const_pkg.DELIMITER
           || io_batch_rec.receiving_institution             || din_api_const_pkg.DELIMITER
           || to_char(io_batch_rec.batch_number, din_api_const_pkg.NUMBER_3DIGITS_FORMAT)
                                                             || din_api_const_pkg.DELIMITER
           || to_char(io_fin_rec.sequential_number, din_api_const_pkg.NUMBER_3DIGITS_FORMAT)
                                                             || din_api_const_pkg.DELIMITER
           || io_fin_rec.card_number                         || din_api_const_pkg.DELIMITER
           || com_api_currency_pkg.get_amount_str(
                  i_amount         => io_fin_rec.oper_amount
                , i_curr_code      => io_fin_rec.oper_currency
                , i_mask_curr_code => com_api_type_pkg.TRUE
                , i_format_mask    => din_api_const_pkg.AMOUNT_FORMAT
                , i_mask_error     => com_api_type_pkg.FALSE
              )                                              || din_api_const_pkg.DELIMITER
           || to_char(io_fin_rec.charge_date, din_api_const_pkg.DATE_FORMAT)
                                                             || din_api_const_pkg.DELIMITER
           || io_fin_rec.date_type                           || din_api_const_pkg.DELIMITER
           || io_fin_rec.charge_type                         || din_api_const_pkg.DELIMITER -- CHTYP (11)
           || io_fin_rec.merchant_name                       || din_api_const_pkg.DELIMITER
           || io_fin_rec.merchant_city                       || din_api_const_pkg.DELIMITER
           || io_fin_rec.merchant_country                    || din_api_const_pkg.DELIMITER
           || io_fin_rec.action_code                         || din_api_const_pkg.DELIMITER -- APPCD (15)
           || io_fin_rec.type_of_charge                      || din_api_const_pkg.DELIMITER -- TYPCH (16)
           || io_fin_rec.originator_refnum                   || din_api_const_pkg.DELIMITER -- REFNO (17)
           || io_fin_rec.auth_code                           || din_api_const_pkg.DELIMITER
           || io_fin_rec.merchant_number                     || din_api_const_pkg.DELIMITER
           || null                                           || din_api_const_pkg.DELIMITER -- BLCUR (20)
           || null                                           || din_api_const_pkg.DELIMITER -- BLMAT (21)
           || io_fin_rec.merchant_international_code         || din_api_const_pkg.DELIMITER
           || io_fin_rec.merchant_street                     || din_api_const_pkg.DELIMITER
           || io_fin_rec.merchant_state                      || din_api_const_pkg.DELIMITER
           || io_fin_rec.merchant_postcode                   || din_api_const_pkg.DELIMITER
           || io_fin_rec.merchant_phone                      || din_api_const_pkg.DELIMITER
           || null                                           || din_api_const_pkg.DELIMITER -- MSCCD, reserved
           || io_fin_rec.mcc                                 || din_api_const_pkg.DELIMITER
           || null                                           || din_api_const_pkg.DELIMITER -- tax1, isn't used
           || null                                           || din_api_const_pkg.DELIMITER -- tax2, isn't used
           || io_fin_rec.original_document_number            || din_api_const_pkg.DELIMITER
           -- CUSRF1 .. CUSRF6, aren't used
           || null                                           || din_api_const_pkg.DELIMITER
           || null                                           || din_api_const_pkg.DELIMITER
           || null                                           || din_api_const_pkg.DELIMITER
           || null                                           || din_api_const_pkg.DELIMITER
           || null                                           || din_api_const_pkg.DELIMITER
           || null                                           || din_api_const_pkg.DELIMITER
           || io_fin_rec.crdh_presence                       || din_api_const_pkg.DELIMITER -- CHOLDP
           || io_fin_rec.card_presence                       || din_api_const_pkg.DELIMITER -- CARDP
           || io_fin_rec.card_data_input_mode                || din_api_const_pkg.DELIMITER -- CPTRM
           || null                                           || din_api_const_pkg.DELIMITER -- ECI
           || null                                           || din_api_const_pkg.DELIMITER -- CAVV
           || io_fin_rec.network_refnum                      || din_api_const_pkg.DELIMITER -- NRID
           || io_fin_rec.card_data_input_capability          || din_api_const_pkg.DELIMITER -- CRDINP
           || null                                           || din_api_const_pkg.DELIMITER -- SURFEE
           || null                                           || din_api_const_pkg.DELIMITER -- TRMTYP
           || io_fin_rec.merchant_country                                                   -- AQGEO
    ;
    if l_line is not null then
        prc_api_file_pkg.put_line(
            i_sess_file_id => io_fin_rec.file_id
          , i_raw_data     => l_line
        );
        io_fin_rec.record_number := prc_api_file_pkg.get_record_number(
                                        i_sess_file_id => io_fin_rec.file_id
                                    );
    end if;

    -- Register charge amount of current message in the parent batch
    if din_api_fin_message_pkg.get_impact(
           i_type_of_charge => io_fin_rec.type_of_charge
       ) = com_api_const_pkg.DEBIT
    then
        io_batch_rec.debit_count   := io_batch_rec.debit_count   + 1;
        io_batch_rec.debit_amount  := io_batch_rec.debit_amount  + io_fin_rec.oper_amount;
    else
        io_batch_rec.credit_count  := io_batch_rec.credit_count  + 1;
        io_batch_rec.credit_amount := io_batch_rec.credit_amount + io_fin_rec.oper_amount;
    end if;
end add_fin_message;

procedure add_addendums(
    i_fin_rec                  in            din_api_type_pkg.t_fin_message_rec
  , i_recap_number             in            din_api_type_pkg.t_recap_number
  , i_batch_rec                in            din_api_type_pkg.t_batch_rec
) is
    LOG_PREFIX                      constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.add_addendums';
    l_line                                   com_api_type_pkg.t_text;
    l_addendum_tab                           din_api_type_pkg.t_addendum_tab;
    l_addendum_ext_tab                       din_api_type_pkg.t_addendum_extented_tab;
    l_function_code                          din_api_type_pkg.t_function_code;
    l_addendum_id                            com_api_type_pkg.t_long_id;
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || ' << with i_fin_rec.id [#1]'
      , i_env_param1 => i_fin_rec.id
    );

    select a.id
         , at.priority
         , a.function_code
         , av.field_name
         , av.field_value
         , af.field_number
         , af.format
         , af.field_length
      bulk collect into
           l_addendum_ext_tab
      from din_addendum a
      join din_addendum_value av  on av.addendum_id   = a.id
      join din_message_type at    on at.function_code = a.function_code
      join din_message_field af   on af.function_code = a.function_code
                                 and af.field_name    = av.field_name
     where a.fin_id            = i_fin_rec.id
       and at.message_category = din_api_const_pkg.MSG_CATEGORY_ADDENDUM
     order by
           at.priority
         , af.field_number;

    --trc_log_pkg.debug('l_addendum_ext_tab.count() = ' || l_addendum_ext_tab.count());

    if l_addendum_ext_tab.count() > 0 then
        for i in 1 .. l_addendum_ext_tab.count() + 1 loop
            --trc_log_pkg.debug('l_function_code [' || l_function_code || ']');

            if  i > l_addendum_ext_tab.count()
                or
                l_function_code != l_addendum_ext_tab(i).function_code
            then
                l_line := din_api_const_pkg.TRANSACTION_CODE_OUTGOING    || din_api_const_pkg.DELIMITER
                       || l_function_code                                || din_api_const_pkg.DELIMITER
                       || i_batch_rec.sending_institution                || din_api_const_pkg.DELIMITER
                       || to_char(i_recap_number, din_api_const_pkg.NUMBER_3DIGITS_FORMAT)
                                                                         || din_api_const_pkg.DELIMITER
                       || i_batch_rec.receiving_institution              || din_api_const_pkg.DELIMITER
                       || to_char(i_batch_rec.batch_number, din_api_const_pkg.NUMBER_3DIGITS_FORMAT)
                                                                         || din_api_const_pkg.DELIMITER
                       || to_char(i_fin_rec.sequential_number, din_api_const_pkg.NUMBER_3DIGITS_FORMAT)
                                                                         || din_api_const_pkg.DELIMITER
                       || to_char(1, din_api_const_pkg.NUMBER_3DIGITS_FORMAT) -- SUSEQ (sub-sequence number)
                       || l_line;

                --trc_log_pkg.debug('(finished) l_line [' || l_line || ']');

                prc_api_file_pkg.put_line(
                    i_sess_file_id => i_fin_rec.file_id
                  , i_raw_data     => l_line
                );

                l_addendum_tab(l_addendum_tab.count() + 1).id := l_addendum_id;
                l_addendum_tab(l_addendum_tab.count()).record_number :=
                    prc_api_file_pkg.get_record_number(
                        i_sess_file_id => i_fin_rec.file_id
                    );

                l_line := null;
            end if;

            if i <= l_addendum_ext_tab.count() then
                --trc_log_pkg.debug(
                --    i_text       => 'l_addendum_ext_tab(#1) = {function_code [#2], field_value [#3]}'
                --  , i_env_param1 => i
                --  , i_env_param2 => l_addendum_ext_tab(i).function_code
                --  , i_env_param3 => l_addendum_ext_tab(i).field_value
                --);

                l_line := l_line || din_api_const_pkg.DELIMITER || l_addendum_ext_tab(i).field_value;
                --trc_log_pkg.debug('l_line [' || l_line || ']');

                l_function_code := l_addendum_ext_tab(i).function_code;
                l_addendum_id   := l_addendum_ext_tab(i).id;
            end if;
        end loop;
    end if;

    forall i in 1 .. l_addendum_tab.count()
        update din_addendum
           set file_id           = i_fin_rec.file_id
             , record_number     = l_addendum_tab(i).record_number
         where id = l_addendum_tab(i).id;

    trc_log_pkg.debug(LOG_PREFIX || ' >>');
end add_addendums;

procedure mark_fin_messages(
    i_fin_message_tab          in            din_api_type_pkg.t_fin_message_tab
) is
begin
    forall i in 1 .. i_fin_message_tab.count()
        update din_fin_message
           set file_id           = i_fin_message_tab(i).file_id
             , batch_id          = i_fin_message_tab(i).batch_id
             , record_number     = i_fin_message_tab(i).record_number
             , sequential_number = i_fin_message_tab(i).sequential_number
             , status            = net_api_const_pkg.CLEARING_MSG_STATUS_UPLOADED
         where id = i_fin_message_tab(i).id;
end mark_fin_messages;

procedure process(
    i_network_id               in            com_api_type_pkg.t_tiny_id    default null
  , i_inst_id                  in            com_api_type_pkg.t_inst_id    default null
  , i_start_date               in            date                          default null
  , i_end_date                 in            date                          default null
  , i_include_affiliate        in            com_api_type_pkg.t_boolean    default com_api_const_pkg.FALSE
) is
    LOG_PREFIX        constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.process';
    l_standard_id              com_api_type_pkg.t_tiny_id;
    l_host_id                  com_api_type_pkg.t_tiny_id;
    l_file_rec                 din_api_type_pkg.t_file_rec;
    l_recap_rec                din_api_type_pkg.t_recap_rec;
    l_batch_rec                din_api_type_pkg.t_batch_rec;
    l_message_id_tab           com_api_type_pkg.t_number_tab;
    l_fin_cur                  din_api_type_pkg.t_fin_message_cur;
    l_fin_tab                  din_api_type_pkg.t_fin_message_tab;
    l_prev_fin_rec             din_api_type_pkg.t_fin_message_rec;
    l_estimated_count          com_api_type_pkg.t_count := 0;
    l_processed_count          com_api_type_pkg.t_count := 0;
    l_messages_count           com_api_type_pkg.t_count := 0;
    l_batch_count              com_api_type_pkg.t_count := 0;
    l_different_chtyp_classes  boolean;

    function open_file(
        i_inst_id             in     com_api_type_pkg.t_inst_id
      , i_network_id          in     com_api_type_pkg.t_tiny_id
    ) return com_api_type_pkg.t_long_id
    is
        l_sess_file_id               com_api_type_pkg.t_long_id;
        l_params                     com_api_type_pkg.t_param_tab;
    begin
        rul_api_param_pkg.set_param(
            i_name    => 'INST_ID'
          , i_value   => to_char(i_inst_id)
          , io_params => l_params
        );
        rul_api_param_pkg.set_param(
            i_name    => 'NETWORK_ID'
          , i_value   => i_network_id
          , io_params => l_params
        );
        rul_api_param_pkg.set_param (
            i_name    => 'KEY_INDEX'
          , i_value   => 1
          , io_params => l_params
        );
        prc_api_file_pkg.open_file(
            o_sess_file_id => l_sess_file_id
          , i_file_type    => din_api_const_pkg.FILE_TYPE_DINERS_CLEARING
          , io_params      => l_params
        );
        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || '->open_file() >> l_sess_file_id [#1]'
          , i_env_param1 => l_sess_file_id
        );
        return l_sess_file_id;
    end open_file;

begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || ' << with i_network_id [#1], i_inst_id [#2]'
                                   || ', i_start_date [#3], i_end_date [#4]'
      , i_env_param1 => i_network_id
      , i_env_param2 => i_inst_id
      , i_env_param3 => to_char(i_start_date, com_api_const_pkg.XML_DATE_FORMAT)
      , i_env_param4 => to_char(i_end_date,   com_api_const_pkg.XML_DATE_FORMAT)
    );

    prc_api_stat_pkg.log_start();

    l_file_rec.is_incoming := com_api_type_pkg.FALSE;
    l_file_rec.network_id  := nvl(i_network_id, din_api_const_pkg.DIN_NETWORK_ID);
    l_file_rec.inst_id     := nvl(i_inst_id,    din_api_const_pkg.DIN_INSTITUTION_ID);
    l_file_rec.recap_total := 0;
    l_file_rec.file_date   := com_api_sttl_day_pkg.get_sysdate();
    l_file_rec.is_rejected := null; -- reserved

    l_host_id     := net_api_network_pkg.get_default_host(i_network_id => l_file_rec.network_id);
    l_standard_id := net_api_network_pkg.get_offline_standard(i_host_id => l_host_id);

    trc_log_pkg.debug(
        i_text       => 'inst_id [#1], network_id [#2], l_host_id [#3], l_standard_id [#4]'
      , i_env_param1 => l_file_rec.inst_id
      , i_env_param2 => l_file_rec.network_id
      , i_env_param3 => l_host_id
      , i_env_param4 => l_standard_id
    );

    l_estimated_count := din_api_fin_message_pkg.estimate_messages_for_export(
                             i_network_id           => l_file_rec.network_id
                           , i_inst_id              => l_file_rec.inst_id
                           , i_start_date           => trunc(i_start_date)
                           , i_end_date             => trunc(i_end_date)
                           , i_include_affiliate    => i_include_affiliate
                         );

    prc_api_stat_pkg.log_estimation(
        i_estimated_count => l_estimated_count
    );

    if l_estimated_count > 0 then
        din_api_fin_message_pkg.enum_messages_for_export(
            o_fin_cur               => l_fin_cur
          , i_network_id            => l_file_rec.network_id
          , i_inst_id               => l_file_rec.inst_id
          , i_start_date            => trunc(i_start_date)
          , i_end_date              => trunc(i_end_date)
          , i_include_affiliate     => i_include_affiliate
        );

        l_file_rec.id := open_file(
                             i_network_id => l_file_rec.network_id
                           , i_inst_id    => l_file_rec.inst_id
                         );
        trc_log_pkg.debug(
            i_text       => 'l_file_rec.id [#1], l_estimated_count [#2]'
          , i_env_param1 => l_file_rec.id
          , i_env_param2 => l_estimated_count
        );

        -- Clearing file contains messages that are grouped into batches, and they are grouped into recaps.
        -- Every recap may contain a maximum of MAX_BATCH_COUNT_WITHIN_RECAP batches,
        -- and every batch contains no more than MAX_MESSAGE_COUNT_WITHIN_BATCH regular messages
        -- plus associated additional detail records (addendum).
        l_batch_count    := 0;
        l_messages_count := 0;
        loop
            l_message_id_tab.delete();

            fetch l_fin_cur bulk collect into l_fin_tab limit BULK_LIMIT;

            for i in 1..l_fin_tab.count() loop
                -- Numeration within a batch
                l_messages_count := mod(l_messages_count + 1, din_api_const_pkg.MAX_MESSAGE_COUNT_WITHIN_BATCH + 1);

                trc_log_pkg.debug('l_messages_count [' || l_messages_count || ']');

                -- Every charge type may be classified as cash or non-cash charge type.
                -- A recap should contain fin. messages of one class only. So if charge type class of
                -- current and previous fin. messages are different then a new recap should be created.
                l_different_chtyp_classes := din_api_fin_message_pkg.is_cash_charge_type(
                                                 i_charge_type => l_prev_fin_rec.charge_type
                                             )
                                          != din_api_fin_message_pkg.is_cash_charge_type(
                                                 i_charge_type => l_fin_tab(i).charge_type
                                             );
                trc_log_pkg.debug(
                    i_text       => 'l_different_chtyp_classes [#1]'
                  , i_env_param1 => case l_different_chtyp_classes
                                        when true  then 'TRUE'
                                        when false then 'FALSE'
                                    end
                );

                -- Start a new recap on the beginning (there are no batch) or on changing one of key fields,
                -- because the cursor <l_fin_tab> returns records that are ordered by these key fields
                if     l_batch_count = 0
                    or l_batch_count = din_api_const_pkg.MAX_BATCH_COUNT_WITHIN_RECAP
                    or l_prev_fin_rec.program_transaction_amount != l_fin_tab(i).program_transaction_amount
                    or l_prev_fin_rec.oper_currency              != l_fin_tab(i).oper_currency
                    or nvl(l_prev_fin_rec.sttl_currency, '0')    != nvl(l_fin_tab(i).sttl_currency, '0')
                    or l_prev_fin_rec.sending_institution        != l_fin_tab(i).sending_institution
                    or l_prev_fin_rec.receiving_institution      != l_fin_tab(i).receiving_institution
                    or l_different_chtyp_classes
                then
                    -- Do not add trailers on the process beginning
                    if l_batch_count > 0 then
                        add_batch_trailer(
                            io_batch_rec   => l_batch_rec
                          , io_recap_rec   => l_recap_rec
                        );
                        add_recap_trailer(
                            io_recap_rec   => l_recap_rec
                        );
                    end if;

                    l_batch_count    := 1;
                    l_messages_count := 1;

                    add_recap_header(
                        i_file_rec     => l_file_rec
                      , i_fin_rec      => l_fin_tab(i)
                      , o_recap_rec    => l_recap_rec
                    );
                    add_batch_header(
                        i_recap_rec    => l_recap_rec
                      , i_batch_number => l_batch_count
                      , o_batch_rec    => l_batch_rec
                    );

                    l_file_rec.recap_total := l_file_rec.recap_total + 1;

                elsif l_messages_count = 0 then
                    -- Current batch is exhausted, add a new batch
                    l_batch_count := l_batch_count + 1;
                    l_messages_count := 1;

                    add_batch_trailer(
                        io_batch_rec   => l_batch_rec
                      , io_recap_rec   => l_recap_rec
                    );
                    add_batch_header(
                        i_recap_rec    => l_recap_rec
                      , i_batch_number => l_batch_count
                      , o_batch_rec    => l_batch_rec
                    );
                end if;

                l_fin_tab(i).sequential_number := l_messages_count;
                l_fin_tab(i).file_id           := l_recap_rec.file_id;

                add_fin_message(
                    io_fin_rec      => l_fin_tab(i)
                  , i_recap_number  => l_recap_rec.recap_number
                  , io_batch_rec    => l_batch_rec
                );
                add_addendums(
                    i_fin_rec       => l_fin_tab(i)
                  , i_recap_number  => l_recap_rec.recap_number
                  , i_batch_rec     => l_batch_rec
                );

                l_message_id_tab(i) := l_fin_tab(i).id;
                l_prev_fin_rec      := l_fin_tab(i);
            end loop;

            mark_fin_messages(
                i_fin_message_tab => l_fin_tab
            );
            opr_api_clearing_pkg.mark_uploaded(
                i_id_tab          => l_message_id_tab
            );

            l_processed_count := l_processed_count + l_fin_tab.count();

            prc_api_stat_pkg.log_current(
                i_current_count   => l_processed_count
              , i_excepted_count  => 0
            );

            exit when l_fin_cur%notfound;
        end loop;

        close l_fin_cur;

        if l_recap_rec.id is not null and l_batch_rec.id is not null then
            add_batch_trailer(
                io_batch_rec => l_batch_rec
              , io_recap_rec => l_recap_rec
            );
            add_recap_trailer(
                io_recap_rec => l_recap_rec
            );
        end if;

        din_api_fin_message_pkg.save_file(
            i_file_rec => l_file_rec
        );

        prc_api_file_pkg.close_file(
            i_sess_file_id => l_file_rec.id
          , i_status       => prc_api_const_pkg.FILE_STATUS_ACCEPTED
        );
    end if;

    prc_api_stat_pkg.log_end(
        i_result_code     => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
      , i_processed_total => l_processed_count
    );

    trc_log_pkg.debug(LOG_PREFIX || ' >>');

exception
    when others then
        if l_fin_cur%isopen then
            close l_fin_cur;
        end if;

        prc_api_stat_pkg.log_end(
            i_result_code => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if l_file_rec.id is not null then
            prc_api_file_pkg.close_file(
                i_sess_file_id => l_file_rec.id
              , i_status       => prc_api_const_pkg.FILE_STATUS_REJECTED
            );
        end if;

        if  com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE
            or
            com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE
        then
            raise;
        else
            com_api_error_pkg.raise_fatal_error(
                i_error      => 'UNHANDLED_EXCEPTION'
              , i_env_param1 => sqlerrm
            );
        end if;
end process;

end;
/
