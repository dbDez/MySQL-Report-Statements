# -- View admin users - add admin users to this table --#
# -- Remove Hash below to use --#
# SELECT `dbpavweb`.`tbladminusers`.* FROM `dbpavweb`.`tbladminusers`;
USE `scandb`;
SELECT "Settting default database to ScanDB" AS '';

# -- Clear the WEB Dealers and Reps tables -- #
SELECT "Clearing the WEB Dealers and Reps tables" AS '';
DELETE `dbpavweb`.`tblwebdealers`.* FROM `dbpavweb`.`tblwebdealers`;
SELECT CONCAT ("Deleted ", ROW_COUNT(), " rows tblwebdealers") AS ''; 
DELETE `dbpavweb`.`tblwebreps`.* FROM `dbpavweb`.`tblwebreps`;
SELECT CONCAT ("Deleted ", ROW_COUNT(), " rows from tblwebreps") AS ''; 
DELETE `dbpavweb`.`tblwebnetworks`.* FROM `dbpavweb`.`tblwebnetworks`;
SELECT CONCAT ("Deleted ", ROW_COUNT(), " rows from tblwebnetworks") AS ''; 

SELECT "Inserting WEB Dealers and Reps" AS '';
INSERT INTO `dbpavweb`.`tblwebdealers` (IDDealer, DealerName,MSISDN) 
SELECT `scandb`.`tbldealers`.`IDDealer`, `scandb`.`tbldealers`.`DealerName`,`scandb`.`tbldealers`.`CFS_MSISDN`
FROM `scandb`.`tbldealers`;
SELECT CONCAT ("Inserted ", ROW_COUNT(), " rows into tblwebdealers") AS ''; 

INSERT INTO `dbpavweb`.`tblwebreps` (IDDealer, IDRep, RepName, RepCode, MSISDN) 
SELECT `scandb`.`tblsalesrep`.`IDDealer`,`scandb`.`tblsalesrep`.`IDRep`,`scandb`.`tblsalesrep`.`RepName`,`scandb`.`tblsalesrep`.`RepCode`,`scandb`.`tblsalesrep`.`CFS_MSISDN_Rep`
FROM `scandb`.`tblsalesrep`;
SELECT CONCAT ("Inserted ", ROW_COUNT(), " rows into tblwebreps") AS ''; 

INSERT INTO `dbpavweb`.`tblwebnetworks` (IDNetwork, Network)
SELECT `scandb`.`tblnetworks`.`IDNetwork`, `scandb`.`tblnetworks`.`NetworkName`
FROM `scandb`.`tblnetworks`;
SELECT CONCAT ("Inserted ", ROW_COUNT(), " rows into tblwebnetworks") AS ''; 

# -- Clear WebUsers Table
DELETE `dbpavweb`.`tblwebusers`.* FROM `dbpavweb`.`tblwebusers`;
SELECT CONCAT ("Deleted ", ROW_COUNT(), " rows from tblwebusers") AS ''; 

# -- Append Admin Users to WebUsers
INSERT INTO `dbpavweb`.`tblwebusers` ( IDDEALER, MSISDN, AccessLevel )
SELECT 0 AS IDDealer,`dbpavweb`.`tblwebadminusers`.`MSISDN`, `dbpavweb`.`tblwebadminusers`.`AccessLevel`
FROM `dbpavweb`.`tblwebadminusers`
WHERE `dbpavweb`.`tblwebadminusers`.`MSISDN` IS NOT NULL;
SELECT CONCAT ("Appended ", ROW_COUNT(), " admin users to tblwebusers") AS '';

# -- Append Dealers to WebUsers
REPLACE INTO `dbpavweb`.`tblwebusers` ( IDDealer, MSISDN, AccessLevel )
SELECT `scandb`.`tbldealers`.`IDDealer`, `scandb`.`tbldealers`.`CFS_MSISDN`, 1 AS LEVEL
FROM `scandb`.`tbldealers`;
SELECT CONCAT ("Appended ", ROW_COUNT(), " Dealers to tblwebusers") AS '';

# -- Append Reps to WebUsers
REPLACE INTO `dbpavweb`.`tblwebusers` ( IDDealer, IDRep, MSISDN, AccessLevel )
SELECT `scandb`.`tblsalesrep`.`IDDealer`, `scandb`.`tblsalesrep`.`IDRep`, `scandb`.`tblsalesrep`.`CFS_MSISDN_Rep`, 2 AS LEVEL
FROM `scandb`.`tblsalesrep`;
SELECT CONCAT ("Appended ", ROW_COUNT(), " Reps to tblwebusers") AS '';

## -------------------------------------------------------------------------------------------------------------------------------------------------------- ##
##                                                                D E A L E R S  O N L Y
## -------------------------------------------------------------------------------------------------------------------------------------------------------- ##

# -- Clear temp tables -- #
SELECT "Clearing TEMP tables..." AS '';
DELETE `dbtemptables`.`tblactivations120`.* FROM `dbtemptables`.`tblactivations120`;
DELETE `dbtemptables`.`tblactivations60`.* FROM `dbtemptables`.`tblactivations60`;
DELETE `dbtemptables`.`tblconnections`.* FROM `dbtemptables`.`tblconnections`;
DELETE `dbtemptables`.`tbldates`.* FROM `dbtemptables`.`tbldates`;
DELETE `dbtemptables`.`tbldeletions`.* FROM `dbtemptables`.`tbldeletions`;
DELETE `dbtemptables`.`tblpaidactivations`.* FROM `dbtemptables`.`tblpaidactivations`;
DELETE `dbtemptables`.`tblrecharges`.* FROM `dbtemptables`.`tblrecharges`;
DELETE `dbtemptables`.`tblricas`.* FROM `dbtemptables`.`tblricas`;
DELETE `dbtemptables`.`tblsentstock`.* FROM `dbtemptables`.`tblsentstock`;
DELETE `dbtemptables`.`tblsimswaps`.* FROM `dbtemptables`.`tblsimswaps`;
DELETE `dbtemptables`.`tbltotals`.* FROM `dbtemptables`.`tbltotals`;
DELETE `dbtemptables`.`tblsentstock`.* FROM `dbtemptables`.`tblsentstock`;
DELETE `dbtemptables`.`tblactivebase`.* FROM `dbtemptables`.`tblactivebase`;

# -- Create Sent Stock by Dealer by Network
SELECT "Creating Sent Stock by Dealer by Network" AS '';
INSERT INTO `dbtemptables`.`tblsentstock` ( IDDealer, IDNetwork, SentMonth, Sent  )
SELECT `scandb`.`tblInvoices`.`IDDealer`, `scandb`.`tblNetworks`.`IDNetwork`, 
LAST_DAY(`scandb`.`tblinvoices`.`InvoiceDate`) AS SentMonth, 
COUNT(`scandb`.`tblStarterPacks`.`SimNumber`) AS Sent 
FROM `scandb`.`tblInvoices` 
INNER JOIN `scandb`.`tblinvoicedetail` ON `scandb`.`tblinvoices`.`IDInv` = `scandb`.`tblinvoicedetail`.`IDInv`
INNER JOIN `scandb`.`tblboxes` ON `scandb`.`tblInvoicedetail`.`IDBox` = `scandb`.`tblboxes`.`IDBox`
INNER JOIN `scandb`.`tblnetworks` ON `scandb`.`tblboxes`.`IDNetwork` = `scandb`.`tblnetworks`.`IDNetwork`
INNER JOIN `scandb`.`tblstarterpacks` ON `scandb`.`tblboxes`.`IDBox` = `scandb`.`tblstarterpacks`.`IDBox`
WHERE `scandb`.`tblInvoices`.`InvoiceDate` > LAST_DAY(DATE_SUB(CURDATE(), INTERVAL 12 MONTH))
GROUP BY `scandb`.`tblInvoices`.`IDDealer`, `scandb`.`tblNetworks`.`IDNetwork`, LAST_DAY(`scandb`.`tblinvoices`.`InvoiceDate`)
HAVING Sent >0;
# SELECT `dbtemptables`.`tblsentstock`.* from `dbtemptables`.`tblsentstock` LIMIT 5;

# -- Create Activations120 by Dealer by Network
SELECT "Creating Activations120 by Dealer by Network" AS '';
INSERT INTO `dbtemptables`.`tblactivations120` ( IDDealer, IDNetwork, ActivationDate, Activations  )
SELECT `scandb`.`tblInvoices`.`IDDealer`, `scandb`.`tblNetworks`.`IDNetwork`, 
LAST_DAY(`scandb`.`tblstarterpacks`.`ActualActivationDate`) AS ActivationDate, 
COUNT(`scandb`.`tblStarterPacks`.`ActualActivationDate`) AS Activations 
FROM `scandb`.`tblInvoices` 
INNER JOIN `scandb`.`tblinvoicedetail` ON `scandb`.`tblinvoices`.`IDInv` = `scandb`.`tblinvoicedetail`.`IDInv`
INNER JOIN `scandb`.`tblboxes` ON `scandb`.`tblInvoicedetail`.`IDBox` = `scandb`.`tblboxes`.`IDBox`
INNER JOIN `scandb`.`tblnetworks` ON `scandb`.`tblboxes`.`IDNetwork` = `scandb`.`tblnetworks`.`IDNetwork`
INNER JOIN `scandb`.`tblstarterpacks` ON `scandb`.`tblboxes`.`IDBox` = `scandb`.`tblstarterpacks`.`IDBox`
WHERE `scandb`.`tblstarterpacks`.`ActualActivationDate` > LAST_DAY(DATE_SUB(CURDATE(), INTERVAL 12 MONTH))
GROUP BY `scandb`.`tblInvoices`.`IDDealer`, `scandb`.`tblNetworks`.`IDNetwork`, LAST_DAY(`scandb`.`tblstarterpacks`.`ActualActivationDate`)
HAVING Activations >0;
# SELECT `dbtemptables`.`tblactivations120`.* FROM `dbtemptables`.`tblactivations120` LIMIT 5;

# -- Create Activations60 by Dealer by Network
SELECT "Creating Activations60 by Dealer by Network" AS '';
INSERT INTO `dbtemptables`.`tblactivations60` ( IDDealer, IDNetwork, ActivationDate, Activations  )
SELECT `scandb`.`tblInvoices`.`IDDealer`, `scandb`.`tblNetworks`.`IDNetwork`, 
LAST_DAY(`scandb`.`tblstarterpacks`.`ActivationDate`) AS ActivationDate, 
COUNT(`scandb`.`tblStarterPacks`.`ActivationDate`) AS Activations 
FROM `scandb`.`tblInvoices` 
INNER JOIN `scandb`.`tblinvoicedetail` ON `scandb`.`tblinvoices`.`IDInv` = `scandb`.`tblinvoicedetail`.`IDInv`
INNER JOIN `scandb`.`tblboxes` ON `scandb`.`tblInvoicedetail`.`IDBox` = `scandb`.`tblboxes`.`IDBox`
INNER JOIN `scandb`.`tblnetworks` ON `scandb`.`tblboxes`.`IDNetwork` = `scandb`.`tblnetworks`.`IDNetwork`
INNER JOIN `scandb`.`tblstarterpacks` ON `scandb`.`tblboxes`.`IDBox` = `scandb`.`tblstarterpacks`.`IDBox`
WHERE `scandb`.`tblstarterpacks`.`ActivationDate` > LAST_DAY(DATE_SUB(CURDATE(), INTERVAL 12 MONTH))
GROUP BY `scandb`.`tblInvoices`.`IDDealer`, `scandb`.`tblNetworks`.`IDNetwork`, LAST_DAY(`scandb`.`tblstarterpacks`.`ActivationDate`)
HAVING Activations >0;

# SELECT `dbtemptables`.`tblactivations60`.* FROM `dbtemptables`.`tblactivations60` LIMIT 5;

# -- Create Connections by Dealer by Network
SELECT "Creating Connections by Dealer by Network" AS '';
INSERT INTO `dbtemptables`.`tblconnections` ( IDDealer, IDNetwork, ConnectionDate, Connections  )
SELECT `scandb`.`tblInvoices`.`IDDealer`, `scandb`.`tblNetworks`.`IDNetwork`, LAST_DAY(`scandb`.`tblstarterpacks`.`ConnectionDate`), 
COUNT(`scandb`.`tblStarterPacks`.`ConnectionDate`) AS Connections
FROM `scandb`.`tblInvoices` 
INNER JOIN `scandb`.`tblinvoicedetail` ON `scandb`.`tblinvoices`.`IDInv` = `scandb`.`tblinvoicedetail`.`IDInv`
INNER JOIN `scandb`.`tblboxes` ON `scandb`.`tblInvoicedetail`.`IDBox` = `scandb`.`tblboxes`.`IDBox`
INNER JOIN `scandb`.`tblnetworks` ON `scandb`.`tblboxes`.`IDNetwork` = `scandb`.`tblnetworks`.`IDNetwork`
INNER JOIN `scandb`.`tblstarterpacks` ON `scandb`.`tblboxes`.`IDBox` = `scandb`.`tblstarterpacks`.`IDBox`
WHERE `scandb`.`tblstarterpacks`.`ConnectionDate` > LAST_DAY(DATE_SUB(CURDATE(), INTERVAL 12 MONTH))
GROUP BY `scandb`.`tblInvoices`.`IDDealer`, `scandb`.`tblNetworks`.`IDNetwork`, LAST_DAY(`scandb`.`tblstarterpacks`.`ConnectionDate`)
HAVING Connections >0;
# SELECT `dbtemptables`.`tblconnections`.* FROM `dbtemptables`.`tblconnections` LIMIT 24;

# -- Create RICAs by Dealer by Network
SELECT "Creating RICAs by Dealer by Network" AS '';
INSERT INTO `dbtemptables`.`tblricas` ( IDDealer, IDNetwork, RicaDate, Ricas  )
SELECT `scandb`.`tblInvoices`.`IDDealer`,`scandb`.`tblNetworks`.`IDNetwork`, 
LAST_DAY(`scandb`.`tblstarterpacks`.`RicaDate`), 
COUNT(`scandb`.`tblStarterPacks`.`RicaDate`) AS Ricas 
FROM `scandb`.`tblInvoices` 
INNER JOIN `scandb`.`tblinvoicedetail` ON `scandb`.`tblinvoices`.`IDInv` = `scandb`.`tblinvoicedetail`.`IDInv`
INNER JOIN `scandb`.`tblboxes` ON `scandb`.`tblInvoicedetail`.`IDBox` = `scandb`.`tblboxes`.`IDBox`
INNER JOIN `scandb`.`tblnetworks` ON `scandb`.`tblboxes`.`IDNetwork` = `scandb`.`tblnetworks`.`IDNetwork`
INNER JOIN `scandb`.`tblstarterpacks` ON `scandb`.`tblboxes`.`IDBox` = `scandb`.`tblstarterpacks`.`IDBox`
WHERE `scandb`.`tblstarterpacks`.`RicaDate` > LAST_DAY(DATE_SUB(CURDATE(), INTERVAL 12 MONTH))
GROUP BY `scandb`.`tblInvoices`.`IDDealer`, `scandb`.`tblNetworks`.`IDNetwork`, LAST_DAY(`scandb`.`tblstarterpacks`.`RicaDate`)
HAVING Ricas >0;
# SELECT `dbtemptables`.`tblricas`.* from `dbtemptables`.`tblricas` LIMIT 15;

