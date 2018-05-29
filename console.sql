
/**
*
* Mine Sweeper, 2018
* Author:  Ondřej Pittl, ondrejpittl.cz
* University project, KIV/DB2.
*
* DBMS Oracle.
*
* ------------------------------------------------------
* Note:
* Naming conventions restricted due to work assignment
* and project evaluation.
*/



-- **************** GameSetting *****************


-- *****
-- Holds game settings.
-- ***********
-- create or replace package game_settings is
--  game_id     number := 1;
--  error_msg   varchar2(255) := '';
--  safetyCheck number  := 1;
-- end;

-- *****
-- Constants definitions.
-- ***********
create or replace package game_constants is
  TRUE      number := 1;
  FALSE     number := 0;

  GAME_STATUS_INITIALIZED number := 1;
  GAME_STATUS_IN_PROGRESS number := 2;
  GAME_STATUS_LOSE        number := 3;
  GAME_STATUS_WIN         number := 4;

  GS_GAME_ID  number := 1;
  GS_ERR_MSG  number := 2;

  RESTRICTION_DIMENSION varchar2(1) := 'd';
  RESTRICTION_MINE      varchar2(1) := 'm';

  DIFFICULTY_DEV      varchar2(1) := 'd';
  DIFFICULTY_BEGINNER varchar2(1) := 'z';
  DIFFICULTY_ADVANCED varchar2(1) := 'p';
  DIFFICULTY_EXPERT   varchar2(1) := 'e';

  MOVE_UNCOVER  number := 1;
  MOVE_MARK     number := 2;
  MOVE_UNMARK   number := 3;
end;


/***************** DataTypes ******************/

create or replace type neighbour_array is varray(8) of number;



/******************* Tables *******************/


--declare
  --rs neighbour_array;
  --adjacentMineCount number;
  --field               pole%rowtype;
begin
  dev_drop_tables();

  -- clean + init database
  --clear_all();
  --initialize();
  --create_game_predefined(game_constants.DIFFICULTY_DEV);
  -- create_game_custom(20, 15, 10);

  -- delete from tmp;
  -- update dev_tmp set dev_tmp.val = 0 where dev_tmp.id = 2;

  -- select * into field from pole where pole.x = 5 and pole.y = 5 and id_hra = gameId();
  -- odkryj_pole(field.id);

  -- print_game_area();
  -- print_game_area_visibility();
  null;
end;


begin
  --devSafetyCheckReset();

  --update pole set pole.visible = 0 where pole.y >= 6;
  --delete from mina where id_pole = (select pole.id from pole where pole.x = 3 and pole.y = 9);

  --new_move(3, 9, game_constants.MOVE_MARK);
  --new_move(3, 8, game_constants.MOVE_UNCOVER);


  --print_game_area();
  --print_game_area_visibility();
  --print_game_area_dev();
  null;
end;

begin
  --update pole set pole.visible = 0;

  --new_move(1, 2, game_constants.MOVE_MARK);
  --new_move(1, 2, game_constants.MOVE_UNMARK);
  new_move(3, 3, game_constants.MOVE_UNCOVER);


  print_game_area();
  print_game_area_visibility();
  print_game_area_dev();
  null;
end;




create table game_settings (
  id        number        primary key,
  val       number,
  str_val   varchar(255)
);


-- *****
-- STAV table.
-- ***********
CREATE TABLE stav (
  id        number,
  status    varchar2(15)  NOT NULL,

  constraint pk_stav_id primary key (id)
);


-- *****
-- HRA table.
-- ***********
CREATE TABLE hra (
  id                  number            PRIMARY KEY,
  id_stav             number            NOT NULL,
  marked_mine_count   number  default 0 NOT NULL,
  start_timestamp     date,
  end_timestamp       date,

  constraint fk_hra_id_stav foreign key(id_stav) references stav(id),
  constraint chk_hra_marked_mine_count CHECK (marked_mine_count >= 0)
);


-- *****
-- OBTIZNOST table.
-- ***********
create table obtiznost (
  id          number          primary key,
  label       varchar2(1)     not null,
  width       number          not null,
  height      number          not null,
  mine_count  number          not null,

  -- 9 <= dimension <= 100
  --CONSTRAINT chk_obtiznost_width CHECK (width BETWEEN 9 AND 100),
  --CONSTRAINT chk_obtiznost_height CHECK (height BETWEEN 9 AND 100),

  -- max 40 % of area
  CONSTRAINT chk_mine_count CHECK (mine_count < (width * height * 0.4))
);

-- *****
-- OMEZENI table.
-- ***********
CREATE TABLE omezeni (
  id      number        PRIMARY KEY,
  type    varchar2(1),
  min     number        NOT NULL,
  max     number        NOT NULL
);


-- *****
-- OBLAST table.
-- ***********
CREATE TABLE oblast (
  id            number        PRIMARY KEY,
  id_hra        number        NOT NULL,
  width         number        NOT NULL,
  height        number        NOT NULL,
	mine_count    number        NOT NULL,
  predefined    varchar(1),
  constraint fk_oblast_id_hra foreign key(id_hra) references hra(id)
);



-- *****
-- POLE table.
-- ***********
CREATE TABLE pole (
  id      number               PRIMARY KEY,
  id_hra  number               NOT NULL,
  x       number               NOT NULL,
  y       number               NOT NULL,
  value   number    default 0  NOT NULL,
  visible number(1) default 0  NOT NULL,

  constraint fk_pole_id_hra foreign key(id_hra) references hra(id),
  CONSTRAINT chk_pole_value check (value between -1 and 8)
);


