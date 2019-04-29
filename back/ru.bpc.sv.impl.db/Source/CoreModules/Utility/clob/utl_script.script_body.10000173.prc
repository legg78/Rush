declare
    l_dict_version_id number;
    l_new_process_id number;
begin
    select id
      into l_dict_version_id 
      from prc_parameter 
     where param_name = 'I_DICT_VERSION';
     
     select id 
       into l_new_process_id
       from prc_process
      where upper(procedure_name) = 'COM_PRC_DICT_EXPORT_PKG.PROCESS';

    for param in (
        select pv.id
          from prc_parameter_value pv
             , prc_container c
             , prc_parameter p
         where pv.container_id = c.id 
           and c.process_id    in (10001050, 10001058)
           and p.id            = pv.param_id
           and p.param_name in ('I_MPT_VERSION', 'I_DWH_VERSION')
    ) loop
        update prc_parameter_value pv
           set pv.param_id    = l_dict_version_id
             , pv.param_value = '1.0'
         where pv.id          = param.id;
    
    end loop;

    update prc_file_attribute a
       set a.file_id = (select f.id from prc_file f where f.process_id = l_new_process_id)
     where a.container_id in (
         select c.id 
           from prc_container c 
          where c.process_id in (10001050, 10001058)
        );

    update prc_container c
       set c.process_id = l_new_process_id
     where c.process_id in  (10001050, 10001058);

end;

