# -- Clear Activation Tables -- #

# --1
DELETE `dbpavweb`.`tblwebactivations_by_dealer_by_month`.* FROM `dbpavweb`.`tblwebactivations_by_dealer_by_month`;
# --2
DELETE `dbpavweb`.`tblwebactivations_by_dealer_by_month_by_network`.* FROM `dbpavweb`.`tblwebactivations_by_dealer_by_month_by_network`;
# --3
DELETE `dbpavweb`.`tblwebactivations_by_dealer_by_month_by_network_ytd`.* FROM `dbpavweb`.`tblwebactivations_by_dealer_by_month_by_network_ytd`;
# --4
DELETE `dbpavweb`.`tblwebactivations_by_rep_by_month`.* FROM `dbpavweb`.`tblwebactivations_by_rep_by_month`;
# --5
DELETE `dbpavweb`.`tblwebactivations_by_rep_by_month_by_network`.* FROM `dbpavweb`.`tblwebactivations_by_rep_by_month_by_network`;
# --6
DELETE `dbpavweb`.`tblwebactivations_by_rep_by_month_by_network_ytd`.* FROM `dbpavweb`.`tblwebactivations_by_rep_by_month_by_network_ytd`;

# --1
INSERT INTO `dbpavweb`.`tblwebactivations_by_rep_by_month_by_network` ( IDDealer, IDRep, IDNetwork, ActivationMonth, Activations )
SELECT `scandb`.`tblInvoices`.`IDDealer`, `scandb`.`tblInvoices`.`IDRep`, `scandb`.`tblnetworks`.`IDNetwork`, DATE_FORMAT(`ActivationDate`,'%Y-%m') AS ActivationMonth, COUNT(`scandb`.`tblstarterpacks`.`ActivationDate`) AS Activations
FROM `scandb`.`tblInvoices`
INNER JOIN `scandb`.`tblinvoicedetail` ON `scandb`.`tblinvoices`.`IDInv` = `scandb`.`tblinvoicedetail`.`IDInv`
INNER JOIN `scandb`.`tblboxes` ON `scandb`.`tblInvoicedetail`.`IDBox` = `scandb`.`tblboxes`.`IDBox`
INNER JOIN `scandb`.`tblnetworks` ON `scandb`.`tblboxes`.`IDNetwork` = `scandb`.`tblnetworks`.`IDNetwork`
INNER JOIN `scandb`.`tblstarterpacks` ON `scandb`.`tblboxes`.`IDBox` = `scandb`.`tblstarterpacks`.`IDBox`
WHERE (((`scandb`.`tblstarterpacks`.`ActivationDate`) > LAST_DAY(DATE_SUB(CURDATE(), INTERVAL 13 MONTH))))
GROUP BY `scandb`.`tblInvoices`.`IDDealer`, `scandb`.`tblInvoices`.`IDRep`, `scandb`.`tblnetworks`.`IDNetwork`, DATE_FORMAT(`ActivationDate`,'%Y-%m')
ORDER BY `scandb`.`tblInvoices`.`IDDealer`, `scandb`.`tblInvoices`.`IDRep`, `scandb`.`tblnetworks`.`IDNetwork`, DATE_FORMAT(`ActivationDate`,'%Y-%m');

# --2
INSERT INTO `dbpavweb`.`tblwebactivations_by_rep_by_month` ( IDDealer, IDRep, ActivationMonth, Activations )
SELECT `dbpavweb`.`tblwebactivations_by_rep_by_month_by_network`.`IDDealer`, `dbpavweb`.`tblwebactivations_by_rep_by_month_by_network`.`IDRep`, 
`dbpavweb`.`tblwebactivations_by_rep_by_month_by_network`.`ActivationMonth`, SUM(`dbpavweb`.`tblwebactivations_by_rep_by_month_by_network`.`Activations`) AS Activations
FROM `dbpavweb`.`tblwebactivations_by_rep_by_month_by_network`
GROUP BY `dbpavweb`.`tblwebactivations_by_rep_by_month_by_network`.`IDDealer`, `dbpavweb`.`tblwebactivations_by_rep_by_month_by_network`.`IDRep`, `dbpavweb`.`tblwebactivations_by_rep_by_month_by_network`.`ActivationMonth`
ORDER BY `dbpavweb`.`tblwebactivations_by_rep_by_month_by_network`.`IDDealer`, `dbpavweb`.`tblwebactivations_by_rep_by_month_by_network`.`IDRep`, `dbpavweb`.`tblwebactivations_by_rep_by_month_by_network`.`ActivationMonth`;

