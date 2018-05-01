-- might be a way easier solution
if (OBJECT_ID('tempdb..#TempData') is not null) drop table #TempData
create table #TempData (ID INT,RefID uniqueidentifier, AdditionalInfo XML)
INSERT INTO #TempData (id,RefID,AdditionalInfo)
select 98,'03A13945-CF2A-4734-BA0F-00000509E9E9',N'<Params>
    <Account>
        <TenantFirstName>Taylor</TenantFirstName>
        <TenantLastName>Hall</TenantLastName>
        <tcode>8</tcode>
    </Account>
    <Account>
        <TenantFirstName>Pam</TenantFirstName>
        <TenantLastName>Hall</TenantLastName>
    </Account>
	 <Account>
        <TenantFirstName>Michael</TenantFirstName>
        <TenantLastName>Hall</TenantLastName>
    </Account>
</Params>'
union
select 99,'7B51ED51-29A6-44ED-8D31-00001000B64D',
N'
<Params> 
        <TenantFirstName>Phil</TenantFirstName>
        <TenantLastName>Foo</TenantLastName>
    	<whatever>argh</whatever>
</Params>'
union
select 100,'9B54ED52-39A6-54E7-3D36-00001000B64F',
N'
<AdditionalInfo>
<Params>
<Account>
  <TenantLastName>LOUIS</TenantLastName> 
  <TenantFirstName>REED</TenantFirstName> 
  <Email>LOUISREED210@GMAIL.COM</Email> 
  <CellPhone>4438766084</CellPhone> 
  <Description>607650</Description> 
  <MoveOutDate>12/31/2018</MoveOutDate> 
  <TCode>t0662602</TCode> 
  <TenantorResidentId>t0662602</TenantorResidentId> 
  <SecondaryResidentId>8416222218221618</SecondaryResidentId> 
  <Scanline>8416222218221618</Scanline> 
  <IsPrimary>1</IsPrimary> 
  <CustomerType>other</CustomerType> 
  <LeaseType /> 
  <IgnoreRestrictedLeaseTypes>0</IgnoreRestrictedLeaseTypes> 
  </Account>
  </Params>
  </AdditionalInfo>
'

--this would be the SEAccountExtended table to get the actual account key
if (OBJECT_ID('tempdb..#SEAAccountExtended') is not null) drop table #SEAAccountExtended
create table #SEAAccountExtended ( id int,SEAccountRefID uniqueidentifier,  FirstName varchar(255), LastName varchar(255))
insert into #SEAAccountExtended(id ,SEAccountRefID,FirstName,LastNAme)
select 1, '03A13945-CF2A-4734-BA0F-00000509E9E9', 'Taylor','Hall'
union
select 2, '03A13945-CF2A-4734-BA0F-00000509E9E9', 'Pam','Hall'
union
select 3, '03A13945-CF2A-4734-BA0F-00000509E9E9', 'Michael','Hall'
union
select 4, '7B51ED51-29A6-44ED-8D31-00001000B64D', 'Phil','Foo'
union
select 5, '9B54ED52-39A6-54E7-3D36-00001000B64F', 'REED','LOUIS'

--------------script you need below, no temp tables, no loops, but needs to execute 3 cte updates for 3 different xml schemas that 95% of the data confirms to-------------------------------------------------------------







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
