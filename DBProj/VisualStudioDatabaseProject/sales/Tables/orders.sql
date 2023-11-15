CREATE TABLE [sales].[orders] (
    [order_id]      INT     IDENTITY (1, 1) NOT NULL,
    [customer_id]   INT     NULL,
    [order_status]  TINYINT NOT NULL,
    [order_date]    DATE    NOT NULL,
    [required_date] DATE    NOT NULL,
    [shipped_date]  DATE    NULL,
    [store_id]      INT     NOT NULL,
    [staff_id]      INT     NOT NULL,
    PRIMARY KEY CLUSTERED ([order_id] ASC)
);