# -- Create SimSwaps by Dealer by Network
SELECT "Creating SimSwaps by Dealer by Network" AS '';
INSERT INTO `dbtemptables`.`tblsimswaps` ( IDDealer, IDNetwork, SimSwapDate, Simswaps  )
SELECT `scandb`.`tblInvoices`.`IDDealer`, `scandb`.`tblNetworks`.`IDNetwork`, 
LAST_DAY(`scandb`.`tblstarterpacks`.`SimSwapDate`), 
COUNT(`scandb`.`tblStarterPacks`.`SimSwapDate`) AS Swaps
FROM `scandb`.`tblInvoices` 
INNER JOIN `scandb`.`tblinvoicedetail` ON `scandb`.`tblinvoices`.`IDInv` = `scandb`.`tblinvoicedetail`.`IDInv`
INNER JOIN `scandb`.`tblboxes` ON `scandb`.`tblInvoicedetail`.`IDBox` = `scandb`.`tblboxes`.`IDBox`
INNER JOIN `scandb`.`tblnetworks` ON `scandb`.`tblboxes`.`IDNetwork` = `scandb`.`tblnetworks`.`IDNetwork`
INNER JOIN `scandb`.`tblstarterpacks` ON `scandb`.`tblboxes`.`IDBox` = `scandb`.`tblstarterpacks`.`IDBox`
WHERE `scandb`.`tblstarterpacks`.`SimSwapDate` > LAST_DAY(DATE_SUB(CURDATE(), INTERVAL 12 MONTH))
GROUP BY `scandb`.`tblInvoices`.`IDDealer`, `scandb`.`tblNetworks`.`IDNetwork`, LAST_DAY(`scandb`.`tblstarterpacks`.`SimSwapDate`)
HAVING Swaps >0;

# -- Create Deletions by Dealer by Network
SELECT "Creating Deletions by Dealer by Network" AS '';
INSERT INTO `dbtemptables`.`tbldeletions` ( IDDealer, IDNetwork, DeletionDate, Deletions  )
SELECT `scandb`.`tblInvoices`.`IDDealer`,`scandb`.`tblNetworks`.`IDNetwork`, 
LAST_DAY(`scandb`.`tblstarterpacks`.`DeletionDate`), 
COUNT(`scandb`.`tblstarterpacks`.`DeletionDate`) AS Deletions
FROM `scandb`.`tblInvoices` 
INNER JOIN `scandb`.`tblinvoicedetail` ON `scandb`.`tblinvoices`.`IDInv` = `scandb`.`tblinvoicedetail`.`IDInv`
INNER JOIN `scandb`.`tblboxes` ON `scandb`.`tblInvoicedetail`.`IDBox` = `scandb`.`tblboxes`.`IDBox`
INNER JOIN `scandb`.`tblnetworks` ON `scandb`.`tblboxes`.`IDNetwork` = `scandb`.`tblnetworks`.`IDNetwork`
INNER JOIN `scandb`.`tblstarterpacks` ON `scandb`.`tblboxes`.`IDBox` = `scandb`.`tblstarterpacks`.`IDBox`
WHERE `scandb`.`tblstarterpacks`.`DeletionDate` > LAST_DAY(DATE_SUB(CURDATE(), INTERVAL 12 MONTH))
GROUP BY `scandb`.`tblInvoices`.`IDDealer`,`scandb`.`tblNetworks`.`IDNetwork`, LAST_DAY(`scandb`.`tblstarterpacks`.`DeletionDate`)
HAVING Deletions >0;

# -- Create Ongoing Recharges by Dealer by Network
SELECT "Creating Ongoing Recharges by Dealer by Network" AS '';
INSERT INTO `dbtemptables`.`tblrecharges` ( IDDealer, IDNetwork, RechargeDate, Recharges  )
SELECT `scandb`.`tblInvoices`.`IDDealer`,`scandb`.`tblNetworks`.`IDNetwork`, 
LAST_DAY(`scandb`.`tblongoing`.`RechargeDate`) AS RechargeDate, 
SUM(`scandb`.`tblongoing`.`RechargeAmount`) AS Recharges 
FROM `scandb`.`tblInvoices` 
INNER JOIN `scandb`.`tblinvoicedetail` ON `scandb`.`tblinvoices`.`IDInv` = `scandb`.`tblinvoicedetail`.`IDInv`
INNER JOIN `scandb`.`tblboxes` ON `scandb`.`tblInvoicedetail`.`IDBox` = `scandb`.`tblboxes`.`IDBox`
INNER JOIN `scandb`.`tblnetworks` ON `scandb`.`tblboxes`.`IDNetwork` = `scandb`.`tblnetworks`.`IDNetwork`
INNER JOIN `scandb`.`tblstarterpacks` ON `scandb`.`tblboxes`.`IDBox` = `scandb`.`tblstarterpacks`.`IDBox`
INNER JOIN `scandb`.`tblongoing` ON `scandb`.`tblongoing`.`IDStarterPack` = `scandb`.`tblstarterpacks`.`IDStarterPack` 
WHERE `scandb`.`tblongoing`.`RechargeDate` > LAST_DAY(DATE_SUB(CURDATE(), INTERVAL 12 MONTH))
GROUP BY `scandb`.`tblInvoices`.`IDDealer`, `scandb`.`tblNetworks`.`IDNetwork`, LAST_DAY(`scandb`.`tblongoing`.`RechargeDate`)
HAVING Recharges >0;

# -- Create Active Base by Dealer by Network
SELECT "Creating Active Base by Dealer by Network" AS '';
INSERT INTO `dbtemptables`.`tblactivebase` ( IDDealer, IDNetwork, RechargeDate, ActBase  )
SELECT `scandb`.`tblInvoices`.`IDDealer`,`scandb`.`tblNetworks`.`IDNetwork`, 
LAST_DAY(`scandb`.`tblongoing`.`RechargeDate`) AS RechargeDate, 
COUNT(`scandb`.`tblongoing`.`IDStarterpack`) AS ActiveBase 
FROM `scandb`.`tblInvoices` 
INNER JOIN `scandb`.`tblinvoicedetail` ON `scandb`.`tblinvoices`.`IDInv` = `scandb`.`tblinvoicedetail`.`IDInv`
INNER JOIN `scandb`.`tblboxes` ON `scandb`.`tblInvoicedetail`.`IDBox` = `scandb`.`tblboxes`.`IDBox`
INNER JOIN `scandb`.`tblnetworks` ON `scandb`.`tblboxes`.`IDNetwork` = `scandb`.`tblnetworks`.`IDNetwork`
INNER JOIN `scandb`.`tblstarterpacks` ON `scandb`.`tblboxes`.`IDBox` = `scandb`.`tblstarterpacks`.`IDBox`
INNER JOIN `scandb`.`tblongoing` ON `scandb`.`tblongoing`.`IDStarterPack` = `scandb`.`tblstarterpacks`.`IDStarterPack` 
WHERE `scandb`.`tblongoing`.`RechargeDate` > LAST_DAY(DATE_SUB(CURDATE(), INTERVAL 12 MONTH))
GROUP BY `scandb`.`tblInvoices`.`IDDealer`, `scandb`.`tblNetworks`.`IDNetwork`, LAST_DAY(`scandb`.`tblongoing`.`RechargeDate`)
HAVING ActiveBase >0;
/* SELECT `dbtemptables`.`tblrecharges`.`RechargeDate`, SUM(`dbtemptables`.`tblrecharges`.`Recharges`) AS Recharges FROM `dbtemptables`.`tblrecharges` 
GROUP BY `dbtemptables`.`tblrecharges`.`RechargeDate`;
*/

# -- Clear `dbtemptables`.`tbldates`
SELECT "Clearing `dbtemptables`.`tbldates`" AS '';
DELETE `dbtemptables`.`tbldates`.* FROM `dbtemptables`.`tbldates`;

# -- Append DealerDates - Now minus 5 months
SELECT "Appending DealerDates - Now minus 5 months" AS '';
INSERT INTO `dbtemptables`.`tbldates` (IDDealer, IDNetwork, ReportingMonth, Total)
SELECT DISTINCT `scandb`.`tblInvoices`.`IDDealer`, `scandb`.`tblNetworks`.`IDNetwork`, LAST_DAY(DATE_SUB(CURDATE(), INTERVAL 5 MONTH)) AS ReportingMonth, 0 AS Total
FROM  `scandb`.`tblInvoices` 
INNER JOIN `scandb`.`tblinvoicedetail` ON `scandb`.`tblInvoices`.`IDInv` = `scandb`.`tblinvoicedetail`.`IDInv`
INNER JOIN `scandb`.`tblBoxes` ON `scandb`.`tblBoxes`.`IDBox` = `scandb`.`tblInvoiceDetail`.`IDBox`
INNER JOIN `scandb`.`tblNetworks` ON `tblBoxes`.`IDNetwork` = `scandb`.`tblNetworks`.`IDNetwork`;
# GROUP BY `scandb`.`tblInvoices`.`IDDealer`, `scandb`.`tblNetworks`.`IDNetwork`, LAST_DAY(DATE_SUB(CURDATE(), INTERVAL 5 MONTH));

# SELECT `dbtemptables`.`tbldates`.`ReportingMonth` FROM `dbtemptables`.`tbldates` GROUP BY `dbtemptables`.`tbldates`.`ReportingMonth`;

# -- Append DealerDates - Now minus 4 months
SELECT "Appending DealerDates - Now minus 4 months" AS '';
INSERT INTO `dbtemptables`.`tbldates` (IDDealer, IDNetwork, ReportingMonth, Total)
SELECT DISTINCT `scandb`.`tblInvoices`.`IDDealer`, `scandb`.`tblNetworks`.`IDNetwork`, LAST_DAY(DATE_SUB(CURDATE(), INTERVAL 4 MONTH)) AS ReportingMonth, 0 AS Total
FROM  `scandb`.`tblInvoices` 
INNER JOIN `scandb`.`tblinvoicedetail` ON `scandb`.`tblInvoices`.`IDInv` = `scandb`.`tblinvoicedetail`.`IDInv`
INNER JOIN `scandb`.`tblBoxes` ON `scandb`.`tblBoxes`.`IDBox` = `scandb`.`tblInvoiceDetail`.`IDBox`
INNER JOIN `scandb`.`tblNetworks` ON `tblBoxes`.`IDNetwork` = `scandb`.`tblNetworks`.`IDNetwork`;
# GROUP BY `scandb`.`tblInvoices`.`IDDealer`, `scandb`.`tblNetworks`.`IDNetwork`, LAST_DAY(DATE_SUB(CURDATE(), INTERVAL 4 MONTH));

# SELECT `dbtemptables`.`tbldates`.`ReportingMonth` FROM `dbtemptables`.`tbldates` GROUP BY `dbtemptables`.`tbldates`.`ReportingMonth`;

# -- Append DealerDates - Now minus 3 months
SELECT "Appending DealerDates - Now minus 3 months" AS '';
INSERT INTO `dbtemptables`.`tbldates` (IDDealer, IDNetwork, ReportingMonth, Total)
SELECT DISTINCT `scandb`.`tblInvoices`.`IDDealer`, `scandb`.`tblNetworks`.`IDNetwork`, LAST_DAY(DATE_SUB(CURDATE(), INTERVAL 3 MONTH)) AS ReportingMonth, 0 AS Total
FROM  `scandb`.`tblInvoices` 
INNER JOIN `scandb`.`tblinvoicedetail` ON `scandb`.`tblInvoices`.`IDInv` = `scandb`.`tblinvoicedetail`.`IDInv`
INNER JOIN `scandb`.`tblBoxes` ON `scandb`.`tblBoxes`.`IDBox` = `scandb`.`tblInvoiceDetail`.`IDBox`
INNER JOIN `scandb`.`tblNetworks` ON `tblBoxes`.`IDNetwork` = `scandb`.`tblNetworks`.`IDNetwork`;
# GROUP BY `scandb`.`tblInvoices`.`IDDealer`, `scandb`.`tblNetworks`.`IDNetwork`, LAST_DAY(DATE_SUB(CURDATE(), INTERVAL 3 MONTH));

# SELECT `dbtemptables`.`tbldates`.`ReportingMonth` FROM `dbtemptables`.`tbldates` GROUP BY `dbtemptables`.`tbldates`.`ReportingMonth`;

# -- Append DealerDates - Now minus 2 months
SELECT "Appending DealerDates - Now minus 2 months" AS '';
INSERT INTO `dbtemptables`.`tbldates` (IDDealer, IDNetwork, ReportingMonth, Total)
SELECT DISTINCT `scandb`.`tblInvoices`.`IDDealer`, `scandb`.`tblNetworks`.`IDNetwork`, LAST_DAY(DATE_SUB(CURDATE(), INTERVAL 2 MONTH)) AS ReportingMonth, 0 AS Total
FROM  `scandb`.`tblInvoices` 
INNER JOIN `scandb`.`tblinvoicedetail` ON `scandb`.`tblInvoices`.`IDInv` = `scandb`.`tblinvoicedetail`.`IDInv`
INNER JOIN `scandb`.`tblBoxes` ON `scandb`.`tblBoxes`.`IDBox` = `scandb`.`tblInvoiceDetail`.`IDBox`
INNER JOIN `scandb`.`tblNetworks` ON `tblBoxes`.`IDNetwork` = `scandb`.`tblNetworks`.`IDNetwork`;
# GROUP BY `scandb`.`tblInvoices`.`IDDealer`, `scandb`.`tblNetworks`.`IDNetwork`, LAST_DAY(DATE_SUB(CURDATE(), INTERVAL 2 MONTH));

# SELECT `dbtemptables`.`tbldates`.`ReportingMonth` FROM `dbtemptables`.`tbldates` GROUP BY `dbtemptables`.`tbldates`.`ReportingMonth`;

# -- Append DealerDates - Now minus 1 month
SELECT "Appending DealerDates - Now minus 1 months" AS '';
INSERT INTO `dbtemptables`.`tbldates` (IDDealer, IDNetwork, ReportingMonth, Total)
SELECT DISTINCT `scandb`.`tblInvoices`.`IDDealer`, `scandb`.`tblNetworks`.`IDNetwork`, LAST_DAY(DATE_SUB(CURDATE(), INTERVAL 1 MONTH)) AS ReportingMonth, 0 AS Total
FROM  `scandb`.`tblInvoices` 
INNER JOIN `scandb`.`tblinvoicedetail` ON `scandb`.`tblInvoices`.`IDInv` = `scandb`.`tblinvoicedetail`.`IDInv`
INNER JOIN `scandb`.`tblBoxes` ON `scandb`.`tblBoxes`.`IDBox` = `scandb`.`tblInvoiceDetail`.`IDBox`
INNER JOIN `scandb`.`tblNetworks` ON `tblBoxes`.`IDNetwork` = `scandb`.`tblNetworks`.`IDNetwork`;
# GROUP BY `scandb`.`tblInvoices`.`IDDealer`, `scandb`.`tblNetworks`.`IDNetwork`, LAST_DAY(DATE_SUB(CURDATE(), INTERVAL 1 MONTH));

