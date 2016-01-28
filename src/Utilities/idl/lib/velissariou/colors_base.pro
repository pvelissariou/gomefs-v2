FUNCTION Colors_Base, RED, GREEN, BLUE

on_error, 2

; ===== BASE colors for the first 128 colors of all custom color tables
colors  = [            'White',   'Black',     'Red',  'Green',    'Blue',    'Cyan',  'Yellow',  'Magenta' ]
  RED   = [                255,         0,       255,        0,         0,         0,       255,       255  ]
  GREEN = [                255,         0,         0,      255,         0,       255,       255,         0  ]
  BLUE  = [                255,         0,         0,        0,       255,       255,         0,       255  ]

colors  = [   colors,  'Brown',  'Orange',  'Purple',  'Pink',  'Violet',  'Maroon',  'Beige',  'Khaki' ]
  RED   = [   RED,      165,       255,       160,     255,       238,       176,      245,     240  ]
  GREEN = [ GREEN,       42,       165,        32,     192,       130,        48,      245,     230  ]
  BLUE  = [  BLUE,       42,         0,       240,     203,       238,        96,      220,     140  ]

colors  = [   colors,  'WT1',  'WT2',  'WT3',  'WT4',  'WT5',  'WT6',  'WT7',  'WT8' ]
  RED   = [   RED,    255,    255,    255,    255,    255,    245,    255,   250  ]
  GREEN = [ GREEN,    255,    250,    255,    255,    248,    245,    245,   240  ]
  BLUE  = [  BLUE,    255,    250,    240,    224,    220,    220,    238,   230  ]

colors  = [   colors,  'BLK1',  'BLK2',  'BLK3',  'BLK4',  'BLK5',  'BLK6',  'BLK7',  'BLK8' ]
  RED   = [   RED,     250,     230,     210,     190,     128,     110,      70,      0  ]
  GREEN = [ GREEN,     250,     230,     210,     190,     128,     110,      70,      0  ]
  BLUE  = [  BLUE,     250,     230,     210,     190,     128,     110,      70,      0  ]

colors  = [   colors,  'White1' ]
  RED   = [   RED,      255  ]
  GREEN = [ GREEN,      255  ]
  BLUE  = [  BLUE,      255  ]

colors  = [   colors,  'Snow',  'Ivory',  'Light Yellow',  'Cornsilk',  'Beige1',  'Seashell' ]
  RED   = [   RED,     255,      255,             255,         255,       245,        255  ]
  GREEN = [ GREEN,     250,      255,             255,         248,       245,        245  ]
  BLUE  = [  BLUE,     250,      240,             224,         220,       220,        238  ]

colors  = [   colors,  'Linen',  'Antique White',  'Papaya',  'Almond',  'Bisque',  'Moccasin' ]
  RED   = [   RED,      250,              250,       255,       255,       255,        255  ]
  GREEN = [ GREEN,      240,              235,       239,       235,       228,        228  ]
  BLUE  = [  BLUE,      230,              215,       213,       205,       196,        181  ]

colors  = [   colors,  'Wheat',  'Burlywood',  'Tan',  'Light Gray',  'Lavender',  'Medium Gray' ]
  RED   = [   RED,      245,          222,    210,           230,         230,           210  ]
  GREEN = [ GREEN,      222,          184,    180,           230,         230,           210  ]
  BLUE  = [  BLUE,      179,          135,    140,           230,         250,           210  ]

colors  = [   colors,  'Gray',  'Slate Gray',  'Dark Gray',  'Charcoal',  'Black1',  'Honeydew',  'Light Cyan' ]
  RED   = [   RED,     190,           112,          110,          70,         0,         240,          224  ]
  GREEN = [ GREEN,     190,           128,          110,          70,         0,         255,          255  ]
  BLUE  = [  BLUE,     190,           144,          110,          70,         0,         255,          240  ]

colors  = [   colors,  'Powder Blue',  'Sky Blue',  'Cornflower Blue',  'Cadet Blue',  'Steel Blue',  'Dodger Blue',  'Royal Blue',  'Blue1' ]
  RED   = [   RED,            176,         135,                100,            95,            70,             30,            65,       0  ]
  GREEN = [ GREEN,            224,         206,                149,           158,           130,            144,           105,       0  ]
  BLUE  = [  BLUE,            230,         235,                237,           160,           180,            255,           225,     255  ]

