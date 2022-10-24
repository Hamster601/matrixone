-- @suit
-- @case
-- @desc:test for timediff(), datediff(), timestampdiff()
-- @label:bvt

-- datediff(expr1, expr2): expr1 - expr2
SELECT DATEDIFF('2007-12-31 23:59:59','2007-12-30');
SELECT DATEDIFF('2010-11-30 23:59:59','2010-12-31');
SELECT DATEDIFF('1997-10-31','2010-12-31');
SELECT DATEDIFF('19991031','2010-12-31');
SELECT DATEDIFF('99991031','2010-12-31');
SELECT DATEDIFF('00011031','2010-12-31');
SELECT DATEDIFF('00010131','2010-12-31');
SELECT DATEDIFF(DATE_ADD('20201011',INTERVAL 1 DAY),'2010-12-31');
SELECT DATEDIFF(DATE_ADD('20201011',INTERVAL 1-1 DAY),'2010-12-31');
SELECT DATEDIFF(DATE_ADD('20201011',INTERVAL 1-1 DAY),NULL);
SELECT DATEDIFF(DATE_ADD('20201011',INTERVAL SIN(10) DAY),NULL);
SELECT DATEDIFF(DATE_ADD('20201011',INTERVAL SIN(10) DAY),'20210110');
SELECT DATEDIFF(DATE_ADD('20201011',INTERVAL SIN(10) DAY),'2021'+'0110');
SELECT DATEDIFF(DATE_ADD('20201011',INTERVAL SIN(1) DAY),DATE_SUB(20201231,INTERVAL 1 YEAR));

-- timestampdiff(expr1 - expr2): expr2 - expr1
SELECT TIMESTAMPDIFF(MONTH,'2003-02-01','2003-05-01');
SELECT TIMESTAMPDIFF(YEAR,'2002-05-01','2001-01-01');
SELECT TIMESTAMPDIFF(MINUTE,'2003-02-01','2003-05-01 12:05:55');
SELECT TIMESTAMPDIFF(DAY,'2002-05-01','2001-01-01');
SELECT TIMESTAMPDIFF(SECOND,'2002-05-01','2001-01-01');
SELECT TIMESTAMPDIFF(HOUR,'2002-05-01','2001-01-01');
SELECT TIMESTAMPDIFF(YEAR,'20020501','20010101');
SELECT TIMESTAMPDIFF(YEAR,'20020501','2010-01-01');
SELECT TIMESTAMPDIFF(YEAR,NULL,'2010-01-01');
SELECT TIMESTAMPDIFF(YEAR,'20020501',NULL);
SELECT TIMESTAMPDIFF(MONTH,'200205'+'0'+'1','2010-01-01');
SELECT TIMESTAMPDIFF(MONTH,'200205'+'01','2010-01-01');
SELECT TIMESTAMPDIFF(MONTH,'200205'+'01',DATE_ADD('19990304',INTERVAL 0 MONTH));

DROP TABLE IF EXISTS t;
CREATE TABLE t(
	d1 DATE,
	d2 DATETIME,
	d3 TIMESTAMP
);
INSERT INTO t VALUES ('2010-01-01', '2010-01-01 00:01:02', '2010-01-01 19:19:19.121435');
INSERT INTO t VALUES ('2012-11-11', '2012-09-18 10:21:00', '2014-11-21 15:12:14.432432');
SELECT DATEDIFF(d1, '19700101'), TIMESTAMPDIFF(MONTH, d1, '1970-02-02') FROM t;
SELECT DATEDIFF(d2, '19701101'), TIMESTAMPDIFF(DAY, d2, '1970-02-02') FROM t;
SELECT DATEDIFF(d3, '19870911'), TIMESTAMPDIFF(SECOND, d3, '1970-02-02') FROM t;
SELECT DATEDIFF(d3, d1) FROM t;
SELECT DATEDIFF(d2, d3) FROM t;
SELECT DATEDIFF(d1, d2) FROM t;

DROP TABLE IF EXISTS t;
DROP TABLE IF EXISTS t1;
CREATE TABLE t(
	id INT,
	d1 DATE,
	d2 DATETIME,
	PRIMARY KEY(id)
);
CREATE TABLE t1(
	id INT,
	d3 TIMESTAMP,
	PRIMARY KEY(id)
);
INSERT INTO t VALUES (1,'2012-11-11','2012-09-18 10:21:00'), (2,'2010-08-05','2022-05-18 20:21:20');
INSERT INTO t VALUES (3,'2212-01-23','2019-12-27 09:21:18'), (4,'2027-09-17','2027-09-28 10:11:10');
INSERT INTO t1 VALUES (1,'2019-12-27 09:21:18'), (2, '2010-02-21 06:55:41');
INSERT INTO t1 VALUES (3,'2020-11-17 15:11:56'), (4, '2012-07-11 17:31:11');
SELECT DATEDIFF(d1,d3) FROM t JOIN t1 ON t.id = t1.id;
SELECT DATEDIFF(d2,d3) FROM t LEFT JOIN t1 ON t.id = t1.id;
SELECT DATEDIFF(d2,d3) FROM t RIGHT JOIN t1 ON t.id = t1.id;
SELECT DATEDIFF(d1,d3) FROM t,t1 WHERE t.id = t1.id;