# SELECT `dbtemptables`.`tbldates`.`ReportingMonth` FROM `dbtemptables`.`tbldates` GROUP BY `dbtemptables`.`tbldates`.`ReportingMonth`;

# -- Append DealerDates - Now 
SELECT "Appending DealerDates - Now" AS '';
INSERT INTO `dbtemptables`.`tbldates` (IDDealer, IDNetwork, ReportingMonth, Total)
SELECT DISTINCT `scandb`.`tblInvoices`.`IDDealer`, `scandb`.`tblNetworks`.`IDNetwork`, LAST_DAY(CURDATE()) AS ReportingMonth, 0 AS Total
FROM  `scandb`.`tblInvoices` 
INNER JOIN `scandb`.`tblinvoicedetail` ON `scandb`.`tblInvoices`.`IDInv` = `scandb`.`tblinvoicedetail`.`IDInv`
INNER JOIN `scandb`.`tblBoxes` ON `scandb`.`tblBoxes`.`IDBox` = `scandb`.`tblInvoiceDetail`.`IDBox`
INNER JOIN `scandb`.`tblNetworks` ON `tblBoxes`.`IDNetwork` = `scandb`.`tblNetworks`.`IDNetwork`;
# GROUP BY `scandb`.`tblInvoices`.`IDDealer`, `scandb`.`tblNetworks`.`IDNetwork`, LAST_DAY(CURDATE());

# SELECT `dbtemptables`.`tbldates`.`ReportingMonth` FROM `dbtemptables`.`tbldates` GROUP BY `dbtemptables`.`tbldates`.`ReportingMonth`;

# -- Clear DealerTotals
SELECT "Clearing DealerTotals" AS '';
DELETE `dbtemptables`.`tbltotals`.* FROM `dbtemptables`.`tbltotals`;

# -- Insert Dealer Totals
SELECT "Inserting Dealer Totals..." AS '';
INSERT INTO `dbtemptables`.`tbltotals` (IDDealer,IDNetwork,ReportMonth,Sent,Ricas,Connections,Activations60,Activations120,Recharges, SimSwaps,Deletions,NetBase)
SELECT `dbtemptables`.`tbldates`.`IDDealer`,`tbldates`.`IDNetwork`,DATE_FORMAT(`dbtemptables`.`tbldates`.`ReportingMonth`,'%Y/%m'),
`dbtemptables`.`tblsentstock`.`Sent`,`dbtemptables`.`tblricas`.`Ricas`,`dbtemptables`.`tblconnections`.`Connections`,`dbtemptables`.`tblactivations60`.`Activations`,
`dbtemptables`.`tblactivations120`.`Activations` AS ACT120,`dbtemptables`.`tblrecharges`.`Recharges`, `dbtemptables`.`tblsimswaps`.`SimSwaps`,`dbtemptables`.`tbldeletions`.`Deletions`, 
`dbtemptables`.`tblactivebase`.`ActBase`
FROM `dbtemptables`.`tbldates` 
LEFT JOIN `dbtemptables`.`tblricas` 
  ON (`dbtemptables`.`tbldates`.`IDDealer` = `dbtemptables`.`tblricas`.`IDDealer`) 
  AND (`dbtemptables`.`tbldates`.`IDNetwork` = `dbtemptables`.`tblricas`.`IDNetwork`) 
  AND (`dbtemptables`.`tbldates`.`ReportingMonth` = `dbtemptables`.`tblricas`.RicaDate) 
LEFT JOIN `dbtemptables`.`tblactivations60`
  ON (`dbtemptables`.`tbldates`.`IDDealer` = `dbtemptables`.`tblactivations60`.`IDDealer`) 
  AND (`dbtemptables`.`tbldates`.`IDNetwork` = `dbtemptables`.`tblactivations60`.`IDNetwork`) 
  AND (`dbtemptables`.`tbldates`.`ReportingMonth` = `dbtemptables`.`tblactivations60`.`ActivationDate`) 
LEFT JOIN `dbtemptables`.`tblactivations120`
  ON (`dbtemptables`.`tbldates`.`IDDealer` = `dbtemptables`.`tblactivations120`.`IDDealer`) 
  AND (`dbtemptables`.`tbldates`.`IDNetwork` = `dbtemptables`.`tblactivations120`.`IDNetwork`) 
  AND (`dbtemptables`.`tbldates`.`ReportingMonth` = `dbtemptables`.`tblactivations120`.`ActivationDate`)
LEFT JOIN `dbtemptables`.`tblconnections` 
  ON (`dbtemptables`.`tbldates`.`IDDealer` = `dbtemptables`.`tblconnections`.`IDDealer`) 
  AND (`dbtemptables`.`tbldates`.`IDNetwork` = `dbtemptables`.`tblconnections`.`IDNetwork`) 
  AND (`dbtemptables`.`tbldates`.`ReportingMonth` = `dbtemptables`.`tblconnections`.ConnectionDate)
LEFT JOIN `dbtemptables`.`tblsentstock` 
  ON (`dbtemptables`.`tbldates`.`IDDealer` = `dbtemptables`.`tblsentstock`.`IDDealer`) 
  AND (`dbtemptables`.`tbldates`.`IDNetwork` = `dbtemptables`.`tblsentstock`.`IDNetwork`) 
  AND (`dbtemptables`.`tbldates`.`ReportingMonth` = `dbtemptables`.`tblsentstock`.`SentMonth`)
LEFT JOIN `dbtemptables`.`tblrecharges` 
  ON (`dbtemptables`.`tbldates`.`IDDealer` = `dbtemptables`.`tblrecharges`.`IDDealer`) 
  AND (`dbtemptables`.`tbldates`.`IDNetwork` = `dbtemptables`.`tblrecharges`.`IDNetwork`)   
  AND (`dbtemptables`.`tbldates`.`ReportingMonth` = `dbtemptables`.`tblrecharges`.`RechargeDate`)
LEFT JOIN `dbtemptables`.`tblsimswaps`
  ON (`dbtemptables`.`tbldates`.`IDDealer` = `dbtemptables`.`tblsimswaps`.`IDDealer`) 
  AND (`dbtemptables`.`tbldates`.`IDNetwork` = `dbtemptables`.`tblsimswaps`.`IDNetwork`)   
  AND (`dbtemptables`.`tbldates`.`ReportingMonth` = `dbtemptables`.`tblsimswaps`.`SimSwapDate`)
LEFT JOIN `dbtemptables`.`tbldeletions`
  ON (`dbtemptables`.`tbldates`.`IDDealer` = `dbtemptables`.`tbldeletions`.`IDDealer`) 
  AND (`dbtemptables`.`tbldates`.`IDNetwork` = `dbtemptables`.`tbldeletions`.`IDNetwork`)   
  AND (`dbtemptables`.`tbldates`.`ReportingMonth` = `dbtemptables`.`tbldeletions`.`DeletionDate`)
LEFT JOIN `dbtemptables`.`tblactivebase`
  ON (`dbtemptables`.`tbldates`.`IDDealer` = `dbtemptables`.`tblactivebase`.`IDDealer`) 
  AND (`dbtemptables`.`tbldates`.`IDNetwork` = `dbtemptables`.`tblactivebase`.`IDNetwork`)   
  AND (`dbtemptables`.`tbldates`.`ReportingMonth` = `dbtemptables`.`tblactivebase`.`RechargeDate`)
WHERE (`dbtemptables`.`tblactivations120`.`Activations` >0
  OR `dbtemptables`.`tblactivations60`.`Activations` >0
  OR `dbtemptables`.`tblconnections`.`Connections` >0
  OR `dbtemptables`.`tblricas`.`Ricas` >0
  OR `dbtemptables`.`tblsentstock`.`Sent` >0
  OR `dbtemptables`.`tblrecharges`.`Recharges` >0
  OR `dbtemptables`.`tblsimswaps`.`SimSwaps`>0
  OR `dbtemptables`.`tbldeletions`.`Deletions`>0
  OR `dbtemptables`.`tblactivebase`.`ActBase`>0);

# SELECT `dbtemptables`.`tbltotals`.* FROM `dbtemptables`.`tbltotals`;

# -- Clear Scrapo Dealers by Month by Network
SELECT "Clearing Scrapo Dealers by Month by Network" AS '';
DELETE `dbpavweb`.`tblweb_scrapo_dealers_by_month_by_network`.* FROM `dbpavweb`.`tblweb_scrapo_dealers_by_month_by_network`;

# -- Insert Scrapo Dealers by Month  by Network
SELECT "Inserting Scrapo Dealers by Month by Network" AS '';
INSERT INTO `dbpavweb`.`tblweb_scrapo_dealers_by_month_by_network` (IDDealer,IDNetwork,ReportMonth,Sent,Ricas,Connections,Activations,Activations120,Recharges,SimSwaps,Deletions,Actbase)
SELECT `dbtemptables`.`tbltotals`.`IDDealer`,`dbtemptables`.`tbltotals`.`IDNetwork`,`dbtemptables`.`tbltotals`.`ReportMonth`,`dbtemptables`.`tbltotals`.`Sent`,
`dbtemptables`.`tbltotals`.`Ricas`,`dbtemptables`.`tbltotals`.`Connections`,`dbtemptables`.`tbltotals`.`Activations60`,`dbtemptables`.`tbltotals`.`Activations120`,
`dbtemptables`.`tbltotals`.`Recharges`, `dbtemptables`.`tbltotals`.`SimSwaps`,`dbtemptables`.`tbltotals`.`Deletions`,`dbtemptables`.`tbltotals`.`NetBase`
FROM `dbtemptables`.`tbltotals`;

# -- Show the Appended Data
# SELECT `dbpavweb`.`tblweb_scrapo_dealers_by_month_by_network`.* FROM `dbpavweb`.`tblweb_scrapo_dealers_by_month_by_network` LIMIT 6;

# -- Clear Scrapo Dealers by Month
SELECT "Clearing Scrapo Dealers by Month" AS '';
DELETE `dbpavweb`.`tblweb_scrapo_dealers_by_month`.* FROM `dbpavweb`.`tblweb_scrapo_dealers_by_month`;

# -- Insert Scrapo Dealers by Month  by Network
SELECT "Inserting Scrapo Dealers by Month" AS '';
INSERT INTO `dbpavweb`.`tblweb_scrapo_dealers_by_month` (IDDealer,ReportMonth,Sent,Ricas,Connections,Activations,Activations120,Recharges,Simswaps,Deletions,Actbase)
SELECT `dbtemptables`.`tbltotals`.`IDDealer`,`dbtemptables`.`tbltotals`.`ReportMonth`,SUM(`dbtemptables`.`tbltotals`.`Sent`) AS SENT,
SUM(`dbtemptables`.`tbltotals`.`Ricas`) AS RICAS, SUM(`dbtemptables`.`tbltotals`.`Connections`) AS CONNECTIONS,
SUM(`dbtemptables`.`tbltotals`.`Activations60`) AS ACT, SUM(`dbtemptables`.`tbltotals`.`Activations120`) AS ACT120, SUM(`dbtemptables`.`tbltotals`.`Recharges`) AS RECHARGES,
SUM(`dbtemptables`.`tbltotals`.`SimSwaps`) AS Swaps, SUM(`dbtemptables`.`tbltotals`.`Deletions`) AS Del, SUM(`dbtemptables`.`tbltotals`.`NetBase`) AS Base
FROM `dbtemptables`.`tbltotals`
GROUP BY `dbtemptables`.`tbltotals`.`IDDealer`,`dbtemptables`.`tbltotals`.`ReportMonth`;
# -- Show the Appended Data
# SELECT `dbpavweb`.`tblweb_scrapo_dealers_by_month`.* FROM `dbpavweb`.`tblweb_scrapo_dealers_by_month` LIMIT 6;


## -------------------------------------------------------------------------------------------------------------------------------------------------------- ##
##                                                                D E A L E R   B Y   R E P
## -------------------------------------------------------------------------------------------------------------------------------------------------------- ##

# -- Clear temp tables -- #
SELECT "Clearing REP temp tables" AS '';
DELETE `dbtemptables`.`tblactivations120_by_rep`.* FROM `dbtemptables`.`tblactivations120_by_rep`;
DELETE `dbtemptables`.`tblactivations60`.* FROM `dbtemptables`.`tblactivations60`;
DELETE `dbtemptables`.`tblconnections`.* FROM `dbtemptables`.`tblconnections`;
DELETE `dbtemptables`.`tbldates`.* FROM `dbtemptables`.`tbldates`;
DELETE `dbtemptables`.`tbldeletions`.* FROM `dbtemptables`.`tbldeletions`;
DELETE `dbtemptables`.`tblpaidactivations_by_rep`.* FROM `dbtemptables`.`tblpaidactivations_by_rep`;
DELETE `dbtemptables`.`tblactivebase_by_rep`.* FROM `dbtemptables`.`tblactivebase_by_rep`;
DELETE `dbtemptables`.`tblrecharges`.* FROM `dbtemptables`.`tblrecharges`;
DELETE `dbtemptables`.`tblricas`.* FROM `dbtemptables`.`tblricas`;
DELETE `dbtemptables`.`tblsentstock` FROM `dbtemptables`.`tblsentstock`;
DELETE `dbtemptables`.`tblsimswaps`.* FROM `dbtemptables`.`tblsimswaps`;
DELETE `dbtemptables`.`tbltotals`.* FROM `dbtemptables`.`tbltotals`;
DELETE `dbtemptables`.`tblsentstock`.* FROM `dbtemptables`.`tblsentstock`;

# -- Create Sent Stock by Dealer by Rep by Network
SELECT "Creating Sent Stock by Dealer by Rep by Network" AS '';
INSERT INTO `dbtemptables`.`tblsentstock` ( IDDealer, IDRep, IDNetwork, SentMonth, Sent  )
SELECT `scandb`.`tblInvoices`.`IDDealer`,`scandb`.`tblInvoices`.`IDRep`, `scandb`.`tblNetworks`.`IDNetwork`, 
LAST_DAY(`scandb`.`tblinvoices`.`InvoiceDate`) AS SentMonth, 
COUNT(`scandb`.`tblStarterPacks`.`SimNumber`) AS Sent 
FROM `scandb`.`tblInvoices`
INNER JOIN `scandb`.`tblinvoicedetail` ON `scandb`.`tblinvoices`.`IDInv` = `scandb`.`tblinvoicedetail`.`IDInv`
INNER JOIN `scandb`.`tblboxes` ON `scandb`.`tblInvoicedetail`.`IDBox` = `scandb`.`tblboxes`.`IDBox`
INNER JOIN `scandb`.`tblnetworks` ON `scandb`.`tblboxes`.`IDNetwork` = `scandb`.`tblnetworks`.`IDNetwork`
INNER JOIN `scandb`.`tblstarterpacks` ON `scandb`.`tblboxes`.`IDBox` = `scandb`.`tblstarterpacks`.`IDBox`
WHERE `scandb`.`tblInvoices`.`InvoiceDate` > LAST_DAY(DATE_SUB(CURDATE(), INTERVAL 5 MONTH))
GROUP BY `scandb`.`tblInvoices`.`IDDealer`, `scandb`.`tblInvoices`.`IDRep`, `scandb`.`tblNetworks`.`IDNetwork`, LAST_DAY(`scandb`.`tblinvoices`.`InvoiceDate`)
HAVING Sent >0;
# SELECT `dbtemptables`.`tblsentstock`.* FROM `dbtemptables`.`tblsentstock` LIMIT 5;

