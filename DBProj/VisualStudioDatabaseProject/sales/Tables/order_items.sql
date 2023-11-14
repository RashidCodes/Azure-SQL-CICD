CREATE TABLE [sales].[order_items] (
    [order_id]   INT             NULL,
    [item_id]    INT             NULL,
    [product_id] INT             NOT NULL,
    [quantity]   INT             NOT NULL,
    [list_price] DECIMAL (10, 2) NOT NULL,
    [discount]   DECIMAL (4, 2)  DEFAULT ((0)) NOT NULL
);

