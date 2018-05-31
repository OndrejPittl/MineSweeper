
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
  GS_DEV  number := 3;

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



-- *************** Game Commands ****************

begin

  -------------- INIT DATABASE --------------
  --  1. drop tables OR clear database
  --  2. create tables, procedures, ...
  --  3. fill with crucial data
  -- drop_tables();
  -- prepare_database();


  ---------------- INIT GAME ----------------
  -- create game:
  --  a) pre-defined difficulty
  --  b) custom difficulty

  --create_game_custom(20, 20, 10);
  --create_game_predefined(game_constants.DIFFICULTY_BEGINNER);


  ------------------ GAME -------------------
  -- new_move(1, 9, game_constants.MOVE_MARK);
  -- new_move(1, 9, game_constants.MOVE_UNMARK);
  -- new_move(9, 9, game_constants.MOVE_UNCOVER);

  -- print_game_area();
  -- print_game_area_all();


  ---------------- RESET GAME ---------------
  -- reset_game();


  ----------------- VIEWS -------------------
  -- select * from vitezove;
  -- select * from porazeni;
  -- select * from chybne_miny;
  -- select * from oblast_tisk;


  ------------------ PRINTS -----------------
  -- print_game_area_all();
  -- print_game_area();
  -- select * from oblast_tisk;



  -------------------------------------------
  ---------------- SCENARIO -----------------
  -------------------------------------------




  null;
end;



/***************** DataTypes ******************/

create or replace type neighbour_array is varray(8) of number;



/******************* Tables *******************/

-- *****
-- Game settings.
--  a) current game ID
--  b) error message
--  c) development flag - enables/disables logging into console in odkryj_pole
-- ***********
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
  start_timestamp     timestamp,
  end_timestamp       timestamp,

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
  CONSTRAINT chk_obtiznost_width CHECK (width BETWEEN 9 AND 100),
  CONSTRAINT chk_obtiznost_height CHECK (height BETWEEN 9 AND 100),

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
-- Database integrity checked with trigger.
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
  CONSTRAINT chk_pole_value check (value between -1 and 8),
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
  constraint fk_tah_id_pole foreign key(id_pole) references pole(id),
  constraint chk_tah_type check (type in (1, 2, 3))
);


-- *****
-- TMP table.
-- Mostly used for odkryj_pole and zaminuj_oblast.
-- ***********
create table tmp (
  id        number        primary key,  -- PK
  param     varchar2(30),               -- string value
  val       number,                     -- number value
  group_id  number
);


-- *****
-- TODO:
-- DEV-ONLY - used as a insurance to prevent from
--            getting stuck in recursion (odkryj_pole).
-- ***********
create table dev_tmp (
  id        number        primary key,
  val       number,
  str_val   varchar(255)
);


/***************** Sequences ******************/

/*
-- simulates "create or replace sequence"
drop sequence seq_tmp_id_increment;
drop sequence seq_hra_id_increment;
drop sequence seq_pole_id_increment;
drop sequence seq_mina_id_increment;
drop sequence seq_oblast_id_increment;
drop sequence seq_tah_id_increment;
*/

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
create or replace function game_id return number as
  id  number;
  begin
    select game_settings.val into id from game_settings
      where game_settings.id = game_constants.GS_GAME_ID;
    return id;
  end;

-- *****
-- Development flag getter.
-- ***********
create or replace function is_dev return number as
  isDev  number;
  begin
    select game_settings.val into isDev from game_settings
      where game_settings.id = game_constants.GS_DEV;
    return isDev;
  end;

-- *****
-- Drops all related tables.
-- ***********
create or replace procedure drop_tables as
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

    dbms_output.put_line('Tables dropped.');
  end;


-- *****
-- Prints horizontal divider.
-- ***********
create or replace procedure print_game_area_header_divider(num in number) as
  divider   varchar2(350);

  begin
    for i in 1..(num + 1) loop
      divider := divider || '---';
    end loop;

    dbms_output.put_line(divider);
  end;