# --3
INSERT INTO `dbpavweb`.`tblwebactivations_by_dealer_by_month_by_network` ( IDDealer, IDNetwork, ActivationMonth, Activations )
SELECT `dbpavweb`.`tblwebactivations_by_rep_by_month_by_network`.`IDDealer`, `dbpavweb`.`tblwebactivations_by_rep_by_month_by_network`.`IDNetwork`, 
`dbpavweb`.`tblwebactivations_by_rep_by_month_by_network`.`ActivationMonth`, SUM(`dbpavweb`.`tblwebactivations_by_rep_by_month_by_network`.`Activations`) AS Activations
FROM `dbpavweb`.`tblwebactivations_by_rep_by_month_by_network`
GROUP BY `dbpavweb`.`tblwebactivations_by_rep_by_month_by_network`.`IDDealer`, `dbpavweb`.`tblwebactivations_by_rep_by_month_by_network`.`IDNetwork`, `dbpavweb`.`tblwebactivations_by_rep_by_month_by_network`.`ActivationMonth`
ORDER BY `dbpavweb`.`tblwebactivations_by_rep_by_month_by_network`.`IDDealer`, `dbpavweb`.`tblwebactivations_by_rep_by_month_by_network`.`IDNetwork`, `dbpavweb`.`tblwebactivations_by_rep_by_month_by_network`.`ActivationMonth`;

# --4
INSERT INTO `dbpavweb`.`tblwebactivations_by_dealer_by_month` ( IDDealer, ActivationMonth, Activations )
SELECT `dbpavweb`.`tblwebactivations_by_rep_by_month_by_network`.`IDDealer`, `dbpavweb`.`tblwebactivations_by_rep_by_month_by_network`.`ActivationMonth`, 
SUM(`dbpavweb`.`tblwebactivations_by_rep_by_month_by_network`.`Activations`) AS Activations
FROM `dbpavweb`.`tblwebactivations_by_rep_by_month_by_network`
GROUP BY `dbpavweb`.`tblwebactivations_by_rep_by_month_by_network`.`IDDealer`, `dbpavweb`.`tblwebactivations_by_rep_by_month_by_network`.`ActivationMonth`
ORDER BY `dbpavweb`.`tblwebactivations_by_rep_by_month_by_network`.`IDDealer`, `dbpavweb`.`tblwebactivations_by_rep_by_month_by_network`.`ActivationMonth`;

# --5
INSERT INTO `dbpavweb`.`tblwebactivations_by_dealer_by_month_by_network_ytd` ( IDDealer, IDNetwork, InvoiceMonth, Scanned, Connections, Activations )
SELECT `scandb`.`tblInvoices`.`IDDealer`, `scandb`.`tblnetworks`.`IDNetwork`, DATE_FORMAT(`scandb`.`tblInvoices`.`InvoiceDate`,'%Y-%m'),
COUNT(`scandb`.`tblstarterpacks`.`SimNumber`) AS Scanned, COUNT(`scandb`.`tblstarterpacks`.`ActualConnectionDate`) AS Connections, COUNT(`scandb`.`tblstarterpacks`.`ActivationDate`) AS Activations
FROM `scandb`.`tblInvoices`
INNER JOIN `scandb`.`tblinvoicedetail` ON `scandb`.`tblinvoices`.`IDInv` = `scandb`.`tblinvoicedetail`.`IDInv`
INNER JOIN `scandb`.`tblboxes` ON `scandb`.`tblInvoicedetail`.`IDBox` = `scandb`.`tblboxes`.`IDBox`
INNER JOIN `scandb`.`tblnetworks` ON `scandb`.`tblboxes`.`IDNetwork` = `scandb`.`tblnetworks`.`IDNetwork`
INNER JOIN `scandb`.`tblstarterpacks` ON `scandb`.`tblboxes`.`IDBox` = `scandb`.`tblstarterpacks`.`IDBox`
WHERE (((`scandb`.`tblInvoices`.`InvoiceDate`) > LAST_DAY(DATE_SUB(CURDATE(), INTERVAL 13 MONTH))))
GROUP BY `scandb`.`tblInvoices`.`IDDealer`, `scandb`.`tblnetworks`.`IDNetwork`, DATE_FORMAT(`scandb`.`tblInvoices`.`InvoiceDate`,'%Y-%m');

