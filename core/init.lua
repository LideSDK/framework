-- ///////////////////////////////////////////////////////////////////
-- // Name:      lide.core.init.lua
-- // Purpose:   Define and initialize framework values
-- // Created:   2016/01/03
-- // Copyright: (c) 2016-2018 Hernan Dario Cano [dcanohdev [at] gmail.com]
-- // License:   GNU GENERAL PUBLIC LICENSE
-- ///////////////////////////////////////////////////////////////////

io.stdout:setvbuf 'no'
io.stderr:setvbuf 'no'

lide = {
	cons   = {}, 	--> This table saves all constants
	errorf = {}, 	--> This table stores all error functions
	
	core   = {
		error  = {},  --> stores all variables related to exceptions control
		base   = { 
			newid = function ( nLastID )
				if nLastID ~= nil then
					lide.core.base.isnumber(nLastID)
					return nLastID +1
				else
					local _MAXID = 999^9
					lide.core.base.maxid = (lide.core.base.maxid or _MAXID) +1
					return lide.core.base.maxid		
				end
			end,

			maxid = 1000,
		},
		lua    = { type = type, error = error, require = require },
		file   = {},  --> stores all variables related to file handling
		folder = {},
	},

	classes = {
		
	}, 	--> stores all classes

	platform = {},
	app = {}
}

-- if interpreter
--if arg and arg[0] then
--	local sf = arg[0]:sub(1, #arg[0] , #arg[0])
--	local n  = sf:reverse():find (package.config:sub(1,1), 1) or 0
--		  sf = sf:reverse():sub (n+1, # sf:reverse()) : reverse()
--	_sourcefolder = sf
--end

--lide.app.folders = { sourcefolder = sf }
 
-- Load lua pure functions with thlua:
require 'lide.core.thlua'

--- Check lua interpreter:
--
local trequireds = { 'io.popen', 'type' }

for _, required_name in pairs(trequireds) do
	local value = required_name:delim '%.'	
	if (#value == 2) then
		local tbl, key  = value[1], value[2]
		if not rawget(rawget(_G, tbl) or {}, key) then
		   print (('[lide.core] interpreter does not support %s.'):format(required_name))
   		   os.exit()			
		end
	elseif (#value == 1) then
		local key  = required_name
		if not rawget(_G, key) then
			print (('[lide.core] interpreter does not support %s.'):format(required_name))
   		    os.exit()			
		end
	end
end

lide.core.oop        = require 'lide.core.oop.init'   --> Object Oriented Model
lide.core.error      = require 'lide.core.error.init'    	--> EH & Exceptions control
lide.core.platform   = require 'lide.core.platform'   --> Operating System 
lide.core.base       = require 'lide.core.base'		--> Lide Core functions
lide.core.base.maxid = 1000;

--
-- register lide.platform:
--

lide.platform = lide.core.platform;

--
-- define base framework values:
--

lide.enum  = lide.core.base.enum;
lide.error = lide.core.error;

--
-- backward compatibility:
--

enum  = lide.enum    -- !Deprecated enum by lide.enum 
class = lide.class   -- !Deprecated class by lide.class

lide.classes = require 'lide.classes.init'



return lide, lide.app