ITEMS_TABLE = {
    [0] = {101,5711,5712,5713,5714,5715,5716,5717,5718,5719,5720,5721,5722,5723,5724,5725,5726}, -- groundy maintile'a, pierwszy elementy to glowny id, ktory moze byc pozniej randomizowany na nastepne z tablicy
    [1] = {352, 353, 354, 355},  -- groundy, pierwszy elementy tablicy to glowny ground tuneli, pozniej jest randomizowany na nastepne z tablicy
    [2] = {1409,1408,1407}, -- przy scianach, w roomach syf roznego rodzaju
    [3] = {
        -- dwu miejscowe elementy PIONOWE np. trumny -------- TO DO OBSLUGA ITEMOW NA TRUMNACH, KATAFALKACH
        {1410,1411},
        {1415,1416},
        {1742,1743},
        {7520,7521},
        {1644,1645},  -- altar stone
        {2610,2622}, -- sacrificial stone
        {2610,2611}, -- sacrificial stone
        {2610,2622}, -- sacrificial stone
        {2616,2611} -- sacrificial stone
    },

    -- dwu miejscowe elementy POZIOME np. trumny -------- TO DO OBSLUGA ITEMOW NA TRUMNACH, KATAFALKACH
    [4] = {
        {1744,1745},
        {7522,7523},
        {1642,1643}, -- altar stone
        {2612,2613}, -- sacrificial stone
        {2612,2623}, -- sacrificial stone
        {2617,2613}, -- sacrificial stone
        {2617,2623} -- sacrificial stone
    },

    [5] = {  --kolumny
        {8538},
        {8539},
        {8540},
        {3766,3767},
        {7058}, -- skull pilar
        {6972,6973},
        {1549}   --- sandstone pilar
    },

    [6] = {  --kolumny, stojace po srodku roomow
        {8538},
        {8539},
        {8540},
        {1445}, -- monument
        {3766,3767},
        {6972,6973},
        {1560,1561}, -- obelisk
        {1551} -- oriental pilar

    },

    [7] = {  --kamyczki czarne
        {3612,3621,3622,3623}, -- pojedyncze
        {3614,3611,3613}, -- 2 i 3
        {3610}, --wiele ale walkable
        {3608,3607,3609,3616} --unwalkable
    },

    [8] = {	-- kamyczki szare
        {3653,3654,3655,3656}, -- pojedyncze
        {3649,3650,3651,3652}, --wieksze
        {3648} -- unwalkable
    },
    [9] = { -- szare oste kamienie
        {8220,8221,8222,8223,8224}, -- walkable
        {8224,8225,8238,8240}, -- male, unwalkable
        {8214,8215,8216,8217,8218,8219} -- duze, unwalkable
    },
    [10] = { -- stalagmity
        {391,386,387,390}
    },
    [11] = { -- walkable items, syf na ziemie
        {2234,2230,2231,2227,2222,2225,2248,2229,2221,2255,
         2975,2976, -- skeleteon slain
         3060     -- dead human
        }
    },
    [12] = {231}, -- drugi ground

    [13] = {5854,5858,5862}, -- oparte o polnocna sciane, na razie wlocznia, scrimtar, zbroja  UWAGA MIECZ POTRZEBUJE SCIANY NA POLNOCNYM ZACHODZIE - TO DO
    [14] = {5855,5859,5863}, -- oparte o zachodnia sciane, na razie wlocznia, scrimtar, zbroja UWAGA MIECZ POTRZEBUJE SCIANY NA POLNOCNYM ZACHODZIE - TO DO

    -- posagi, patrzace na poludnie  -- pod sciana
    [15] = {
        {1450}, -- watchdog statue pustynne
        {1451}, -- pustynne
        {1444}, -- hero statue
        {1453}, -- gargoyle statue
        {8836}, -- guardian statue
        {8422}, -- druid statue
        {3739}, -- archer statue
        {9243}, -- new gargoyle statue
        {9306}-- vamp lord statue
    },
    -- posagi, patrzace na wschod -- pod sciana
    [16] = {
        {1455}, -- gargoyle statue
        {8837}, -- guardian statue
        {3740}, -- archer statue
        {9244} --new gargoyle statue

    },
    [17] = { -- itemy 2x2 sqm
        {{3729,3730},{3731,3732}}, -- dried well
        {{8418,8419},{8420,8421}} -- knight statue (with hydra)
    },
    [18] = { ---------------------hangable syf na sciany polnocne
             5058, -- cobra
             1474, -- cobra2
             5016, -- skull
             5018, -- skull2
             9517, -- small shield
             10170, -- big shield
             7234, -- wooden shield
             7565, -- empty coffin
             7560, -- coffin
             8237 -- jagged stone
    },
    [19] = { ---------------------hangable syf na sciany zachodnie
             5060, -- cobra
             1472, -- cobra2
             5017, -- skull
             5019,  -- skull2
             9518, -- small shield
             10171, -- big shield
             7235, -- wooden shield
             7564, -- empty coffin
             7561, -- coffin
             8239 -- jagged stone
    },
    [20] = { -- krew na sciany, hangable na polnocne
        1900,1901,1902,9731
    },
    [21] = { -- krew na sciany, hangable na zachodnie
        7139,7138,7137,9732
    },
    [22] = {8133}, -- drugi ground gory, red mountain

    -- posagi, patrzace na poludnie -- na srodku roomu
    [23] = {
        {1450}, -- watchdog statue pustynne
        {1451}, -- pustynne
        {1444}, -- hero statue
        {1453}, -- gargoyle statue
        {8836}, -- guardian statue
        {8422}, -- druid statue
        {3739}, -- archer statue
        {9243}, -- new gargoyle statue
        {9306}-- vamp lord statue
    },
    -- posagi, patrzace na wschod -- na srodku roomu
    [24] = {
        {1455}, -- gargoyle statue
        {8837}, -- guardian statue
        {3740}, -- archer statue
        {9244} --new gargoyle statue

    }
}