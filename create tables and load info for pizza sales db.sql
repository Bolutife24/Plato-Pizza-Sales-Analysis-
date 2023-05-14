USE Portfolio
-- create tables in the database


CREATE TABLE pizza (
    pizza_id        VARCHAR(80)        NOT NULL,
    pizza_type_id   VARCHAR(80)        NOT NULL,
	size            CHAR(5)            NOT NULL,
	price           FLOAT              NOT NULL
  );
GO

CREATE TABLE pizza_type (
     pizza_type_id       VARCHAR(50)        NOT NULL,
     name                VARCHAR(50)        NOT NULL,
	 category            VARCHAR(50)        NOT NULL,
	 ingredients         VARCHAR(250)       NOT NULL

); 
GO

DROP TABLE orders_info

CREATE TABLE orders_info (
     order_id       INT         NOT NULL,
     date           DATE      NOT NULL,
	 time           VARCHAR(8)   NOT NULL,
	PRIMARY KEY(order_id)
); 
GO

CREATE TABLE order_details_info (
     order_details_id       INT               NOT NULL,
	 order_id               INT               NOT NULL,
     pizza_id               VARCHAR(50)       NOT NULL,
	 quantity               INT               NOT NULL,
	PRIMARY KEY(order_details_id)
); 
GO

--Load tables in the database

-- import the file
BULK INSERT  dbo.pizza
FROM 'inserted the file path for this data'  # insert your file path for the data
WITH
(
        FORMAT='CSV',
        FIRSTROW=2
)
GO

BULK INSERT  dbo.pizza_type
FROM 'inserted the file path for this data'  # insert your file path for the data
WITH
(
        FORMAT='CSV',
        FIRSTROW=2
)
GO

BULK INSERT  orders_info
FROM 'inserted the file path for this data'  # insert your file path for the data
WITH
(
        FORMAT='CSV',
        FIRSTROW=2
)
GO


BULK INSERT  order_details_info
FROM 'inserted the file path for this data' # insert your file path for the data
WITH
(
        FORMAT='CSV',
        FIRSTROW=2
)
GO

SELECT TOP 10*
FROM orders_info