# -- Create Activations120 by Dealer by by Rep by Network
SELECT "Creating Activations120 by Dealer by by Rep by Network" AS '';
INSERT INTO `dbtemptables`.`tblactivations120_by_rep` ( IDDealer, IDRep, IDNetwork, ActivationDate, Activations  )
SELECT `scandb`.`tblInvoices`.`IDDealer`, `scandb`.`tblInvoices`.`IDRep`, `scandb`.`tblNetworks`.`IDNetwork`, 
LAST_DAY(`scandb`.`tblstarterpacks`.`ActualActivationDate`) AS ActivationDate, 
COUNT(`scandb`.`tblStarterPacks`.`ActualActivationDate`) AS Activations 
FROM `scandb`.`tblInvoices`
INNER JOIN `scandb`.`tblinvoicedetail` ON `scandb`.`tblinvoices`.`IDInv` = `scandb`.`tblinvoicedetail`.`IDInv`
INNER JOIN `scandb`.`tblboxes` ON `scandb`.`tblInvoicedetail`.`IDBox` = `scandb`.`tblboxes`.`IDBox`
INNER JOIN `scandb`.`tblnetworks` ON `scandb`.`tblboxes`.`IDNetwork` = `scandb`.`tblnetworks`.`IDNetwork`
INNER JOIN `scandb`.`tblstarterpacks` ON `scandb`.`tblboxes`.`IDBox` = `scandb`.`tblstarterpacks`.`IDBox`
WHERE `scandb`.`tblstarterpacks`.`ActualActivationDate` > LAST_DAY(DATE_SUB(CURDATE(), INTERVAL 5 MONTH))
GROUP BY `scandb`.`tblInvoices`.`IDDealer`, `scandb`.`tblInvoices`.`IDRep`, `scandb`.`tblNetworks`.`IDNetwork`, LAST_DAY(`scandb`.`tblstarterpacks`.`ActualActivationDate`)
HAVING Activations >0;

# SELECT `dbtemptables`.`tblactivations120`.* FROM `dbtemptables`.`tblactivations120` LIMIT 5;

# -- Create Activations60 by Dealer by Rep by Network
SELECT "Creating Activations60 by Dealer by Rep by Network" AS '';
INSERT INTO `dbtemptables`.`tblactivations60` ( IDDealer, IDRep, IDNetwork, ActivationDate, Activations  )
SELECT `scandb`.`tblInvoices`.`IDDealer`,`scandb`.`tblInvoices`.`IDRep`,`scandb`.`tblNetworks`.`IDNetwork`, 
LAST_DAY(`scandb`.`tblstarterpacks`.`ActivationDate`) AS ActivationDate, 
COUNT(`scandb`.`tblStarterPacks`.`ActivationDate`) AS Activations 
FROM `scandb`.`tblInvoices`
INNER JOIN `scandb`.`tblinvoicedetail` ON `scandb`.`tblinvoices`.`IDInv` = `scandb`.`tblinvoicedetail`.`IDInv`
INNER JOIN `scandb`.`tblboxes` ON `scandb`.`tblInvoicedetail`.`IDBox` = `scandb`.`tblboxes`.`IDBox`
INNER JOIN `scandb`.`tblnetworks` ON `scandb`.`tblboxes`.`IDNetwork` = `scandb`.`tblnetworks`.`IDNetwork`
INNER JOIN `scandb`.`tblstarterpacks` ON `scandb`.`tblboxes`.`IDBox` = `scandb`.`tblstarterpacks`.`IDBox`
WHERE `scandb`.`tblstarterpacks`.`ActivationDate` > LAST_DAY(DATE_SUB(CURDATE(), INTERVAL 5 MONTH))
GROUP BY `scandb`.`tblInvoices`.`IDDealer`,`scandb`.`tblInvoices`.`IDRep`, `scandb`.`tblNetworks`.`IDNetwork`, LAST_DAY(`scandb`.`tblstarterpacks`.`ActivationDate`)
HAVING Activations >0;
# SELECT `dbtemptables`.`tblactivations60`.* FROM `dbtemptables`.`tblactivations60` LIMIT 5;

# -- Create Connections by Dealer by Rep by Network
SELECT "Creating Connections by Dealer by Rep by Network" AS '';
INSERT INTO `dbtemptables`.`tblconnections` ( IDDealer, IDRep, IDNetwork, ConnectionDate, Connections  )
SELECT `scandb`.`tblInvoices`.`IDDealer`,`scandb`.`tblInvoices`.`IDRep`, `scandb`.`tblNetworks`.`IDNetwork`, LAST_DAY(`scandb`.`tblstarterpacks`.`ConnectionDate`), 
COUNT(`scandb`.`tblStarterPacks`.`ConnectionDate`) AS Connections
FROM `scandb`.`tblInvoices` 
INNER JOIN `scandb`.`tblinvoicedetail` ON `scandb`.`tblinvoices`.`IDInv` = `scandb`.`tblinvoicedetail`.`IDInv`
INNER JOIN `scandb`.`tblboxes` ON `scandb`.`tblInvoicedetail`.`IDBox` = `scandb`.`tblboxes`.`IDBox`
INNER JOIN `scandb`.`tblnetworks` ON `scandb`.`tblboxes`.`IDNetwork` = `scandb`.`tblnetworks`.`IDNetwork`
INNER JOIN `scandb`.`tblstarterpacks` ON `scandb`.`tblboxes`.`IDBox` = `scandb`.`tblstarterpacks`.`IDBox`
WHERE `scandb`.`tblstarterpacks`.`ConnectionDate` > LAST_DAY(DATE_SUB(CURDATE(), INTERVAL 5 MONTH))
GROUP BY `scandb`.`tblInvoices`.`IDDealer`,`scandb`.`tblInvoices`.`IDRep`,`scandb`.`tblInvoices`.`IDRep`, `scandb`.`tblNetworks`.`IDNetwork`, LAST_DAY(`scandb`.`tblstarterpacks`.`ConnectionDate`)
HAVING Connections >0;
# SELECT `dbtemptables`.`tblconnections`.* FROM `dbtemptables`.`tblconnections` LIMIT 24;

# -- Create RICAs by Dealer by Rep by Network
SELECT "Creating RICAs by Dealer by Rep by Network" AS '';
INSERT INTO `dbtemptables`.`tblricas` ( IDDealer, IDRep, IDNetwork, RicaDate, Ricas  )
SELECT `scandb`.`tblInvoices`.`IDDealer`,`scandb`.`tblInvoices`.`IDRep`, `scandb`.`tblNetworks`.`IDNetwork`, 
LAST_DAY(`scandb`.`tblstarterpacks`.`RicaDate`), 
COUNT(`scandb`.`tblStarterPacks`.`RicaDate`) AS Ricas 
FROM `scandb`.`tblInvoices` 
INNER JOIN `scandb`.`tblinvoicedetail` ON `scandb`.`tblinvoices`.`IDInv` = `scandb`.`tblinvoicedetail`.`IDInv`
INNER JOIN `scandb`.`tblboxes` ON `scandb`.`tblInvoicedetail`.`IDBox` = `scandb`.`tblboxes`.`IDBox`
INNER JOIN `scandb`.`tblnetworks` ON `scandb`.`tblboxes`.`IDNetwork` = `scandb`.`tblnetworks`.`IDNetwork`
INNER JOIN `scandb`.`tblstarterpacks` ON `scandb`.`tblboxes`.`IDBox` = `scandb`.`tblstarterpacks`.`IDBox`
WHERE `scandb`.`tblstarterpacks`.`RicaDate` > LAST_DAY(DATE_SUB(CURDATE(), INTERVAL 5 MONTH))
GROUP BY `scandb`.`tblInvoices`.`IDDealer`,`scandb`.`tblInvoices`.`IDRep`, `scandb`.`tblNetworks`.`IDNetwork`, LAST_DAY(`scandb`.`tblstarterpacks`.`RicaDate`)
HAVING Ricas >0;
# SELECT `dbtemptables`.`tblricas`.* FROM `dbtemptables`.`tblricas` LIMIT 15;

# -- Create SimSwaps by Dealer by Rep by Network
SELECT "Creating SimSwaps by Dealer by Rep by Network" AS '';
INSERT INTO `dbtemptables`.`tblsimswaps` ( IDDealer, IDRep, IDNetwork, SimSwapDate, Simswaps  )
SELECT `scandb`.`tblInvoices`.`IDDealer`, `scandb`.`tblInvoices`.`IDRep`, `scandb`.`tblNetworks`.`IDNetwork`, 
LAST_DAY(`scandb`.`tblstarterpacks`.`SimSwapDate`), 
COUNT(`scandb`.`tblStarterPacks`.`SimSwapDate`) AS Swaps
FROM `scandb`.`tblInvoices` 
INNER JOIN `scandb`.`tblinvoicedetail` ON `scandb`.`tblinvoices`.`IDInv` = `scandb`.`tblinvoicedetail`.`IDInv`
INNER JOIN `scandb`.`tblboxes` ON `scandb`.`tblInvoicedetail`.`IDBox` = `scandb`.`tblboxes`.`IDBox`
INNER JOIN `scandb`.`tblnetworks` ON `scandb`.`tblboxes`.`IDNetwork` = `scandb`.`tblnetworks`.`IDNetwork`
INNER JOIN `scandb`.`tblstarterpacks` ON `scandb`.`tblboxes`.`IDBox` = `scandb`.`tblstarterpacks`.`IDBox`
WHERE `scandb`.`tblstarterpacks`.`SimSwapDate` > LAST_DAY(DATE_SUB(CURDATE(), INTERVAL 5 MONTH))
GROUP BY `scandb`.`tblInvoices`.`IDDealer`, `scandb`.`tblInvoices`.`IDRep`, `scandb`.`tblNetworks`.`IDNetwork`, LAST_DAY(`scandb`.`tblstarterpacks`.`SimSwapDate`)
HAVING Swaps >0;

# -- Create Deletions by Dealer by Rep by Network
SELECT "Creating Deletions by Dealer by Rep by Network" AS '';
INSERT INTO `dbtemptables`.`tbldeletions` ( IDDealer, IDRep, IDNetwork, DeletionDate, Deletions  )
SELECT `scandb`.`tblInvoices`.`IDDealer`,`scandb`.`tblInvoices`.`IDRep`,`scandb`.`tblNetworks`.`IDNetwork`, 
LAST_DAY(`scandb`.`tblstarterpacks`.`DeletionDate`),
COUNT(`scandb`.`tblstarterpacks`.`DeletionDate`) AS Deletions
FROM `scandb`.`tblInvoices` 
INNER JOIN `scandb`.`tblinvoicedetail` ON `scandb`.`tblinvoices`.`IDInv` = `scandb`.`tblinvoicedetail`.`IDInv`
INNER JOIN `scandb`.`tblboxes` ON `scandb`.`tblInvoicedetail`.`IDBox` = `scandb`.`tblboxes`.`IDBox`
INNER JOIN `scandb`.`tblnetworks` ON `scandb`.`tblboxes`.`IDNetwork` = `scandb`.`tblnetworks`.`IDNetwork`
INNER JOIN `scandb`.`tblstarterpacks` ON `scandb`.`tblboxes`.`IDBox` = `scandb`.`tblstarterpacks`.`IDBox`
WHERE `scandb`.`tblstarterpacks`.`DeletionDate` > LAST_DAY(DATE_SUB(CURDATE(), INTERVAL 5 MONTH))
GROUP BY `scandb`.`tblInvoices`.`IDDealer`,`scandb`.`tblInvoices`.`IDRep`,`scandb`.`tblNetworks`.`IDNetwork`, LAST_DAY(`scandb`.`tblstarterpacks`.`DeletionDate`)
HAVING Deletions >0;

# -- Create Paid Activations by Dealer by Rep by Network
SELECT "Creating Paid Activations by Dealer by Rep by Network" AS '';
INSERT INTO `dbtemptables`.`tblpaidactivations_by_rep` ( IDDealer, IDRep, IDNetwork, ActualActivationDate, PaidActivations )
SELECT `scandb`.`tblInvoices`.`IDDealer`,`scandb`.`tblInvoices`.`IDRep`,`scandb`.`tblNetworks`.`IDNetwork`, 
LAST_DAY(`scandb`.`tblstarterpacks`.`ActualActivationDate`),
# COUNT(`scandb`.`tblstarterpacks`.`ActivationDate`) AS Activations,
COUNT(`scandb`.`tblstarterpacks`.`AgentPaidDate`) AS PaidActivations
FROM `scandb`.`tblInvoices` 
INNER JOIN `scandb`.`tblinvoicedetail` ON `scandb`.`tblinvoices`.`IDInv` = `scandb`.`tblinvoicedetail`.`IDInv`
INNER JOIN `scandb`.`tblboxes` ON `scandb`.`tblInvoicedetail`.`IDBox` = `scandb`.`tblboxes`.`IDBox`
INNER JOIN `scandb`.`tblnetworks` ON `scandb`.`tblboxes`.`IDNetwork` = `scandb`.`tblnetworks`.`IDNetwork`
INNER JOIN `scandb`.`tblstarterpacks` ON `scandb`.`tblboxes`.`IDBox` = `scandb`.`tblstarterpacks`.`IDBox`
WHERE `scandb`.`tblstarterpacks`.`ActualActivationDate` > LAST_DAY(DATE_SUB(CURDATE(), INTERVAL 5 MONTH))
GROUP BY `scandb`.`tblInvoices`.`IDDealer`,`scandb`.`tblInvoices`.`IDRep`,`scandb`.`tblNetworks`.`IDNetwork`, LAST_DAY(`scandb`.`tblstarterpacks`.`ActualActivationDate`)
HAVING PaidActivations >0;

# -- Create Active Base by Dealer by Rep by Network
SELECT "Creating Active Base by Dealer by Rep by Network" AS '';
INSERT INTO `dbtemptables`.`tblactivebase_by_rep` ( IDDealer, IDRep, IDNetwork, RechargeDate, ActBase  )
SELECT `scandb`.`tblInvoices`.`IDDealer`, `scandb`.`tblInvoices`.`IDRep`,`scandb`.`tblNetworks`.`IDNetwork`, 
LAST_DAY(`scandb`.`tblongoing`.`RechargeDate`) AS RechargeDate, 
COUNT(`scandb`.`tblongoing`.`IDStarterpack`) AS ActiveBase 
FROM `scandb`.`tblInvoices` 
INNER JOIN `scandb`.`tblinvoicedetail` ON `scandb`.`tblinvoices`.`IDInv` = `scandb`.`tblinvoicedetail`.`IDInv`
INNER JOIN `scandb`.`tblboxes` ON `scandb`.`tblInvoicedetail`.`IDBox` = `scandb`.`tblboxes`.`IDBox`
INNER JOIN `scandb`.`tblnetworks` ON `scandb`.`tblboxes`.`IDNetwork` = `scandb`.`tblnetworks`.`IDNetwork`
INNER JOIN `scandb`.`tblstarterpacks` ON `scandb`.`tblboxes`.`IDBox` = `scandb`.`tblstarterpacks`.`IDBox`
INNER JOIN `scandb`.`tblongoing` ON `scandb`.`tblongoing`.`IDStarterPack` = `scandb`.`tblstarterpacks`.`IDStarterPack` 
WHERE `scandb`.`tblongoing`.`RechargeDate` > LAST_DAY(DATE_SUB(CURDATE(), INTERVAL 5 MONTH))
GROUP BY `scandb`.`tblInvoices`.`IDDealer`, `scandb`.`tblInvoices`.`IDRep`,`scandb`.`tblNetworks`.`IDNetwork`, LAST_DAY(`scandb`.`tblongoing`.`RechargeDate`)
HAVING ActiveBase >0;

