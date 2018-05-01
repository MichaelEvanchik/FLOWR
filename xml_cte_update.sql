
--xml type 1 /Params/Account/TenantFirstName/
;WITH cte AS
(
    SELECT *
          ,(
	SELECT 
	t.AdditionalInfo
	.query(N'/Params/Account[(TenantFirstName/text())[1]=sql:column("FirstName") 
	and (TenantLastName/text())[1]=sql:column("LastName")]')
.query(N'<Account>
	 {
		for $nd in /Account/*
		return 
		if(local-name($nd)="TenantFirstName") then
			<TenantFirstName>{concat("first"[1],xs:string(sql:column("se.id")))}</TenantFirstName>
		else if(local-name($nd)="TenantLastName") then
			<TenantLastName>{concat("last"[1],xs:string(sql:column("se.id")))}</TenantLastName>
		else
		$nd
	 }  
	 </Account> ') AS [*]
	FROM #TempData AS t
	INNER JOIN #SEAAccountExtended AS se ON t.RefID=se.SEAccountRefID
	where t.id = ilv.id and t.AdditionalInfo.exist('/Params/Account/TenantFirstName/text()') = 1
	ORDER BY se.id
	FOR XML PATH(''),ROOT('Params'),TYPE
           ) AS NewAdditionalInfo
    FROM #TempData AS ilv
)
update cte set AdditionalInfo = NewAdditionalInfo where not cte.NewAdditionalInfo is null








--xml type 2  /Params/TenantFirstName/  (which only have 1 tenant)
;WITH cte AS
(
    SELECT *
          ,(
	SELECT 
	t.AdditionalInfo
	.query(N'//Params[(TenantFirstName/text())[1]=sql:column("FirstName") 
						 and (TenantLastName/text())[1]=sql:column("LastName")]')
	.query(N'
	for $nd in /Params/*
	return 
	if(local-name($nd)="TenantFirstName") then
		<TenantFirstName>{concat("first"[1],xs:string(sql:column("se.id")))}</TenantFirstName>
	else if(local-name($nd)="TenantLastName") then
		<TenantLastName>{concat("last"[1],xs:string(sql:column("se.id")))}</TenantLastName>
	else
	$nd 
	 ') AS [*]
	FROM #TempData AS t
	INNER JOIN #SEAAccountExtended AS se ON t.RefID=se.SEAccountRefID
	where t.id = ilv.id and t.AdditionalInfo.exist('/Params/TenantFirstName/text()') = 1
	ORDER BY se.id
	FOR XML PATH(''),ROOT('Params'),TYPE
           ) AS NewAdditionalInfo
    FROM #TempData AS ilv
)
update cte set AdditionalInfo = NewAdditionalInfo where not cte.NewAdditionalInfo is null







--xml type 3 /AdditionalInfo/Params/Account/TenantFirstName
;WITH cte AS
(
    SELECT *
          ,(
	SELECT 
	t.AdditionalInfo
	.query(N'/AdditionalInfo/Params/Account[(TenantFirstName/text())[1]=sql:column("FirstName") 
						 and (TenantLastName/text())[1]=sql:column("LastName")]')
	.query(N'<Params><Account>
			 {
				for $nd in /Account/*
				return 
				if(local-name($nd)="TenantFirstName") then
					<TenantFirstName>{concat("first"[1],xs:string(sql:column("se.id")))}</TenantFirstName>
				else if(local-name($nd)="TenantLastName") then
					<TenantLastName>{concat("last"[1],xs:string(sql:column("se.id")))}</TenantLastName>
				else
				$nd
			 }  
	 </Account></Params> ') AS [*]
	FROM #TempData AS t
	INNER JOIN #SEAAccountExtended AS se ON t.RefID=se.SEAccountRefID
	where t.id = ilv.id and t.AdditionalInfo.exist('/AdditionalInfo/Params/Account/TenantFirstName/text()') = 1
	ORDER BY se.id
	FOR XML PATH(''),ROOT('AdditionalInfo'),TYPE
           ) AS NewAdditionalInfo
    FROM #TempData AS ilv
)
select NewAdditionalInfo from cte
