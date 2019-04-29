create or replace force view net_ui_host_substitution_vw as
select n.id
     , n.seqnum
     , n.oper_type
     , n.terminal_type
     , n.pan_low
     , n.pan_high
     , n.acq_inst_id
     , case when n.acq_inst_id = '%' then 
          n.acq_inst_id
      else 
          get_text (i_table_name    => 'ost_institution',
                    i_column_name   => 'name',
                    i_object_id     => n.acq_inst_id,
                    i_lang          => l.lang)
      end AS acq_inst_name   
     , n.acq_network_id
     , case when n.acq_network_id = '%' then 
          n.acq_network_id
      else
          get_text (i_table_name    => 'net_network',
                    i_column_name   => 'name',
                    i_object_id     => n.acq_network_id,
                    i_lang          => l.lang)
     end AS acq_network_name
     , n.card_inst_id
     , case when n.card_inst_id = '%' then 
          n.card_inst_id
      else      
          get_text (i_table_name    => 'ost_institution',
                    i_column_name   => 'name',
                    i_object_id     => n.card_inst_id,
                    i_lang          => l.lang)
      end AS card_inst_name
     , n.card_network_id
     , case when n.card_network_id = '%' then 
          n.card_network_id
      else     
          get_text (i_table_name    => 'net_network',
                    i_column_name   => 'name',
                    i_object_id     => n.card_network_id,
                    i_lang          => l.lang)
      end AS card_network_name
     , n.iss_inst_id
     , case when n.iss_inst_id = '%' then 
          n.iss_inst_id
      else    
          get_text (i_table_name    => 'ost_institution',
                    i_column_name   => 'name',
                    i_object_id     => n.iss_inst_id,
                    i_lang          => l.lang)
      end AS iss_inst_name
     , n.iss_network_id
     , case when n.iss_network_id = '%' then 
          n.iss_network_id
      else    
          get_text (i_table_name    => 'net_network',
                    i_column_name   => 'name',
                    i_object_id     => n.iss_network_id,
                    i_lang          => l.lang)
      end AS iss_network_name
     , n.priority          
     , n.substitution_inst_id
     , case when n.substitution_inst_id = '%' then
          n.substitution_inst_id
      else     
          get_text (i_table_name    => 'ost_institution',
                    i_column_name   => 'name',
                    i_object_id     => n.substitution_inst_id,
                    i_lang          => l.lang)
      end AS sub_inst_name
     , n.substitution_network_id
     , case when n.substitution_network_id = '%' then
          n.substitution_network_id
      else    
          get_text (i_table_name    => 'net_network',
                    i_column_name   => 'name',
                    i_object_id     => n.substitution_network_id,
                    i_lang          => l.lang)
      end AS sub_network_name
     , n.msg_type
     , n.oper_reason
     , n.oper_currency 
     , n.merchant_array_id
     , n.terminal_array_id
     , n.card_country
     , l.lang
 FROM net_host_substitution n, com_language_vw l
/