-- *****
-- MINA table.
-- ***********
CREATE TABLE mina (
  id      number  PRIMARY KEY,
  id_hra  number  NOT NULL,
  id_pole number  NOT NULL,

  constraint fk_mina_id_hra foreign key(id_hra) references hra(id),
  constraint fk_mina_id_pole foreign key(id_pole) references pole(id)
);


-- *****
-- TAH table.
-- ***********
CREATE TABLE tah (
  id        number  PRIMARY KEY,
  id_hra    number  NOT NULL,
  id_pole   number  NOT NULL,
  type      number  NOT NULL,
  timestamp DATE    NOT NULL,

  constraint fk_tah_id_hra foreign key(id_hra) references hra(id),
  constraint fk_tah_id_pole foreign key(id_pole) references pole(id)
);





----------------------------

-- *****
-- TMP table.
-- ***********
create table tmp (
  id        number        primary key,  -- PK
  param     varchar2(30),               -- string value
  val       number,                     -- number value
  group_id  number
);

-- *****
-- TODO:
-- DEV-ONLY
-- ***********
create table dev_tmp (
  id        number        primary key,
  val       number,
  str_val   varchar(255)
);


/***************** Sequences ******************/


drop sequence seq_tmp_id_increment;
drop sequence seq_hra_id_increment;
drop sequence seq_pole_id_increment;
drop sequence seq_mina_id_increment;
drop sequence seq_oblast_id_increment;
drop sequence seq_tah_id_increment;

-- *****
-- Sequence: Auto-increment ID of the Pole table.
-- ***********
create sequence seq_pole_id_increment increment by 1 start with 1;


-- *****
-- Sequence: Auto-increment ID of the Tmp table.
-- ***********
create sequence seq_tmp_id_increment increment by 1 start with 1;


-- *****
-- Sequence: Auto-increment ID of the Hra table.
-- ***********
create sequence seq_hra_id_increment increment by 1 start with 1;

-- *****
-- Sequence: Auto-increment ID of the Mina table.
-- ***********
create sequence seq_mina_id_increment increment by 1 start with 1;

-- *****
-- Sequence: Auto-increment ID of the Oblast table.
-- ***********
create sequence seq_oblast_id_increment increment by 1 start with 1;

-- *****
-- Sequence: Auto-increment ID of the Tah table.
-- ***********
create sequence seq_tah_id_increment increment by 1 start with 1;






/***************** Procedures *****************/

-- *****
-- Game ID getter.
-- ***********
create or replace function gameId return number as
  id  number;
  begin
    select game_settings.val into id from game_settings
      where game_settings.id = game_constants.GS_GAME_ID;
    return id;
  end;

-- *****
-- Drops all related tables.
-- ***********
create or replace procedure dev_drop_tables as
  type array_t is varray(20) of varchar2(20);
  expectedTables array_t := array_t(
      'tmp',
      'tah',
      'oblast',
      'mina',
      'pole',
      'hra',
      'stav',
      'obtiznost',
      'omezeni',
      'dev_tmp',
      'game_settings'
  );

  TYPE v_array IS TABLE OF VARCHAR2(20);
  realTables v_array;

  begin
    select table_name BULK COLLECT into realTables from all_tables
      where owner like 'PITTL' and table_name not like 'XML_SOUBORY';

    for i in 1..expectedTables.count loop
      if upper(expectedTables(i)) not member of realTables then
        continue;
      end if;

      EXECUTE IMMEDIATE 'drop table ' || expectedTables(i);
      DBMS_OUTPUT.put_line('  Dropped table: ' || expectedTables(i));
    end loop;
  end;


-- *****
-- Prints X-axis.
-- ***********
create or replace procedure print_game_area_x_axis_header(colCount in number) as
  divider varchar2(2);
  begin
    DBMS_OUTPUT.put_line(' ');

    DBMS_OUTPUT.put('   ');
    for i in 1..colCount loop
      if i > 9 then
        divider := ' ';
      else
        divider := '  ';
      end if;
      DBMS_OUTPUT.put(divider || i);
    end loop;
  end;

-- *****
-- Prints Y-axis.
-- ***********
create or replace procedure print_game_area_y_axis_header(idx in number) as
  divider varchar2(2);
  begin
    if idx < 10 then
      divider := ' |';
    elsif idx >= 10 then
      divider := '|';
    end if;
    DBMS_OUTPUT.put(idx || divider);
  end;

-- *****
-- Prints values of all fields of the playground.
-- ***********
create or replace procedure print_game_area_dev as
  p         pole%rowtype;
  area      oblast%rowtype;
  fieldRow  varchar2(255);

  cursor cFields is
    select * from pole
    where pole.id_hra = gameId()
    order by pole.y, pole.x;

  begin
    select * into area from oblast where oblast.id_hra = gameId();
    open cFields;

    DBMS_OUTPUT.put_line(' ');
    DBMS_OUTPUT.put_line('*** Playground (dev-only):');

    -- x-axis header
    print_game_area_x_axis_header(area.width);

    DBMS_OUTPUT.new_line;

    for i in 1..(area.width + 2) loop
      DBMS_OUTPUT.put('---');
    end loop;

    DBMS_OUTPUT.new_line;

    loop
      fetch cFields into p;
      exit when cFields%notfound;

      if p.x = 1 then
        print_game_area_y_axis_header(p.y);
      end if;

      if p.value < 0 then
        DBMS_OUTPUT.put(' ' || p.value);
      else
        DBMS_OUTPUT.put('  ' || p.value);
      end if;



      if mod(p.x, area.width) = 0 then
        DBMS_OUTPUT.new_line;
      end if;
    end loop;

    close cFields;
  end;