DROP TABLE IF EXISTS t;
DROP TABLE IF EXISTS t1;
CREATE TABLE t(
	id INT,
	d1 TIMESTAMP,
	PRIMARY KEY(id)
);
CREATE TABLE t1(
	id INT,
	d3 TIMESTAMP,
	PRIMARY KEY(id)
);
INSERT INTO t VALUES (1,'2019-12-27 09:21:18'), (2, '20100221065541');
INSERT INTO t VALUES (3,'2020-11-17 15:11:56'), (4, '2012-07-11 17:31:11');
INSERT INTO t1 VALUES (1,'20181017092118'), (2, '2008-08-01 06:55:41');
INSERT INTO t1 VALUES (3,'2021-02-21 15:11:56'), (4, '2019-07-01 17:31:11');
SELECT TIMESTAMPDIFF(MONTH,d1,d3) FROM t,t1 WHERE t.id = t1.id;
SELECT TIMESTAMPDIFF(YEAR,d3,d1) FROM t JOIN t1 ON t.id = t1.id;
SELECT TIMESTAMPDIFF(DAY,d1,d3) FROM t LEFT JOIN t1 ON t.id = t1.id;
SELECT TIMESTAMPDIFF(MINUTE,d3,d1) FROM t RIGHT JOIN t1 ON t.id <> t1.id;
SELECT TIMESTAMPDIFF(MONTH,d3,d1) FROM t RIGHT JOIN t1 ON t.id = t1.id;

DROP TABLE IF EXISTS t;
DROP TABLE IF EXISTS t1;
CREATE TABLE t(
	id INT,
	d1 DATE,
	d2 DATETIME,
	d3 TIMESTAMP,
	PRIMARY KEY(id)
);
CREATE TABLE t1(
	id INT,
	str1 VARCHAR(30),
	str2 CHAR(30),
	PRIMARY KEY(id)
);
INSERT INTO t VALUES (1,'2012-11-11','2012-09-18 10:21:00','2012-09-18 10:21:00');
INSERT INTO t VALUES (2,'2012-01-01','2015-05-15 15:25:50','2015-05-15 15:25:05');
INSERT INTO t1 VALUES (1,'2012-11-11','2015-05-15 15:45:17');
INSERT INTO t1 VALUES (2,'2009-12-01','2015-08-05 16:45:17');
SELECT DATEDIFF(d1,str1), DATEDIFF(d1,str2) FROM t, t1;
SELECT DATEDIFF(d2,str1), DATEDIFF(d2,str2) FROM t, t1;
SELECT DATEDIFF(d3,str1), DATEDIFF(d3,str2) FROM t, t1;
SELECT TIMESTAMPDIFF(MONTH,d1,str1), TIMESTAMPDIFF(YEAR,d1,str2) FROM t, t1;
SELECT TIMESTAMPDIFF(SECOND,d2,str1), TIMESTAMPDIFF(DAY,d2,str2) FROM t, t1;
SELECT TIMESTAMPDIFF(MINUTE,d3,str1), TIMESTAMPDIFF(MONTH,d3,str2) FROM t, t1;
SELECT DATEDIFF(d1,str1), DATEDIFF(d1,str2) FROM t JOIN t1 ON t.id = t1.id;
SELECT DATEDIFF(d2,str1), DATEDIFF(d2,str2) FROM t LEFT JOIN t1 ON t.id = t1.id;
SELECT DATEDIFF(d3,str1), DATEDIFF(d3,str2) FROM t RIGHT JOIN t1 ON t.id = t1.id;

DROP TABLE IF EXISTS t;
DROP TABLE IF EXISTS t1;
CREATE TABLE t(
	id INT,
	d1 DATE,
	d2 DATETIME,
	d3 TIMESTAMP,
	PRIMARY KEY(id)
);
CREATE TABLE t1(
	id INT,
	i1 INT,
	i2 BIGINT,
	PRIMARY KEY(id)
);
INSERT INTO t VALUES (1,'2012-11-11','2012-09-18 10:21:00','2012-09-18 10:21:00');
INSERT INTO t VALUES (2,'2012-01-01','2015-05-15 15:25:50','2015-05-15 15:25:05');
INSERT INTO t1 VALUES (1,1666096275,1609430400), (2,1546272000,1575129600);
SELECT DATEDIFF(d1,FROM_UNIXTIME(i1)), DATEDIFF(d1,FROM_UNIXTIME(i2)) FROM t,t1;
SELECT DATEDIFF(d2,FROM_UNIXTIME(i1)), DATEDIFF(d2,FROM_UNIXTIME(i2)) FROM t,t1;
SELECT DATEDIFF(d3,FROM_UNIXTIME(i1)), DATEDIFF(d3,FROM_UNIXTIME(i2)) FROM t,t1;
SELECT TIMESTAMPDIFF(MONTH,d1,FROM_UNIXTIME(i1)), TIMESTAMPDIFF(MONTH,d1,FROM_UNIXTIME(i2)) FROM t,t1;
SELECT TIMESTAMPDIFF(MONTH,d2,FROM_UNIXTIME(i1)), TIMESTAMPDIFF(MONTH,d2,FROM_UNIXTIME(i2)) FROM t,t1;
SELECT TIMESTAMPDIFF(MONTH,d3,FROM_UNIXTIME(i1)), TIMESTAMPDIFF(MONTH,d3,FROM_UNIXTIME(i2)) FROM t,t1;

DROP TABLE IF EXISTS t;
CREATE TABLE t(
	id INT,
	i1 INT,
	PRIMARY KEY(id)
);
INSERT INTO t SELECT DATEDIFF('2007-12-31 23:59:59','2007-12-30'), DATEDIFF('2007-11-11 23:59:59','2007-12-30');
-- @bvt:issue#5723
INSERT INTO t SELECT TIMESTAMPDIFF(MONTH,'2003-02-01','2003-05-01'), TIMESTAMPDIFF(YEAR,'2010-02-01','2003-05-01');
-- @bvt:issue
SELECT * FROM t;