local Gamestate = require 'hump.gamestate'

---------- COMMAND FORMAT ----------
-- table with following values
-- name: command name (redundant but useful)
-- helpString: printed when 'help' command is run
-- helpOrder: optional. if present, determines order that this shows up in the help string. lower => higher on the screen. if not present, will be shown at the bottom. ties are broken lexicographically
-- action: function that defines the command's behavior. should always be passed the terminal instance of the calling context

local cmds = {}

cmds.help = {
	name = 'help',
	helpString = 'print this message',
	helpOrder = -50,
	-- NEEDS TO BE PASSED THE CURRENT PARSER INSTANCE
	action = function(terminal, parser)
		local function helpSort(cmd1, cmd2)
			local a, b = cmd1.helpOrder or 137137137137137137137137137137137137137, cmd2.helpOrder or 137137137137137137137137137137137137137
			if a ~= b then
				return a < b
			else
				return cmd1.helpString < cmd2.helpString
			end
		end

		terminal:print('Available commands:')
		local order = {}
		local len = 0
		for s, cmd in pairs(parser.commands) do
			table.insert(order, cmd)
			len = math.max(#cmd.name, len)
		end
		table.sort(order, helpSort)
		for i,cmd in ipairs(order) do
			terminal:print(cmd.name..(' '):rep(len-#cmd.name)..' '..cmd.helpString)
		end
	end
}

cmds.exit = {
	name = 'exit',
	helpString = 'exit current application and return to previous',
	helpOrder = -30,
	action = function(terminal)
		local status, error = pcall(function() Gamestate.pop() end)
		if error and error:find('more') then
			-- FIXME: depends on wording of 'No more states to pop!' error message
			love.event.quit()
		end
	end
}

return cmds