-- *****
-- Prints the playground.
-- ***********
create or replace procedure print_game_area as
  p         pole%rowtype;
  area      oblast%rowtype;
  fieldRow  varchar2(255);

  markRecCount  number;

  cursor cFields is
    select * from pole
    where pole.id_hra = gameId()
    order by pole.y, pole.x;

  begin
    select * into area from oblast where oblast.id_hra = gameId();
    open cFields;

    DBMS_OUTPUT.put_line(' ');
    DBMS_OUTPUT.put_line('*** Playground - classic:');

    -- x-axis header
    print_game_area_x_axis_header(area.width);

    DBMS_OUTPUT.new_line;

    for i in 1..(area.width + 2) loop
      DBMS_OUTPUT.put('---');
    end loop;

    DBMS_OUTPUT.new_line;

    loop
      fetch cFields into p;
      exit when cFields%notfound;

      if p.x = 1 then
        print_game_area_y_axis_header(p.y);
      end if;

      select count(mina.id) into markRecCount from mina
        where mina.id_pole = p.id;


      if markRecCount > 0 then
        DBMS_OUTPUT.put('  x');
      else
        if p.visible = game_constants.TRUE then
          if p.value < 0 then
            DBMS_OUTPUT.put(' ' || p.value);
          else
            DBMS_OUTPUT.put('  ' || p.value);
          end if;
        else
          DBMS_OUTPUT.put('  _');
        end if;
      end if;

      if mod(p.x, area.width) = 0 then
        DBMS_OUTPUT.new_line;
      end if;
    end loop;

    close cFields;
  end;

-- *****
-- Prints visibility of fields of the playground.
-- ***********
create or replace procedure print_game_area_visibility as
  p         pole%rowtype;
  area      oblast%rowtype;
  fieldRow  varchar2(255);

  markRecCount  number;

  cursor cFields is
    select * from pole
    where pole.id_hra = gameId()
    order by pole.y, pole.x;

  begin
    select * into area from oblast where oblast.id_hra = gameId();
    open cFields;

    DBMS_OUTPUT.put_line(' ');
    DBMS_OUTPUT.put_line('*** Playground - visibility (dev-only):');

    -- x-axis header
    print_game_area_x_axis_header(area.width);

    DBMS_OUTPUT.new_line;

    for i in 1..(area.width + 2) loop
      DBMS_OUTPUT.put('---');
    end loop;

    DBMS_OUTPUT.new_line;

    loop
      fetch cFields into p;
      exit when cFields%notfound;

      if p.x = 1 then
        print_game_area_y_axis_header(p.y);
      end if;


      select count(mina.id) into markRecCount from mina
        where mina.id_pole = p.id;

      DBMS_OUTPUT.put('  ' || p.visible);


      if mod(p.x, area.width) = 0 then
        DBMS_OUTPUT.new_line;
      end if;
    end loop;

    close cFields;
  end;


-- *****
-- Initializes database with required data.
-- ***********
create or replace procedure initialize as
  begin
    insert all
      into game_settings values(game_constants.GS_GAME_ID, 1, null)
      into game_settings values(game_constants.GS_ERR_MSG, null, null)
    select * from dual;

    insert all
      into obtiznost values(4, game_constants.DIFFICULTY_DEV, 5,  5, 5)
      into obtiznost values(1, game_constants.DIFFICULTY_BEGINNER, 9,  9, 10)
      into obtiznost values(2, game_constants.DIFFICULTY_ADVANCED, 16, 16, 40)
      into obtiznost values(3, game_constants.DIFFICULTY_EXPERT,   16, 30, 99)
    select * from dual;

    insert all
      into omezeni values (1, game_constants.RESTRICTION_DIMENSION, 9, 100)
      into omezeni values (2, game_constants.RESTRICTION_MINE, 0, 40)
    select * from dual;

    insert all
      into stav values (game_constants.GAME_STATUS_INITIALIZED, 'initialized')
      into stav values (game_constants.GAME_STATUS_IN_PROGRESS, 'in progress')
      into stav values (game_constants.GAME_STATUS_WIN,         'won')
      into stav values (game_constants.GAME_STATUS_LOSE,        'lost')
    select * from dual;

    insert all

      -- safety check
      into dev_tmp values(1, 100, null)
      into dev_tmp values(2, 0,  null)

    select * from dual;
    commit;
  end;

create or replace procedure create_new_game as
  begin
    insert into hra(id) values(null);
    commit;
  end;

-- *****
-- Initializes game with ID game_settings.game_id.
-- ***********
create or replace procedure create_game_custom(w in number, h in number, m in number) as
  begin
    create_new_game();
    insert into oblast(width, height, mine_count) values (w, h, m);
    print_game_area();
    commit;
  end;

-- *****
-- Initializes game with ID game_settings.game_id.
-- ***********
create or replace procedure create_game_predefined(difficulty in varchar2) as
  begin
    create_new_game();
    insert into oblast(predefined) values (difficulty);
    print_game_area();
    commit;
  end;

-- *****
-- Game ID setter.
-- ***********
create or replace procedure setGameId(gameId in number) as
  begin
    update game_settings set game_settings.val = gameId
      where game_settings.id = game_constants.GS_GAME_ID;
  end;

