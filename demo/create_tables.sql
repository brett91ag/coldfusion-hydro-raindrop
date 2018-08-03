/* SQL Server format - may need adjusting for other RDMS */

CREATE TABLE [auth](
	[username] [varchar](50) NOT NULL,
	[password] [varchar](50) NOT NULL,
	[hydroID] [varchar](50) NULL,
	[confirmed] [bit] NOT NULL,
 CONSTRAINT [PK_auth] PRIMARY KEY CLUSTERED 
(
	[username] ASC
)
)
GO

ALTER TABLE [auth] ADD  CONSTRAINT [DF_auth_confirmed]  DEFAULT (0) FOR [confirmed]
GO
