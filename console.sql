
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



/**************** GameSetting *****************/

--drop package  game_settings;
create or replace package game_settings is
  game_id number := 1;

  safetyCheck number  := 1;
end;

create or replace package game_constants is
  TRUE      number := 1;
  FALSE     number := 0;
end;


/***************** DataTypes ******************/

create or replace type neighbour_array is varray(8) of number;



/******************* Tables *******************/

/**
* OBTIZNOST table.
*/
create table obtiznost (
  id          number          primary key,
  label       varchar2(10)    not null,
  width       number          not null,
  height      number          not null,
  mine_count  number          not null,

  -- 9 <= dimension <= 100
  CONSTRAINT chk_width CHECK (width BETWEEN 9 AND 100),
  CONSTRAINT chk_height CHECK (height BETWEEN 9 AND 100),

  -- max 40 % of area
  CONSTRAINT chk_mine_count CHECK (mine_count < (width * height * 0.4))
);

/**
* OMEZENI table.
*/
CREATE TABLE omezeni (
  id      number        PRIMARY KEY,
  type    varchar2(1),
  min     number        NOT NULL,
  max     number        NOT NULL
);

/**
* OBLAST table.
*/
CREATE TABLE oblast (
  id            number  PRIMARY KEY,
  id_hra        number  NOT NULL,
  id_obtiznost  number,
  width         number,
  height        number,
	mine_count    number,

  CONSTRAINT fk_id_obtiznost FOREIGN KEY (id_obtiznost) REFERENCES OBTIZNOST (ID),
  constraint fk_id_hra foreign key(id_hra) references hra(id)

  /*,

  constraint chk_conditions check (
    id_obtiznost  is not null and
    width         is not null and
    height        is not null and
    mine_count    is not null
  )
  */
);


/**
* POLE table.
*/
CREATE TABLE pole (
  id      number               PRIMARY KEY,
  id_hra  number               NOT NULL,
  x       number               NOT NULL,
  y       number               NOT NULL,
  value   number    default 0  NOT NULL,
  visible number(1) default 0  NOT NULL,

  constraint fk_id_hra foreign key(id_hra) references hra(id),
  CONSTRAINT chk_value check (value between -1 and 8)
);

/**
* MINA table.
*/
CREATE TABLE mina (
  id      number  PRIMARY KEY,
  id_hra  number  NOT NULL,
  id_pole number  NOT NULL,

  constraint fk_id_hra foreign key(id_hra) references hra(id),
  constraint fk_id_pole foreign key(id_pole) references pole(id)
);

/**
* TAH table.
*/
CREATE TABLE tah (
  id        number  PRIMARY KEY,
  id_hra    number  NOT NULL,
  id_pole   number  NOT NULL,
  timestamp DATE    NOT NULL,

  constraint fk_id_hra foreign key(id_hra) references hra(id),
  constraint fk_id_pole foreign key(id_pole) references pole(id)
);

/**
* STAV table.
*/
CREATE TABLE stav (
  id        number,
  status    number  NOT NULL,

  constraint pk_id primary key (id)
);

/**
* HRA table.
*/
CREATE TABLE hra (
  id                  number              PRIMARY KEY,
  id_stav             number              NOT NULL,
  marked_mine_count   number  default 0   NOT NULL,
  start_timestamp     date,
  end_timestamp       date,

  constraint fk_id_stav foreign key(id_stav) references stav(id),
  constraint chk_marked_mine_count CHECK (marked_mine_count >= 0)
);

----------------------------

/**
* TMP table.
*/
create table tmp (
  id        number        primary key,  -- PK
  param     varchar2(30),               -- string value
  val       number,                     -- number value
  group_id  number
);



/***************** Sequences ******************/

/**
* Sequence: Auto-increment ID of the Pole table.
*/
create sequence seq_pole_id_increment increment by 1 start with 1;

/**
* Sequence: Auto-increment ID of the Tmp table.
*/
create sequence seq_tmp_id_increment increment by 1 start with 1;