-- *****
-- Err msg getter.
-- ***********
create or replace function errMsg return varchar2 as
  msg  varchar2(255);
  begin
    select game_settings.str_val into msg from game_settings
      where game_settings.id = game_constants.GS_ERR_MSG;
    return msg;
  end;

-- *****
-- Err msg setter.
-- ***********
create or replace procedure setErrMsg(msg in varchar2) as
  begin
    update game_settings set game_settings.str_val = msg
      where game_settings.id = game_constants.GS_ERR_MSG;
  end;

-- *****
-- TODO:
-- Checks number of iterations.
-- ***********
create or replace function devIsSafe return number as
  it    number;
  lim   number;
  begin
    select dev_tmp.val into lim from dev_tmp
      where dev_tmp.id = 1;

    select dev_tmp.val into it from dev_tmp
      where dev_tmp.id = 2;

    dbms_output.put_line(it || '/' || lim);

    if it < lim then
      return game_constants.TRUE;
    else
      return game_constants.FALSE;
    end if;
  end;

-- *****
-- TODO:
-- Number of iterations getter.
-- ***********
create or replace function devSafetyCheck return number as
  val    number;
  begin
    select dev_tmp.val into val from dev_tmp
      where dev_tmp.id = 2;

    dbms_output.put_line('safety check: ' || val);

    return val;
  end;

-- *****
-- TODO:
-- Increments number of iterations.
-- ***********
create or replace procedure devSafetyCheckInc as
  begin
    update dev_tmp set dev_tmp.val = dev_tmp.val + 1
      where dev_tmp.id = 2;
  end;

-- *****
-- TODO:
-- Resets number of iterations.
-- ***********
create or replace procedure devSafetyCheckReset as
  begin
    update dev_tmp set dev_tmp.val = 0 where dev_tmp.id = 2;
  end;

create or replace procedure clearTmp(gId in number) as
  begin
    dbms_output.put_line('clearing TMP');
    if gId is not null then
      delete from tmp where tmp.group_id = gId;
    else
      delete from tmp;
    end if;
  end;

-- *****
-- Clears data related to game with ID game_settings.game_id.
-- ***********
create or replace procedure clear_game as
  g_id  number;
  begin
    g_id := gameId();
    delete from tmp;
    delete from tah     where tah.id_hra = g_id;
    delete from oblast  where oblast.id_hra = g_id;
    delete from mina    where mina.id_hra = g_id;
    delete from pole    where pole.id_hra = g_id;
    delete from hra     where hra.id = g_id;
    commit;
  end;

-- *****
-- Wipes database and keeps DB structure.
-- ***********
create or replace procedure clear_all as
  begin
    delete from tmp;
    delete from tah;
    delete from oblast;
    delete from mina;
    delete from pole;
    delete from hra;
    delete from stav;
    delete from obtiznost;
    delete from omezeni;
    delete from dev_tmp;
    delete from game_settings;
    commit;
  end;

-- *****
-- Generates Fields of the Pole table.
-- (new records –> Pole)
-- ***********
create or replace procedure initialize_fields as
  x     number;
  y     number;
  s     number;
  area  oblast%rowtype;

  begin
    select * into area from oblast where oblast.id_hra = gameId();

    s := area.width * area.height;

    for i in 0..(s - 1) loop
      x := mod(i, area.width) + 1;
      y := floor(i / area.width) + 1;
      insert into pole (id_hra, x, y) values (gameId(), x, y);
      --dbms_output.put_line('x: ' || x || ' y: ' || y);
    end loop;
  end;

-- *****
-- Randomly places mines on the area.
-- ***********
create or replace procedure zaminuj_oblast as
  cursor cFields is
  select pole.id from pole where pole.id_hra = gameId();

  cursor cTmps is
  select tmp.group_id from tmp order by tmp.val;

  area          oblast%rowtype;
  fId           number;
  rndId         number;
  mineCount     number;
  tmpFieldId    number;

  begin
    mineCount := 0;
    select * into area from oblast where oblast.id_hra = gameId();

    delete from tmp;

    -- each field is given a random number
    open cFields;

    loop
      fetch cFields into fId;
      exit when cFields%notfound;

      rndId := round(DBMS_RANDOM.VALUE * (area.width * area.height - 1) + 1);
      insert into tmp(param, val, group_id) values (null, rndId, fId);
    end loop;

    close cFields;

    -- order fields by random number
    -- & select first N fields
    open cTmps;

    loop
      fetch cTmps into tmpFieldId;
      exit when cTmps%notfound or mineCount = area.mine_count;

      --DBMS_output.put_line(mineCount || '/' || area.mine_count);
      update pole set pole.value = -1 where pole.id = tmpFieldId;
      mineCount := mineCount + 1;
    end loop;

    close cTmps;


    clearTmp(null);
    commit;

  exception
    when no_data_found then
      raise_application_error(-20002, 'ERROR: Oblast hry id ' || gameId() || ' nebyla nalezena.');
  end;



