create or replace force view opr_participant_unpivot_vw as
select 
   o.oper_id
   , x.column_id
   , x.column_name
   , x.data_type
   , o.participant_type
   , (case x.column_name
        when 'inst_id' then to_char(o.inst_id,'FM000000000000000000.0000')
        when 'network_id' then to_char(o.network_id,'FM000000000000000000.0000')
        when 'split_hash' then to_char(o.split_hash,'FM000000000000000000.0000')
        when 'client_id_type' then o.client_id_type
        when 'client_id_value' then o.client_id_value
        when 'customer_id' then to_char(o.customer_id,'FM000000000000000000.0000')
        when 'auth_code' then o.auth_code
        when 'card_id' then to_char(o.card_id,'FM000000000000000000.0000')
        when 'card_instance_id' then to_char(o.card_instance_id,'FM000000000000000000.0000')
        when 'card_type_id' then to_char(o.card_type_id,'FM000000000000000000.0000')
        when 'card_mask' then o.card_mask
        when 'card_hash' then to_char(o.card_hash,'FM000000000000000000.0000')
        when 'card_seq_number' then to_char(o.card_seq_number,'FM000000000000000000.0000')
        when 'card_expir_date' then to_char(o.card_expir_date,'yyyymmddhh24miss')
        when 'card_service_code' then o.card_service_code
        when 'card_country' then o.card_country
        when 'card_network_id' then to_char(o.card_network_id,'FM000000000000000000.0000')
        when 'card_inst_id' then to_char(o.card_inst_id,'FM000000000000000000.0000')
        when 'account_id' then to_char(o.account_id,'FM000000000000000000.0000')
        when 'account_type' then o.account_type
        when 'account_number' then o.account_number
        when 'account_amount' then to_char(o.account_amount,'FM000000000000000000.0000')
        when 'account_currency' then o.account_currency
        when 'merchant_id' then to_char(o.merchant_id,'FM000000000000000000.0000')
        when 'terminal_id' then to_char(o.terminal_id,'FM000000000000000000.0000')
      else 'n/a'
      end) as value
 from opr_participant o
 join (select z.column_id
            , lower(z.column_name) as column_name
            , lower(z.data_type) as data_type 
         from user_tab_columns z 
        where lower(z.table_name) = 'opr_participant' 
          and lower(z.column_name) != 'oper_id'
          and lower(z.column_name) != 'participant_type'
          ) x on (1=1)
/