/**
* Sequence: Auto-increment ID of the Hra table.
*/
create sequence seq_hra_id_increment increment by 1 start with 1;



/****************** Triggers ******************/

/**
* Trigger: Auto-increment ID of the Pole table.
*/
create or replace trigger trig_pole_id_increment
  before insert on pole
  for each row
  begin
    select seq_pole_id_increment.nextval into :new.id from dual;
  end;


-- drop trigger trig_tmp_id_increment;

/**
* Trigger: Auto-increment ID of the Tmp table.
*/
create or replace trigger trig_tmp_id_increment
  before insert on tmp
  for each row
  begin
    select seq_tmp_id_increment.nextval into :new.id from dual;
  end;

/**
* Trigger: Auto-increment ID of the Tmp table.
*/
create or replace trigger trig_hra_id_increment
  before insert on hra
  for each row
  begin
    select seq_hra_id_increment.nextval into :new.id from dual;
  end;





/***************** Procedures *****************/



-- drop sequence seq_pole_id_increment;
-- drop sequence seq_hra_id_increment;
-- drop sequence seq_tmp_id_increment;

declare
begin
  -- delete tables + triggers
  dev_drop_tables();

  -- clean + init database
  clear_all();
  initialize();

  -- clean current game
  clear_game();
  initialize_game();
end;



create or replace procedure initialize as
  begin
    insert all
      into stav values(1, 1)
      into stav values(2, 2)
    select * from dual;

    insert all
      into obtiznost values(1, 'zacatecnik', 9,  9, 10)
      into obtiznost values(2, 'pokrocily', 16, 16, 40)
      into obtiznost values(3, 'expert',    16, 30, 99)
    select * from dual;

    insert all
      into omezeni values(1, 1, 9, 100)
      into omezeni values(2, 2, 1, 40)
    select * from dual;
  end;

create or replace procedure initialize_game as
  begin
    game_settings.game_id := 1;

    insert into hra(id_stav) values(1);
    insert into oblast values(1, 1, null, 10, 10, 1);

    initialize_fields();
    zaminuj_oblast();
    spocitej_oblast();
    print_game_area();
  end;

create or replace procedure clear_game as
  begin
    delete from tmp;
    delete from tah     where tah.id_hra = game_settings.game_id;
    delete from oblast  where oblast.id_hra = game_settings.game_id;
    delete from mina    where mina.id_hra = game_settings.game_id;
    delete from pole    where pole.id_hra = game_settings.game_id;
    delete from hra     where hra.id = game_settings.game_id;
    delete from stav    where stav.id;
  end;

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
  end;


/**
* Generates Fields of the Pole table.
* (new records –> Pole)
*/
create or replace procedure initialize_fields as
  x     number;
  y     number;
  s     number;
  area  oblast%rowtype;

  begin
    select * into area from oblast where oblast.id_hra = game_settings.game_id;

    s := area.width * area.height;

    for i in 0..(s - 1) loop
      x := mod(i, area.width) + 1;
      y := floor(i / area.width) + 1;
      insert into pole (id_hra, x, y) values (game_settings.game_id, x, y);
      --dbms_output.put_line('x: ' || x || ' y: ' || y);
    end loop;
  end;

  begin
    delete from pole where pole.id_hra = game_settings.game_id;
    initialize_fields();
    print_game_area();
  end;

/**
* Randomly places mines on the area.
*/
create or replace procedure zaminuj_oblast as
  cursor cFields is
  select pole.id from pole where pole.id_hra = game_settings.game_id;

  cursor cTmps is
  select tmp.group_id from tmp order by tmp.val;

  area          oblast%rowtype;
  fId           number;
  rndId         number;
  mineCount     number;
  tmpFieldId    number;

  begin
    mineCount := 0;
    select * into area from oblast where oblast.id_hra = game_settings.game_id;

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
    commit;

  exception
    when no_data_found then
      raise_application_error(-20001, 'ERROR: Oblast hry id ' || game_settings.game_id || ' nebyla nalezena.');
  end;