# -- 6
INSERT INTO `dbpavweb`.`tblwebactivations_by_rep_by_month_by_network_ytd`( IDDealer, IDRep, IDNetwork, InvoiceMonth, Scanned, Connections, Activations )
SELECT `scandb`.`tblInvoices`.`IDDealer`, `scandb`.`tblInvoices`.`IDRep`,`scandb`.`tblnetworks`.`IDNetwork`, DATE_FORMAT(`scandb`.`tblInvoices`.`InvoiceDate`,'%Y-%m'),
COUNT(`scandb`.`tblstarterpacks`.`SimNumber`) AS Scanned, COUNT(`scandb`.`tblstarterpacks`.`ActualConnectionDate`) AS Connections, COUNT(`scandb`.`tblstarterpacks`.`ActivationDate`) AS Activations
FROM `scandb`.`tblInvoices`
INNER JOIN `scandb`.`tblinvoicedetail` ON `scandb`.`tblinvoices`.`IDInv` = `scandb`.`tblinvoicedetail`.`IDInv`
INNER JOIN `scandb`.`tblboxes` ON `scandb`.`tblInvoicedetail`.`IDBox` = `scandb`.`tblboxes`.`IDBox`
INNER JOIN `scandb`.`tblnetworks` ON `scandb`.`tblboxes`.`IDNetwork` = `scandb`.`tblnetworks`.`IDNetwork`
INNER JOIN `scandb`.`tblstarterpacks` ON `scandb`.`tblboxes`.`IDBox` = `scandb`.`tblstarterpacks`.`IDBox`
WHERE (((`scandb`.`tblInvoices`.`InvoiceDate`) > LAST_DAY(DATE_SUB(CURDATE(), INTERVAL 13 MONTH))))
GROUP BY `scandb`.`tblInvoices`.`IDDealer`, `scandb`.`tblInvoices`.`IDRep`,`scandb`.`tblnetworks`.`IDNetwork`, DATE_FORMAT(`scandb`.`tblInvoices`.`InvoiceDate`,'%Y-%m');

# -- Delete Purchases Tables -- #
DELETE `dbpavweb`.`tblwebpurchases_by_dealer`.* FROM `dbpavweb`.`tblwebpurchases_by_dealer`;
DELETE `dbpavweb`.`tblwebpurchases_by_rep`.* FROM `dbpavweb`.`tblwebpurchases_by_rep`;

# -- Populate Purchases tables -- #
INSERT INTO `dbpavweb`.`tblwebpurchases_by_rep` (IDDealer,IDRep,IDNetwork,BuyMonth,InvoiceQty,Activated)
SELECT `scandb`.`tblInvoices`.`IDDealer`, `scandb`.`tblInvoices`.`IDRep`,`scandb`.`tblnetworks`.`IDNetwork`, DATE_FORMAT(`scandb`.`tblInvoices`.`InvoiceDate`,'%Y-%m'),
COUNT(`scandb`.`tblstarterpacks`.`SimNumber`) AS StockSent, COUNT(`scandb`.`tblstarterpacks`.`ActivationDate`) AS Activations
FROM `scandb`.`tblInvoices`
INNER JOIN `scandb`.`tblinvoicedetail` ON `scandb`.`tblinvoices`.`IDInv` = `scandb`.`tblinvoicedetail`.`IDInv`
INNER JOIN `scandb`.`tblboxes` ON `scandb`.`tblInvoicedetail`.`IDBox` = `scandb`.`tblboxes`.`IDBox`
INNER JOIN `scandb`.`tblnetworks` ON `scandb`.`tblboxes`.`IDNetwork` = `scandb`.`tblnetworks`.`IDNetwork`
INNER JOIN `scandb`.`tblstarterpacks` ON `scandb`.`tblboxes`.`IDBox` = `scandb`.`tblstarterpacks`.`IDBox`
WHERE (((`scandb`.`tblInvoices`.`InvoiceDate`) > LAST_DAY(DATE_SUB(CURDATE(), INTERVAL 13 MONTH))))
GROUP BY `scandb`.`tblInvoices`.`IDDealer`, `scandb`.`tblInvoices`.`IDRep`,`scandb`.`tblnetworks`.`IDNetwork`, DATE_FORMAT(`scandb`.`tblInvoices`.`InvoiceDate`,'%Y-%m');

