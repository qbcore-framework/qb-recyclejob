# qb-recyclejob
Recycling Job For QB-Core

# License

    QBCore Framework
    Copyright (C) 2021 Joshua Eger

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>


Add this item to your shared items
['recycledmaterials'] 			 = {['name'] = 'recycledmaterials', 			['label'] = 'Recycled Materials', 		['weight'] = 500, 		['type'] = 'item', 		['image'] = 'recycledmaterials.png', 	['unique'] = false, 	['useable'] = false, 	['shouldClose'] = false,   ['combinable'] = nil,   ['description'] = 'Look at you, saving the earth!'},

Add this wherever you spawn your peds

  { -- RECYCLING CENTER PED
      model = 's_m_y_xmech_02',
      coords = vector4(-572.4, -1632.1, 18.41, 168.63),
      gender = 'male',
      scenario = 'WORLD_HUMAN_CLIPBOARD',
      freeze = true,
      invincible = true,
      blockevents = true
  },
