--1. Napisz procedurê, która zwraca pracowników zarabiaj¹cych mniej, ni¿ wartoœæ podana jako parametr procedury i zwieksza ich zarobki o 10%.

CREATE PROCEDURE pokazGolfiste
@kwota int
AS BEGIN
	DECLARE @zarobki INT, @idgolfisty INT, @zarobkipo INT
	DECLARE kursor CURSOR FOR SELECT idgolfisty FROM sponsoring WHERE idgolfisty <= (SELECT MAX(IdGolfisty) FROM golfista)
	OPEN kursor
	FETCH NEXT FROM kursor INTO @idgolfisty
	WHILE @@FETCH_STATUS=0
	BEGIN
		SELECT @zarobki = SUM(kwota) FROM sponsoring WHERE IdGolfisty = @idgolfisty
		UPDATE sponsoring set kwota = kwota * 1.1 WHERE @zarobki < @kwota AND idgolfisty = @idgolfisty;
		SELECT @zarobkipo = SUM(kwota) FROM sponsoring WHERE IdGolfisty = @idgolfisty
			IF @zarobki < @zarobkipo
			BEGIN
				PRINT 'Zwiekszono pensje golfisty ' + CONVERT(VARCHAR, @idgolfisty) + ' z ' + CONVERT(VARCHAR, @zarobki)  + ' na ' + CONVERT(VARCHAR, @zarobkipo)
			END
		FETCH NEXT FROM kursor INTO @idgolfisty
	END
	CLOSE kursor
	DEALLOCATE kursor
END

GO

/*
select avg(kwota) from sponsoring;
GO

EXECUTE pokazGolfiste 2421;
GO

SELECT * FROM sponsoring;
GO
*/

--2. Procedura przyjmujaca jako parametr idGolfisty, idSponsora oraz kwote jaka chce on zmienic. W przypadku, gdy nie ma takiego IdGolfisty, badz idSponsora zostanie wypisany odpowiedni
--   komunikat. Kwota nowa nie moze byc mniejsza od poprzedniej.

CREATE PROCEDURE zmienPlace
@idGolfisty int,
@idSponsora int,
@kwota int
AS BEGIN
	IF NOT EXISTS( SELECT * FROM Golfista WHERE IdGolfisty=@idGolfisty)
		PRINT 'Nie istnieje Golfista o takim id'
	ELSE
		IF NOT EXISTS ( SELECT * FROM Sponsor WHERE IdSponsora = @idSponsora )
				PRINT 'Nie istnieje Sponsor o takim id'
		ELSE
			IF @kwota <= ( SELECT kwota FROM sponsoring WHERE IdGolfisty=@idGolfisty AND IdSponsora=@idSponsora )
				PRINT 'Nie wolno zmienic kwoty na mniejsza, badz rowna obecnej.'
			ELSE
				UPDATE Sponsoring SET kwota = @kwota WHERE IdGolfisty=@idGolfisty AND IdSponsora=@idSponsora
END

GO

/*
execute zmienPlace 1,1,1000
*/

--3.	Utwórz wyzwalacz, który nie pozwoli na wykonanie operacji DELETE, jeœli kwota jest wieksza niz srednia kwota w tabeli sponsoring.
-- IDGOLFISTA INT FK(od Golfista), IDSPONSORA INT FK(od Sponsor), KWOTA INT

CREATE TRIGGER niePozwolUsunac
ON Sponsoring
FOR DELETE
AS
DECLARE @kwota int
DECLARE kursor CURSOR FOR SELECT kwota FROM deleted;
OPEN kursor
FETCH NEXT FROM kursor INTO @kwota
WHILE @@FETCH_STATUS = 0
	BEGIN
		IF  @kwota >= ( SELECT AVG(kwota) FROM sponsoring)
			ROLLBACK
		FETCH NEXT FROM kursor INTO @kwota
	END
	CLOSE kursor
	DEALLOCATE kursor
GO

	/*
	select * from sponsoring

	select avg(kwota) from sponsoring --2930  1>=2930

	drop trigger niepozwolusunac

	select * from sponsoring where idgolfisty = 10
	*/

--4.	Stwórz wyzwalacz, który nie pozwoli na zmianê nazwiska golfisty
--		oraz
--		nie pozwoli wstawiæ golfisty ju¿ istniej¹cego (sprawdzaj¹c po id i nazwisku).

CREATE TRIGGER updateGolfista
ON Golfista
FOR UPDATE, INSERT
AS 
DECLARE @nazwisko VARCHAR(30), @idGolfisty INT
DECLARE kursor CURSOR FOR SELECT nazwisko, idGolfisty FROM inserted
OPEN kursor
FETCH NEXT FROM kursor INTO @nazwisko, @idGolfisty

IF (SELECT COUNT(*) FROM deleted) = 0
BEGIN
	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF EXISTS (SELECT idGolfisty FROM Golfista WHERE nazwisko = @nazwisko AND idGolfisty != @idGolfisty)

			DELETE FROM Golfista WHERE idGolfisty = @idGolfisty

		FETCH NEXT FROM kursor INTO @idGolfisty, @nazwisko
	END
END

ELSE
BEGIN
	WHILE @@FETCH_STATUS = 0
	BEGIN
		DECLARE @starenazwisko VARCHAR(20)
		
		SELECT @starenazwisko = nazwisko
		FROM deleted 
		WHERE idGolfisty = @idGolfisty
			
			IF @starenazwisko != @nazwisko

				UPDATE Golfista SET nazwisko = @starenazwisko WHERE idGolfisty = @idGolfisty

		
		FETCH NEXT FROM kursor INTO @nazwisko, @idGolfisty
	END
END
	CLOSE kursor
	DEALLOCATE kursor
GO