-- might be a way easier solution.

--go up one directory if want test data

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


