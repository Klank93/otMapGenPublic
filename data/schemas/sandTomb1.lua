ITEMS_TABLE = {
    [0] = {8133}, -- itemId of the main "external" ground, can be later randomized by next elements in this table (row)
    [1] = {419, 412}, -- itemId of the main walkable ground of tunnels, can be later randomized by next elements in this table (row)
    [2] = {1409,1408,1407,2023}, -- items near to the wall, to beautify
    [3] = {
        -- vertical 2sqm size items e.g. coffins // todo: handle the items on the coffins, altars etc.
        {1410,1411},
        {1415,1416},
        {11771,11770},
        {1644,1645},  -- altar stone
        {2610,2622}, -- sacrificial stone
        {2610,2611}, -- sacrificial stone
        {2610,2622}, -- sacrificial stone
        {2616,2611} -- sacrificial stone
    },

    [4] = {
        -- horizontal 2sqm size items e.g. coffins // todo: handle the items on the coffins, altars etc.
        {1642,1643}, -- altar stone
        {11773,11772},
        {2612,2613}, -- sacrificial stone
        {2612,2623}, -- sacrificial stone
        {2617,2613}, -- sacrificial stone
        {2617,2623} -- sacrificial stone
    },

    [5] = {  -- columns, pillars standing near to walls
        {1445}, -- sandstone statue
        {1550}, -- pillar
        {1550}, -- oriental pillar
        {1560,1561}, -- broken obelisk/ obelisk
        {7058}, -- skull pillar
        {6972},
        {1486},
        {12083},
        {1549} -- sandstone pillar
    },

    [6] = {  -- columns, pillars standing in the middle of rooms
        {1445}, -- sandstone statue
        {1550}, -- pillar
        {1550}, -- oriental pillar
        {1560,1561}, -- broken obelisk/ obelisk
        {7058}, -- skull pillar
        {6972},
        {1486},
        {12083},
        {1549}   -- sandstone pillar
    },

    [7] = {  -- black ground stones
        {3612,3621,3622,3623}, -- single ones
        {3614,3611,3613}, -- two or three at once
        {3610}, -- many but still walkable
        {3608,3607,3609,3616} -- unwalkable
    },
    [8] = {	-- grey ground stones
        {3653,3654,3655,3656}, -- single ones
        {3649,3650,3651,3652}, -- two or three at once
        {3648} -- unwalkable
    },
    [9] = { -- grey sharp stones
        {8220,8221,8222,8223,8224}, -- walkable
        {8224,8238,8240}, -- small ones, unwalkable
        {8214,8215,8216,8217,8218,8219} -- big ones, unwalkable
    },
    [10] = { -- stalagmites
        {391,386,387,390}
    },
    [11] = { -- walkable items, trash on the floor
        {2234,2230,2231,2227,2222,2225,2248,2229,2221,2255,2228,
         2975,2976, -- skeleton slain
         3060, -- dead human
         --10912, 10913, 10911, -- bunch of grass for the desert -- todo: is it working?
         1905 -- bloodspot
        }
    },
    [12] = {231}, -- second ground
    [13] = {5854,5858,5862}, -- leaning against the north wall like spears, armor, etc...
    [14] = {5855,5859,5863}, -- leaning against the west wall like spears, armor, etc...

    -- statues, looking south - ext to the wall
    [15] = {
        {1450}, -- watchdog statue, desert one
        {1451}, -- desert ones
        {1444}, -- hero statue
        {1453}, -- gargoyle statue
        {8836}, -- guardian statue
        {8422}, -- druid statue
        {3739}, -- archer statue
        {9243}, -- new gargoyle statue
        {9306} -- vamp lord statue
    },
    -- statues, looking east - ext to the wall
    [16] = {
        {1455}, -- gargoyle statue
        {8837}, -- guardian statue
        {3740}, -- archer statue
        {9244} -- new gargoyle statue

    },
    [17] = { -- items 2x2 sqm
        {{3729,3730},{3731,3732}}, -- dried well
        {{8418,8419},{8420,8421}} -- knight statue (with hydra)
    },
    [18] = { -- hangable stuff for north walls
             5058, -- cobra
             1474, -- cobra2
             5016, -- skull
             5018, -- skull2
             9517, -- small shield
             10170, -- big shield
             7234, -- wooden shield
             1829,
             11778,
             11776,
             11777,
             11780
    },
    [19] = { -- hangable stuff for west walls
             5060, -- cobra
             1472, -- cobra2
             5017, -- skull
             5019,  -- skull2
             9518, -- small shield
             10171, -- big shield
             7235, -- wooden shield
             1830,
             11781,
             11779,
             11774,
             11775
    },
    [20] = { -- blood on the walls, hangable for north walls
        1900,1901,1902,9731
    },
    [21] = { -- blood on the walls, hangable for west walls
        7139,7138,7137,9732
    },
    [22] = {1071}, -- second ground for mountain, SANDSTONE

    -- statues, looking south - in the middle of the rooms
    [23] = {
        {1450}, -- watchdog statue desert one
        {1451}, -- desert ones
        {1444}, -- hero statue
        {1453}, -- gargoyle statue
        {9243}, -- new gargoyle statue
        {1442},
        {1467} -- cobra statue
    },
    -- statues, looking east - in the middle of the rooms
    [24] = {
        {1478},
        {1455}, -- gargoyle statue
        {3740}, -- archer statue
        {9244} --new gargoyle statue
    }
}
