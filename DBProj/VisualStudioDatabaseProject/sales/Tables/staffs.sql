CREATE TABLE [sales].[staffs] (
    [staff_id]   INT           IDENTITY (1, 1) NOT NULL,
    [first_name] VARCHAR (50)  NOT NULL,
    [last_name]  VARCHAR (50)  NOT NULL,
    [email]      VARCHAR (255) NOT NULL,
    [phone]      VARCHAR (25)  NULL,
    [active]     TINYINT       NOT NULL,
    [store_id]   INT           NOT NULL,
    [manager_id] INT           NULL,
    PRIMARY KEY CLUSTERED ([staff_id] ASC),
    UNIQUE NONCLUSTERED ([email] ASC)
);

