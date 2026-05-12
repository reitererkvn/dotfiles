CREATE OR ALTER VIEW [dbo].[VIEW_GREG_RF] AS
WITH 
-- SCHRITT 1: Nur die nackten IDs für die Hierarchie holen (extrem schnell)
BaseIDs AS (
    SELECT 
        G.ID AS GREGID,
        P.vId AS vertreterId,
        P.vtr AS vertritt
    FROM NOTARGREGISTER G
    JOIN REGISTERPROTOKOLL RP ON G.ID = RP.NOTARGREGISTER_ID
        AND RP.ID = (SELECT MAX(ID) FROM REGISTERPROTOKOLL WHERE NOTARGREGISTER_ID = G.ID)
    OUTER APPLY OPENJSON(RP.HISTORISCHER_EINTRAG, '$.personen') WITH (
        vId INT '$.id',
        vtr INT '$.vertreterdaten.vertrittid'
    ) AS P
),

-- SCHRITT 2: Den Sort-Pfad rekursiv aufbauen (nur mit IDs)
Hierarchy AS (
    SELECT GREGID, vertreterId, vertritt, 0 AS LVL,
           CAST(RIGHT('000000' + CAST(vertreterId AS VARCHAR(10)), 6) AS VARCHAR(MAX)) AS SPATH
    FROM BaseIDs WHERE vertritt IS NULL
    UNION ALL
    SELECT b.GREGID, b.vertreterId, b.vertritt, h.LVL + 1,
           h.SPATH + '/' + RIGHT('000000' + CAST(b.vertreterId AS VARCHAR(10)), 6)
    FROM BaseIDs b
    JOIN Hierarchy h ON b.vertritt = h.vertreterId AND b.GREGID = h.GREGID
),

