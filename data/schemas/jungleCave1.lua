-- WARNING: if you extend this table with unwalkable items, please remember to add them in array under lib/data/unwalkableItems.lua ! (to keep tableMode working)
ITEMS_TABLE = {
    [0] = {919}, -- groundy maintile'a, pierwszy elementy to glowny id, ktory moze byc pozniej randomizowany na nastepne z tablicy
    [1] = {4405,4406,4407,4408,4409,4410,4411,4412,4413,4413,4414,4415,4416,4417,4418,4419,4420,4421},  -- groundy, pierwszy elementy tablicy to glowny ground tuneli, pozniej jest randomizowany na nastepne z tablicy
    [2] = {1285,1304,5708,5709,5619,5620}, -- przy scianach, w roomach syf roznego rodzaju
    [3] = {
        -- dwu miejscowe elementy PIONOWE np. trumny -------- TO DO OBSLUGA ITEMOW NA TRUMNACH, KATAFALKACH
    },

    -- dwu miejscowe elementy POZIOME np. trumny -------- TO DO OBSLUGA ITEMOW NA TRUMNACH, KATAFALKACH
    [4] = {
        {1305,1306}
    },

    [5] = {  --kolumny
    },
    [6] = {  --kolumny, stojace po srodku roomow
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
    [9] = { -- szare ostre kamienie
        {8220,8221,8222,8223,8224}, -- walkable
        {8224,8225,8238,8240}, -- male, unwalkable
        {8214,8215,8216,8217,8218,8219} -- duze, unwalkable
    },
    [10] = { -- stalagmity
        {391,386,387,390}
    },
    [11] = { -- walkable items, syf na ziemie
        {2234,2230,2231,2227,2222,2225,2248,2229,2221,
         2975,2976, -- skeleteon slain
         3060     -- dead human
        }
    },
    [12] = {3263}, -- drugi ground

    [13] = { -- oparte o polnocna sciane, na razie wlocznia, scrimtar, zbroja  UWAGA MIECZ POTRZEBUJE SCIANY NA POLNOCNYM ZACHODZIE - TO DO

	},
    [14] = {-- oparte o zachodnia sciane, na razie wlocznia, scrimtar, zbroja UWAGA MIECZ POTRZEBUJE SCIANY NA POLNOCNYM ZACHODZIE - TO DO

	},

    [15] = { -- posagi, patrzace na poludnie  -- pod sciana
    },

    [16] = { -- posagi, patrzace na wschod -- pod sciana
    },

    [17] = { -- itemy 2x2 sqm
		{{1296,1297},{1298,1299}}, -- 2x2 stone1
		{{1300,1301},{1302,1303}}, -- 2x2 stone2
		{{3624,3625},{3626,3627}}, -- 2x2 stone3
    },

    [18] = { ---------------------hangable syf na sciany polnocne

    },
    [19] = { ---------------------hangable syf na sciany zachodnie

    },
    [20] = { -- krew na sciany, hangable na polnocne
    },
    [21] = { -- krew na sciany, hangable na zachodnie
    },
    [22] = {8133}, -- drugi ground gory, red mountain

    -- posagi, patrzace na poludnie -- na srodku roomu
    [23] = {

    },
    -- posagi, patrzace na wschod -- na srodku roomu
    [24] = {

    }
}
