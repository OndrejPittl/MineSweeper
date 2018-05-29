
/******************* Test *********************/

drop sequence seq_tmp_id_increment;
drop sequence seq_hra_id_increment;
drop sequence seq_pole_id_increment;
drop sequence seq_mina_id_increment;
drop sequence seq_oblast_id_increment;


declare
begin
  dev_drop_tables();

  -- clean + init database
  -- clear_all();
  -- initialize();

  -- clean current game
  -- clear_game();
  -- initialize_game();
end;

begin
  delete from pole where pole.id_hra = game_settings.game_id;
  initialize_fields();
  zaminuj_oblast();
  print_game_area();
  spocitej_oblast();
  print_game_area();
end;


begin
  --delete from tmp;
  --print_game_area();
  --odkryj_pole(1, 3);
  --print_game_area();
end;



begin
  update pole set pole.value = 0;
  zaminuj_oblast();
  spocitej_oblast();
  print_game_area();
end;


-- drop table tah;



begin
  delete from pole where pole.id_hra = game_settings.game_id;
  initialize_fields();
  print_game_area();
end;




declare
  neighbours   neighbour_array;
begin
  neighbours := get_neighbour_fields(2,2);
end;




begin
    --unmarkedCantBeUnmarkedEx    exception;
  --new_move(4, 9, game_constants.MOVE_UNMARK);

  --markedCantBeMarkedEx        exception;
  --new_move(4, 9, game_constants.MOVE_MARK);
  --new_move(4, 9, game_constants.MOVE_MARK);

  --markedCantBeUncoveredEx     exception;
  --new_move(4, 9, game_constants.MOVE_UNCOVER);

  --uncoveredCantBeUncoveredEx  exception;
  --new_move(4, 9, game_constants.MOVE_UNMARK);
  --new_move(4, 9, game_constants.MOVE_UNCOVER);
  --new_move(4, 9, game_constants.MOVE_UNCOVER);

  --uncoveredCantBeMarkedEx     exception;
  --new_move(4, 9, game_constants.MOVE_MARK);
end;