# -- Create Ongoing Recharges by Dealer Rep by Network
SELECT "Creating Ongoing Recharges by Dealer Rep by Network" AS '';
INSERT INTO `dbtemptables`.`tblrecharges` ( IDDealer, IDRep, IDNetwork, RechargeDate, Recharges  )
SELECT `scandb`.`tblInvoices`.`IDDealer`,`scandb`.`tblInvoices`.`IDRep`, `scandb`.`tblNetworks`.`IDNetwork`, 
LAST_DAY(`scandb`.`tblongoing`.`RechargeDate`) AS RechargeDate, 
SUM(`scandb`.`tblongoing`.`RechargeAmount`) AS Recharges 
FROM `scandb`.`tblInvoices` 
INNER JOIN `scandb`.`tblinvoicedetail` ON `scandb`.`tblinvoices`.`IDInv` = `scandb`.`tblinvoicedetail`.`IDInv`
INNER JOIN `scandb`.`tblboxes` ON `scandb`.`tblInvoicedetail`.`IDBox` = `scandb`.`tblboxes`.`IDBox`
INNER JOIN `scandb`.`tblnetworks` ON `scandb`.`tblboxes`.`IDNetwork` = `scandb`.`tblnetworks`.`IDNetwork`
INNER JOIN `scandb`.`tblstarterpacks` ON `scandb`.`tblboxes`.`IDBox` = `scandb`.`tblstarterpacks`.`IDBox`
INNER JOIN `scandb`.`tblongoing` ON `scandb`.`tblongoing`.`IDStarterPack` = `scandb`.`tblstarterpacks`.`IDStarterPack` 
WHERE `scandb`.`tblongoing`.`RechargeDate` > LAST_DAY(DATE_SUB(CURDATE(), INTERVAL 5 MONTH))
GROUP BY `scandb`.`tblInvoices`.`IDDealer`,`scandb`.`tblInvoices`.`IDRep`, `scandb`.`tblNetworks`.`IDNetwork`, LAST_DAY(`scandb`.`tblongoing`.`RechargeDate`)
HAVING Recharges >0;
/* SELECT `dbtemptables`.`tblrecharges`.`IDDealer`,`dbtemptables`.`tblrecharges`.`IDRep`,`dbtemptables`.`tblrecharges`.`RechargeDate`, SUM(`dbtemptables`.`tblrecharges`.`Recharges`) AS Recharges FROM `dbtemptables`.`tblrecharges` 
GROUP BY `dbtemptables`.`tblrecharges`.`IDDealer`,`dbtemptables`.`tblrecharges`.`IDRep`,`dbtemptables`.`tblrecharges`.`RechargeDate`;
*/

# -- Clear `dbtemptables`.`tbldates`
SELECT "Clearing `dbtemptables`.`tbldates`" AS '';
DELETE `dbtemptables`.`tbldates_by_rep`.* FROM `dbtemptables`.`tbldates_by_rep`;

# -- Append DealerDates by Rep - Now minus 5 months
SELECT "Appending DealerDates by Rep - Now minus 5 months" AS '';
INSERT INTO `dbtemptables`.`tbldates_by_rep` (IDDealer, IDRep, IDNetwork, ReportingMonth, Total)
SELECT `scandb`.`tblInvoices`.`IDDealer`,`scandb`.`tblInvoices`.`IDRep`, `scandb`.`tblNetworks`.`IDNetwork`, LAST_DAY(DATE_SUB(CURDATE(), INTERVAL 5 MONTH)) AS ReportingMonth, 0 AS Total
FROM `scandb`.`tblInvoices` 
INNER JOIN `scandb`.`tblinvoicedetail` ON `scandb`.`tblInvoices`.`IDInv` = `scandb`.`tblinvoicedetail`.`IDInv`
INNER JOIN `scandb`.`tblBoxes` ON `scandb`.`tblBoxes`.`IDBox` = `scandb`.`tblInvoiceDetail`.`IDBox`
INNER JOIN `scandb`.`tblNetworks` ON `tblBoxes`.`IDNetwork` = `scandb`.`tblNetworks`.`IDNetwork`
GROUP BY `scandb`.`tblInvoices`.`IDDealer`,`scandb`.`tblInvoices`.`IDRep`, `scandb`.`tblNetworks`.`IDNetwork`, LAST_DAY(DATE_SUB(CURDATE(), INTERVAL 5 MONTH));
# SELECT `dbtemptables`.`tbldates_by_rep`.`ReportingMonth` FROM `dbtemptables`.`tbldates_by_rep` GROUP BY `dbtemptables`.`tbldates_by_rep`.`ReportingMonth`;

# -- Append DealerDates by Rep - Now minus 4 months
SELECT "Appending DealerDates by Rep - Now minus 4 months" AS '';
INSERT INTO `dbtemptables`.`tbldates_by_rep` (IDDealer, IDRep, IDNetwork, ReportingMonth, Total)
SELECT `scandb`.`tblInvoices`.`IDDealer`,`scandb`.`tblInvoices`.`IDRep`, `scandb`.`tblNetworks`.`IDNetwork`, LAST_DAY(DATE_SUB(CURDATE(), INTERVAL 4 MONTH)) AS ReportingMonth, 0 AS Total
FROM `scandb`.`tblInvoices` 
INNER JOIN `scandb`.`tblinvoicedetail` ON `scandb`.`tblInvoices`.`IDInv` = `scandb`.`tblinvoicedetail`.`IDInv`
INNER JOIN `scandb`.`tblBoxes` ON `scandb`.`tblBoxes`.`IDBox` = `scandb`.`tblInvoiceDetail`.`IDBox`
INNER JOIN `scandb`.`tblNetworks` ON `tblBoxes`.`IDNetwork` = `scandb`.`tblNetworks`.`IDNetwork`
GROUP BY `scandb`.`tblInvoices`.`IDDealer`,`scandb`.`tblInvoices`.`IDRep`, `scandb`.`tblNetworks`.`IDNetwork`, LAST_DAY(DATE_SUB(CURDATE(), INTERVAL 4 MONTH));
# SELECT `dbtemptables`.`tbldates_by_rep`.`ReportingMonth` FROM `dbtemptables`.`tbldates_by_rep` GROUP BY `dbtemptables`.`tbldates_by_rep`.`ReportingMonth`;

# -- Append DealerDates by Rep - Now minus 3 months
SELECT "Appending DealerDates by Rep - Now minus 3 months" AS '';
INSERT INTO `dbtemptables`.`tbldates_by_rep` (IDDealer, IDRep, IDNetwork, ReportingMonth, Total)
SELECT `scandb`.`tblInvoices`.`IDDealer`,`scandb`.`tblInvoices`.`IDRep`, `scandb`.`tblNetworks`.`IDNetwork`, LAST_DAY(DATE_SUB(CURDATE(), INTERVAL 3 MONTH)) AS ReportingMonth, 0 AS Total
FROM `scandb`.`tblInvoices` 
INNER JOIN `scandb`.`tblinvoicedetail` ON `scandb`.`tblInvoices`.`IDInv` = `scandb`.`tblinvoicedetail`.`IDInv`
INNER JOIN `scandb`.`tblBoxes` ON `scandb`.`tblBoxes`.`IDBox` = `scandb`.`tblInvoiceDetail`.`IDBox`
INNER JOIN `scandb`.`tblNetworks` ON `tblBoxes`.`IDNetwork` = `scandb`.`tblNetworks`.`IDNetwork`
GROUP BY `scandb`.`tblInvoices`.`IDDealer`,`scandb`.`tblInvoices`.`IDRep`, `scandb`.`tblNetworks`.`IDNetwork`, LAST_DAY(DATE_SUB(CURDATE(), INTERVAL 3 MONTH));
# SELECT `dbtemptables`.`tbldates_by_rep`.`ReportingMonth` FROM `dbtemptables`.`tbldates_by_rep` GROUP BY `dbtemptables`.`tbldates_by_rep`.`ReportingMonth`;

# -- Append DealerDates by Rep - Now minus 2 months
SELECT "Appending DealerDates by Rep - Now minus 2 months" AS '';
INSERT INTO `dbtemptables`.`tbldates_by_rep` (IDDealer, IDRep, IDNetwork, ReportingMonth, Total)
SELECT `scandb`.`tblInvoices`.`IDDealer`,`scandb`.`tblInvoices`.`IDRep`, `scandb`.`tblNetworks`.`IDNetwork`, LAST_DAY(DATE_SUB(CURDATE(), INTERVAL 2 MONTH)) AS ReportingMonth, 0 AS Total
FROM `scandb`.`tblInvoices` 
INNER JOIN `scandb`.`tblinvoicedetail` ON `scandb`.`tblInvoices`.`IDInv` = `scandb`.`tblinvoicedetail`.`IDInv`
INNER JOIN `scandb`.`tblBoxes` ON `scandb`.`tblBoxes`.`IDBox` = `scandb`.`tblInvoiceDetail`.`IDBox`
INNER JOIN `scandb`.`tblNetworks` ON `tblBoxes`.`IDNetwork` = `scandb`.`tblNetworks`.`IDNetwork`
GROUP BY `scandb`.`tblInvoices`.`IDDealer`,`scandb`.`tblInvoices`.`IDRep`, `scandb`.`tblNetworks`.`IDNetwork`, LAST_DAY(DATE_SUB(CURDATE(), INTERVAL 2 MONTH));
# SELECT `dbtemptables`.`tbldates_by_rep`.`ReportingMonth` FROM `dbtemptables`.`tbldates_by_rep` GROUP BY `dbtemptables`.`tbldates_by_rep`.`ReportingMonth`;

# -- Append DealerDates by Rep - Now minus 1 month
SELECT "Appending DealerDates by Rep - Now minus 1 months" AS '';
INSERT INTO `dbtemptables`.`tbldates_by_rep` (IDDealer, IDRep, IDNetwork, ReportingMonth, Total)
SELECT `scandb`.`tblInvoices`.`IDDealer`,`scandb`.`tblInvoices`.`IDRep`, `scandb`.`tblNetworks`.`IDNetwork`, LAST_DAY(DATE_SUB(CURDATE(), INTERVAL 1 MONTH)) AS ReportingMonth, 0 AS Total
FROM `scandb`.`tblInvoices` 
INNER JOIN `scandb`.`tblinvoicedetail` ON `scandb`.`tblInvoices`.`IDInv` = `scandb`.`tblinvoicedetail`.`IDInv`
INNER JOIN `scandb`.`tblBoxes` ON `scandb`.`tblBoxes`.`IDBox` = `scandb`.`tblInvoiceDetail`.`IDBox`
INNER JOIN `scandb`.`tblNetworks` ON `tblBoxes`.`IDNetwork` = `scandb`.`tblNetworks`.`IDNetwork`
GROUP BY `scandb`.`tblInvoices`.`IDDealer`,`scandb`.`tblInvoices`.`IDRep`, `scandb`.`tblNetworks`.`IDNetwork`, LAST_DAY(DATE_SUB(CURDATE(), INTERVAL 1 MONTH));
# SELECT `dbtemptables`.`tbldates_by_rep`.`ReportingMonth` FROM `dbtemptables`.`tbldates_by_rep` GROUP BY `dbtemptables`.`tbldates_by_rep`.`ReportingMonth`;

# -- Append DealerDates by Rep - Now 
SELECT "Appending DealerDates by Rep - This month" AS '';
INSERT INTO `dbtemptables`.`tbldates_by_rep` (IDDealer, IDRep, IDNetwork, ReportingMonth, Total)
SELECT `scandb`.`tblInvoices`.`IDDealer`,`scandb`.`tblInvoices`.`IDRep`, `scandb`.`tblNetworks`.`IDNetwork`, LAST_DAY(CURDATE()) AS ReportingMonth, 0 AS Total
FROM `scandb`.`tblInvoices` 
INNER JOIN `scandb`.`tblinvoicedetail` ON `scandb`.`tblInvoices`.`IDInv` = `scandb`.`tblinvoicedetail`.`IDInv`
INNER JOIN `scandb`.`tblBoxes` ON `scandb`.`tblBoxes`.`IDBox` = `scandb`.`tblInvoiceDetail`.`IDBox`
INNER JOIN `scandb`.`tblNetworks` ON `tblBoxes`.`IDNetwork` = `scandb`.`tblNetworks`.`IDNetwork`
GROUP BY `scandb`.`tblInvoices`.`IDDealer`,`scandb`.`tblInvoices`.`IDRep`, `scandb`.`tblNetworks`.`IDNetwork`, LAST_DAY(CURDATE());
# SELECT `dbtemptables`.`tbldates_by_rep`.`ReportingMonth` FROM `dbtemptables`.`tbldates_by_rep` GROUP BY `dbtemptables`.`tbldates_by_rep`.`ReportingMonth`;

# -- Clear DealerTotals by Rep
SELECT "Clearing DealerTotals by Rep" AS '';
DELETE `dbtemptables`.`tbltotals`.* FROM `dbtemptables`.`tbltotals`;

# -- Insert Dealer by Rep Totals
SELECT "Inserting Dealer by Rep Totals" AS '';
INSERT INTO `dbtemptables`.`tbltotals` (IDDealer,IDRep,IDNetwork,ReportMonth,Sent,Ricas,Connections,Activations60,Activations120,PaidActivations,NetBase,Recharges,SimSwaps,Deletions)
SELECT `dbtemptables`.`tbldates_by_rep`.`IDDealer`,`dbtemptables`.`tbldates_by_rep`.`IDRep`,`tbldates_by_rep`.`IDNetwork`,DATE_FORMAT(`dbtemptables`.`tbldates_by_rep`.`ReportingMonth`,'%Y/%m'),
`dbtemptables`.`tblsentstock`.`Sent`,`dbtemptables`.`tblricas`.`Ricas`,`dbtemptables`.`tblconnections`.`Connections`,`dbtemptables`.`tblactivations60`.`Activations`,
`dbtemptables`.`tblactivations120_by_rep`.`Activations` AS ACT120, `dbtemptables`.`tblpaidactivations_by_rep`.`PaidActivations`,`dbtemptables`.`tblactivebase_by_rep`.`ActBase`,
`dbtemptables`.`tblrecharges`.`Recharges`,`dbtemptables`.`tblsimswaps`.`SimSwaps`, `dbtemptables`.`tbldeletions`.`Deletions`
FROM `dbtemptables`.`tbldates_by_rep`
LEFT JOIN `dbtemptables`.`tblricas` 
  ON (`dbtemptables`.`tbldates_by_rep`.`IDDealer` = `dbtemptables`.`tblricas`.`IDDealer`) 
  AND (`dbtemptables`.`tbldates_by_rep`.`IDRep` = `dbtemptables`.`tblricas`.`IDRep`) 
  AND (`dbtemptables`.`tbldates_by_rep`.`IDNetwork` = `dbtemptables`.`tblricas`.`IDNetwork`) 
  AND (`dbtemptables`.`tbldates_by_rep`.`ReportingMonth` = `dbtemptables`.`tblricas`.RicaDate) 
