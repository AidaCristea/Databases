

CREATE TABLE Countries(
	idCountry INT PRIMARY KEY IDENTITY(1,1),
	nameCountry VARCHAR(100)
)

INSERT INTO Countries VALUES ('country1'), ('country2')


CREATE TABLE Coaches(
	idCoach INT PRIMARY KEY IDENTITY(1,1),
	nameCoach VARCHAR(100),
	dob DATE,
	countryId INT FOREIGN KEY REFERENCES Countries(idCountry)
)
INSERT INTO Coaches VALUES ('coach1', '2000-12-27', 1), ('coach2', '1999-11-10', 2), ('coach3', '1998-10-20', 1)

CREATE TABLE Team(
	idTeam INT PRIMARY KEY IDENTITY(1,1),
	coachId INT FOREIGN KEY REFERENCES Coaches(idCoach),
	city VARCHAR(100),
	nameTeam VARCHAR(100) UNIQUE
)

INSERT INTO Team VALUES (1, 'Cluj', 'team1'), (2, 'Turda', 'team2'), (3, 'Alba', 'team3')

CREATE TABLE Player(
	idPlayer INT PRIMARY KEY IDENTITY(1,1),
	namePlayer VARCHAR(100),
	countryId INT FOREIGN KEY REFERENCES Countries(idCountry),
	teamId INT FOREIGN KEY REFERENCES Team(idTeam)
)

INSERT INTO Player VALUES ('player1', 1, 1), ('player2', 2, 2), ('player3', 1, 3)


CREATE TABLE Games(
	idGame INT PRIMARY KEY IDENTITY(1,1),
	gameDate DATE,
	hostTeam INT FOREIGN KEY REFERENCES Team(idTeam),
	guestTeam INT FOREIGN KEY REFERENCES Team(idTeam),
	score VARCHAR(100),
	flag INT
)

INSERT INTO Games VALUES ('2020-12-20', 1, 2, '2-0', 0), ('2021-11-12', 2, 3, '1-0', 1), ('2022-10-14', 3, 1, '4-3', 1)


CREATE TABLE Rankings(
	gameId INT FOREIGN KEY REFERENCES Games(idGame),
	winnerTeam INT FOREIGN KEY REFERENCES Team(idTeam),
	PRIMARY KEY (gameId, winnerTeam)
)


INSERT INTO Rankings VALUES (1,1), (2, 3), (3, 3)


GO
CREATE OR ALTER PROCEDURE addGame @gdate DATE, @ht INT, @gT INT, @score VARCHAR(100), @fl INT AS
BEGIN
		DECLARE @nr INT
		SET @nr =0
		SELECT @nr = COUNT(*) FROM Games WHERE Games.hostTeam = @ht AND Games.guestTeam=@gT AND Games.gameDate=@gdate

		IF (@nr<>0) BEGIN
			UPDATE Games
			SET Games.score=@score
			WHERE Games.hostTeam = @ht AND Games.guestTeam=@gT AND Games.gameDate=@gdate
		END
		ELSE BEGIN
			INSERT INTO Games VALUES (@gdate, @ht, @gT, @score, @fl)
		END
END

SELECT * FROM Games
EXEC addGame '2020-10-12', 1, 2, '2-3', 1
SELECT * FROM Games
EXEC addGame '2022-10-14', 3, 1, '5-3', 1
SELECT * FROM Games


-- view shows name of the teams that won all the games they ever played
-- Not working
GO
CREATE OR ALTER VIEW teamsAll AS
	SELECT Team.nameTeam
	FROM Team
	WHERE Team.idTeam IN (
						SELECT Rankings.winnerTeam
						FROM Rankings
						INNER JOIN Games ON Games.idGame=Rankings.gameId
						GROUP BY Rankings.winnerTeam 
						HAVING COUNT(*) = (SELECT COUNT(*) FROM Rankings )
						)
	     
SELECT * FROM teamsAll 

-- fct nr of coaches that won more than R games decided in overtime

GO
CREATE FUNCTION uf_moreWin(@R INT) 
RETURNS TABLE
AS
RETURN
		SELECT COUNT(Team.idTeam) AS TeamW
		FROM Team
		WHERE Team.idTeam IN (
				SELECT Rankings.winnerTeam
				FROM Rankings
				INNER JOIN Games ON Rankings.gameId=Games.idGame
				WHERE Games.flag=1
				GROUP BY Rankings.winnerTeam
				HAVING COUNT(Rankings.winnerTeam)> @R
				)

SELECT * FROM uf_moreWin(1)