colors  = [   colors,  'Navy',  'Pale Green',  'Aquamarine',  'Spring Green',  'Cyan1' ]
  RED   = [   RED,       0,           152,           127,               0,       0  ]
  GREEN = [ GREEN,       0,           251,           255,             250,     255  ]
  BLUE  = [  BLUE,     128,           152,           212,             154,     255  ]

colors  = [   colors,  'Turquoise',  'Light Sea Green',  'Sea Green',  'Forest Green',  'Teal',  'Green Yellow',  'Chartreuse',  'Lawn Green' ]
  RED   = [   RED,           64,                143,           46,              34,       0,             173,           127,          124  ]
  GREEN = [ GREEN,          224,                188,          139,             139,     128,             255,           255,          252  ]
  BLUE  = [  BLUE,          208,                143,           87,              34,     128,              47,             0,            0  ]

colors  = [   colors,  'Green1',  'Lime Green',  'Olive Drab',  'Olive',  'Dark Green',  'Pale Goldenrod' ]
  RED   = [   RED,         0,            50,           107,       85,             0,              238  ]
  GREEN = [ GREEN,       255,           205,           142,      107,           100,              232  ]
  BLUE  = [  BLUE,         0,            50,            35,       47,             0,              170  ]

colors  = [   colors,  'Khaki1',  'Dark Khaki',  'Yellow1',  'Gold',  'Goldenrod',  'Dark Goldenrod' ]
  RED   = [   RED,       240,           189,        255,     255,          218,              184  ]
  GREEN = [ GREEN,       230,           183,        255,     215,          165,              134  ]
  BLUE  = [  BLUE,       140,           107,          0,       0,           32,               11  ]

colors  = [   colors,  'Saddle Brown',  'Rose',  'Pink1',  'Rosy Brown',  'Sandy Brown',  'Peru' ]
  RED   = [   RED,             139,     255,      255,           188,            244,    205  ]
  GREEN = [ GREEN,              69,     228,      192,           143,            164,    133  ]
  BLUE  = [  BLUE,              19,     225,      203,           143,             96,     63  ]

colors  = [   colors,  'Indian Red',  'Chocolate',  'Sienna',  'Dark Salmon',  'Salmon',  'Light Salmon' ]
  RED   = [   RED,           205,          210,       160,            233,       250,            255  ]
  GREEN = [ GREEN,            92,          105,        82,            150,       128,            160  ]
  BLUE  = [  BLUE,            92,           30,        45,            122,       114,            122  ]

colors  = [   colors,  'Orange1',  'Coral',  'Light Coral',  'Firebrick',  'Dark Red',  'Brown1',  'Hot Pink' ]
  RED   = [   RED,        255,      255,            240,          178,         139,       165,        255  ]
  GREEN = [ GREEN,        165,      127,            128,           34,           0,        42,        105  ]
  BLUE  = [  BLUE,          0,       80,            128,           34,           0,        42,        180  ]

colors  = [   colors,  'Deep Pink',  'Magenta1',  'Tomato',  'Orange Red',  'Red1',  'Crimson',  'Violet Red' ]
  RED   = [   RED,          255,         255,       255,           255,     255,        220,          208  ]
  GREEN = [ GREEN,           20,           0,        99,            69,       0,         20,           32  ]
  BLUE  = [  BLUE,          147,         255,        71,             0,       0,         60,          144  ]

colors  = [   colors,  'Maroon1',  'Thistle',  'Plum',  'Violet1',  'Orchid',  'Medium Orchid' ]
  RED   = [   RED,        176,        216,     221,        238,       218,             186  ]
  GREEN = [ GREEN,         48,        191,     160,        130,       112,              85  ]
  BLUE  = [  BLUE,         96,        216,     221,        238,       214,             211  ]

colors  = [   colors,  'Dark Orchid',  'Blue Violet',  'Purple1' ]
  RED   = [   RED,            153,            138,       160  ]
  GREEN = [ GREEN,             50,             43,        32  ]
  BLUE  = [  BLUE,            204,            226,       240  ]

colors  = [   colors,  'Slate Blue',  'Dark Slate Blue' ]
  RED   = [   RED,           106,                72  ]
  GREEN = [ GREEN,            90,                61  ]
  BLUE  = [  BLUE,           205,               139  ]

; ======================================================================
ncolors = n_elements(colors)

RED   = reform(RED,   ncolors)
GREEN = reform(GREEN, ncolors)
BLUE  = reform(BLUE,  ncolors)

return, reform(colors, 1, ncolors)

end