-- *****
-- Collects ID of fields of all adjacent fields of the given one.
-- ***********
create or replace function get_neighbour_fields(field in pole%rowtype) return neighbour_array as
  neighbours   neighbour_array;
  area              oblast%rowtype;
  xMin              number;
  xMax              number;
  yMin              number;
  yMax              number;
  i                 number;
  gId               number;

  begin
    neighbours := neighbour_array();
    gId := gameId();

    select * into area from oblast where oblast.id_hra = gId;

    xMin := field.x - 1;
    if(xMin < 1) then
      xMin := 1;
    end if;

    xMax := field.x + 1;
    if(xMax > area.width) then
      xMax := area.width;
    end if;


    yMin := field.y - 1;
    if(yMin < 1) then
      yMin := 1;
    end if;

    yMax := field.y + 1;
    if(yMax > area.width) then
      yMax := area.width;
    end if;

    i := 1;

    -- into neighbour
    for rec in (select * from pole
        where pole.id_hra = gId and
              pole.x between xMin and xMax and
              pole.y between yMin and yMax) loop

      continue when rec.x = field.x and rec.y = field.y;

      neighbours.extend;
      neighbours(i) := rec.id;
      i := i + 1;
    end loop;

    return neighbours;
  end;

-- *****
-- Counts mines of neighbours.
-- ***********
create or replace function count_adjacent_mines(neighbours in neighbour_array) return number as
  i                 number;

  neighbourField    pole%rowtype;
  fieldValue        number;

  begin
    fieldValue := 0;

    -- iterate through all neighbours
    i := neighbours.first;

    while (i is not null) loop

      -- get neighbour
      select * into neighbourField
        from pole where pole.id = neighbours(i);

      -- is it a mine?
      if neighbourField.value = -1 then
        fieldValue := fieldValue + 1;
      end if;

      i := neighbours.next(i);
    end loop;

    return fieldValue;
  end;


-- *****
-- Counts covered neighbouring fields.
-- ***********
create or replace function count_adjacent_covered_fields(neighbours in neighbour_array) return number as
  i                 number;
  neighbourField    pole%rowtype;
  fieldValue        number;

  begin
    fieldValue := 0;

    -- iterate through all neighbours
    i := neighbours.first;

    while (i is not null) loop

      -- get neighbour
      select * into neighbourField
        from pole where pole.id = neighbours(i);

      -- Is it covered?
      if neighbourField.visible = game_constants.FALSE and
         neighbourField.value != -1 then
        fieldValue := fieldValue + 1;
      end if;

      i := neighbours.next(i);
    end loop;

    return fieldValue;
  end;

-- *****
-- Counts surrounding mines for each field.
-- ***********
create or replace procedure spocitej_oblast as
  cursor cFields is
    select * from pole where pole.id_hra = gameId();

  field         pole%rowtype;
  fieldValue    number;
  neighbours    neighbour_array;

  begin
    open cFields;

    loop
      fetch cFields into field;
      exit when cFields%notfound;

      -- It's a mine!
      continue when field.value = -1;

      -- get neighbour IDs
      neighbours := get_neighbour_fields(field);

      -- count surrounding mines
      fieldValue := count_adjacent_mines(neighbours);

      update pole set value = fieldValue where pole.id = field.id;
    end loop;

    close cFields;
  end;

-- *****
-- Checks whether is the field marked or not.
-- ***********
create or replace function is_marked(field in pole%rowtype) return number as
  recCountInMinaTable       number;

  begin
    select count(mina.id) into recCountInMinaTable from mina
      where mina.id_pole = field.id and mina.id_hra = gameId();

      if recCountInMinaTable > 0 then
        return game_constants.TRUE;
      end if;

    return game_constants.FALSE;
  end;

-- *****
-- Uncovers a field.
-- TODO: and checks a winning state?
-- ***********
create or replace procedure uncover_field(field in out pole%rowtype) as
  begin
    update pole set pole.visible = game_constants.TRUE where pole.id = field.id;
    field.visible := game_constants.TRUE;
  end;

-- *****
-- Registers a beginning of the game – records start datetime and sets a status of the game.
-- ***********
create or replace procedure register_game_beginning as
  begin
    update hra
      set hra.start_timestamp = SYSDATE,
          hra.id_stav = game_constants.GAME_STATUS_IN_PROGRESS
      where hra.id = gameId();
  end;

-- *****
-- Registers a lost of the game – records end datetime and sets a status of the game.
-- ***********
create or replace procedure register_game_lose as
  begin
    dbms_output.put_line('You lose!');
    update hra
      set hra.end_timestamp = SYSDATE,
          hra.id_stav = game_constants.GAME_STATUS_LOSE
      where hra.id = gameId();
  end;

-- *****
-- Registers a win of the game – records end datetime and sets a status of the game.
-- ***********
create or replace procedure register_game_win as
  begin
    dbms_output.put_line('You win!');
    update hra
      set hra.end_timestamp = SYSDATE,
          hra.id_stav = game_constants.GAME_STATUS_WIN
      where hra.id = gameId();
  end;

-- *****
-- Checks whether the field contains a mine or not.
-- ***********
create or replace function odkryta_mina(field in pole%rowtype) return number as
  begin

    if field.value = -1 then
      dbms_output.put_line('Mine was found at x: ' || field.x || ' y: ' || field.y || '.');
      return game_constants.TRUE;
    end if;

    return game_constants.FALSE;
  end;