-- *****
-- Prints X-axis.
-- ***********
create or replace procedure print_game_area_x_axis_header(colCount in number) as
  rowStr  varchar2(350);
  divider varchar2(2);
  begin
    print_game_area_header_divider(colCount);
    rowStr := rowStr || '   ';

    for i in 1..colCount loop
      if i > 9 then
        divider := ' ';
      else
        divider := '  ';
      end if;
      rowStr := rowStr || divider || i;
    end loop;

    dbms_output.put_line(rowStr);
    print_game_area_header_divider(colCount);
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
-- Builds a string of values of the fields forming a row at the specified index.
-- ***********
create or replace function radek_oblasti(rowNum in number, renderYAxisHeader in number, renderAll in number) return varchar2 as
  area          oblast%rowtype;
  rowString     varchar2(350) := null;
  markRecCount  number;

  begin
    select * into area from oblast where oblast.id_hra = game_id();

    if rowNum not between 1 and area.height then
      return rowString;
    end if;

    --select LISTAGG(pole.value, '|') WITHIN GROUP (ORDER BY pole.x)
    --  into rowString from pole where pole.y = rowNum and pole.id_hra = game_id();

    for rec in (select * from pole
                where pole.y = rowNum and pole.id_hra = game_id()
                order by pole.x asc) loop

      if rowString is null and renderYAxisHeader = game_constants.TRUE then
        print_game_area_y_axis_header(rowNum);
      end if;


      select count(mina.id) into markRecCount from mina
        where mina.id_pole = rec.id;

      if renderAll = game_constants.FALSE and markRecCount > 0 then
        rowString := rowString || '  x';
      else
        if rec.visible = game_constants.TRUE or renderAll = game_constants.TRUE then
          if rec.value < 0 then
            rowString := rowString || ' ';
          else
            rowString := rowString || '  ';
          end if;

          rowString := rowString || rec.value;
        else
          rowString := rowString || '  _';
        end if;
      end if;
    end loop;

    return rowString;
  end;


-- *****
-- Prints values of all fields of the playground.
-- ***********
create or replace procedure print_game_area_dev as
  area      oblast%rowtype;
  fieldRow  varchar2(255);

  begin
    select * into area from oblast where oblast.id_hra = game_id();

    -- x-axis header
    print_game_area_x_axis_header(area.width);

    for i in 1..area.height loop
      dbms_output.put_line(
          radek_oblasti(i, game_constants.TRUE, game_constants.true));
    end loop;
  end;

-- *****
-- Prints the playground.
-- ***********
create or replace procedure print_game_area as
  p         pole%rowtype;
  area      oblast%rowtype;

  begin
    select * into area from oblast where oblast.id_hra = game_id();

    -- x-axis header
    print_game_area_x_axis_header(area.width);

    for i in 1..area.height loop
      dbms_output.put_line(
          radek_oblasti(i, game_constants.TRUE, game_constants.false));
    end loop;
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
    where pole.id_hra = game_id()
    order by pole.y, pole.x;

  begin
    select * into area from oblast where oblast.id_hra = game_id();
    open cFields;

    -- x-axis header
    print_game_area_x_axis_header(area.width);

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
-- Prints playground, visibility and uncovered playgoround.
-- ***********
create or replace procedure print_game_area_all as
  begin
    DBMS_OUTPUT.put_line(' ');
    DBMS_OUTPUT.put_line('Playground:');
    print_game_area();

    DBMS_OUTPUT.put_line(' ');
    DBMS_OUTPUT.put_line('Visibility:');
    print_game_area_visibility();

    DBMS_OUTPUT.put_line(' ');
    DBMS_OUTPUT.put_line('Dev-only:');
    print_game_area_dev();
  end;


-- *****
-- Initializes database with required data.
-- ***********
create or replace procedure initialize as
  begin
    insert all
      into game_settings values(game_constants.GS_GAME_ID, 1, null)
      into game_settings values(game_constants.GS_ERR_MSG, null, null)
      into game_settings values(game_constants.GS_DEV, game_constants.FALSE, null)
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
      into dev_tmp values(1, 1000, null)
      into dev_tmp values(2, 0,  null)
    select * from dual;
    commit;
  end;

create or replace procedure create_new_game as
  begin
    insert into hra(id) values(null);
    dbms_output.put_line('Game created.');
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
-- Resets current game.
-- ***********
create or replace procedure reset_game as
  begin
    update pole set pole.visible = game_constants.FALSE;
    delete from mina where mina.id_hra = game_id();
    print_game_area_all();
  end;

-- *****
-- Game ID setter.
-- ***********
create or replace procedure setgame_id(game_id in number) as
  begin
    update game_settings set game_settings.val = game_id
      where game_settings.id = game_constants.GS_GAME_ID;
  end;