LEFT JOIN `dbtemptables`.`tblactivations60`
  ON (`dbtemptables`.`tbldates_by_rep`.`IDDealer` = `dbtemptables`.`tblactivations60`.`IDDealer`) 
  AND (`dbtemptables`.`tbldates_by_rep`.`IDRep` = `dbtemptables`.`tblactivations60`.`IDRep`) 
  AND (`dbtemptables`.`tbldates_by_rep`.`IDNetwork` = `dbtemptables`.`tblactivations60`.`IDNetwork`) 
  AND (`dbtemptables`.`tbldates_by_rep`.`ReportingMonth` = `dbtemptables`.`tblactivations60`.`ActivationDate`) 
LEFT JOIN `dbtemptables`.`tblactivations120_by_rep`
  ON (`dbtemptables`.`tbldates_by_rep`.`IDDealer` = `dbtemptables`.`tblactivations120_by_rep`.`IDDealer`) 
  AND (`dbtemptables`.`tbldates_by_rep`.`IDRep` = `dbtemptables`.`tblactivations120_by_rep`.`IDRep`) 
  AND (`dbtemptables`.`tbldates_by_rep`.`IDNetwork` = `dbtemptables`.`tblactivations120_by_rep`.`IDNetwork`) 
  AND (`dbtemptables`.`tbldates_by_rep`.`ReportingMonth` = `dbtemptables`.`tblactivations120_by_rep`.`ActivationDate`) 
LEFT JOIN `dbtemptables`.`tblconnections` 
  ON (`dbtemptables`.`tbldates_by_rep`.`IDDealer` = `dbtemptables`.`tblconnections`.`IDDealer`) 
  AND (`dbtemptables`.`tbldates_by_rep`.`IDRep` = `dbtemptables`.`tblconnections`.`IDRep`)  
  AND (`dbtemptables`.`tbldates_by_rep`.`IDNetwork` = `dbtemptables`.`tblconnections`.`IDNetwork`) 
  AND (`dbtemptables`.`tbldates_by_rep`.`ReportingMonth` = `dbtemptables`.`tblconnections`.ConnectionDate)
LEFT JOIN `dbtemptables`.`tblsentstock` 
  ON (`dbtemptables`.`tbldates_by_rep`.`IDDealer` = `dbtemptables`.`tblsentstock`.`IDDealer`) 
  AND (`dbtemptables`.`tbldates_by_rep`.`IDRep` = `dbtemptables`.`tblsentstock`.`IDRep`)  
  AND (`dbtemptables`.`tbldates_by_rep`.`IDNetwork` = `dbtemptables`.`tblsentstock`.`IDNetwork`) 
  AND (`dbtemptables`.`tbldates_by_rep`.`ReportingMonth` = `dbtemptables`.`tblsentstock`.`SentMonth`)
LEFT JOIN `dbtemptables`.`tblactivebase_by_rep`
  ON (`dbtemptables`.`tbldates_by_rep`.`IDDealer` = `dbtemptables`.`tblactivebase_by_rep`.`IDDealer`) 
  AND (`dbtemptables`.`tbldates_by_rep`.`IDRep` = `dbtemptables`.`tblactivebase_by_rep`.`IDRep`)  
  AND (`dbtemptables`.`tbldates_by_rep`.`IDNetwork` = `dbtemptables`.`tblactivebase_by_rep`.`IDNetwork`) 
  AND (`dbtemptables`.`tbldates_by_rep`.`ReportingMonth` = `dbtemptables`.`tblactivebase_by_rep`.`RechargeDate`)
LEFT JOIN `dbtemptables`.`tblrecharges` 
  ON (`dbtemptables`.`tbldates_by_rep`.`IDDealer` = `dbtemptables`.`tblrecharges`.`IDDealer`) 
  AND (`dbtemptables`.`tbldates_by_rep`.`IDRep` = `dbtemptables`.`tblrecharges`.`IDRep`) 
  AND (`dbtemptables`.`tbldates_by_rep`.`IDNetwork` = `dbtemptables`.`tblrecharges`.`IDNetwork`)   
  AND (`dbtemptables`.`tbldates_by_rep`.`ReportingMonth` = `dbtemptables`.`tblrecharges`.`RechargeDate`)
 LEFT JOIN `dbtemptables`.`tblsimswaps`
  ON (`dbtemptables`.`tbldates_by_rep`.`IDDealer` = `dbtemptables`.`tblsimswaps`.`IDDealer`) 
  AND (`dbtemptables`.`tbldates_by_rep`.`IDRep` = `dbtemptables`.`tblsimswaps`.`IDRep`) 
  AND (`dbtemptables`.`tbldates_by_rep`.`IDNetwork` = `dbtemptables`.`tblsimswaps`.`IDNetwork`)   
  AND (`dbtemptables`.`tbldates_by_rep`.`ReportingMonth` = `dbtemptables`.`tblsimswaps`.`SimSwapDate`)
LEFT JOIN `dbtemptables`.`tbldeletions`
  ON (`dbtemptables`.`tbldates_by_rep`.`IDDealer` = `dbtemptables`.`tbldeletions`.`IDDealer`)
  AND (`dbtemptables`.`tbldates_by_rep`.`IDRep` = `dbtemptables`.`tbldeletions`.`IDRep`) 
  AND (`dbtemptables`.`tbldates_by_rep`.`IDNetwork` = `dbtemptables`.`tbldeletions`.`IDNetwork`)   
  AND (`dbtemptables`.`tbldates_by_rep`.`ReportingMonth` = `dbtemptables`.`tbldeletions`.`DeletionDate`)
LEFT JOIN `dbtemptables`.`tblpaidactivations_by_rep`
  ON (`dbtemptables`.`tbldates_by_rep`.`IDDealer` = `dbtemptables`.`tblpaidactivations_by_rep`.`IDDealer`)
  AND (`dbtemptables`.`tbldates_by_rep`.`IDRep` = `dbtemptables`.`tblpaidactivations_by_rep`.`IDRep`) 
  AND (`dbtemptables`.`tbldates_by_rep`.`IDNetwork` = `dbtemptables`.`tblpaidactivations_by_rep`.`IDNetwork`)   
  AND (`dbtemptables`.`tbldates_by_rep`.`ReportingMonth` = `dbtemptables`.`tblpaidactivations_by_rep`.`ActualActivationDate`)
WHERE (`dbtemptables`.`tblactivations120_by_rep`.`Activations` >0
  OR `dbtemptables`.`tblactivations60`.`Activations` >0
  OR `dbtemptables`.`tblconnections`.`Connections` >0
  OR `dbtemptables`.`tblricas`.`Ricas` >0
  OR `dbtemptables`.`tblsentstock`.`Sent` >0
  OR `dbtemptables`.`tblrecharges`.`Recharges` >0
  OR `dbtemptables`.`tblsimswaps`.`SimSwaps`>0
  OR `dbtemptables`.`tbldeletions`.`Deletions`>0
  OR `dbtemptables`.`tblactivebase_by_rep`.`ActBase` >0
  OR `dbtemptables`.`tblpaidactivations_by_rep`.`PaidActivations` >0);

# SELECT `dbtemptables`.`tbltotals`.* FROM `dbtemptables`.`tbltotals`;

# -- Clear Scrapo Dealers by Rep by Month by Network
SELECT "Clearing Scrapo Dealers by Rep by Month by Network" AS '';
DELETE `dbpavweb`.`tblweb_scrapo_reps_by_month_by_network`.* FROM `dbpavweb`.`tblweb_scrapo_reps_by_month_by_network`;

# -- Insert Scrapo Dealers by Rep by Month by Network
SELECT "Inserting Scrapo Dealers by Rep by Month by Network" AS '';
INSERT INTO `dbpavweb`.`tblweb_scrapo_reps_by_month_by_network` (IDDealer,IDRep, IDNetwork,ReportMonth,Sent,Ricas,Connections,Activations,Activations120,ActBase, Recharges, Simswaps, Deletions )
SELECT `dbtemptables`.`tbltotals`.`IDDealer`,`dbtemptables`.`tbltotals`.`IDRep`,`dbtemptables`.`tbltotals`.`IDNetwork`,`dbtemptables`.`tbltotals`.`ReportMonth`,`dbtemptables`.`tbltotals`.`Sent`,
`dbtemptables`.`tbltotals`.`Ricas`,`dbtemptables`.`tbltotals`.`Connections`,`dbtemptables`.`tbltotals`.`Activations60`, `dbtemptables`.`tbltotals`.`Activations120`,`dbtemptables`.`tbltotals`.`NetBase`,
`dbtemptables`.`tbltotals`.`Recharges`,`dbtemptables`.`tbltotals`.`SimSwaps`,`dbtemptables`.`tbltotals`.`Deletions`
FROM `dbtemptables`.`tbltotals`;
# -- Show the Appended Data
# SELECT `dbpavweb`.`tblweb_scrapo_reps_by_month_by_network`.* FROM `dbpavweb`.`tblweb_scrapo_reps_by_month_by_network` LIMIT 6;

# -- Clear Scrapo Dealers by Rep by Month
SELECT "Clearing Scrapo Dealers by Rep by Month" AS '';
DELETE `dbpavweb`.`tblweb_scrapo_reps_by_month`.* FROM `dbpavweb`.`tblweb_scrapo_reps_by_month`;

# -- Insert Scrapo Dealers by Rep by Month by Network
SELECT "Inserting Scrapo Dealers by Rep by Month by Network" AS '';
INSERT INTO `dbpavweb`.`tblweb_scrapo_reps_by_month` (IDDealer, IDRep, ReportMonth,Sent,Ricas,Connections,Activations,Activations120,ActBase,Recharges,Simswaps,Deletions)
SELECT `dbtemptables`.`tbltotals`.`IDDealer`,`dbtemptables`.`tbltotals`.`IDRep`,`dbtemptables`.`tbltotals`.`ReportMonth`,SUM(`dbtemptables`.`tbltotals`.`Sent`) AS SENT,
SUM(`dbtemptables`.`tbltotals`.`Ricas`) AS RICAS, SUM(`dbtemptables`.`tbltotals`.`Connections`) AS CONNECTIONS,
SUM(`dbtemptables`.`tbltotals`.`Activations60`) AS ACT, SUM(`dbtemptables`.`tbltotals`.`Activations120`) AS ACT120, 
SUM(`dbtemptables`.`tbltotals`.`NetBase`) AS ACTBASE, SUM(`dbtemptables`.`tbltotals`.`Recharges`) AS RECHARGES,
COUNT(`dbtemptables`.`tbltotals`.`SimSwaps`) AS SIMSWAPS ,COUNT(`dbtemptables`.`tbltotals`.`Deletions`) AS DELETIONS
FROM `dbtemptables`.`tbltotals`
GROUP BY `dbtemptables`.`tbltotals`.`IDDealer`,`dbtemptables`.`tbltotals`.`IDRep`,`dbtemptables`.`tbltotals`.`ReportMonth`;
# -- Show the Appended Data
# SELECT `dbpavweb`.`tblweb_scrapo_reps_by_month`.* FROM `dbpavweb`.`tblweb_scrapo_reps_by_month` LIMIT 6;


## -------------------------------------------------------------------------------------------------------------------------------------------------------- ##
##                                                                D E A L E R   B Y   A G E N T                                                             ##
## -------------------------------------------------------------------------------------------------------------------------------------------------------- ##

# -- Clear AGENT temp tables -- #
SELECT "Clearing AGENT temp tables" AS '';
DELETE `dbtemptables`.`tblactivations_by_agent`.* FROM `dbtemptables`.`tblactivations_by_agent`;
DELETE `dbtemptables`.`tblconnections_by_agent`.* FROM `dbtemptables`.`tblconnections_by_agent`;
DELETE `dbtemptables`.`tbldates_by_agent`.* FROM `dbtemptables`.`tbldates_by_agent`;
DELETE `dbtemptables`.`tbldeletions_by_agent`.* FROM `dbtemptables`.`tbldeletions_by_agent`;
DELETE `dbtemptables`.`tblpaidactivations_by_agent`.* FROM `dbtemptables`.`tblpaidactivations_by_agent`;
DELETE `dbtemptables`.`tblrecharges_by_agent`.* FROM `dbtemptables`.`tblrecharges_by_agent`;
DELETE `dbtemptables`.`tblricas_by_agent`.* FROM `dbtemptables`.`tblricas_by_agent`;
DELETE `dbtemptables`.`tblsimswaps_by_agent`.* FROM `dbtemptables`.`tblsimswaps_by_agent`;
DELETE `dbtemptables`.`tbltotals_by_agent`.* FROM `dbtemptables`.`tbltotals_by_agent`;

# -- Create Activations by Dealer by Agent by Network
SELECT "Creating Activations by Dealer by Agent by Network" AS '';
INSERT INTO `dbtemptables`.`tblactivations_by_agent` ( IDDealer, AgentMSISDN, IDNetwork, ActivationDate, Activations  )
SELECT `scandb`.`tblInvoices`.`IDDealer`,`scandb`.`tblstarterpacks`.`RicaAgentMSISDN`,`scandb`.`tblNetworks`.`IDNetwork`, 
LAST_DAY(`scandb`.`tblstarterpacks`.`ActivationDate`) AS ActivationDate, 
COUNT(`scandb`.`tblStarterPacks`.`ActivationDate`) AS Activations 
FROM `scandb`.`tblInvoices`
INNER JOIN `scandb`.`tblinvoicedetail` ON `scandb`.`tblinvoices`.`IDInv` = `scandb`.`tblinvoicedetail`.`IDInv`
INNER JOIN `scandb`.`tblboxes` ON `scandb`.`tblInvoicedetail`.`IDBox` = `scandb`.`tblboxes`.`IDBox`
INNER JOIN `scandb`.`tblnetworks` ON `scandb`.`tblboxes`.`IDNetwork` = `scandb`.`tblnetworks`.`IDNetwork`
INNER JOIN `scandb`.`tblstarterpacks` ON `scandb`.`tblboxes`.`IDBox` = `scandb`.`tblstarterpacks`.`IDBox`
WHERE (`scandb`.`tblstarterpacks`.`ActivationDate` > LAST_DAY(DATE_SUB(CURDATE(), INTERVAL 5 MONTH)) AND `scandb`.`tblstarterpacks`.`RicaAgentMSISDN` IS NOT NULL)
GROUP BY `scandb`.`tblInvoices`.`IDDealer`,`scandb`.`tblstarterpacks`.`RicaAgentMSISDN`, `scandb`.`tblNetworks`.`IDNetwork`, LAST_DAY(`scandb`.`tblstarterpacks`.`ActivationDate`)
HAVING Activations >0;