-- *****
-- Recursive procedure uncovering all neighbour fields of a field
-- not neighbouring with a mine.
--
-- 1. check value of the given field
--     – not a mine –> uncover
--     – mine –> game over
-- 2. check if all not-mine fields are uncovered
--     – true –> win
-- . check if not neighbouring with a mine
--     — true –> recursive call for each field
--     – false == stop condition
-- ***********
-- create or replace procedure odkryj_pole(fieldX in number, fieldY in number) as
create or replace procedure odkryj_pole(fieldId in number) as
  field               pole%rowtype;
  fieldCount          number;
  adjacentMineCount   number;
  adjacentCoveredCount  number;
  neighbours          neighbour_array;

  n                   number;
  neighbour           pole%rowtype;

  recInTmpCount       number;

  currentFieldId      number;

  begin

    -- stuck-in-loop protection
    devSafetyCheckInc();
    if devIsSafe() = game_constants.FALSE then
      dbms_output.put_line('STOPPED AT SAFETY CHECK.');
      return;
    end if;

    -- get the field from DB
    select * into field from pole where pole.id = fieldId;
    dbms_output.put_line('Uncovering: ' || field.id);

    -- store processed field == set 'processed' flag to field
    insert into tmp(param, val, group_id) values (null, field.id, 0);


    -- Marked? –> Skip uncovering.
    if is_marked(field) = game_constants.FALSE then

      -- uncover
      uncover_field(field);

      -- Was a mine?
      if odkryta_mina(field) = game_constants.TRUE then
        return;
      end if;
    end if;

    dbms_output.put_line('odkryj_pole');


    -- no need to check if the player has already won
    -- in case the player has already won, there is
    -- no field to uncover

    -- get neighbour IDs
    neighbours := get_neighbour_fields(field);

    -- count adjacent mines
    adjacentMineCount := count_adjacent_mines(neighbours);
    dbms_output.put_line('adjacent mines: ' || adjacentMineCount);

    -- if any of neighbours is a mine -> end
    if adjacentMineCount > 0 then
      dbms_output.put_line('-- Adjacent mine!');
      return;
    end if;


    -- count adjacent covered fields
    adjacentCoveredCount := count_adjacent_covered_fields(neighbours);
    dbms_output.put_line('adjacent covered: ' || adjacentCoveredCount);

    -- no neighbouring covered fields –> end
    if adjacentCoveredCount = 0 then
      dbms_output.put_line('-- No neighbouring covered fields.');
      return;
    end if;

    -- if no mines surround –> recursive call
    n := neighbours.first;

    while (n is not null) loop

      -- get current field
      currentFieldId := neighbours(n);

      -- move 'pointer'
      n := neighbours.next(n);

      select count(tmp.id) into recInTmpCount from tmp where tmp.val = currentFieldId;
      dbms_output.put_line('-- checking neighbour: ' || currentFieldId);
      dbms_output.put_line('-- count: ' || recInTmpCount);

      if recInTmpCount > 0 then
        dbms_output.put_line('-- already processed');
        continue;
      else
        dbms_output.put_line('-- new one');
      end if;

      --continue when recInTmpCount > 0;
      --select * into neighbour from pole where pole.id = currentFieldId;
      odkryj_pole(currentFieldId);
    end loop;
  end;

-- *****
-- Checks whether it is possible to mark a field as a mine or not.
-- ***********
create or replace function mnoho_min return number as
  markedFieldCount  number;
  mineCount         number;

  begin
    select count(mina.id) into markedFieldCount from mina
      where mina.id_hra = gameId();

    select oblast.mine_count into mineCount from oblast
      where id_hra = gameId();

    if markedFieldCount >= mineCount then
      return game_constants.TRUE;
    end if;

    return game_constants.FALSE;
  end;

-- *****
-- After winning the game, it marks covered fields as mined
-- (i.e. inserts records into MINA table).
-- ***********
create or replace procedure oznac_miny as
  begin
    --insert into mina (id_hra, id_pole) select gameId(), pole.id from pole
    --where pole.id_hra = gameId() and pole.visible = 0;
    insert into mina (id_pole) select pole.id from pole
      where pole.id_hra = gameId() and pole.visible = 0;
  end;

-- *****
-- Checks whether user input is in accordance with the restrictions.
-- true – invalid params
-- false – valid params
-- ***********
create or replace function spatny_parametr(width in number, height in number, mine_count in number) return number as
  fieldCount            number;
  maxMineCount          number;

  dimensionRestriction  omezeni%rowtype;
  mineRestriction       omezeni%rowtype;

  msg                   varchar(150);

  begin

    select * into dimensionRestriction from omezeni
    where omezeni.type = game_constants.RESTRICTION_DIMENSION;

    select * into mineRestriction from omezeni
    where omezeni.type = game_constants.RESTRICTION_MINE;

    fieldCount := width * height;
    maxMineCount := to_number(floor(mineRestriction.max / 100 * fieldCount));

    -- check dimension restrictions
    if width  not between dimensionRestriction.min and dimensionRestriction.max or
       height not between dimensionRestriction.min and dimensionRestriction.max then
      setErrMsg('ERROR: Dimension is out of bounds. Please, enter dimensions in the range of ' || dimensionRestriction.min || ' and ' || dimensionRestriction.max || '.');
      return -1;
    end if;

    -- check mines restriction
    if mine_count not between 1 and maxMineCount then
      setErrMsg('ERROR: Invalid mine count. Number of mines must be at least 1 and must not exceed ' || mineRestriction.max || '% of area (i.e.' || maxMineCount || ' mines for selected area).');
      return -2;
    end if;

    return game_constants.FALSE;
  end;


-- *****
-- Builds a string of values of the fields forming a row at the specified index.
-- ***********
create or replace function radek_oblasti(rowNum in number) return varchar2 as
  --area        oblast%rowtype;
  rowString   varchar2(350);

  begin
    -- select * into area from oblast where oblast.id_hra = game_settings.game_id;

    -- if rowNum not between 1 and area.height then
    --  return null;
    -- end if;

    -- LISTAGG(pole.value, '|') WITHIN GROUP (ORDER BY pole.x) "row",
    -- select group_concat(pole.value separator '|') from pole where pole.y = rowNum
    -- and pole.id_hra = game_settings.game_id;

    select LISTAGG(pole.value, '|') WITHIN GROUP (ORDER BY pole.x)
      into rowString from pole where pole.y = rowNum and pole.id_hra = gameId();

    return rowString;
  end;