INSERT INTO `dbpavweb`.`tblwebpurchases_by_dealer` (IDDealer,IDNetwork,BuyMonth,InvoiceQty,Activated)
SELECT `scandb`.`tblInvoices`.`IDDealer`, `scandb`.`tblnetworks`.`IDNetwork`, DATE_FORMAT(`scandb`.`tblInvoices`.`InvoiceDate`,'%Y-%m'),
COUNT(`scandb`.`tblstarterpacks`.`SimNumber`) AS StockSent, COUNT(`scandb`.`tblstarterpacks`.`ActivationDate`) AS Activations
FROM `scandb`.`tblInvoices`
INNER JOIN `scandb`.`tblinvoicedetail` ON `scandb`.`tblinvoices`.`IDInv` = `scandb`.`tblinvoicedetail`.`IDInv`
INNER JOIN `scandb`.`tblboxes` ON `scandb`.`tblInvoicedetail`.`IDBox` = `scandb`.`tblboxes`.`IDBox`
INNER JOIN `scandb`.`tblnetworks` ON `scandb`.`tblboxes`.`IDNetwork` = `scandb`.`tblnetworks`.`IDNetwork`
INNER JOIN `scandb`.`tblstarterpacks` ON `scandb`.`tblboxes`.`IDBox` = `scandb`.`tblstarterpacks`.`IDBox`
WHERE (((`scandb`.`tblInvoices`.`InvoiceDate`) > LAST_DAY(DATE_SUB(CURDATE(), INTERVAL 13 MONTH))))
GROUP BY `scandb`.`tblInvoices`.`IDDealer`, `scandb`.`tblnetworks`.`IDNetwork`, DATE_FORMAT(`scandb`.`tblInvoices`.`InvoiceDate`,'%Y-%m');

# -- Clear PayoutSheet -- #
DELETE `dbpavweb`.`tblwebpayout_sheet`.* FROM `dbpavweb`.`tblwebpayout_sheet`;

# -- Append Payout Sheet -- #
INSERT INTO `dbpavweb`.`tblwebpayout_sheet` (IDDealer, Network, PayMonth,Activations,Act_Bonus,Act_Excl_Vat,
Act_Incl_VAT,Recharges,RebatePercentage,VL_Excl_VAT,VL_Incl_VAT,Total_Excl_VAT,Total_Incl_VAT)
SELECT DISTINCT `scandb`.`tbldealers`.`IDDealer`,`scandb`.`rptpayoutsheet`.`Network`,`scandb`.`rptpayoutsheet`.`PayMonth`,
`scandb`.`rptpayoutsheet`.`Activations`,`scandb`.`rptpayoutsheet`.`Act_Bonus`,`scandb`.`rptpayoutsheet`.`Act_Excl_Vat`,`scandb`.`rptpayoutsheet`.`Act_Incl_VAT`,
`scandb`.`rptpayoutsheet`.`Recharges`,`scandb`.`rptpayoutsheet`.`RebatePercentage`,`scandb`.`rptpayoutsheet`.`VL_Excl_VAT`,`scandb`.`rptpayoutsheet`.`VL_Incl_VAT`,
`scandb`.`rptpayoutsheet`.`Total Excl VAT`,`scandb`.`rptpayoutsheet`.`Total Incl VAT`
FROM `scandb`.`tbldealers`
INNER JOIN `scandb`.`rptpayoutsheet` ON `scandb`.`tbldealers`.`DealerName` = `scandb`.`rptpayoutsheet`.`Dealer`
WHERE `scandb`.`rptpayoutsheet`.`PayMonth` IS NOT NULL;

# -- Append Payout History -- #
INSERT INTO `dbpavweb`.`tblwebpayout_history` (IDDealer,Network,PayMonth,Activations,Act_Bonus,Act_Excl_Vat,
Act_Incl_VAT,Recharges,RebatePercentage,VL_Excl_VAT,VL_Incl_VAT,Total_Excl_VAT,Total_Incl_VAT)
SELECT DISTINCT `scandb`.`tbldealers`.`IDDealer`,`scandb`.`rptpayoutsheet`.`Network`,`scandb`.`rptpayoutsheet`.`PayMonth`,
`scandb`.`rptpayoutsheet`.`Activations`,`scandb`.`rptpayoutsheet`.`Act_Bonus`,`scandb`.`rptpayoutsheet`.`Act_Excl_Vat`,`scandb`.`rptpayoutsheet`.`Act_Incl_VAT`,
`scandb`.`rptpayoutsheet`.`Recharges`,`scandb`.`rptpayoutsheet`.`RebatePercentage`,`scandb`.`rptpayoutsheet`.`VL_Excl_VAT`,`scandb`.`rptpayoutsheet`.`VL_Incl_VAT`,
`scandb`.`rptpayoutsheet`.`Total Excl VAT`,`scandb`.`rptpayoutsheet`.`Total Incl VAT`
FROM `scandb`.`tbldealers`
INNER JOIN `scandb`.`rptpayoutsheet` ON `scandb`.`tbldealers`.`DealerName` = `scandb`.`rptpayoutsheet`.`Dealer`
WHERE `scandb`.`rptpayoutsheet`.`PayMonth` IS NOT NULL;

