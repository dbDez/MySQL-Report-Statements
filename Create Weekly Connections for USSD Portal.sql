#-- 1
DELETE `dbpavweb`.`tblwebconnections_by_dealer_by_month`.* FROM `dbpavweb`.`tblwebconnections_by_dealer_by_month`;
# --2
DELETE `dbpavweb`.`tblwebconnections_by_dealer_by_month_by_network`.* FROM `dbpavweb`.`tblwebconnections_by_dealer_by_month_by_network`;
# --3
DELETE `dbpavweb`.`tblwebconnections_by_dealer_by_month_by_network_ytd`.* FROM `dbpavweb`.`tblwebconnections_by_dealer_by_month_by_network_ytd`;
# --4
DELETE `dbpavweb`.`tblwebconnections_by_dealer_by_week`.* FROM `dbpavweb`.`tblwebconnections_by_dealer_by_week`;
# --5
DELETE `dbpavweb`.`tblwebconnections_by_dealer_by_week_by_network`.* FROM `dbpavweb`.`tblwebconnections_by_dealer_by_week_by_network`;
# --6
DELETE `dbpavweb`.`tblwebconnections_by_rep_by_month_by_network`.* FROM `dbpavweb`.`tblwebconnections_by_rep_by_month_by_network`;
# --7
DELETE `dbpavweb`.`tblwebconnections_by_rep_by_week_by_network`.* FROM `dbpavweb`.`tblwebconnections_by_rep_by_week_by_network`;

# --1
INSERT INTO `dbpavweb`.tblwebconnections_by_dealer_by_month ( IDDealer, ConnectionMonth, Connections )
SELECT `scandb`.tbldealers.IDDealer, DATE_FORMAT(`ActualConnectionDate`,'%Y-%m') AS ConnectionMonth, COUNT(`scandb`.tblstarterpacks.SimNumber) AS Connections
FROM (((((`scandb`.tblstarterpacks INNER JOIN `scandb`.tblboxes ON `scandb`.tblstarterpacks.IDBox = `scandb`.tblboxes.IDBox) INNER JOIN `scandb`.`tblnetworks` ON `scandb`.tblboxes.IDNetwork = `scandb`.tblnetworks.IDNetwork) INNER JOIN `scandb`.tblinvoicedetail ON `scandb`.tblboxes.IDBox = `scandb`.tblinvoicedetail.IDBox) INNER JOIN `scandb`.tblinvoices ON `scandb`.tblinvoicedetail.IDInv = `scandb`.tblinvoices.IDInv) INNER JOIN `scandb`.tbldealers ON `scandb`.tblinvoices.IDDealer = `scandb`.tbldealers.IDDealer) INNER JOIN `scandb`.tblsalesrep ON `scandb`.tblinvoices.IDRep = `scandb`.tblsalesrep.IDRep
WHERE (((`scandb`.tblstarterpacks.ActualConnectionDate) > LAST_DAY(DATE_SUB(CURDATE(), INTERVAL 13 MONTH))))
GROUP BY `scandb`.tbldealers.IDDealer, DATE_FORMAT(`ActualConnectionDate`,'%Y-%m')
ORDER BY `scandb`.tbldealers.IDDealer, DATE_FORMAT(`ActualConnectionDate`,'%Y-%m');