-- *****
-- Checks if a winning state occured.
-- ***********
create or replace function vyhra return number as
  mineCount           number;
  coveredFieldCount   number;

  begin
    -- better implementation:
    -- select count(pole.id) into fieldCount from pole
    --  where id_hra = game_settings.game_id and
    --        pole.visible = game_constants.FALSE and
    --        pole.value != -1;

    select count(pole.id) into mineCount from pole
      where id_hra = gameId() and pole.value = -1;

    select count(pole.id) into coveredFieldCount from pole
      where id_hra = gameId() and pole.visible = game_constants.FALSE;

    if mineCount = coveredFieldCount then
      return game_constants.TRUE;
    end if;

    return game_constants.FALSE;
  end;

-- *****
-- Gets the field from the database.
-- ***********
create or replace function get_field(fieldX in number, fieldY in number) return pole%rowtype as
  field         pole%rowtype;
  area          oblast%rowtype;
  outOfBoundsEx exception;

  begin
    select * into area from oblast
      where oblast.id_hra = gameId();

    if fieldX not between 1 and area.width or
       fieldY not between 1 and area.height then
      raise outOfBoundsEx;
    end if;

    select * into field from pole
      where pole.x = fieldX and
            pole.y = fieldY and
            pole.id_hra = gameId();
    return field;

  exception
    when outOfBoundsEx then
      raise_application_error(-20010, 'ERROR: Coordinates out of bounds. Please, ' ||
        'enter valid coordinates - x in range of 1 to ' || area.width || ' and ' ||
        'y in range of 1 to ' || area.height);
  end;

-- *****
-- Handles new move.
-- ***********
create or replace procedure new_move(fieldX in number, fieldY in number, moveType in number) as
  field   pole%rowtype;

  begin
    field := get_field(fieldX, fieldY);
    insert into tah(id_pole, type) values (field.id, moveType);
    commit;
  end;









/****************** Triggers ******************/


-- *****
-- Trigger: Auto-increment ID of the Pole table.
-- ***********
create or replace trigger trig_pole_initialization
  before insert on pole
  for each row
  begin
    select seq_pole_id_increment.nextval into :new.id from dual;
  end;


-- *****
-- Trigger: Auto-increment ID of the Tmp table.
-- ***********
create or replace trigger trig_tmp_initialization
  before insert on tmp
  for each row
  begin
    select seq_tmp_id_increment.nextval into :new.id from dual;
  end;


-- *****
-- Trigger: Auto-increment ID of the Hra table.
-- ***********
create or replace trigger trig_hra_initialization
  before insert on hra
  for each row
  declare
  begin
    select seq_hra_id_increment.nextval into :new.id from dual;
    :new.id_stav := game_constants.GAME_STATUS_INITIALIZED;
    setGameId(:new.id);
    dbms_output.put_line('inserting into hra: ' || :new.id);
  end;


-- *****
-- Trigger: Auto-increment ID of the Mina table.
-- ***********
create or replace trigger trig_mina_initialization
  before insert on mina
  for each row
  begin
    select seq_mina_id_increment.nextval into :new.id from dual;
    :new.id_hra := gameId();
  end;


-- *****
-- Trigger: Auto-increment ID of the Tah table.
-- ***********
create or replace trigger trig_tah_initialization
  before insert on tah
  for each row
  declare
    endTimestamp                date;
    field                       pole%rowtype;
    mineRowCount                number;
    markedCantBeUncoveredEx     exception;
    markedCantBeMarkedEx        exception;
    unmarkedCantBeUnmarkedEx    exception;
    uncoveredCantBeUncoveredEx  exception;
    uncoveredCantBeMarkedEx     exception;
    markedTooManyFieldsEx       exception;
    gameEndedEx                 exception;
  begin
    -- Is game still in progress?
    select hra.end_timestamp into endTimestamp from hra
      where hra.id = gameId();

    if endTimestamp is not null then
      raise gameEndedEx;
    end if;

    select count(mina.id) into mineRowCount from mina
      where mina.id_pole = :new.id_pole;

    select * into field from pole where pole.id = :new.id_pole;

    dbms_output.put('action : ');

    if :new.type = game_constants.MOVE_MARK then
      dbms_output.put_line('mark');
    elsif :new.type = game_constants.MOVE_UNMARK then
      dbms_output.put_line('unmark');
    elsif :new.type = game_constants.MOVE_UNCOVER then
      dbms_output.put_line('uncover');
    end if;


    if field.visible = game_constants.TRUE then
      dbms_output.put_line('visible');
    else
      dbms_output.put_line('not visible');
    end if;


    if mineRowCount > 0 then
      dbms_output.put_line('marked');
    else
      dbms_output.put_line('not marked');
    end if;


    -- marked field
    if mineRowCount > 0 then

      -- marked –> uncover
      if :new.type = game_constants.MOVE_UNCOVER then
        raise markedCantBeUncoveredEx;

      -- marked –> mark
      elsif :new.type = game_constants.MOVE_MARK then
        raise markedCantBeMarkedEx;
      end if;

    -- unmarked && uncovered field
    elsif mineRowCount = 0 and field.visible = game_constants.FALSE then

      if :new.type = game_constants.MOVE_UNMARK then
        raise unmarkedCantBeUnmarkedEx;
      end if;

    -- uncovered field
    elsif field.visible = game_constants.TRUE then

      -- uncovered -> mark
      if :new.type = game_constants.MOVE_MARK then
        raise uncoveredCantBeMarkedEx;

      -- uncovered –> uncover
      elsif :new.type = game_constants.MOVE_UNCOVER then
        raise uncoveredCantBeUncoveredEx;
      end if;
    end if;

    -- A number of marked fields can't exceed a number of mines.
    if :new.type = game_constants.MOVE_MARK and
       mnoho_min() = game_constants.TRUE then
      raise markedTooManyFieldsEx;
    end if;


    select seq_tah_id_increment.nextval into :new.id from dual;
    :new.timestamp := SYSDATE;
    :new.id_hra := gameId();

  exception
    when markedCantBeUncoveredEx then
      raise_application_error(-20005, 'You are not able to uncover a field marked as a mine unless you unmark it.');
    when markedCantBeMarkedEx then
      raise_application_error(-20006, 'You are not able to mark a field which is already marked.');
    when unmarkedCantBeUnmarkedEx then
      raise_application_error(-20009, 'You are not able to unmark a field which is not marked.');
    when uncoveredCantBeUncoveredEx then
      raise_application_error(-20007, 'You are not able to uncover a field which is already uncovered.');
    when uncoveredCantBeMarkedEx then
      raise_application_error(-20008, 'You are not able to mark a field which is uncovered.');
    when markedTooManyFieldsEx then
      raise_application_error(-20011, 'A number of marked fields can''t exceed a number of mines.');
    when gameEndedEx then
      raise_application_error(-20012, 'Game has already ended.');
  end;