create or replace procedure spocitej_oblast as
  cursor cFields is
    select * from pole where pole.id_hra = game_settings.game_id;

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
      neighbours := get_neighbour_fields(field.x, field.y);

      -- count surrounding mines
      fieldValue := count_adjacent_mines(neighbours);

      update pole set value = fieldValue where pole.id = field.id;
    end loop;

    close cFields;
    commit;
  end;


  begin
    delete from pole where pole.id_hra = game_settings.game_id;
    initialize_fields();
    zaminuj_oblast();
    print_game_area();
    spocitej_oblast();
    print_game_area();
  end;


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


/**
* Collects ID of fields of all adjacent fields of the given one.
*/
create or replace function get_neighbour_fields(fieldX in number, fieldY in number) return neighbour_array as
  neighbours   neighbour_array;
  area              oblast%rowtype;
  xMin              number;
  xMax              number;
  yMin              number;
  yMax              number;
  i                 number;

  begin
    neighbours := neighbour_array();

    select * into area from oblast where oblast.id_hra = game_settings.game_id;

    xMin := fieldX - 1;
    if(xMin < 1) then
      xMin := 1;
    end if;

    xMax := fieldX + 1;
    if(xMax > area.width) then
      xMax := area.width;
    end if;


    yMin := fieldY - 1;
    if(yMin < 1) then
      yMin := 1;
    end if;

    yMax := fieldY + 1;
    if(yMax > area.width) then
      yMax := area.width;
    end if;

    i := 1;

    -- into neighbour
    for rec in (select * from pole
        where pole.id_hra = game_settings.game_id and
              pole.x between xMin and xMax and
              pole.y between yMin and yMax) loop

      continue when rec.x = fieldX and rec.y = fieldY;

      neighbours.extend;
      neighbours(i) := rec.id;
      i := i + 1;
    end loop;

    return neighbours;
  end;

  declare
    neighbours   neighbour_array;
  begin
    neighbours := get_neighbour_fields(2,2);
  end;



create or replace procedure odkryj_pole(fieldX in number, fieldY in number) as
  field               pole%rowtype;
  fieldCount          number;
  adjacentMineCount   number;
  neighbours          neighbour_array;

  n                   number;
  neighbour           pole%rowtype;

  recInTmpCount       number;



  begin
    game_settings.safetyCheck := game_settings.safetyCheck + 1;

    if game_settings.safetyCheck >= 100 then
      return;
    end if;


    select * into field from pole
      where pole.id_hra = game_settings.game_id and
            pole.x = fieldX and
            pole.y = fieldY;


    dbms_output.put_line('Uncovering: ' || field.id);

    -- if mine -> end game
    -- may happen only at first run
    -- (when the player hits a mine)
    if field.value = -1 then
      dbms_output.put_line('-- Mine found!');
      end_game();
      return;
    end if;


    insert into tmp(param, val, group_id) values (null, field.id, 0);


    -- not a mine
    uncover_field(field);

    -- check if the player has already won
    if check_if_winning_state() = game_constants.TRUE then
      win_game();
    end if;

    -- get neighbour IDs
    neighbours := get_neighbour_fields(field.x, field.y);

    -- count adjacent mines
    adjacentMineCount := count_adjacent_mines(neighbours);

    -- if any of neighbours is a mine -> end
    if adjacentMineCount > 0 then
      dbms_output.put_line('-- Adjacent mine!');
      return;
    end if;

    return;


    -- if no mines surround –> recursive call
    n := neighbours.first;

    while (n is not null) loop

      dbms_output.put_line('-- checking neighbour: ' || neighbours(n));

      select count(tmp.id) into recInTmpCount from tmp where tmp.val = neighbours(n);
      continue when recInTmpCount > 0;

      select * into neighbour from pole where pole.id = neighbours(n);
      odkryj_pole(neighbour.x, neighbour.y);

      n := neighbours.next(n);
    end loop;


  end;


begin
  --delete from tmp;
  --print_game_area();
  --odkryj_pole(1, 3);
  --print_game_area();
