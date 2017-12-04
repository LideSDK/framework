-- ///////////////////////////////////////////////////////////////////////////////
-- // Name:        core/error.lua
-- // Purpose:     
-- // Created:     2016/01/04
-- // Copyright:   (c) 2016 Dario Cano
-- // License:     lide license
-- ///////////////////////////////////////////////////////////////////////////////

local error = {

	lperr = function ( sErrMsg, nlevel )
		lide.core.base.isstring(sErrMsg)
		nlevel = nlevel or 1
		-- levels { 
		--	 1 = the function itself
		-- 	 2 = error dispatcher
		--   3 = caller of error_dispacher()
		--   4 = caller of 3
		--	 ..= main()
		-- }	
		local print_ok = true
		local function print( ... )
			io.stderr:write( tostring(unpack{...} or '') .. '\n')
		end
		
		local err_msg = ('Lide, Error: %s\n\n'):format(sErrMsg)
		
		local tmp_file_src = '' -- Esto es para que todos los levels continuos se junten:
		-- [/fs/ss/loo.lua]
		-- [line:1] dadasdsada
		-- [line:104] dadasdsada
		--
		-- Comienza desde 2: "la funcion que genera el error":
		-- repeat nlevel  = nlevel +1 (...)
		local traceback = ''
		local i = nlevel repeat i = i +1
			local level = debug.getinfo(i)
			if level then
				if level.short_src then
				local short_src   = tostring(level.short_src or 'NULL_FILE') end
				local currentline = tonumber(level.currentline or -3) --> -3 simplemnte es para identificar que es un error, este numero no tiene nada que ver con nada.
				local namewhat    = tostring(level.namewhat or 'NULL_NAMEWHAT')
				local name        = tostring(level.name or 'NULL_NAME')
				local print_line  = true

				if level.what == 'main' then
					name     = 'main'
					namewhat = 'chunk'
				end
				
				if name == 'NULL_NAME' and level.what == 'main' then
					name = '..main chunk..'
				end

				if (namewhat == 'global') and (type(level.func) == 'function') then
					namewhat = 'global function definition'
				elseif (namewhat == 'upvalue') or (namewhat == 'local') and (type(level.func) == 'function') then
					namewhat = 'local function definition'
				elseif (namewhat == 'method') and ( name == 'init' ) and (type(level.func) == 'function') then
					local _, self = debug.getlocal(i, 1) -- get 'self'
					name = 'constructor '
					namewhat = ('definition of "%s"'):format(tostring(self:class() or ''))
				elseif (namewhat == 'method') and (type(level.func) == 'function') then
					local _, self, class_name = debug.getlocal(i, 1) -- get 'self'
					
					if self and getmetatable(self) and getmetatable(self).__lideobj and not self.getName 
						and type(getmetatable(self).__index) == 'table' then 
						local class_name = getmetatable(self).__index.name()
						if  getmetatable(self).__lideobj and getmetatable(self).__type == 'class' then						
							print_line = false --> no imprimir estalinea en el traceback --[./lide/core/oop/yaci.lua]
						end
					else
						if self and getmetatable(self) and getmetatable(self).__lideobj and getmetatable(self).__type ~= 'class' then
							-- Obtenemos el nombre de la clase desde yaci:
							class_name = self:class():name()
						end
					end
					namewhat = ('method of "%s" object'):format(class_name or '')
				end

				if print_line then
					if (tmp_file_src ~= short_src) then 
						traceback = (traceback .. '[%s]\n' ):format(tostring(short_src))
					end
					traceback = traceback.. ('[line:%d] in %s %s.\n'):format(currentline, name, namewhat)
				end
				
				tmp_file_src = short_src ;
			end
		until not debug.getinfo(i) or debug.getinfo(i).what == 'main'

		print(err_msg .. traceback) os.exit()
	end
}

return error