# --2
INSERT INTO `dbpavweb`.tblwebconnections_by_dealer_by_month_by_network ( IDDealer, IDNetwork, ConnectionMonth, Connections )
SELECT `scandb`.tbldealers.IDDealer, `scandb`.tblnetworks.IDNetwork, DATE_FORMAT(`ActualConnectionDate`,'%Y-%m') AS ConnectionMonth, COUNT(`scandb`.tblstarterpacks.SimNumber) AS Connections
FROM (((((`scandb`.tblstarterpacks INNER JOIN `scandb`.tblboxes ON `scandb`.tblstarterpacks.IDBox = `scandb`.tblboxes.IDBox) INNER JOIN `scandb`.`tblnetworks` ON `scandb`.tblboxes.IDNetwork = `scandb`.tblnetworks.IDNetwork) INNER JOIN `scandb`.tblinvoicedetail ON `scandb`.tblboxes.IDBox = `scandb`.tblinvoicedetail.IDBox) INNER JOIN `scandb`.tblinvoices ON `scandb`.tblinvoicedetail.IDInv = `scandb`.tblinvoices.IDInv) INNER JOIN `scandb`.tbldealers ON `scandb`.tblinvoices.IDDealer = `scandb`.tbldealers.IDDealer) INNER JOIN `scandb`.tblsalesrep ON `scandb`.tblinvoices.IDRep = `scandb`.tblsalesrep.IDRep
WHERE (((`scandb`.tblstarterpacks.ActualConnectionDate) > LAST_DAY(DATE_SUB(CURDATE(), INTERVAL 13 MONTH))))
GROUP BY `scandb`.tbldealers.IDDealer, `scandb`.tblnetworks.IDNetwork, DATE_FORMAT(`ActualConnectionDate`,'%Y-%m')
ORDER BY `scandb`.tbldealers.IDDealer, `scandb`.tblnetworks.IDNetwork, DATE_FORMAT(`ActualConnectionDate`,'%Y-%m');

# --3
INSERT INTO `dbpavweb`.tblwebconnections_by_dealer_by_month_by_network_ytd ( IDDealer, IDNetwork, InvoiceMonth, Taken, Connections )
SELECT `scandb`.tbldealers.IDDealer, `scandb`.tblnetworks.IDNetwork, DATE_FORMAT(`scandb`.`tblinvoices`.`InvoiceDate`,'%Y-%m') AS InvoiceMonth, COUNT(`scandb`.tblstarterpacks.SimNumber) AS Taken, COUNT(`scandb`.tblstarterpacks.ActualConnectionDate) AS Connections
FROM (((((`scandb`.tblstarterpacks INNER JOIN `scandb`.tblboxes ON `scandb`.tblstarterpacks.IDBox = `scandb`.tblboxes.IDBox) INNER JOIN `scandb`.`tblnetworks`ON `scandb`.tblboxes.IDNetwork = `scandb`.tblnetworks.IDNetwork) INNER JOIN `scandb`.tblinvoicedetail ON `scandb`.tblboxes.IDBox = `scandb`.tblinvoicedetail.IDBox) INNER JOIN `scandb`.tblinvoices ON `scandb`.tblinvoicedetail.IDInv = `scandb`.tblinvoices.IDInv) INNER JOIN `scandb`.tbldealers ON `scandb`.tblinvoices.IDDealer = `scandb`.tbldealers.IDDealer) INNER JOIN `scandb`.tblsalesrep ON `scandb`.tblinvoices.IDRep = `scandb`.tblsalesrep.IDRep
WHERE (((`scandb`.tblinvoices.InvoiceDate) > LAST_DAY(DATE_SUB(CURDATE(), INTERVAL 13 MONTH))))
GROUP BY `scandb`.tbldealers.IDDealer, `scandb`.tblnetworks.IDNetwork, DATE_FORMAT(`scandb`.`tblinvoices`.`InvoiceDate`,'%Y-%m')
ORDER BY `scandb`.tbldealers.IDDealer, `scandb`.tblnetworks.IDNetwork, DATE_FORMAT(`scandb`.`tblinvoices`.`InvoiceDate`,'%Y-%m');

