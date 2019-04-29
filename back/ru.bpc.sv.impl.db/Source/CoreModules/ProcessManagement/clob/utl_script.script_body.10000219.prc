begin update prc_session_file set status = decode(status
                                       , 'PSFS0001', 'FLSTACPT'
                                       , 'PSFS0002', 'FLSTACPT'
                                       , 'PSFS0003', 'FLSTRJCT'
                                       , 'PSFS0004', 'FLSTRJCT'
                                       , 'PSFS0005', 'FLSTACPT'
                                       , status
                                      ); end;
