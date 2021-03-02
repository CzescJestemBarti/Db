SET SERVEROUTPUT ON;
--1. Procedura dodawajaca nowego golfiste przyjmujaca parametry Imie, Nazwisko, RokUrodzenia, idPomocnika (jezeli nie istnieje
--   taki pomocnik, zostanie wyswietlona informacja oraz zostanie on dodany).

CREATE OR REPLACE PROCEDURE dodajGolfiste( n_im VARCHAR2, n_nazw VARCHAR2, n_rok DATE, n_idpom int)
AS
n_idgolf int;
n_idpomnowy int;
n_count int;
BEGIN
    SELECT MAX(idgolfisty)+1 INTO n_idgolf FROM golfista;
    SELECT COUNT(*) INTO n_count FROM Pomocnik WHERE idpomocnika=n_idpom;
    SELECT MAX(idpomocnika)+1 INTO n_idpomnowy FROM pomocnik;
    
    IF n_count>0 THEN
        INSERT INTO Golfista VALUES(n_idgolf, n_im, n_nazw, n_rok, n_idpom);
        dbms_output.put_line('Dodalem golfiste ' || n_im ||' ' || n_nazw ||'.');
    ELSE
        INSERT INTO Pomocnik VALUES('POMOCNIK', 'NOWY', n_idpomnowy);
        dbms_output.put_line('Dodano pomocnika.');
        INSERT INTO Golfista VALUES(n_idgolf, n_im, n_nazw, n_rok, n_idpomnowy);
        dbms_output.put_line('Dodalem golfiste ' || n_im ||' ' ||  n_nazw || '.');
    END IF;
END;

EXECUTE dodajGolfiste('TEST', 'TEST', TO_DATE('2000.02.02','YYYY-MM-DD'), 1003);

--2. Procedura szukajaca najlepszego sposrod x zawodnikow turnieju.

CREATE OR REPLACE PROCEDURE znajdzNajlepszego(ile int)
AS
tmp int;
aktualny int;
faworyt int;
ilegolf int;
w_imie varchar2(30);
w_nazwisko varchar2(30);
w_id int;
BEGIN
    tmp:=2;
    --warunek nie wyjscia poza
    SELECT COUNT(*) into ilegolf FROM golfista;
    
    IF ile <= 0 OR ile > ilegolf THEN
        dbms_output.put_line('Podaj liczbe naturalna, wieksza od zera oraz mniejsza od ilosci golfistow: ' || ilegolf);
    ELSE
        -- ile := 1
        SELECT (MAX(IDUDERZENIA)-MIN(IDUDERZENIA)) INTO aktualny FROM Uderzenie WHERE idGolfisty = 1;    
            faworyt := aktualny;
        WHILE(tmp <= ile) 
        LOOP
        SELECT (MAX(IDUDERZENIA)-MIN(IDUDERZENIA)) INTO aktualny FROM Uderzenie WHERE idGolfisty = tmp;    
                IF aktualny < faworyt THEN
                    faworyt := aktualny;
                    w_id := tmp;
                END IF;
            tmp:=tmp+1;
        END LOOP;
        SELECT imie INTO w_imie FROM Golfista WHERE idGolfisty = w_id;
        SELECT nazwisko INTO w_nazwisko FROM Golfista WHERE idGolfisty = w_id;
        dbms_output.put_line('Najlepszy zawodnik to ' || w_imie || ' ' || w_nazwisko  ||' z wynikiem ' || faworyt);
    END IF;
END;

EXECUTE znajdzFinaliste(10);


--3. Wyzwalacz, nieumozliwiajacy dodanie golfisty jezeli rok jego daty urodzenia jest wiekszy niz najstarszego zawodnika.

CREATE OR REPLACE TRIGGER zaStary
BEFORE INSERT
ON golfista
FOR EACH ROW
DECLARE
n_rok date;
BEGIN
        SELECT MIN(rokUrodzenia) into n_rok FROM golfista;
       
        IF :new.rokUrodzenia < n_rok THEN
            raise_application_error(-20420, 'Zbyt stary gracz.');
        END IF;
END;

--4. Wyzwalacz, ktory nie pozwoli na zmienienie sponsora, jezeli jakis Golfista ma juz sponsora oraz nie pozwoli 
--   usunac sponsoring jezeli kwota jest wieksza od 1300.

CREATE OR REPLACE TRIGGER trigger41
BEFORE UPDATE OR DELETE
ON Sponsoring
FOR EACH ROW
DECLARE
n_count int;
BEGIN
    IF UPDATING THEN
        IF :new.IdSponsora!=:old.IdSponsora AND :old.IdSponsora IS NOT NULL THEN
            raise_application_error(-20420, 'Ten golfista ma juz sponsora.');
        END IF;
    ELSIF DELETING THEN
        IF :old.kwota > 1300 THEN
            raise_application_error(-20420, 'Ten golfista zarabia wiecej niz 1300, sprobuj najpierw zmniejszyc zarobek.');
        END IF;
    END IF;
END;