end;



create or replace function check_if_winning_state return number as
  fieldCount  number;

  begin
    select count(pole.id) into fieldCount from pole
      where id_hra = game_settings.game_id and
            pole.visible = game_constants.FALSE and
            pole.value != -1;

    if fieldCount = 0 then
      return game_constants.TRUE;
    end if;

    return game_constants.FALSE;
  end;


create or replace procedure uncover_field(field in out pole%rowtype) as
  begin
    update pole set pole.visible = game_constants.TRUE where pole.id = field.id;
    field.visible := game_constants.TRUE;
  end;

create or replace procedure start_game as
  begin
    null;
  end;

create or replace procedure end_game as
  begin
    null;
  end;

create or replace procedure win_game as
  begin
    dbms_output.put_line('You win!');
  end;





/******************* Views ********************/







/******************* Test *********************/


begin

    --INSERT INTO pole values (1, 1, x, y, val);
    --select * from pole where pole.id_hra = game_settings.game_id and pole.x = x and pole.y = y;
  end;



  truncate table pole;

  begin
    initialize_fields();
  end;

  select * from pole;



  begin
    update pole set pole.value = 0;

    zaminuj_oblast();

    spocitej_oblast();

    print_game_area();
  end;



/************** Development-only **************/

create table dev_tmp (
  id    number  primary key,
  param varchar2(30),
  val   number
);

--insert into dev_tmp values (1, 'print_game_area', 1);


create or replace procedure dev_drop_tables as
  tbl_name    varchar2(100);

  cursor c_tables is
    select table_name from all_tables
    where owner like 'PITTL' and table_name not like 'XML_SOUBORY';

  begin
    DBMS_OUTPUT.put_line('Table dropping starts.');
    open c_tables;

    loop

      -- next table
      fetch c_tables into tbl_name;

      -- no tables?
      if c_tables%notfound then
        DBMS_OUTPUT.put_line('  No tables found.');
        DBMS_OUTPUT.put_line('Table dropping ends.');
        exit;
      end if;

      EXECUTE IMMEDIATE 'drop table ' || tbl_name;
      DBMS_OUTPUT.put_line('  Dropped table: ' || tbl_name);
    end loop;

    close c_tables;
    commit;

  exception
    when others then
      DBMS_OUTPUT.PUT_LINE ('Some errors occured while dropping tables.');
      DBMS_OUTPUT.PUT_LINE (SQLERRM);
      DBMS_OUTPUT.PUT_LINE (SQLCODE);
  end;



  create or replace procedure print_game_area as
    p         pole%rowtype;
    area      oblast%rowtype;
    fieldRow  varchar2(255);

    cursor cFields is
      select * from pole
      where pole.id_hra = game_settings.game_id
      order by pole.y, pole.x;

    begin
      select * into area from oblast where oblast.id_hra = game_settings.game_id;
      open cFields;

      DBMS_OUTPUT.put('   ');
      for i in 1..area.width loop
        DBMS_OUTPUT.put('  ' || i);
      end loop;

      DBMS_OUTPUT.new_line;

      for i in 1..(area.width + 2) loop
        DBMS_OUTPUT.put('---');
      end loop;

      DBMS_OUTPUT.new_line;

      loop
        fetch cFields into p;
        exit when cFields%notfound;

        if p.x = 1 and p.y < 10 then
          DBMS_OUTPUT.put(p.y || ' |');
        elsif p.x = 1 and p.y >= 10 then
          DBMS_OUTPUT.put(p.y || '|');
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


  begin
    print_game_area();
  end;








/************ Data initialization. ************/

-- OBTIZNOST
insert all
  into obtiznost values (1, 'začátečník', 9, 9, 10)
  into obtiznost values (2, 'pokročilý', 16, 16, 40)
  into obtiznost values (3, 'expert', 16, 30, 99)
select * from dual;

-- OMEZENI
insert all
  into omezeni values (1, 'D', 9, 100)
  into omezeni values (2, 'M', 0, 40)
select * from dual;