-- *****
-- Err msg getter.
-- ***********
create or replace function err_msg return varchar2 as
  msg  varchar2(255);
  begin
    select game_settings.str_val into msg from game_settings
      where game_settings.id = game_constants.GS_ERR_MSG;
    return msg;
  end;

-- *****
-- Err msg setter.
-- ***********
create or replace procedure set_err_msg(msg in varchar2) as
  begin
    update game_settings set game_settings.str_val = msg
      where game_settings.id = game_constants.GS_ERR_MSG;
  end;

-- *****
-- TODO:
-- Checks number of iterations.
-- ***********
create or replace function dev_is_safe return number as
  it    number;
  lim   number;
  begin
    select dev_tmp.val into lim from dev_tmp
      where dev_tmp.id = 1;

    select dev_tmp.val into it from dev_tmp
      where dev_tmp.id = 2;

    if is_dev() = game_constants.TRUE then
      dbms_output.put_line('iteration: ' || it || '/' || lim);
    end if;

    if it < lim then
      return game_constants.TRUE;
    else
      return game_constants.FALSE;
    end if;
  end;

-- *****
-- Number of iterations getter in odkryj_pole.
-- ***********
create or replace function dev_safety_check return number as
  val    number;
  begin
    select dev_tmp.val into val from dev_tmp
      where dev_tmp.id = 2;
    --dbms_output.put_line('safety check: ' || val);
    return val;
  end;

-- *****
-- Increments number of iterations.
-- ***********
create or replace procedure dev_safety_checkInc as
  begin
    update dev_tmp set dev_tmp.val = dev_tmp.val + 1
      where dev_tmp.id = 2;
  end;

-- *****
-- Resets number of iterations.
-- ***********
create or replace procedure dev_safety_checkReset as
  begin
    update dev_tmp set dev_tmp.val = 0 where dev_tmp.id = 2;
  end;

-- *****
-- Clears TMP table.
-- ***********
create or replace procedure clear_tmp(gId in number) as
  begin
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
    g_id := game_id();
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
-- Wipes database and initializes with crucial data.
-- ***********
create or replace procedure prepare_database as
  begin
    -- clean + init database
    clear_all();
    initialize();
    dbms_output.put_line('Database prepared.');
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
    select * into area from oblast where oblast.id_hra = game_id();

    s := area.width * area.height;

    for i in 0..(s - 1) loop
      x := mod(i, area.width) + 1;
      y := floor(i / area.width) + 1;
      insert into pole (id_hra, x, y) values (game_id(), x, y);
      --dbms_output.put_line('x: ' || x || ' y: ' || y);
    end loop;
  end;

-- *****
-- Randomly places mines on the area.
-- ***********
create or replace procedure zaminuj_oblast as
  cursor cFields is
  select pole.id from pole where pole.id_hra = game_id();

  cursor cTmps is
  select tmp.group_id from tmp order by tmp.val;

  area          oblast%rowtype;
  fId           number;
  rndId         number;
  mineCount     number;
  tmpFieldId    number;

  begin
    mineCount := 0;
    select * into area from oblast where oblast.id_hra = game_id();

    clear_tmp(null);

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
    clear_tmp(null);

  exception
    when no_data_found then
      raise_application_error(-20002, 'ERROR: Oblast hry id ' || game_id() || ' nebyla nalezena.');
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
    gId := game_id();

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
    select * from pole where pole.id_hra = game_id();

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
      where mina.id_pole = field.id and mina.id_hra = game_id();

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
      set hra.start_timestamp = CURRENT_TIMESTAMP,
          hra.id_stav = game_constants.GAME_STATUS_IN_PROGRESS
      where hra.id = game_id();
  end;

-- *****
-- Registers a lost of the game – records end datetime and sets a status of the game.
-- ***********
create or replace procedure register_game_lose as
  begin
    dbms_output.put_line('------------------------------------------');
    dbms_output.put_line('---------------- You lose! ---------------');
    dbms_output.put_line('------------------------------------------');
    update hra
      set hra.end_timestamp = SYSDATE,
          hra.id_stav = game_constants.GAME_STATUS_LOSE
      where hra.id = game_id();
  end;

-- *****
-- Registers a win of the game – records end datetime and sets a status of the game.
-- ***********
create or replace procedure register_game_win as
  begin
    dbms_output.put_line('******************************************');
    dbms_output.put_line('**************** You win! ****************');
    dbms_output.put_line('******************************************');
    update hra
      set hra.end_timestamp = SYSDATE,
          hra.id_stav = game_constants.GAME_STATUS_WIN
      where hra.id = game_id();
  end;