# --4
INSERT INTO `dbpavweb`.tblwebconnections_by_dealer_by_week ( IDDealer, ConnectionWeek, Connections )
SELECT `scandb`.tbldealers.IDDealer, YEARWEEK(DATE_FORMAT(`ActualConnectionDate`,'%Y/%m/%d')) AS ConnectionWeek, COUNT(`scandb`.tblstarterpacks.SimNumber) AS Connections
FROM (((((`scandb`.tblstarterpacks INNER JOIN `scandb`.tblboxes ON `scandb`.tblstarterpacks.IDBox = `scandb`.tblboxes.IDBox) INNER JOIN `scandb`.`tblnetworks` ON `scandb`.tblboxes.IDNetwork = `scandb`.tblnetworks.IDNetwork) INNER JOIN `scandb`.tblinvoicedetail ON `scandb`.tblboxes.IDBox = `scandb`.tblinvoicedetail.IDBox) INNER JOIN `scandb`.tblinvoices ON `scandb`.tblinvoicedetail.IDInv = `scandb`.tblinvoices.IDInv) INNER JOIN `scandb`.tbldealers ON `scandb`.tblinvoices.IDDealer = `scandb`.tbldealers.IDDealer) INNER JOIN `scandb`.tblsalesrep ON `scandb`.tblinvoices.IDRep = `scandb`.tblsalesrep.IDRep
WHERE (((`scandb`.tblstarterpacks.ActualConnectionDate) IS NOT NULL AND (`scandb`.tblstarterpacks.ActualConnectionDate) > LAST_DAY(DATE_SUB(CURDATE(), INTERVAL 6 MONTH))))
GROUP BY `scandb`.tbldealers.IDDealer, YEARWEEK(DATE_FORMAT(`ActualConnectionDate`,'%Y/%m/%d'))
ORDER BY `scandb`.tbldealers.IDDealer, YEARWEEK(DATE_FORMAT(`ActualConnectionDate`,'%Y/%m/%d'));

# --5
INSERT INTO `dbpavweb`.tblwebconnections_by_dealer_by_week_by_network ( IDDealer, IDNetwork, ConnectionWeek, Connections )
SELECT `scandb`.tbldealers.IDDealer, `scandb`.tblnetworks.IDNetwork, YEARWEEK(DATE_FORMAT(`ActualConnectionDate`,'%Y/%m/%d'))AS ConnectionWeek, COUNT(`scandb`.tblstarterpacks.SimNumber) AS Connections
FROM (((((`scandb`.tblstarterpacks INNER JOIN `scandb`.tblboxes ON `scandb`.tblstarterpacks.IDBox = `scandb`.tblboxes.IDBox) INNER JOIN `scandb`.`tblnetworks` ON `scandb`.tblboxes.IDNetwork = `scandb`.tblnetworks.IDNetwork) INNER JOIN `scandb`.tblinvoicedetail ON `scandb`.tblboxes.IDBox = `scandb`.tblinvoicedetail.IDBox) INNER JOIN `scandb`.tblinvoices ON `scandb`.tblinvoicedetail.IDInv = `scandb`.tblinvoices.IDInv) INNER JOIN `scandb`.tbldealers ON `scandb`.tblinvoices.IDDealer = `scandb`.tbldealers.IDDealer) INNER JOIN `scandb`.tblsalesrep ON `scandb`.tblinvoices.IDRep = `scandb`.tblsalesrep.IDRep
WHERE (((`scandb`.tblstarterpacks.ActualConnectionDate) > LAST_DAY(DATE_SUB(CURDATE(), INTERVAL 6 MONTH))))
GROUP BY `scandb`.tbldealers.IDDealer, `scandb`.tblnetworks.IDNetwork, YEARWEEK(DATE_FORMAT(`ActualConnectionDate`,'%Y/%m/%d'))
ORDER BY `scandb`.tbldealers.IDDealer, `scandb`.tblnetworks.IDNetwork, YEARWEEK(DATE_FORMAT(`ActualConnectionDate`,'%Y/%m/%d'));

