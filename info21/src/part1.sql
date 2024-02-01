DROP TYPE IF EXISTS status;

DROP TABLE IF EXISTS Peers,
                     Tasks,
                     Verter,
                     Friends,
                     Checks,
                     TransferredPoints,
                     P2P,
                     XP,
                     TimeTracking,
                     Recommendations CASCADE;

CREATE TABLE IF NOT EXISTS Peers (
	Nickname varchar PRIMARY KEY NOT NULL,
	Birthday date
)

CREATE TABLE IF NOT EXISTS Tasks (
-- Чтобы получить доступ к заданию, нужно выполнить задание, являющееся его условием входа.
-- Для упрощения будем считать, что у каждого задания всего одно условие входа.
-- В таблице должно быть одно задание, у которого нет условия входа (т.е. поле ParentTask равно null).
	
    Title varchar PRIMARY KEY NOT NULL,
    ParentTask varchar,
    MaxXP int NOT NULL,
    CONSTRAINT fk_Tasks_ParentTask FOREIGN KEY (ParentTask) REFERENCES Tasks (Title)
);

CREATE TYPE status AS ENUM ('Start', 'Success', 'Failure');

CREATE TABLE IF NOT EXISTS P2P (
-- Каждая P2P проверка состоит из 2-х записей в таблице: первая имеет статус начало, вторая - успех или неуспех. 
-- В таблице не может быть больше одной незавершенной P2P проверки, относящейся к конкретному заданию, пиру и проверяющему. 
-- Каждая P2P проверка (т.е. обе записи, из которых она состоит) ссылается на проверку в таблице Checks, к которой она относится.
	
	ID serial PRIMARY KEY,
	"Check" bigint NOT NULL,
	CheckingPeer varchar NOT NULL,
	"State" status,
	"Time" time NOT NULL,
	CONSTRAINT fk_P2P_Check FOREIGN KEY ("Check") REFERENCES Checks (ID),
	CONSTRAINT fk_P2P_CheckingPeer FOREIGN KEY (CheckingPeer) REFERENCES Peers (Nickname)
);


CREATE TABLE IF NOT EXISTS Verter (
-- Каждая проверка Verter'ом состоит из 2-х записей в таблице: первая имеет статус начало, вторая - успех или неуспех. 
-- Каждая проверка Verter'ом (т.е. обе записи, из которых она состоит) ссылается на проверку в таблице Checks, к которой она относится. 
-- Проверка Verter'ом может ссылаться только на те проверки в таблице Checks, которые уже включают в себя успешную P2P проверку.
	
	ID serial PRIMARY KEY,
	"Check" bigint NOT NULL,
	"State" status,
	"Time" time NOT NULL,
	CONSTRAINT fk_Verter_Check FOREIGN KEY ("Check") REFERENCES Checks (ID)
);

CREATE TABLE IF NOT EXISTS Checks (
-- Описывает проверку задания в целом. Проверка обязательно включает в себя один этап P2P и, возможно, этап Verter.
-- Для упрощения будем считать, что пир ту пир и автотесты, относящиеся к одной проверке, всегда происходят в один день.
-- Проверка считается успешной, если соответствующий P2P этап успешен, а этап Verter успешен, либо отсутствует.
-- Проверка считается неуспешной, хоть один из этапов неуспешен.
-- То есть проверки, в которых ещё не завершился этап P2P, или этап P2P успешен, но ещё не завершился этап Verter, не относятся ни к успешным, ни к неуспешным.

	ID serial PRIMARY KEY,
	Peer varchar NOT NULL,
	Task varchar NOT NULL,
	"Date" date,
	CONSTRAINT fk_Checks_Peer FOREIGN KEY (Peer) REFERENCES Peers (Nickname),
	CONSTRAINT fk_Checks_Task FOREIGN KEY (Task) REFERENCES Tasks (Title)
);

CREATE TABLE IF NOT EXISTS TransferredPoints (
-- При каждой P2P проверке проверяемый пир передаёт один пир поинт проверяющему.
-- Эта таблица содержит все пары проверяемый-проверяющий и кол-во переданных пир поинтов, то есть,
-- другими словами, количество P2P проверок указанного проверяемого пира, данным проверяющим.
	
	ID serial PRIMARY KEY,
	CheckingPeer varchar NOT NULL,
	CheckedPeer varchar NOT NULL,
	PointsAmount int NOT NULL DEFAULT 0,
	CONSTRAINT fk_TransferredPoints_CheckingPeer FOREIGN KEY (CheckingPeer) REFERENCES Peers (Nickname),
	CONSTRAINT fk_TransferredPoints_CheckedPeer FOREIGN KEY (CheckedPeer) REFERENCES Peers (Nickname)
);

CREATE TABLE IF NOT EXISTS Friends (
-- Дружба взаимная, т.е. первый пир является другом второго, а второй - другом первого.
	
	ID serial PRIMARY KEY,
	Peer1 varchar NOT NULL,
	Peer2 varchar NOT NULL,
	CONSTRAINT fk_Friends_Peer1 FOREIGN KEY (Peer1) REFERENCES Peers (Nickname),
	CONSTRAINT fk_Friends_Peer2 FOREIGN KEY (Peer2) REFERENCES Peers (Nickname)
);

CREATE TABLE IF NOT EXISTS Recommendations (
	ID serial PRIMARY KEY,
	Peer varchar NOT NULL,
	RecommendedPeer varchar NOT NULL,
	CONSTRAINT check_equality CHECK (Peer != RecommendedPeer),
	CONSTRAINT fk_Recommendations_Peer FOREIGN KEY (Peer) REFERENCES Peers (Nickname),
	CONSTRAINT fk_Recommendations_RecommendedPeer FOREIGN KEY (RecommendedPeer) REFERENCES Peers (Nickname)
);

CREATE TABLE IF NOT EXISTS XP (
	ID serial PRIMARY KEY,
    "Check" bigint NOT NULL,
	XPAmount bigint NOT NULL,
	CONSTRAINT fk_XP_Check FOREIGN KEY ("Check") REFERENCES Checks (ID)
);

CREATE TABLE IF NOT EXISTS TimeTracking (
	ID serial PRIMARY KEY,
    Peer VARCHAR NOT NULL,
	"Date" DATE NOT NULL,
    "Time" TIME WITHOUT TIME ZONE NOT NULL,
    "State" VARCHAR NOT NULL  CHECK ("State" IN ('1', '2')),
	CONSTRAINT fk_TimeTracking_Peer foreign key (Peer) REFERENCES Peers (Nickname)
);