# SELECT `dbtemptables`.`tblactivations_by_agent`.* FROM `dbtemptables`.`tblactivations_by_agent` LIMIT 5;

# -- Create PAID Activations by Dealer by Agent by Network
SELECT "Creating PAID Activations by Dealer by Agent by Network" AS '';
INSERT INTO `dbtemptables`.`tblpaidactivations_by_agent` ( IDDealer, IDNetwork, AgentMSISDN, ActivationDate, Activations  )
SELECT `scandb`.`tblInvoices`.`IDDealer`,`scandb`.`tblNetworks`.`IDNetwork`, `scandb`.`tblstarterpacks`.`RicaAgentMSISDN`,
LAST_DAY(`scandb`.`tblstarterpacks`.`ActualActivationDate`) AS ActivationDate, 
COUNT(`scandb`.`tblStarterPacks`.`AgentPaidDate`) AS Activations 
FROM `scandb`.`tblInvoices`
INNER JOIN `scandb`.`tblinvoicedetail` ON `scandb`.`tblinvoices`.`IDInv` = `scandb`.`tblinvoicedetail`.`IDInv`
INNER JOIN `scandb`.`tblboxes` ON `scandb`.`tblInvoicedetail`.`IDBox` = `scandb`.`tblboxes`.`IDBox`
INNER JOIN `scandb`.`tblnetworks` ON `scandb`.`tblboxes`.`IDNetwork` = `scandb`.`tblnetworks`.`IDNetwork`
INNER JOIN `scandb`.`tblstarterpacks` ON `scandb`.`tblboxes`.`IDBox` = `scandb`.`tblstarterpacks`.`IDBox`
WHERE (`scandb`.`tblstarterpacks`.`ActualActivationDate` > LAST_DAY(DATE_SUB(CURDATE(), INTERVAL 5 MONTH)) AND `scandb`.`tblstarterpacks`.`RicaAgentMSISDN` IS NOT NULL)
GROUP BY `scandb`.`tblInvoices`.`IDDealer`,`scandb`.`tblstarterpacks`.`RicaAgentMSISDN`, `scandb`.`tblNetworks`.`IDNetwork`, LAST_DAY(`scandb`.`tblstarterpacks`.`ActualActivationDate`)
HAVING Activations >0;

# SELECT `dbtemptables`.`tblpaidactivations`.* FROM `dbtemptables`.`tblpaidactivations` LIMIT 15;

# -- Create Connections by Dealer by Agent by Network
SELECT "Creating Connections by Dealer by Agent by Network" AS '';
INSERT INTO `dbtemptables`.`tblconnections_by_agent` ( IDDealer, AgentMSISDN, IDNetwork, ConnectionDate, Connections  )
SELECT `scandb`.`tblInvoices`.`IDDealer`,`scandb`.`tblstarterpacks`.`RicaAgentMSISDN`, `scandb`.`tblNetworks`.`IDNetwork`, LAST_DAY(`scandb`.`tblstarterpacks`.`ConnectionDate`), 
COUNT(`scandb`.`tblStarterPacks`.`ConnectionDate`) AS Connections
FROM `scandb`.`tblInvoices` 
INNER JOIN `scandb`.`tblinvoicedetail` ON `scandb`.`tblinvoices`.`IDInv` = `scandb`.`tblinvoicedetail`.`IDInv`
INNER JOIN `scandb`.`tblboxes` ON `scandb`.`tblInvoicedetail`.`IDBox` = `scandb`.`tblboxes`.`IDBox`
INNER JOIN `scandb`.`tblnetworks` ON `scandb`.`tblboxes`.`IDNetwork` = `scandb`.`tblnetworks`.`IDNetwork`
INNER JOIN `scandb`.`tblstarterpacks` ON `scandb`.`tblboxes`.`IDBox` = `scandb`.`tblstarterpacks`.`IDBox`
WHERE (`scandb`.`tblstarterpacks`.`ConnectionDate` > LAST_DAY(DATE_SUB(CURDATE(), INTERVAL 5 MONTH)) AND `scandb`.`tblstarterpacks`.`RicaAgentMSISDN` IS NOT NULL)
GROUP BY `scandb`.`tblInvoices`.`IDDealer`,`scandb`.`tblstarterpacks`.`RicaAgentMSISDN`,`scandb`.`tblNetworks`.`IDNetwork`, LAST_DAY(`scandb`.`tblstarterpacks`.`ConnectionDate`)
HAVING Connections >0;

# SELECT `dbtemptables`.`tblconnections_by_agent`.* FROM `dbtemptables`.`tblconnections_by_agent` LIMIT 24;

# -- Create RICAs by Dealer by Agent by Network
SELECT "Creating RICAs by Dealer by Agent by Network" AS '';
INSERT INTO `dbtemptables`.`tblricas_by_agent` ( IDDealer, AgentMSISDN, IDNetwork, RicaDate, Ricas  )
SELECT `scandb`.`tblInvoices`.`IDDealer`,`scandb`.`tblstarterpacks`.`RicaAgentMSISDN`, `scandb`.`tblNetworks`.`IDNetwork`, 
LAST_DAY(`scandb`.`tblstarterpacks`.`RicaDate`), 
COUNT(`scandb`.`tblStarterPacks`.`RicaDate`) AS Ricas 
FROM `scandb`.`tblInvoices` 
INNER JOIN `scandb`.`tblinvoicedetail` ON `scandb`.`tblinvoices`.`IDInv` = `scandb`.`tblinvoicedetail`.`IDInv`
INNER JOIN `scandb`.`tblboxes` ON `scandb`.`tblInvoicedetail`.`IDBox` = `scandb`.`tblboxes`.`IDBox`
INNER JOIN `scandb`.`tblnetworks` ON `scandb`.`tblboxes`.`IDNetwork` = `scandb`.`tblnetworks`.`IDNetwork`
INNER JOIN `scandb`.`tblstarterpacks` ON `scandb`.`tblboxes`.`IDBox` = `scandb`.`tblstarterpacks`.`IDBox`
WHERE (`scandb`.`tblstarterpacks`.`RicaDate` > LAST_DAY(DATE_SUB(CURDATE(), INTERVAL 5 MONTH)) AND `scandb`.`tblstarterpacks`.`RicaAgentMSISDN` IS NOT NULL)
GROUP BY `scandb`.`tblInvoices`.`IDDealer`,`scandb`.`tblstarterpacks`.`RicaAgentMSISDN`, `scandb`.`tblNetworks`.`IDNetwork`, LAST_DAY(`scandb`.`tblstarterpacks`.`RicaDate`)
HAVING Ricas >0;
# SELECT `dbtemptables`.`tblricas`.* FROM `dbtemptables`.`tblricas` LIMIT 15;

# -- Create Deletions by Dealer by Agent by Network
SELECT "Creating Deletions by Dealer by Agent by Network" AS '';
INSERT INTO `dbtemptables`.`tbldeletions_by_agent` ( IDDealer, AgentMSISDN, IDNetwork, DeletionDate, Deletions  )
SELECT `scandb`.`tblInvoices`.`IDDealer`,`scandb`.`tblstarterpacks`.`RicaAgentMSISDN`, `scandb`.`tblNetworks`.`IDNetwork`, 
LAST_DAY(`scandb`.`tblstarterpacks`.`DeletionDate`) AS DeletionDate, 
COUNT(`scandb`.`tblStarterPacks`.`DeletionDate`) AS Deletions
FROM `scandb`.`tblInvoices` 
INNER JOIN `scandb`.`tblinvoicedetail` ON `scandb`.`tblinvoices`.`IDInv` = `scandb`.`tblinvoicedetail`.`IDInv`
INNER JOIN `scandb`.`tblboxes` ON `scandb`.`tblInvoicedetail`.`IDBox` = `scandb`.`tblboxes`.`IDBox`
INNER JOIN `scandb`.`tblnetworks` ON `scandb`.`tblboxes`.`IDNetwork` = `scandb`.`tblnetworks`.`IDNetwork`
INNER JOIN `scandb`.`tblstarterpacks` ON `scandb`.`tblboxes`.`IDBox` = `scandb`.`tblstarterpacks`.`IDBox`
WHERE (`scandb`.`tblstarterpacks`.`DeletionDate` > LAST_DAY(DATE_SUB(CURDATE(), INTERVAL 5 MONTH)) AND `scandb`.`tblstarterpacks`.`RicaAgentMSISDN` IS NOT NULL)
GROUP BY `scandb`.`tblInvoices`.`IDDealer`,`scandb`.`tblstarterpacks`.`RicaAgentMSISDN`,`scandb`.`tblNetworks`.`IDNetwork`, LAST_DAY(`scandb`.`tblstarterpacks`.`DeletionDate`)
HAVING DELETIONS >0;

# -- Create Ongoing Recharges by Dealer by Agent by Network
SELECT "Creating Ongoing Recharges by Dealer by Agent by Network" AS '';
INSERT INTO `dbtemptables`.`tblrecharges_by_agent` ( IDDealer, AgentMSISDN, IDNetwork, RechargeDate, Recharges  )
SELECT `scandb`.`tblInvoices`.`IDDealer`,`scandb`.`tblstarterpacks`.`RicaAgentMSISDN`, `scandb`.`tblNetworks`.`IDNetwork`, 
LAST_DAY(`scandb`.`tblongoing`.`RechargeDate`) AS RechargeDate, 
SUM(`scandb`.`tblongoing`.`RechargeAmount`) AS Recharges 
FROM `scandb`.`tblInvoices` 
INNER JOIN `scandb`.`tblinvoicedetail` ON `scandb`.`tblinvoices`.`IDInv` = `scandb`.`tblinvoicedetail`.`IDInv`
INNER JOIN `scandb`.`tblboxes` ON `scandb`.`tblInvoicedetail`.`IDBox` = `scandb`.`tblboxes`.`IDBox`
INNER JOIN `scandb`.`tblnetworks` ON `scandb`.`tblboxes`.`IDNetwork` = `scandb`.`tblnetworks`.`IDNetwork`
INNER JOIN `scandb`.`tblstarterpacks` ON `scandb`.`tblboxes`.`IDBox` = `scandb`.`tblstarterpacks`.`IDBox`
INNER JOIN `scandb`.`tblongoing` ON `scandb`.`tblongoing`.`IDStarterpack` = `scandb`.`tblstarterpacks`.`IDStarterPack` 
WHERE (`scandb`.`tblongoing`.`RechargeDate` > LAST_DAY(DATE_SUB(CURDATE(), INTERVAL 5 MONTH)) AND `scandb`.`tblstarterpacks`.`RicaAgentMSISDN` IS NOT NULL)
GROUP BY `scandb`.`tblInvoices`.`IDDealer`,`scandb`.`tblstarterpacks`.`RicaAgentMSISDN`, `scandb`.`tblNetworks`.`IDNetwork`, LAST_DAY(`scandb`.`tblongoing`.`RechargeDate`)
HAVING Recharges >0;

/* SELECT `dbtemptables`.`tblrecharges`.`IDDealer`,`dbtemptables`.`tblrecharges`.`AgentMSISDN`,`dbtemptables`.`tblrecharges`.`RechargeDate`, SUM(`dbtemptables`.`tblrecharges`.`Recharges`) AS Recharges FROM `dbtemptables`.`tblrecharges` 
GROUP BY `dbtemptables`.`tblrecharges`.`IDDealer`,`dbtemptables`.`tblrecharges`.`AgentMSISDN`,`dbtemptables`.`tblrecharges`.`RechargeDate`;
*/

# -- Clear `dbtemptables`.`tbldates`
SELECT "Clearing `dbtemptables`.`tbldates`" AS '';
DELETE `dbtemptables`.`tbldates_by_agent`.* FROM `dbtemptables`.`tbldates_by_agent`;

# -- Append DealerDates - Now minus 5 months
SELECT "Appending DealerDates - Now minus 5 months" AS '';
INSERT INTO `dbtemptables`.`tbldates_by_agent` (IDDealer, AgentMSISDN, IDNetwork, ReportingMonth)
SELECT `scandb`.`tblInvoices`.`IDDealer`,`scandb`.`tblstarterpacks`.`RicaAgentMSISDN`, `scandb`.`tblNetworks`.`IDNetwork`, LAST_DAY(DATE_SUB(CURDATE(), INTERVAL 5 MONTH)) AS ReportingMonth
FROM `scandb`.`tblInvoices` 
INNER JOIN `scandb`.`tblinvoicedetail` ON `scandb`.`tblInvoices`.`IDInv` = `scandb`.`tblinvoicedetail`.`IDInv`
INNER JOIN `scandb`.`tblBoxes` ON `scandb`.`tblBoxes`.`IDBox` = `scandb`.`tblInvoiceDetail`.`IDBox`
INNER JOIN `scandb`.`tblstarterpacks` ON `scandb`.`tblBoxes`.`IDBox` = `scandb`.`tblstarterpacks`.`IDBox`
INNER JOIN `scandb`.`tblNetworks` ON `tblBoxes`.`IDNetwork` = `scandb`.`tblNetworks`.`IDNetwork`
WHERE `scandb`.`tblstarterpacks`.`RicaAgentMSISDN` IS NOT NULL
GROUP BY `scandb`.`tblInvoices`.`IDDealer`,`scandb`.`tblstarterpacks`.`RicaAgentMSISDN`, `scandb`.`tblNetworks`.`IDNetwork`, LAST_DAY(DATE_SUB(CURDATE(), INTERVAL 5 MONTH));

# -- Append DealerDates by Agent - Now minus 4 months
SELECT "Appending DealerDates - Now minus 4 months" AS '';
INSERT INTO `dbtemptables`.`tbldates_by_agent_to_append`(IDDealer, AgentMSISDN, IDNetwork, ReportingMonth)
SELECT `dbtemptables`.`tbldates_by_agent`.`IDDealer`,`dbtemptables`.`tbldates_by_agent`.`AgentMSISDN`, `dbtemptables`.`tbldates_by_agent`.`IDNetwork`, 
LAST_DAY(DATE_SUB(CURDATE(), INTERVAL 4 MONTH)) AS ReportingMonth
FROM `dbtemptables`.`tbldates_by_agent`;

# -- Append DealerDates by Agent - Now minus 3 months
SELECT "Appending DealerDates - Now minus 3 months" AS '';
INSERT INTO `dbtemptables`.`tbldates_by_agent_to_append`(IDDealer, AgentMSISDN, IDNetwork, ReportingMonth)
SELECT `dbtemptables`.`tbldates_by_agent`.`IDDealer`,`dbtemptables`.`tbldates_by_agent`.`AgentMSISDN`, `dbtemptables`.`tbldates_by_agent`.`IDNetwork`, 
LAST_DAY(DATE_SUB(CURDATE(), INTERVAL 3 MONTH)) AS ReportingMonth
FROM `dbtemptables`.`tbldates_by_agent`;

