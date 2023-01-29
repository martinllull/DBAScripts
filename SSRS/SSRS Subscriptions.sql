USE ReportServer
GO
;
   WITH subscriptionXmL
          AS (
               SELECT
                SubscriptionID ,
                OwnerID ,
                Report_OID ,
                Locale ,
                InactiveFlags ,
                ExtensionSettings ,
                CONVERT(XML, ExtensionSettings) AS ExtensionSettingsXML ,
                ModifiedByID ,
                ModifiedDate ,
                Description ,
                LastStatus ,
                EventType ,
                MatchData ,
                LastRunTime ,
                Parameters ,
                DeliveryExtension ,
                Version
               FROM
                ReportServer.dbo.Subscriptions
             ),
                 -- Get the settings as pairs
        SettingsCTE
          AS (
               SELECT
                SubscriptionID ,
                ExtensionSettings ,
    -- include other fields if you need them.
                ISNULL(Settings.value('(./*:Name/text())[1]', 'nvarchar(1024)'),
                       'Value') AS SettingName ,
                Settings.value('(./*:Value/text())[1]', 'nvarchar(max)') AS SettingValue
               FROM
                subscriptionXmL
                CROSS APPLY subscriptionXmL.ExtensionSettingsXML.nodes('//*:ParameterValue') Queries ( Settings )
             )
    SELECT
        *
    FROM
        SettingsCTE
    WHERE
        settingName IN ( 'TO', 'CC', 'BCC' )
		AND SettingValue LIKE ('%SomeString%')

-------------------
SELECT *
FROM dbo.Subscriptions S
INNER JOIN dbo.Catalog C (NOLOCK) ON C.ItemID = S.Report_OID
WHERE S.SubscriptionID IN (
'36BF92BE-1090-4662-842F-976A9CD0CBA6',
'56EF7C12-FF55-4D5E-AF9F-C71C1948E1F8',
'FCECF3A8-F8F8-4138-ABB5-E2E138F71534'
);
GO