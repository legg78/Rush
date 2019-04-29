create or replace package body svy_api_survey_pkg is

function get_survey(
    i_id               in com_api_type_pkg.t_short_id
  , i_mask_error       in com_api_type_pkg.t_boolean   default com_api_const_pkg.FALSE
) return svy_api_type_pkg.t_survey_rec is
    l_survey_rec          svy_api_type_pkg.t_survey_rec;
begin
    select s.id
         , s.seqnum
         , s.inst_id
         , s.entity_type
         , s.survey_number
         , s.status
         , s.start_date
         , s.end_date
      into l_survey_rec
      from svy_survey s
     where s.id = i_id;

    return l_survey_rec;
exception
    when no_data_found then
        if nvl(i_mask_error, com_api_const_pkg.FALSE) = com_api_type_pkg.FALSE then
            com_api_error_pkg.raise_error(
                i_error      => 'SURVEY_BY_ID_NOT_FOUND'
              , i_env_param1 => i_id
            );
        else
           trc_log_pkg.debug(
               i_text        => 'Survey not found by ID [#1]' 
             , i_env_param1  => i_id
           );
           return l_survey_rec;
        end if;
end get_survey;

function get_survey(
    i_survey_number    in com_api_type_pkg.t_name
  , i_inst_id          in com_api_type_pkg.t_inst_id
  , i_mask_error       in com_api_type_pkg.t_boolean   default com_api_const_pkg.FALSE
) return svy_api_type_pkg.t_survey_rec is
    l_survey_rec       svy_api_type_pkg.t_survey_rec;
begin
    select s.id
         , s.seqnum
         , s.inst_id
         , s.entity_type
         , s.survey_number
         , s.status
         , s.start_date
         , s.end_date
      into l_survey_rec
      from svy_survey s
     where s.id = (select min(s.id) keep (dense_rank first order by s.inst_id)
                     from svy_survey s
                    where s.survey_number  = i_survey_number
                      and s.inst_id       in (i_inst_id, ost_api_const_pkg.DEFAULT_INST));

    return l_survey_rec;
exception
    when no_data_found then
        if nvl(i_mask_error, com_api_const_pkg.FALSE) = com_api_type_pkg.FALSE then
            com_api_error_pkg.raise_error(
                i_error      => 'SURVEY_BY_NUMBER_NOT_FOUND'
              , i_env_param1 => i_survey_number
              , i_env_param2 => i_inst_id
            );
        else
           trc_log_pkg.debug(
               i_text        => 'Survey not found by number [#1] for institution [#2]' 
             , i_env_param1  => i_survey_number
             , i_env_param2  => i_inst_id
           );
           return l_survey_rec;
        end if;
end get_survey;

end svy_api_survey_pkg;
/