# SELECT `dbtemptables`.`tbldates_by_agent`.`ReportingMonth` FROM `dbtemptables`.`tbldates_by_agent` GROUP BY `dbtemptables`.`tbldates_by_agent`.`ReportingMonth`;

# -- Append DealerDates by Agent - Now minus 2 months
SELECT "Appending DealerDates - Now minus 2 months" AS '';
INSERT INTO `dbtemptables`.`tbldates_by_agent_to_append`(IDDealer, AgentMSISDN, IDNetwork, ReportingMonth)
SELECT `dbtemptables`.`tbldates_by_agent`.`IDDealer`,`dbtemptables`.`tbldates_by_agent`.`AgentMSISDN`, `dbtemptables`.`tbldates_by_agent`.`IDNetwork`, 
LAST_DAY(DATE_SUB(CURDATE(), INTERVAL 2 MONTH)) AS ReportingMonth
FROM `dbtemptables`.`tbldates_by_agent`;

# -- Append DealerDates by Agent - Now minus 1 month
SELECT "Appending DealerDates - Now minus 1 months" AS '';
INSERT INTO `dbtemptables`.`tbldates_by_agent_to_append`(IDDealer, AgentMSISDN, IDNetwork, ReportingMonth)
SELECT `dbtemptables`.`tbldates_by_agent`.`IDDealer`,`dbtemptables`.`tbldates_by_agent`.`AgentMSISDN`, `dbtemptables`.`tbldates_by_agent`.`IDNetwork`, 
LAST_DAY(DATE_SUB(CURDATE(), INTERVAL 1 MONTH)) AS ReportingMonth
FROM `dbtemptables`.`tbldates_by_agent`;

# -- Append DealerDates by Agent - Now 
SELECT "Appending DealerDates - This month" AS '';
INSERT INTO `dbtemptables`.`tbldates_by_agent_to_append`(IDDealer, AgentMSISDN, IDNetwork, ReportingMonth)
SELECT `dbtemptables`.`tbldates_by_agent`.`IDDealer`,`dbtemptables`.`tbldates_by_agent`.`AgentMSISDN`, `dbtemptables`.`tbldates_by_agent`.`IDNetwork`, 
LAST_DAY(CURDATE()) AS ReportingMonth
FROM `dbtemptables`.`tbldates_by_agent`;

# -- Append the Appended Dates to the MAIN dates -- #
SELECT "Appending the Appended Dates to the MAIN dates" AS '';
INSERT INTO `dbtemptables`.`tbldates_by_agent`(IDDealer, AgentMSISDN, IDNetwork, ReportingMonth)
SELECT `dbtemptables`.`tbldates_by_agent_to_append`.`IDDealer`,`dbtemptables`.`tbldates_by_agent_to_append`.`AgentMSISDN`, `dbtemptables`.`tbldates_by_agent_to_append`.`IDNetwork`, 
`dbtemptables`.`tbldates_by_agent_to_append`.`ReportingMonth`
FROM `dbtemptables`.`tbldates_by_agent_to_append`;

# -- Clear the Appended Dates table after use -- #
SELECT "Clearing the Appended Dates table after use" AS '';
DELETE `dbtemptables`.`tbldates_by_agent_to_append`.* FROM `dbtemptables`.`tbldates_by_agent_to_append`;

# -- Clear DealerTotals
SELECT "Clearing DealerTotals" AS '';
DELETE `dbtemptables`.`tbltotals_by_agent`.* FROM `dbtemptables`.`tbltotals_by_agent`;

# -- Insert Dealer by Agent Totals
SELECT "Inserting Dealer by Agent Totals" AS '';
INSERT INTO `dbtemptables`.`tbltotals_by_agent` (IDDealer, AgentMSISDN, IDNetwork, ReportMonth, Ricas, Connections, Activations60, PaidActivations, Recharges, Deletions)
SELECT `dbtemptables`.`tbldates_by_agent`.`IDDealer`,`dbtemptables`.`tbldates_by_agent`.`AgentMSISDN`,`tbldates_by_agent`.`IDNetwork`,DATE_FORMAT(`dbtemptables`.`tbldates_by_agent`.`ReportingMonth`,'%Y/%m'),
`dbtemptables`.`tblricas_by_agent`.`Ricas`,`dbtemptables`.`tblconnections_by_agent`.`Connections`,`dbtemptables`.`tblactivations_by_agent`.`Activations`,
`dbtemptables`.`tblpaidactivations_by_agent`.`Activations`,`dbtemptables`.`tblrecharges_by_agent`.`Recharges`, `dbtemptables`.`tbldeletions_by_agent`.`Deletions`
FROM `dbtemptables`.`tbldates_by_agent` 
LEFT JOIN `dbtemptables`.`tblricas_by_agent` 
  ON (`dbtemptables`.`tbldates_by_agent`.`IDDealer` = `dbtemptables`.`tblricas_by_agent`.`IDDealer`) 
  AND (`dbtemptables`.`tbldates_by_agent`.`AgentMSISDN` = `dbtemptables`.`tblricas_by_agent`.`AgentMSISDN`) 
  AND (`dbtemptables`.`tbldates_by_agent`.`IDNetwork` = `dbtemptables`.`tblricas_by_agent`.`IDNetwork`) 
  AND (`dbtemptables`.`tbldates_by_agent`.`ReportingMonth` = `dbtemptables`.`tblricas_by_agent`.RicaDate) 
LEFT JOIN `dbtemptables`.`tblconnections_by_agent` 
  ON (`dbtemptables`.`tbldates_by_agent`.`IDDealer` = `dbtemptables`.`tblconnections_by_agent`.`IDDealer`) 
  AND (`dbtemptables`.`tbldates_by_agent`.`AgentMSISDN` = `dbtemptables`.`tblconnections_by_agent`.`AgentMSISDN`)  
  AND (`dbtemptables`.`tbldates_by_agent`.`IDNetwork` = `dbtemptables`.`tblconnections_by_agent`.`IDNetwork`) 
  AND (`dbtemptables`.`tbldates_by_agent`.`ReportingMonth` = `dbtemptables`.`tblconnections_by_agent`.ConnectionDate)
LEFT JOIN `dbtemptables`.`tblactivations_by_agent`
  ON (`dbtemptables`.`tbldates_by_agent`.`IDDealer` = `dbtemptables`.`tblactivations_by_agent`.`IDDealer`) 
  AND (`dbtemptables`.`tbldates_by_agent`.`AgentMSISDN` = `dbtemptables`.`tblactivations_by_agent`.`AgentMSISDN`) 
  AND (`dbtemptables`.`tbldates_by_agent`.`IDNetwork` = `dbtemptables`.`tblactivations_by_agent`.`IDNetwork`) 
  AND (`dbtemptables`.`tbldates_by_agent`.`ReportingMonth` = `dbtemptables`.`tblactivations_by_agent`.`ActivationDate`)
LEFT JOIN `dbtemptables`.`tblpaidactivations_by_agent`
  ON (`dbtemptables`.`tbldates_by_agent`.`IDDealer` = `dbtemptables`.`tblpaidactivations_by_agent`.`IDDealer`) 
  AND (`dbtemptables`.`tbldates_by_agent`.`AgentMSISDN` = `dbtemptables`.`tblpaidactivations_by_agent`.`AgentMSISDN`) 
  AND (`dbtemptables`.`tbldates_by_agent`.`IDNetwork` = `dbtemptables`.`tblpaidactivations_by_agent`.`IDNetwork`) 
  AND (`dbtemptables`.`tbldates_by_agent`.`ReportingMonth` = `dbtemptables`.`tblpaidactivations_by_agent`.`ActivationDate`)
LEFT JOIN `dbtemptables`.`tblrecharges_by_agent` 
  ON (`dbtemptables`.`tbldates_by_agent`.`IDDealer` = `dbtemptables`.`tblrecharges_by_agent`.`IDDealer`) 
  AND (`dbtemptables`.`tbldates_by_agent`.`AgentMSISDN` = `dbtemptables`.`tblrecharges_by_agent`.`AgentMSISDN`) 
  AND (`dbtemptables`.`tbldates_by_agent`.`IDNetwork` = `dbtemptables`.`tblrecharges_by_agent`.`IDNetwork`)   
  AND (`dbtemptables`.`tbldates_by_agent`.`ReportingMonth` = `dbtemptables`.`tblrecharges_by_agent`.`RechargeDate`)
LEFT JOIN `dbtemptables`.`tbldeletions_by_agent`
  ON (`dbtemptables`.`tbldates_by_agent`.`IDDealer` = `dbtemptables`.`tbldeletions_by_agent`.`IDDealer`) 
  AND (`dbtemptables`.`tbldates_by_agent`.`AgentMSISDN` = `dbtemptables`.`tbldeletions_by_agent`.`AgentMSISDN`) 
  AND (`dbtemptables`.`tbldates_by_agent`.`IDNetwork` = `dbtemptables`.`tbldeletions_by_agent`.`IDNetwork`)   
  AND (`dbtemptables`.`tbldates_by_agent`.`ReportingMonth` = `dbtemptables`.`tbldeletions_by_agent`.`DeletionDate`)
WHERE (`dbtemptables`.`tblricas_by_agent`.`Ricas` >0
OR `dbtemptables`.`tblconnections_by_agent`.`Connections` >0
OR `dbtemptables`.`tblactivations_by_agent`.`Activations` >0
OR `dbtemptables`.`tblpaidactivations_by_agent`.`Activations` >0
OR `dbtemptables`.`tblrecharges_by_agent`.`Recharges` >0
OR `dbtemptables`.`tbldeletions_by_agent`.`Deletions`>0);

# SELECT `dbtemptables`.`tbltotals_by_agent`.* FROM `dbtemptables`.`tbltotals_by_agent`;


# -- Clear Scrapo Dealers by Agent by Month by Network
SELECT "Clearing Scrapo Dealers by Agent by Month by Network" AS '';
DELETE `dbpavweb`.`tblweb_scrapo_agents_by_month_by_network`.* FROM `dbpavweb`.`tblweb_scrapo_agents_by_month_by_network`;

# -- Insert Scrapo Dealers by Rep by Month by Network
SELECT "Inserting Scrapo Dealers by Rep by Month by Network" AS '';
INSERT INTO `dbpavweb`.`tblweb_scrapo_agents_by_month_by_network` (IDDealer,AgentMSISDN,IDNetwork,ReportMonth,Ricas,Connections,Activations,PaidActivations,Recharges, Deletions)
SELECT `dbtemptables`.`tbltotals_by_agent`.`IDDealer`,`dbtemptables`.`tbltotals_by_agent`.`AgentMSISDN`,`dbtemptables`.`tbltotals_by_agent`.`IDNetwork`,`dbtemptables`.`tbltotals_by_agent`.`ReportMonth`,
`dbtemptables`.`tbltotals_by_agent`.`Ricas`,`dbtemptables`.`tbltotals_by_agent`.`Connections`,`dbtemptables`.`tbltotals_by_agent`.`Activations60`,
`dbtemptables`.`tbltotals_by_agent`.`PaidActivations`,`dbtemptables`.`tbltotals_by_agent`.`Recharges`,`dbtemptables`.`tbltotals_by_agent`.`Deletions`
FROM `dbtemptables`.`tbltotals_by_agent`;
# -- Show the Appended Data
# SELECT `dbpavweb`.`tblweb_scrapo_agents_by_month_by_network`.* FROM `dbpavweb`.`tblweb_scrapo_agents_by_month_by_network` LIMIT 6;

# -- Clear Scrapo Dealers by Agents by Month
SELECT "Clearing Scrapo Dealers by Agents by Month" AS '';
DELETE `dbpavweb`.`tblweb_scrapo_agents_by_month`.* FROM `dbpavweb`.`tblweb_scrapo_agents_by_month`;
# -- Insert Scrapo Dealers by Agent by Month by Network
INSERT INTO `dbpavweb`.`tblweb_scrapo_agents_by_month` (IDDealer,AgentMSISDN,ReportMonth,Ricas,Connections,Activations,PaidActivations,Recharges,Deletions)
SELECT `dbtemptables`.`tbltotals_by_agent`.`IDDealer`,`dbtemptables`.`tbltotals_by_agent`.`AgentMSISDN`,`dbtemptables`.`tbltotals_by_agent`.`ReportMonth`,
SUM(`dbtemptables`.`tbltotals_by_agent`.`Ricas`) AS Ricas,SUM(`dbtemptables`.`tbltotals_by_agent`.`Connections`) AS Connections,SUM(`dbtemptables`.`tbltotals_by_agent`.`Activations60`) AS Activations,
SUM(`dbtemptables`.`tbltotals_by_agent`.`PaidActivations`) AS PaidAct,SUM(`dbtemptables`.`tbltotals_by_agent`.`Recharges`) AS Recharges,SUM(`dbtemptables`.`tbltotals_by_agent`.`Deletions`) AS Deletions
FROM `dbtemptables`.`tbltotals_by_agent`
GROUP BY `dbtemptables`.`tbltotals_by_agent`.`IDDealer`,`dbtemptables`.`tbltotals_by_agent`.`AgentMSISDN`,`dbtemptables`.`tbltotals_by_agent`.`ReportMonth`
HAVING Ricas > 0 OR connections >0 OR Activations >0 OR PaidAct >0 OR Recharges >0 OR Deletions >0;
# -- Show the Appended Data
# SELECT `dbpavweb`.`tblweb_scrapo_agents_by_month`.* FROM `dbpavweb`.`tblweb_scrapo_agents_by_month` LIMIT 6;

# -- Append Payout History -- #
SELECT "Appending Payout History" AS '';
INSERT INTO `dbpavweb`.`tblwebpayout_history` (IDDealer,Network,PayMonth,Activations,Act_Bonus,Act_Excl_Vat,
Act_Incl_VAT,Recharges,RebatePercentage,VL_Excl_VAT,VL_Incl_VAT,Total_Excl_VAT,Total_Incl_VAT)
SELECT DISTINCT `scandb`.`tbldealers`.`IDDealer`,`scandb`.`rptpayoutsheet`.`Network`,`scandb`.`rptpayoutsheet`.`PayMonth`,
`scandb`.`rptpayoutsheet`.`Activations`,`scandb`.`rptpayoutsheet`.`Act_Bonus`,`scandb`.`rptpayoutsheet`.`Act_Excl_Vat`,`scandb`.`rptpayoutsheet`.`Act_Incl_VAT`,
`scandb`.`rptpayoutsheet`.`Recharges`,`scandb`.`rptpayoutsheet`.`RebatePercentage`,`scandb`.`rptpayoutsheet`.`VL_Excl_VAT`,`scandb`.`rptpayoutsheet`.`VL_Incl_VAT`,
`scandb`.`rptpayoutsheet`.`Total Excl VAT`,`scandb`.`rptpayoutsheet`.`Total Incl VAT`
FROM `scandb`.`tbldealers`
INNER JOIN `scandb`.`rptpayoutsheet` ON `scandb`.`tbldealers`.`DealerName` = `scandb`.`rptpayoutsheet`.`Dealer`
WHERE `scandb`.`rptpayoutsheet`.`PayMonth` IS NOT NULL;