-- *****
-- Checks whether the field contains a mine or not.
-- ***********
create or replace function odkryta_mina(field in pole%rowtype) return number as
  begin

    if field.value = -1 then
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


  itNum               number := 0;

  begin

    -- stuck-in-loop protection
    dev_safety_checkInc();

    itNum := dev_safety_check();

    if dev_is_safe() = game_constants.FALSE then
      dbms_output.put_line('ERROR: STOPPED AT SAFETY CHECK.');
      return;
    end if;

    -- get the field from DB
    select * into field from pole where pole.id = fieldId;
    -- store processed field == set 'processed' flag to field
    insert into tmp(param, val, group_id) values (null, field.id, 0);


    -- Marked? –> Skip uncovering.
    if is_marked(field) = game_constants.FALSE then

      -- uncover
      if is_dev() = game_constants.TRUE then
        dbms_output.put_line('-- uncovering: ' || field.id);
      end if;

      uncover_field(field);

      -- Was a mine?
      if odkryta_mina(field) = game_constants.TRUE then
        return;
      end if;
    else
      if is_dev() = game_constants.TRUE then
        dbms_output.put_line('-- skipping: ' || field.id);
      end if;
    end if;

    -- no need to check if the player has already won
    -- in case the player has already won, there is
    -- no field to uncover

    -- get neighbour IDs
    neighbours := get_neighbour_fields(field);

    -- count adjacent mines
    adjacentMineCount := count_adjacent_mines(neighbours);

    -- if any of neighbours is a mine -> end
    if adjacentMineCount > 0 then
      if is_dev() = game_constants.TRUE then
        dbms_output.put_line('-- adjacent mines: ' || adjacentMineCount || '!!!');
      end if;
      return;
    else
      if is_dev() = game_constants.TRUE then
        dbms_output.put_line('-- adjacent mines: ' || adjacentMineCount);
      end if;
    end if;


    -- count adjacent covered fields
    adjacentCoveredCount := count_adjacent_covered_fields(neighbours);

    if is_dev() = game_constants.TRUE then
      dbms_output.put_line('-- adjacent covered: ' || adjacentCoveredCount);
    end if;

    -- no neighbouring covered fields –> end
    if adjacentCoveredCount = 0 then
      if is_dev() = game_constants.TRUE then
        dbms_output.put_line('-- no neighbouring covered fields');
      end if;
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

      if is_dev() = game_constants.TRUE then
        dbms_output.put_line('-- checking neighbour: ' || currentFieldId || ' of ' || field.id);
      end if;

      if recInTmpCount > 0 then
        if is_dev() = game_constants.TRUE then
          dbms_output.put_line('   -- already processed');
        end if;
        continue;
      end if;

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
      where mina.id_hra = game_id();

    select oblast.mine_count into mineCount from oblast
      where id_hra = game_id();

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
    --insert into mina (id_hra, id_pole) select game_id(), pole.id from pole
    --where pole.id_hra = game_id() and pole.visible = 0;
    insert into mina (id_pole) select pole.id from pole
      where pole.id_hra = game_id() and pole.visible = 0;
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
      set_err_msg('ERROR: Dimension is out of bounds. Please, enter dimensions in the range of ' || dimensionRestriction.min || ' and ' || dimensionRestriction.max || '.');
      return -1;
    end if;

    -- check mines restriction
    if mine_count not between 1 and maxMineCount then
      set_err_msg('ERROR: Invalid mine count. Number of mines must be at least 1 and must not exceed ' || mineRestriction.max || '% of area (i.e.' || maxMineCount || ' mines for selected area).');
      return -2;
    end if;

    return game_constants.FALSE;
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
      where id_hra = game_id() and pole.value = -1;

    select count(pole.id) into coveredFieldCount from pole
      where id_hra = game_id() and pole.visible = game_constants.FALSE;

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
      where oblast.id_hra = game_id();

    if fieldX not between 1 and area.width or
       fieldY not between 1 and area.height then
      raise outOfBoundsEx;
    end if;

    select * into field from pole
      where pole.x = fieldX and
            pole.y = fieldY and
            pole.id_hra = game_id();
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
    setgame_id(:new.id);
  end;


-- *****
-- Trigger: Auto-increment ID of the Mina table.
-- ***********
create or replace trigger trig_mina_initialization
  before insert on mina
  for each row
  begin
    select seq_mina_id_increment.nextval into :new.id from dual;
    :new.id_hra := game_id();
  end;

