﻿/*
Deployment script for VisualStudioDatabaseProject

This code was generated by a tool.
Changes to this file may cause incorrect behavior and will be lost if
the code is regenerated.
*/

GO
SET ANSI_NULLS, ANSI_PADDING, ANSI_WARNINGS, ARITHABORT, CONCAT_NULL_YIELDS_NULL, QUOTED_IDENTIFIER ON;

SET NUMERIC_ROUNDABORT OFF;


GO
:setvar DatabaseName "VisualStudioDatabaseProject"
:setvar DefaultFilePrefix "VisualStudioDatabaseProject"
:setvar DefaultDataPath "C:\Users\rmohammed\AppData\Local\Microsoft\VisualStudio\SSDT\VisualStudioDatabaseProject"
:setvar DefaultLogPath "C:\Users\rmohammed\AppData\Local\Microsoft\VisualStudio\SSDT\VisualStudioDatabaseProject"

GO
:on error exit
GO
/*
Detect SQLCMD mode and disable script execution if SQLCMD mode is not supported.
To re-enable the script after enabling SQLCMD mode, execute the following:
SET NOEXEC OFF; 
*/
:setvar __IsSqlCmdEnabled "True"
GO
IF N'$(__IsSqlCmdEnabled)' NOT LIKE N'True'
    BEGIN
        PRINT N'SQLCMD mode must be enabled to successfully execute this script.';
        SET NOEXEC ON;
    END


GO
USE [$(DatabaseName)];


GO
IF EXISTS (SELECT 1
           FROM   [master].[dbo].[sysdatabases]
           WHERE  [name] = N'$(DatabaseName)')
    BEGIN
        ALTER DATABASE [$(DatabaseName)]
            SET ARITHABORT ON,
                CONCAT_NULL_YIELDS_NULL ON,
                CURSOR_DEFAULT LOCAL 
            WITH ROLLBACK IMMEDIATE;
    END


GO
IF EXISTS (SELECT 1
           FROM   [master].[dbo].[sysdatabases]
           WHERE  [name] = N'$(DatabaseName)')
    BEGIN
        ALTER DATABASE [$(DatabaseName)]
            SET PAGE_VERIFY NONE,
                DISABLE_BROKER 
            WITH ROLLBACK IMMEDIATE;
    END


GO
ALTER DATABASE [$(DatabaseName)]
    SET TARGET_RECOVERY_TIME = 0 SECONDS 
    WITH ROLLBACK IMMEDIATE;


GO
IF EXISTS (SELECT 1
           FROM   [master].[dbo].[sysdatabases]
           WHERE  [name] = N'$(DatabaseName)')
    BEGIN
        ALTER DATABASE [$(DatabaseName)]
            SET QUERY_STORE (QUERY_CAPTURE_MODE = ALL, CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 367), MAX_STORAGE_SIZE_MB = 100) 
            WITH ROLLBACK IMMEDIATE;
    END


GO
PRINT N'Creating User [azure-sql-role]...';


GO
CREATE USER [azure-sql-role] WITHOUT LOGIN;


GO
REVOKE CONNECT TO [azure-sql-role];


GO
PRINT N'Creating Role Membership [db_owner] for [azure-sql-role]...';


GO
EXECUTE sp_addrolemember @rolename = N'db_owner', @membername = N'azure-sql-role';


GO
PRINT N'Creating Schema [production]...';


GO
CREATE SCHEMA [production]
    AUTHORIZATION [dbo];


GO
PRINT N'Creating Schema [sales]...';


GO
CREATE SCHEMA [sales]
    AUTHORIZATION [dbo];


GO
PRINT N'Creating Table [production].[stocks]...';


GO
CREATE TABLE [production].[stocks] (
    [store_id]   INT NULL,
    [product_id] INT NULL,
    [quantity]   INT NULL
);


GO
PRINT N'Creating Table [production].[products]...';


GO
CREATE TABLE [production].[products] (
    [product_id]   INT             IDENTITY (1, 1) NOT NULL,
    [product_name] VARCHAR (255)   NOT NULL,
    [brand_id]     INT             NOT NULL,
    [category_id]  INT             NOT NULL,
    [model_year]   SMALLINT        NOT NULL,
    [list_price]   DECIMAL (10, 2) NOT NULL,
    PRIMARY KEY CLUSTERED ([product_id] ASC)
);


GO
PRINT N'Creating Table [production].[brands]...';


GO
CREATE TABLE [production].[brands] (
    [brand_id]   INT           IDENTITY (1, 1) NOT NULL,
    [brand_name] VARCHAR (255) NOT NULL,
    PRIMARY KEY CLUSTERED ([brand_id] ASC)
);


GO
PRINT N'Creating Table [production].[categories]...';


GO
CREATE TABLE [production].[categories] (
    [category_id]   INT           IDENTITY (1, 1) NOT NULL,
    [category_name] VARCHAR (255) NOT NULL,
    PRIMARY KEY CLUSTERED ([category_id] ASC)
);


GO
PRINT N'Creating Table [sales].[order_items]...';


GO
CREATE TABLE [sales].[order_items] (
    [order_id]   INT             NULL,
    [item_id]    INT             NULL,
    [product_id] INT             NOT NULL,
    [quantity]   INT             NOT NULL,
    [list_price] DECIMAL (10, 2) NOT NULL,
    [discount]   DECIMAL (4, 2)  NOT NULL
);


GO
PRINT N'Creating Table [sales].[orders]...';


GO
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


GO
PRINT N'Creating Table [sales].[staffs]...';


GO
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


GO
PRINT N'Creating Table [sales].[stores]...';


GO
CREATE TABLE [sales].[stores] (
    [store_id]   INT           IDENTITY (1, 1) NOT NULL,
    [store_name] VARCHAR (255) NOT NULL,
    [phone]      VARCHAR (25)  NULL,
    [email]      VARCHAR (255) NULL,
    [street]     VARCHAR (255) NULL,
    [city]       VARCHAR (255) NULL,
    [state]      VARCHAR (10)  NULL,
    [zip_code]   VARCHAR (5)   NULL,
    PRIMARY KEY CLUSTERED ([store_id] ASC)
);


GO
PRINT N'Creating Table [sales].[customers]...';


GO
CREATE TABLE [sales].[customers] (
    [customer_id] INT           IDENTITY (1, 1) NOT NULL,
    [first_name]  VARCHAR (255) NOT NULL,
    [last_name]   VARCHAR (255) NOT NULL,
    [phone]       VARCHAR (25)  NULL,
    [email]       VARCHAR (255) NOT NULL,
    [street]      VARCHAR (255) NULL,
    [city]        VARCHAR (50)  NULL,
    [state]       VARCHAR (25)  NULL,
    [zip_code]    VARCHAR (5)   NULL,
    PRIMARY KEY CLUSTERED ([customer_id] ASC)
);


GO
PRINT N'Creating Default Constraint unnamed constraint on [sales].[order_items]...';


GO
ALTER TABLE [sales].[order_items]
    ADD DEFAULT ((0)) FOR [discount];


GO
PRINT N'Update complete.';


GO