-- SCHRITT 3: Hauptdaten (RawData)
RawData AS (
    SELECT GREG.ID AS GREGID, GREG.AKTNR, Akt.AKTENZAHL, GREG.NOTARNR AS OE, GREG.DATUM AS DATUM, GREG.GZAHL AS GZAHL, GREG.GZNR as GZNR,
        CASE WHEN cast(GREG.GEGENSTAND as NVARCHAR(MAX)) = historisch.Inhalt then '' else GREG.GEGENSTAND END as GEGENSTAND,
        GREG.ANMERKUNG as ANMERKUNG,
        historisch.inhalt as INHALT,
        CASE WHEN RP.AKTION_ID = 5 then 'nicht verwendet' else GREG.BEMERKUNG END as BEMERKUNG, 
        GREG.WERT, 
    CASE 
        WHEN GREG.ERRICHTUNGSFORM = 1 then 'in Papierform vor dem Notar errichtet' 
        WHEN GREG.ERRICHTUNGSFORM = 2 then 'elektronisch vor dem Notar errichtet' 
        WHEN GREG.ERRICHTUNGSFORM = 3 then 'zur Gänze elektronisch unter Nutzung einer elektronischen Kommunikationsmöglichkeit errichtet (§ 69b Abs. 1 NO)' 
        WHEN GREG.ERRICHTUNGSFORM = 4 then 'teilweise elektronisch unter Nutzung einer elektronischen Kommunikationsmöglichkeit errichtet (§ 69b Abs. 4a NO)' 
        ELSE '' 
    END as EF,
    CASE 
        WHEN RP.AKTION_ID = 5 THEN 'nicht verwendet' 
        WHEN RP.AKTION_ID = 7 THEN CONCAT('RESERVIERT', CASE WHEN GREG.BEMERKUNG <> '' then CONCAT(' (', GREG.BEMERKUNG, ')') else '' END)
        ELSE 
            STUFF(
                ISNULL(CASE WHEN CHARINDEX('0', GREG.AMTSHANDLUNGEN) > 0 THEN ', Not. Protokoll' ELSE '' END, '') +
                ISNULL(CASE WHEN CHARINDEX('2', GREG.AMTSHANDLUNGEN) > 0 THEN ', Notariatsakt' ELSE '' END, '') +
                ISNULL(CASE WHEN CHARINDEX('4', GREG.AMTSHANDLUNGEN) > 0 THEN ', Notariatsaktgesetz' ELSE '' END, '') +
                ISNULL(CASE WHEN CHARINDEX('3', GREG.AMTSHANDLUNGEN) > 0 THEN ', vollstreckbar' ELSE '' END, ''),
                1, 2, ''
            )
    END
    +
    CASE WHEN GREG.NOTARNR <> historisch.juristnr 
    THEN ', beurkundet von ' + CASE WHEN historisch.juristtv <> '' THEN historisch.juristtv + ' ' ELSE '' END + historisch.juristvn + ' ' + historisch.juristnn + CASE WHEN historisch.juristtn <> '' then ' ' + historisch.juristtn ELSE '' END
    ELSE '' END
    AS AMTSHANDLUNG,

    UPPER(SUBSTRING(CASE WHEN ISNULL(COALESCE(per.firmenname, per.firmenname_new), '') <> '' THEN ISNULL(COALESCE(per.firmenname, per.firmenname_new), '') ELSE ISNULL(COALESCE(per.nachname, per.nachname_new), '') + ' ' + ISNULL(COALESCE(per.vorname, per.vorname_new), '') END, 1, 1)) AS ANFANGSBUCHSTABE,   
    CASE WHEN ISNULL(COALESCE(per.firmenname, per.firmenname_new), '') <> '' THEN ISNULL(COALESCE(per.firmenname, per.firmenname_new), '') ELSE ISNULL(COALESCE(per.nachname, per.nachname_new), '')  + CASE WHEN ISNULL(COALESCE(per.titelnachkurz, per.titelnachkurz_new), '') <> '' THEN ' ' + ISNULL(COALESCE(per.titelnachkurz, per.titelnachkurz_new), '') ELSE '' END + CASE WHEN ISNULL(COALESCE(per.titelvorkurz, per.titelvorkurz_new), '') <> '' THEN  ISNULL( ', ' + COALESCE(per.titelvorkurz, per.titelvorkurz_new) + ' ', '') ELSE ' ' END +  ISNULL(COALESCE(per.vorname, per.vorname_new), '') END 
    +  
    (
        CASE WHEN ISNULL(COALESCE(per.geburtsdatum, per.geburtsdatum_new), '') <> '' 
            THEN ', geb. ' + ISNULL(COALESCE(per.geburtsdatum, per.geburtsdatum_new), '') ELSE '' END + 
        CASE WHEN ISNULL(COALESCE(per.geburtsort, per.geburtsort_new), '') <> '' then ', Geburtsort: ' + ISNULL(COALESCE(per.geburtsort, per.geburtsort_new), '') ELSE '' END +
        CASE WHEN ISNULL(COALESCE(per.geburtsland, per.geburtsland_new), '') <> '' then ', ' + ISNULL(COALESCE(per.geburtsland, per.geburtsland_new), '') ELSE '' END +
        CASE WHEN ISNULL(COALESCE(per.registernummer, per.registernummer_new), '') <> '' THEN ', ' +   
            CASE WHEN COALESCE(firmentyp, firmentyp_new) in (1, 2) THEN 'FN ' WHEN COALESCE(firmentyp, firmentyp_new) = 3 THEN 'ZVR ' WHEN COALESCE(firmentyp, firmentyp_new) = 5 THEN 'RegNr. ' ELSE '' END + 
            ISNULL(COALESCE(per.registernummer, per.registernummer_new), '') ELSE '' END
    ) 
    +
    (
        CASE WHEN ISNULL(COALESCE(per.adr_strasse, per.adr_strasse_new), '') <> '' THEN ', ' + ISNULL(COALESCE(per.adr_strasse, per.adr_strasse_new), '') ELSE '' END +    
        CASE WHEN ISNULL(COALESCE(per.adr_hausnummer, per.adr_hausnummer_new), '') <> '' THEN ' ' + ISNULL(COALESCE(per.adr_hausnummer, per.adr_hausnummer_new), '') ELSE '' END +   
        CASE WHEN ISNULL(COALESCE(per.adr_stiegetop, per.adr_stiegetop_new), '') <> '' THEN '/' + ISNULL(COALESCE(per.adr_stiegetop, per.adr_stiegetop_new), '') ELSE '' END +  
        CASE WHEN ISNULL(COALESCE(per.adr_plz, per.adr_plz_new), '') <> '' THEN ', ' + ISNULL(COALESCE(per.adr_plz, per.adr_plz_new), '') ELSE '' END +  
        CASE WHEN ISNULL(COALESCE(per.adr_ort, per.adr_ort_new), '') <> '' THEN ' ' + ISNULL(COALESCE(per.adr_ort, per.adr_ort_new), '') ELSE '' END +  
        CASE WHEN ISNULL(COALESCE(per.adr_landbez, per.adr_landbez_new), '') <> '' THEN ', ' + ISNULL(COALESCE(per.adr_landbez, per.adr_landbez_new), '') ELSE '' END + 
        CASE 
            WHEN ISNULL(COALESCE(per.adr_landeu, per.adr_landeu_new), '') = 'true' and ISNULL(COALESCE(per.adr_landbez, per.adr_landbez_new), '') = 'Österreich' THEN ' (Österreich)' 
            WHEN ISNULL(COALESCE(per.adr_landeu, per.adr_landeu_new), '') = 'true' and ISNULL(COALESCE(per.adr_landbez, per.adr_landbez_new), '') <> 'Österreich'  THEN ' (EU-Mitgliedsstaat)' 
            WHEN ISNULL(COALESCE(per.adr_landeu, per.adr_landeu_new), '') = 'false' THEN 
                CASE WHEN ISNULL(COALESCE(per.adr_isDrittstaatRisiko, per.adr_isDrittstaatRisiko_new), '') = 'true' THEN ' (Drittstaat mit hohem Risiko)' ELSE ' (Drittstaat)' END
            ELSE '' 
        END +
        CASE WHEN ISNULL(COALESCE(per.gstaat, per.gstaat_new), '') <> '' THEN ', Land der Gründung: ' + ISNULL(COALESCE(per.gstaat, per.gstaat_new), '') ELSE '' END + 
        CASE 
            WHEN ISNULL(COALESCE(per.glandeu, per.glandeu_new), '') = 'true' and ISNULL(COALESCE(per.gstaat, per.gstaat_new), '') = 'Österreich' THEN ' (Österreich)' 
            WHEN ISNULL(COALESCE(per.glandeu, per.glandeu_new), '') = 'true' and ISNULL(COALESCE(per.gstaat, per.gstaat_new), '') <> 'Österreich'  THEN ' (EU-Mitgliedsstaat)' 
            WHEN ISNULL(COALESCE(per.glandeu, per.glandeu_new), '') = 'false' THEN 
                CASE WHEN ISNULL(COALESCE(per.grisiko, per.grisiko_new), '') = 'true' THEN ' (Drittstaat mit hohem Risiko)' ELSE ' (Drittstaat)' END
            ELSE '' 
        END
    ) AS Person,

    CONCAT(AW.AWTyp, CASE WHEN AW.AWBezeichnung <> '' then ', ' + AW.AWBezeichnung END, CASE WHEN AW.AWNUMMER <> '' then ', Nr. ' + AW.AWNUMMER END,
    CASE WHEN AW.AWBehoerde <> '' then ', ausstellende Behörde: ' + AW.AWBehoerde END, CASE WHEN AW.AWLand <> '' then ', ausstellendes Land: ' + AW.AWLand END, CASE WHEN AW.AWvon <> '' then ', gültig von: ' + AW.AWvon END, CASE WHEN AW.AWbis <> '' then ', bis: ' + AW.AWbis END,
    CASE WHEN AW.AWSNummer <> '' then ', Ausweissammlungsnummer: ' + AW.AWSNummer END) AS Ausw,

    CASE WHEN ZG1.ID is not NULL then
        CONCAT(CASE WHEN ZG1.TV <> '' then ZG1.TV + ' ' END, ZG1.VN, ' ',  ZG1.NN, CASE WHEN ZG1.TV <> '' then ' ' + ZG1.TV END, ', geb. ', ZG1.Geb, ', ', ZG1.stra, ', ', ZG1.stiege, ', ', ZG1.plz, ', ', ZG1.ort, ', ', ZG1.Land + CASE WHEN ZG1.landeu = 'true' THEN ' (EU-Mitgliedsstaat)' WHEN ZG1.landeu = 'false' THEN ' (Drittstaat)' ELSE '' END)
        + ', ' +
        CONCAT(ZG1.AWTyp, CASE WHEN ZG1.AWBezeichnung <> '' then ', ' + ZG1.AWBezeichnung END, CASE WHEN ZG1.AWNUMMER <> '' then ', Nr. ' + ZG1.AWNUMMER END,
        CASE WHEN ZG1.AWBehoerde <> '' then ', ausstellende Behörde: ' + ZG1.AWBehoerde END, CASE WHEN ZG1.AWLand <> '' then ', ausstellendes Land: ' + ZG1.AWLand END,  CASE WHEN ZG1.AWvon <> '' then ', gültig von: ' + ZG1.AWvon END, CASE WHEN ZG1.AWbis <> '' then ', bis: ' + ZG1.AWbis END,
        CASE WHEN ZG1.AWSNummer <> '' then ', Ausweissammlungsnummer: ' + ZG1.AWSNummer END)
    ELSE NULL END AS Zeuge1,

    CASE WHEN ZG2.ID is not NULL then
        CONCAT(CASE WHEN ZG2.TV <> '' then ZG2.TV + ' ' END, ZG2.VN, ' ',  ZG2.NN, CASE WHEN ZG2.TV <> '' then ' ' + ZG2.TV END, ', geb. ', ZG2.Geb, ', ', ZG2.stra, ', ', ZG2.stiege, ', ', ZG2.plz, ', ', ZG2.ort, ', ', ZG2.Land + CASE WHEN ZG2.landeu = 'true' THEN ' (EU-Mitgliedsstaat)' WHEN ZG2.landeu = 'false' THEN ' (Drittstaat)' ELSE '' END)
        + ', ' +
        CONCAT(ZG2.AWTyp, CASE WHEN ZG2.AWBezeichnung <> '' then ', ' + ZG2.AWBezeichnung END, CASE WHEN ZG2.AWNUMMER <> '' then ', Nr. ' + ZG2.AWNUMMER END,
        CASE WHEN ZG2.AWBehoerde <> '' then ', ausstellende Behörde: ' + ZG2.AWBehoerde END, CASE WHEN ZG2.AWLand <> '' then ', ausstellendes Land: ' + ZG2.AWLand END,  CASE WHEN ZG2.AWvon <> '' then ', gültig von: ' + ZG2.AWvon END, CASE WHEN ZG2.AWbis <> '' then ', bis: ' + ZG2.AWbis END,
        CASE WHEN ZG2.AWSNummer <> '' then ', Ausweissammlungsnummer: ' + ZG2.AWSNummer END)
    ELSE NULL END AS Zeuge2,

    CASE WHEN RP.AKTION_ID = 7 THEN 1 ELSE 0 END AS RESERVIERT, 
    CASE WHEN RP.AKTION_ID = 5 THEN 1 ELSE 0 END AS STORNIERT,
    per.rolle as ROLLE, per.vertreterId as vertreterId, per.vertritt as vertritt, 
    historisch.urkundenart,

    -- RFGZ: Urkundenbezogene Risikofaktoren (Rf-RL konform)
    CASE WHEN historisch.risikofaktoren is not null THEN 
        STUFF(CONCAT(
            CASE WHEN RF.urkundentyp_text <> '' AND RF.urkundentyp_text IS NOT NULL THEN ', ' + RF.urkundentyp_text ELSE '' END,
            CASE WHEN RF.formpflicht = 'true' THEN ', Errichtung aufgrund einer gesetzlichen Formpflicht' ELSE '' END,
            CASE WHEN RF.geschaeftskategorie = 'true' THEN 
                CONCAT(', Geschäft gem. Pkt. 3.1.1. bis 3.1.5. der Risikofaktoren-RL',
                    CASE WHEN RF.immobilien = 'true' THEN ', Kauf oder Verkauf von Immobilien' ELSE '' END,
                    CASE WHEN RF.unternehmen = 'true' THEN ', Kauf oder Verkauf von Unternehmen' ELSE '' END,
                    CASE WHEN RF.gesellschaften = 'true' THEN ', Gründung, Betrieb oder Verwaltung von Gesellschaften' ELSE '' END,
                    CASE WHEN RF.trusts = 'true' THEN ', Gründung, Betrieb oder Verwaltung von Trusts, Stiftungen oder ähnlichen Strukturen' ELSE '' END,
                    CASE WHEN RF.vermoegensverwaltung = 'true' THEN ', Vermögensverwaltung' ELSE '' END
                )
            ELSE '' END,
            CASE WHEN RF.sonstigegeschaeftskategorie = 'true' THEN ', sonstiges Geschäft gem. Pkt. 3.1.6. der Risikofaktoren-RL' ELSE '' END,
            CASE WHEN RF.risikoausmass = 1 THEN ', geringes Risiko' WHEN RF.risikoausmass = 2 THEN ', mittleres Risiko' WHEN RF.risikoausmass = 3 THEN ', hohes Risiko' ELSE '' END,
            CASE WHEN RF.umstand <> 'false' AND RF.umstand IS NOT NULL THEN ', ' + RF.umstand ELSE '' END,
            CASE WHEN RF.verdachtsmeldung <> '' THEN ', Hinweise auf Erstattung von Verdachtsmeldungen gem § 36c NO: ' + RF.verdachtsmeldung ELSE '' END
        ), 1, 2, '')
    ELSE '' END AS RFGZ,

    ISNULL(COALESCE(per.personnr, per.personnr_new), '') as PersonID, 
    
    -- RFPER: Personenbezogene Risikofaktoren (Rf-RL konform)
    CASE WHEN per.PRSF is not null THEN 
        STUFF(CONCAT(
            -- 1. 5-Jahres-Info (Rein informativ, blockiert nichts)
            CASE 
                WHEN PRF.hasErfassung5Jahre = 'true' THEN ', Innerhalb der letzten 5 Jahre erfolgte bereits eine Eintragung der Partei im Geschäftsregister, Beurkundungsregister oder Treuhandregister des Amtsträgers' 
                WHEN RF.geschaeftskategorie = 'true' THEN ', Innerhalb der letzten 5 Jahre erfolgte keine Eintragung der Partei im Geschäftsregister, Beurkundungsregister oder Treuhandregister des Amtsträgers'
                ELSE '' 
            END,
            -- 2. PEP-Status (Detailliert nach Rf-RL)
            CASE WHEN ISNULL(PRF.keinePruefpflichtRfrl, 'false') <> 'true' THEN
                CASE 
                    WHEN PRF.isexponiert = 'true' THEN 
                        CONCAT(', ', CASE WHEN per.juristisch = 'true' THEN 'Wirtschaftliche Eigentümer sind PEP' ELSE 'PEP' END, 
                               CASE WHEN PRF.isExponiertConfirmationType = 'Notariat' THEN ' (Prüfung durch Notariat)' ELSE ' (Parteienangabe)' END)
                    WHEN PRF.isExponiertConfirmationType = 'Notariat' THEN 
                        CONCAT(', ', CASE WHEN per.juristisch = 'true' THEN 'Wirtschaftliche Eigentümer sind keine PEP (Prüfung durch Notariat)' ELSE 'Keine PEP (Prüfung durch Notariat)' END)
                    WHEN PRF.isExponiertConfirmationType = 'Parteienangabe' THEN 
                        CONCAT(', ', CASE WHEN per.juristisch = 'true' THEN 'Wirtschaftliche Eigentümer sind keine PEP (Parteienangabe)' ELSE 'Keine PEP (Parteienangabe)' END)
                    ELSE ''
                END
            ELSE ', PEP-Status: keine Prüfpflicht gem. Rf-Rl' END,
            -- 3. Staatsbürgerschaften (Multi-Support)
            (SELECT STUFF((
                SELECT CONCAT(', Staatsbürgerschaft: ', S.land_bezeichnung, 
                    CASE 
                        WHEN S.land_euland = 'true' AND S.land_bezeichnung = 'Österreich' THEN ' (Österreich)' 
                        WHEN S.land_euland = 'true' AND S.land_bezeichnung <> 'Österreich' THEN ' (EU-Mitgliedsstaat)' 
                        WHEN S.land_euland = 'false' THEN CASE WHEN S.land_risikostaat = 'true' THEN ' (Drittstaat mit hohem Risiko)' ELSE ' (Drittstaat)' END
                        ELSE '' 
                    END,
                    CASE WHEN S.hasAmtlichesDokument = 'true' THEN CONCAT(', nachgewiesen durch amtl. Dokument: ', S.documentId) ELSE ', nicht nachgewiesen durch amtl. Dokument' END
                )
                FROM OPENJSON(per.PRSF, '$.staatsbuergerschaften') WITH (
                    land_bezeichnung NVARCHAR(50) '$.land.bezeichnung',
                    land_euland NVARCHAR(10) '$.land.euland',
                    land_risikostaat NVARCHAR(10) '$.land.risikostaat',
                    hasAmtlichesDokument NVARCHAR(10) '$.hasAmtlichesDokument',
                    documentId NVARCHAR(50) '$.documentId'
                ) AS S
                FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 2, ''))
            ,
            -- 4. Flüchtling / Schutzstatus
            CASE WHEN PRF.isFluechtling = 'true' THEN CONCAT(', Flüchtling', CASE WHEN PRF.hasDocumentFluechtling = 'true' THEN ', nachgewiesen durch amtl. Dokument' ELSE '' END) ELSE '' END,
            CASE WHEN PRF.hasSchutzstatus = 'true' THEN CONCAT(', Person mit subsidiärem Schutzstatus', CASE WHEN PRF.hasDocumentSchutzstatus = 'true' THEN ', nachgewiesen durch amtl. Dokument' ELSE ', nicht nachgewiesen durch amtl. Dokument' END) ELSE '' END,
            CASE WHEN PRF.schutzStaat <> '' THEN ', schutzzuerkennender Staat: ' + PRF.schutzStaat ELSE '' END,
            -- 5. Trustee (Express Trusts)
            CASE WHEN PRF.hasTrustee = 'true' THEN CONCAT(', Trustee eines Express Trusts oder Person mit entsprechender Position aufgrund ähnlicher Rechtsvereinbarung gem. Pkt. 3.3.3. der Risikofaktoren-RL, Grundlegende Informationen gemäß Pkt. 3.3.3.1. der Risikofaktoren-RL: ', PRF.trusteeGrundinfo, ', Angaben gemäß Pkt. 3.3.3.2. der Risikofaktoren-RL: ', PRF.trusteeAngaben) ELSE '' END,
            -- 6. Abweichender Schwerpunkt
            CASE WHEN PRF.isAdresseSchwerpunktAbweichend = 'true' THEN 
                CONCAT(', Schwerpunkt der Wirtschaflichen Tätigkeit abweichend: ',
                    ISNULL(per.abw_strasse, ''), ' ', ISNULL(per.abw_hausnummer, ''), 
                    CASE WHEN per.abw_stiegetop <> '' THEN '/' + per.abw_stiegetop ELSE '' END, ', ',
                    ISNULL(per.abw_plz, ''), ' ', ISNULL(per.abw_ort, ''), ', ', ISNULL(per.abw_landbez, ''),
                    CASE WHEN per.abw_landeu = 'true' THEN ' (EU-Mitgliedsstaat)' WHEN per.abw_landeu = 'false' AND per.abw_risikostaat = 'true' THEN ' (Drittstaat mit hohem Risiko)' WHEN per.abw_landeu = 'false' AND per.abw_risikostaat = 'false' THEN ' (Drittstaat)' ELSE '' END
                )
            ELSE '' END
        ), 1, 2, '')
    ELSE '' END AS RFPER,
    COUNT(COALESCE(per.personnr, per.personnr_new)) OVER(PARTITION BY GREG.ID) AS Anzahl_Personen

    FROM NOTARGREGISTER GREG  
    JOIN REGISTERPROTOKOLL RP ON GREG.ID = RP.NOTARGREGISTER_ID AND RP.ID = (SELECT MAX(RP2.ID) FROM REGISTERPROTOKOLL RP2 WHERE GREG.ID = RP2.NOTARGREGISTER_ID)
    LEFT JOIN AKT ON GREG.AKTNR = Akt.AKTNR
    OUTER APPLY OPENJSON(RP.HISTORISCHER_EINTRAG) WITH (
        personen NVARCHAR(MAX) '$.personen' AS JSON,
        risikofaktoren NVARCHAR(MAX) '$.risikofaktoren' AS JSON,
        urkundenart NVARCHAR(50) '$.urkundenart.text',
        inhalt NVARCHAR(MAX) '$.inhalt',
        juristnr int '$.beurkundenderjurist.personnr',
        juristvn NVARCHAR(150) '$.beurkundenderjurist.name.vorname',
        juristnn NVARCHAR(150) '$.beurkundenderjurist.name.nachname',
        juristtv NVARCHAR(150) '$.beurkundenderjurist.titel.vor.kurz',
        juristtn NVARCHAR(150) '$.beurkundenderjurist.titel.nach.kurz'
    ) AS historisch   
    OUTER APPLY OPENJSON(historisch.personen) WITH (  
        firmenname NVARCHAR(300) '$.firmenname',  
        firmenname_new NVARCHAR(300) '$.persondaten.firmenname', 
        vorname NVARCHAR(150) '$.name.vorname',  
        vorname_New NVARCHAR(150) '$.persondaten.name.vorname',  
        nachname NVARCHAR(150) '$.name.nachname',  
        nachname_new NVARCHAR(150) '$.persondaten.name.nachname',  
        personnr int '$.personnr',  
        personnr_new int '$.persondaten.personnr', 
        registernummer NVARCHAR(50) '$.registernummer',  
        registernummer_new NVARCHAR(50) '$.persondaten.registernummer',  
        titelnachkurz NVARCHAR(50) '$.titel.nach.kurz',  
        titelnachkurz_new NVARCHAR(50) '$.persondaten.titel.nach.kurz',  
        titelvorkurz NVARCHAR(50) '$.titel.vor.kurz',  
        titelvorkurz_new NVARCHAR(50) '$.persondaten.titel.vor.kurz',  
        geburtsdatum NVARCHAR(50) '$.geburtsdatum', 
        geburtsdatum_new NVARCHAR(50) '$.persondaten.geburtsdatum', 
        geburtsort NVARCHAR(50) '$.geburtsort', 
        geburtsort_new NVARCHAR(50) '$.persondaten.geburtsort',
        geburtsland NVARCHAR(50) '$.geburtsland.bezeichnung', 
        geburtsland_new NVARCHAR(50) '$.persondaten.geburtsland.bezeichnung', 
        firmentyp int '$.typ.value', 
        firmentyp_new int '$.persondaten.typ.value', 
        vertritt int '$.vertreterdaten.vertrittid',
        rolle NVARCHAR(50) '$.vertreterdaten.rollenbezeichnung',
        juristisch NVARCHAR(10) '$.persondaten.juristisch',
        PRSF NVARCHAR(MAX) '$.persondaten.risikofaktoren' AS JSON,
        vertreterId INT '$.id',
        gstaat NVARCHAR(50) '$.gruendungsstaat.bezeichnung',
        glandeu NVARCHAR(50) '$.gruendungsstaat.euland',
        grisiko NVARCHAR(50) '$.gruendungsstaat.risikostaat',
        gstaat_new NVARCHAR(50) '$.persondaten.gruendungsstaat.bezeichnung',
        glandeu_new NVARCHAR(50) '$.persondaten.gruendungsstaat.euland',
        grisiko_new NVARCHAR(50) '$.persondaten.gruendungsstaat.risikostaat',
        AUSW NVARCHAR(MAX) '$.persondaten.standardausweis' AS JSON,
        -- Adressen direkt hier extrahieren (um Kreuzprodukte zu vermeiden)
        adr_hauptadresse NVARCHAR(10) '$.persondaten.adressen[0].hauptadresse',
        adr_strasse NVARCHAR(300) '$.persondaten.adressen[0].strasse',
        adr_hausnummer NVARCHAR(50) '$.persondaten.adressen[0].hausnummer',
        adr_stiegetop NVARCHAR(50) '$.persondaten.adressen[0].stiegetop',
        adr_plz NVARCHAR(50) '$.persondaten.adressen[0].plz',
        adr_ort NVARCHAR(100) '$.persondaten.adressen[0].ort',
        adr_landbez NVARCHAR(50) '$.persondaten.adressen[0].land.bezeichnung',
        adr_landeu NVARCHAR(10) '$.persondaten.adressen[0].land.euland',
        adr_isDrittstaatRisiko NVARCHAR(10) '$.persondaten.adressen[0].land.risikostaat',
        -- Abweichender Schwerpunkt
        abw_strasse NVARCHAR(300) '$.persondaten.risikofaktoren.adresseSchwerpunktAbweichend.strasse',
        abw_hausnummer NVARCHAR(50) '$.persondaten.risikofaktoren.adresseSchwerpunktAbweichend.hausnummer',
        abw_stiegetop NVARCHAR(50) '$.persondaten.risikofaktoren.adresseSchwerpunktAbweichend.stiegetop',
        abw_plz NVARCHAR(50) '$.persondaten.risikofaktoren.adresseSchwerpunktAbweichend.plz',
        abw_ort NVARCHAR(100) '$.persondaten.risikofaktoren.adresseSchwerpunktAbweichend.ort',
        abw_landbez NVARCHAR(50) '$.persondaten.risikofaktoren.adresseSchwerpunktAbweichend.land.bezeichnung',
        abw_landeu NVARCHAR(10) '$.persondaten.risikofaktoren.adresseSchwerpunktAbweichend.land.euland',
        abw_risikostaat NVARCHAR(10) '$.persondaten.risikofaktoren.adresseSchwerpunktAbweichend.land.risikostaat'
    ) AS per   
    OUTER APPLY OPENJSON(per.AUSW) WITH(
        AWNummer NVARCHAR(50) '$.nummer',
        AWSNummer NVARCHAR(50) '$.ausweissammlungsnummer',
        AWTyp NVARCHAR(MAX) '$.typ.text',
        AWBezeichnung NVARCHAR(MAX) '$.bezeichnung',
        AWBehoerde NVARCHAR(MAX) '$.behoerde',
        AWvon NVARCHAR(50) '$.gueltigvon',
        AWbis NVARCHAR(50) '$.gueltigbis',
        AWLand NVARCHAR(MAX) '$.land.bezeichnung',
        ZG1 NVARCHAR(MAX) '$.zeuge1' AS JSON,
        ZG2 NVARCHAR(MAX) '$.zeuge2' AS JSON
    ) AS AW
    OUTER APPLY OPENJSON(AW.ZG1) WITH(
        ID NVARCHAR(10) '$.personnr',
        VN NVARCHAR(MAX) '$.name.vorname',
        NN NVARCHAR(MAX) '$.name.nachname',
        TV NVARCHAR(50) '$.titel.vor.kurz',
        TN NVARCHAR(50) '$.titel.nach.kurz',
        Geb NVARCHAR(50) '$.geburtsdatum',
        Stra NVARCHAR(MAX) '$.adressen.strasse',
        stiege NVARCHAR(50) '$.adressen.stiegetop',
        plz NVARCHAR(50) '$.adressen.plz',
        ort NVARCHAR(MAX) '$.adressen.ort',
        Land NVARCHAR(MAX) '$.adressen.land.bezeichnung',
        landeu NVARCHAR(50) '$.adressen.land.euland',
        AWNUMMER NVARCHAR(50) '$.standardausweis.nummer',
        AWTyp NVARCHAR(50) '$.standardausweis.typ.text',
        AWBezeichnung NVARCHAR(50) '$.standardausweis.bezeichnung',
        AWBehoerde NVARCHAR(MAX) '$.standardausweis.behoerde',
        AWvon NVARCHAR(50) '$.gueltigvon',
        AWbis NVARCHAR(50) '$.gueltigbis',
        AWSNummer NVARCHAR(50) '$.standardausweis.ausweissammlungsnummer'
    ) AS ZG1
    OUTER APPLY OPENJSON(AW.ZG2) WITH(
        ID NVARCHAR(10) '$.personnr',
        VN NVARCHAR(MAX) '$.name.vorname',
        NN NVARCHAR(MAX) '$.name.nachname',
        TV NVARCHAR(50) '$.titel.vor.kurz',
        TN NVARCHAR(50) '$.titel.nach.kurz',
        Geb NVARCHAR(50) '$.geburtsdatum',
        Stra NVARCHAR(MAX) '$.adressen.strasse',
        stiege NVARCHAR(50) '$.adressen.stiegetop',
        plz NVARCHAR(50) '$.adressen.plz',
        ort NVARCHAR(MAX) '$.adressen.ort',
        Land NVARCHAR(MAX) '$.adressen.land.bezeichnung',
        landeu NVARCHAR(50) '$.adressen.land.euland',
        AWNUMMER NVARCHAR(50) '$.standardausweis.nummer',
        AWTyp NVARCHAR(50) '$.standardausweis.typ.text',
        AWBezeichnung NVARCHAR(50) '$.standardausweis.bezeichnung',
        AWBehoerde NVARCHAR(MAX) '$.standardausweis.behoerde',
        AWvon NVARCHAR(50) '$.gueltigvon',
        AWbis NVARCHAR(50) '$.gueltigbis',
        AWSNummer NVARCHAR(50) '$.standardausweis.ausweissammlungsnummer'
    ) AS ZG2
    OUTER APPLY OPENJSON(historisch.risikofaktoren) WITH (
        urkundentyp_text NVARCHAR(MAX) '$.urkundentyp.text',
        formpflicht NVARCHAR(10) '$.formpflicht',
        umstand NVARCHAR(MAX) '$.umstand',
        verdachtsmeldung NVARCHAR(MAX) '$.verdachtsmeldung',
        risikoausmass INT '$.risikoausmass',
        geschaeftskategorie NVARCHAR(10) '$.geschaeftskategorie',
        sonstigegeschaeftskategorie NVARCHAR(10) '$.sonstigegeschaeftskategorie',
        immobilien NVARCHAR(10) '$.immobilien',
        unternehmen NVARCHAR(10) '$.unternehmen',
        gesellschaften NVARCHAR(10) '$.gesellschaften',
        trusts NVARCHAR(10) '$.trusts',
        vermoegensverwaltung NVARCHAR(10) '$.vermoegensverwaltung'
    ) AS RF
    OUTER APPLY OPENJSON(per.PRSF) WITH (  
        isexponiert NVARCHAR(10) '$.isExponiert',
        isExponiertConfirmationType NVARCHAR(50) '$.isExponiertConfirmationType',
        isStaatenlos NVARCHAR(10) '$.isStaatenlos',
        isFluechtling NVARCHAR(10) '$.isFluechtling',
        hasDocumentFluechtling NVARCHAR(10) '$.hasDocumentFluechtling',
        hasSchutzstatus NVARCHAR(10) '$.hasSchutzstatus',
        hasDocumentSchutzstatus NVARCHAR(10) '$.hasDocumentSchutzstatus',
        hasTrustee NVARCHAR(10) '$.hasTrustee',
        trusteeGrundinfo NVARCHAR(MAX) '$.trusteeGrundinfo',
        trusteeAngaben NVARCHAR(MAX) '$.trusteeAngaben',
        hasErfassung5Jahre NVARCHAR(10) '$.hasErfassung5Jahre',
        keinePruefpflichtRfrl NVARCHAR(10) '$.keinePruefpflichtRfrl',
        schutzStaat NVARCHAR(50) '$.schutzStaat.bezeichnung',
        isAdresseSchwerpunktAbweichend NVARCHAR(10) '$.isAdresseSchwerpunktAbweichend'
    ) AS PRF
)

-- SCHRITT 4: Alles zusammenführen
SELECT 
    R.*, 
    CASE WHEN H.LVL is NULL then 0 else H.LVL end AS HIERARCHIE, 
    H.SPATH AS SORT_PATH 
FROM RawData R
FULL JOIN Hierarchy H ON R.GREGID = H.GREGID AND R.vertreterId = H.vertreterId
WHERE R.GREGID is not null;
