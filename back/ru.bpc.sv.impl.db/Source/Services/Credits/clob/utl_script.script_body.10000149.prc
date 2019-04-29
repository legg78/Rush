begin
    update crd_event_bunch_type set event_type = 'CYTP1010' where event_type = 'CYTP0407';
    update crd_event_bunch_type set event_type = 'CYTP1011' where event_type = 'CYTP0408';
    update crd_event_bunch_type set event_type = 'CYTP1012' where event_type = 'CYTP0406';
end;
