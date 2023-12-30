USE [master]
GO
/* Differente ways to check endpoints information and owner */
SELECT	E.endpoint_id, 
		E.name, 
		E.protocol_desc, 
		E.type_desc,
		E.state_desc,
		E.principal_id,
		P.name AS PrincipalName,
		E.port
FROM sys.tcp_endpoints E
INNER JOIN sys.server_principals P ON E.principal_id = P.principal_id
--WHERE E.type_desc = 'DATABASE_MIRRORING';
GO

SELECT SUSER_NAME(principal_id) AS endpoint_owner,
name as endpoint_name
FROM sys.database_mirroring_endpoints;
GO

/* Endpoint permissions */
SELECT ep.name,
sp.STATE, 
CONVERT(nvarchar(38), 
SUSER_NAME(sp.grantor_principal_id)) AS [GRANT BY],
sp.TYPE AS PERMISSION,
CONVERT(nvarchar(46),
SUSER_NAME(sp.grantee_principal_id)) AS [GRANT TO]
FROM sys.server_permissions sp, sys.endpoints ep
WHERE sp.major_id = ep.endpoint_id
--AND [name] = 'Hadr_endpoint';
GO

/* Change endpoint owner */
USE [master];
GO
ALTER AUTHORIZATION ON ENDPOINT::EndPointName TO NewOwner;
GO
GRANT CONNECT ON ENDPOINT::EndPointName TO [UserName];
GO

/* Delete an endpoint */
USE [master]
GO
DROP ENDPOINT endpointName;
GO