CREATE TABLE [production].[brands] (
    [brand_id]   INT           IDENTITY (1, 1) NOT NULL,
    [brand_name] VARCHAR (255) NOT NULL,
    PRIMARY KEY CLUSTERED ([brand_id] ASC)
);