-- *****
-- Trigger: Counts mines and stores in HRA table.
-- ***********
create or replace trigger trig_mine_recount
  after insert or delete on mina
  declare
    mineCount number;
  begin
    select count(mina.id) into mineCount from mina where mina.id_hra = game_id();
    update hra set hra.marked_mine_count = mineCount where hra.id = game_id();
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
      where hra.id = game_id();

    if endTimestamp is not null then
      raise gameEndedEx;
    end if;

    select count(mina.id) into mineRowCount from mina
      where mina.id_pole = :new.id_pole;

    select * into field from pole where pole.id = :new.id_pole;

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
    :new.id_hra := game_id();

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
-- Trigger: Area initialization.
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
    :new.id_hra := game_id();

  exception
    when invalidDifficulty then
      RAISE_APPLICATION_ERROR( -20001, 'ERROR: Invalid difficulty selected.');
    null;

    when invalidParamsDimension then
        raise_application_error( -20003, err_msg());
      null;

    when invalidParamsMineCount then
      raise_application_error( -20004, err_msg());
      null;
  end;



-- *****
-- Trigger: Fields initialization.
-- ***********
create or replace trigger trig_fields_initialization
  after insert on oblast
  begin
    initialize_fields();
    zaminuj_oblast();
    spocitej_oblast();
  end;


-- *****
-- Trigger: Checks whether the uncovered field is mine or not.
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
      dbms_output.put_line('Mine was found at x: ' || field.x || ' y: ' || field.y || '.');
      register_game_lose();
    end if;
  end;

-- *****
-- Trigger: Check wheter the last move was a winning one or not.
-- ***********
create or replace trigger trig_win_check
  after update of visible on pole
  begin
    if vyhra() = game_constants.TRUE then
      register_game_win();
      oznac_miny();
    end if;
  end;

-- *****
-- Trigger: Game finalization.
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
-- Trigger: Move finalization.
-- ***********
create or replace trigger trig_tah_finalization
  after insert on tah
  for each row
  begin
    case
      when :new.type = game_constants.MOVE_UNCOVER then
        dev_safety_checkReset();
        clear_tmp(null);
        odkryj_pole(:new.id_pole);
      null;
      when :new.type = game_constants.MOVE_MARK then
        insert into mina(id_pole) values (:new.id_pole);
      when :new.type = game_constants.MOVE_UNMARK then
        delete from mina where mina.id_pole = :new.id_pole; -- and id_hra - zbytecne
    end case;
  end;

-- *****
-- Trigger: Registers game start.
-- ***********
create or replace trigger trig_game_beginning
  after insert on tah
  declare
    game  hra%rowtype;
  begin
    select * into game from hra where hra.id = game_id();

    if game.start_timestamp is null then
      register_game_beginning();
    end if;
  end;




/******************* Views ********************/

-- *****
-- View: Marked non-mine fields.
-- ***********
create or replace view chybne_miny as
  select  p.id as "ID pole",
          p.x as "souřadnice X",
          p.y as "souřadnice Y",
          p.value as "hodnota"
  from pole p inner join mina m on p.id = m.id_pole
  where p.value != -1
  order by p.id_hra, p.y, p.x;

-- *****
-- View: Successfully ended games.
-- ***********
create or replace view vitezove as
  select h.id as "ID hry",
         o.width || 'x' || o.height as rozměr,
         o.mine_count as "počet min",
         h.end_timestamp - h.start_timestamp as "doba hry"
  from hra h inner join oblast o on h.id = o.id_hra
  where h.id_stav = 4
  order by h.id;

-- *****
-- View: Unsuccessfully ended games.
-- ***********
create or replace view porazeni as
  select h.id as "ID hry",
         o.width || 'x' || o.height as "rozměr",
         o.mine_count as "počet min",
         h.end_timestamp - h.start_timestamp as "doba hry",
         (  select count(m.id)
            from mina m inner join pole p on p.id = m.id_pole
            where m.id_hra = h.id and
                  p.value = -1 ) as "správně odhaleno"
  from hra h inner join oblast o on h.id = o.id_hra
  where h.id_stav = 3
  order by h.id;

-- *****
-- View: Prints playground of the current game.
-- ***********
create or replace view oblast_tisk as
  select radek_oblasti(pole.y, 1, 0) as "hrací pole"
  from pole
  where pole.id_hra = game_id()
  group by pole.y
  order by pole.y;