# -- 6
INSERT INTO `dbpavweb`.tblwebconnections_by_rep_by_month_by_network ( IDDealer, IDRep, IDNetwork, ConnectionMonth, Connections )
SELECT `scandb`.tbldealers.IDDealer, `scandb`.tblsalesrep.IDRep, `scandb`.tblnetworks.IDNetwork, DATE_FORMAT(`ActualConnectionDate`,'%Y-%m') AS ConnectionMonth, COUNT(`scandb`.tblstarterpacks.SimNumber) AS Connections
FROM (((((`scandb`.tblstarterpacks INNER JOIN `scandb`.tblboxes ON `scandb`.tblstarterpacks.IDBox = `scandb`.tblboxes.IDBox) INNER JOIN `scandb`.`tblnetworks` ON `scandb`.tblboxes.IDNetwork = `scandb`.tblnetworks.IDNetwork) INNER JOIN `scandb`.tblinvoicedetail ON `scandb`.tblboxes.IDBox = `scandb`.tblinvoicedetail.IDBox) INNER JOIN `scandb`.tblinvoices ON `scandb`.tblinvoicedetail.IDInv = `scandb`.tblinvoices.IDInv) INNER JOIN `scandb`.tbldealers ON `scandb`.tblinvoices.IDDealer = `scandb`.tbldealers.IDDealer) INNER JOIN `scandb`.tblsalesrep ON `scandb`.tblinvoices.IDRep = `scandb`.tblsalesrep.IDRep
WHERE (((`scandb`.tblstarterpacks.ActualConnectionDate) > LAST_DAY(DATE_SUB(CURDATE(), INTERVAL 13 MONTH))))
GROUP BY `scandb`.tbldealers.IDDealer, `scandb`.tblsalesrep.IDRep, `scandb`.tblnetworks.IDNetwork, DATE_FORMAT(`ActualConnectionDate`,'%Y-%m')
ORDER BY `scandb`.tbldealers.IDDealer, `scandb`.tblsalesrep.IDRep, `scandb`.tblnetworks.IDNetwork, DATE_FORMAT(`ActualConnectionDate`,'%Y-%m');

# --7
INSERT INTO `dbpavweb`.tblwebconnections_by_rep_by_week_by_network ( IDDealer, IDRep, IDNetwork, ConnectionWeek, Connections )
SELECT `scandb`.tbldealers.IDDealer, `scandb`.tblsalesrep.IDRep, `scandb`.tblnetworks.IDNetwork, YEARWEEK(DATE_FORMAT(`ActualConnectionDate`,'%Y/%m/%d')) AS ConnectionWeek, COUNT(`scandb`.tblstarterpacks.SimNumber) AS Connections
FROM (((((`scandb`.tblstarterpacks INNER JOIN `scandb`.tblboxes ON `scandb`.tblstarterpacks.IDBox = `scandb`.tblboxes.IDBox) INNER JOIN `scandb`.`tblnetworks` ON `scandb`.tblboxes.IDNetwork = `scandb`.tblnetworks.IDNetwork) INNER JOIN `scandb`.tblinvoicedetail ON `scandb`.tblboxes.IDBox = `scandb`.tblinvoicedetail.IDBox) INNER JOIN `scandb`.tblinvoices ON `scandb`.tblinvoicedetail.IDInv = `scandb`.tblinvoices.IDInv) INNER JOIN `scandb`.tbldealers ON `scandb`.tblinvoices.IDDealer = `scandb`.tbldealers.IDDealer) INNER JOIN `scandb`.tblsalesrep ON `scandb`.tblinvoices.IDRep = `scandb`.tblsalesrep.IDRep
WHERE (((`scandb`.tblstarterpacks.ActualConnectionDate) > LAST_DAY(DATE_SUB(CURDATE(), INTERVAL 6 MONTH))))
GROUP BY `scandb`.tbldealers.IDDealer, `scandb`.tblsalesrep.IDRep, `scandb`.tblnetworks.IDNetwork, YEARWEEK(DATE_FORMAT(`ActualConnectionDate`,'%Y/%m/%d'))
ORDER BY `scandb`.tbldealers.IDDealer, `scandb`.tblsalesrep.IDRep, `scandb`.tblnetworks.IDNetwork, YEARWEEK(DATE_FORMAT(`ActualConnectionDate`,'%Y/%m/%d'));