-- *****
-- Trigger:
-- ***********
create or replace trigger trig_oblast_initialization
  before insert on oblast
  for each row
  declare
    difficulty              obtiznost%rowtype;
    invalidDifficulty       exception;
    invalidParamsDimension  exception;
    invalidParamsMineCount  exception;
    rs                      number;
  begin

    if :new.predefined is not null then

      -- PRE-DEFINED DIFFICULTY
      dbms_output.put_line('Pre-defined difficulty selected.');

      -- if none of pre-defined difficulties -> exception
      if :new.predefined not in (
        game_constants.DIFFICULTY_DEV,
        game_constants.DIFFICULTY_BEGINNER,
        game_constants.DIFFICULTY_ADVANCED,
        game_constants.DIFFICULTY_EXPERT
      ) then raise invalidDifficulty; end if;

      -- width, height, mines
      select * into difficulty from obtiznost
        where obtiznost.label like :new.predefined;

      :new.width        := difficulty.width;
      :new.height       := difficulty.height;
      :new.mine_count   := difficulty.mine_count;

    else
      -- CUSTOM DIFFICULTY
      dbms_output.put_line('Custom difficulty selected.');

      -- validation
      rs := spatny_parametr(:new.width, :new.height, :new.mine_count);

      if    rs = -1 then  raise invalidParamsDimension;
      elsif rs = -2 then  raise invalidParamsMineCount; end if;
    end if;

    -- id
      select seq_oblast_id_increment.nextval
        into :new.id from dual;

    -- id_hra
    :new.id_hra := gameId();



  exception
    when invalidDifficulty then
      RAISE_APPLICATION_ERROR( -20001, 'ERROR: Invalid difficulty selected.');
    null;

    when invalidParamsDimension then
        raise_application_error( -20003, errMsg());
      null;

    when invalidParamsMineCount then
      raise_application_error( -20004, errMsg());
      null;
  end;



-- *****
-- Trigger:
-- ***********
create or replace trigger trig_fields_initialization
  after insert on oblast
  begin
    initialize_fields();
    zaminuj_oblast();
    spocitej_oblast();
  end;


-- *****
-- Trigger:
-- ***********
create or replace trigger trig_mine_check
  after update of visible on pole
  for each row
  declare
    field   pole%rowtype;
  begin
    field.value := :new.value;
    field.x     := :new.x;
    field.y     := :new.y;

    if :new.visible = game_constants.FALSE then
      return;
    end if;

    if odkryta_mina(field) = game_constants.TRUE then
      register_game_lose();
    end if;
  end;

create or replace trigger trig_win_check
  after update of visible on pole
  begin
    if vyhra() = game_constants.TRUE then
      register_game_win();
    end if;
  end;

-- *****
-- Trigger:
-- ***********
create or replace trigger trig_hra_finalization
  before update of id_stav on hra
  for each row
  begin
    if :new.id_stav = game_constants.GAME_STATUS_IN_PROGRESS then
      :new.start_timestamp := SYSDATE;
    elsif :new.id_stav in (
      game_constants.GAME_STATUS_LOSE,
      game_constants.GAME_STATUS_WIN
    ) then
      :new.end_timestamp := SYSDATE;
    end if;
  end;


-- *****
-- Trigger:
-- ***********
create or replace trigger trig_tah_finalization
  after insert on tah
  for each row
  begin
    clearTmp(null);

    case
      when :new.type = game_constants.MOVE_UNCOVER then
        odkryj_pole(:new.id_pole);
      when :new.type = game_constants.MOVE_MARK then
        insert into mina(id_pole) values (:new.id_pole);
      when :new.type = game_constants.MOVE_UNMARK then
        delete from mina where mina.id_pole = :new.id_pole; -- and id_hra - zbytecne
    end case;

    register_game_beginning();
  end;











/******************* Views ********************/





