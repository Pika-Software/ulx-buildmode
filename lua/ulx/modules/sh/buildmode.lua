local module_name = 'ULX.BuildMode'
local category_name = "Utility"

-- Shared Meta-Functions
do

    local PLAYER = FindMetaTable( 'Player' )

    function PLAYER:InBuildMode()
        return self:GetNWBool( module_name, false )
    end

end

if CLIENT then

    -- Language

    -- Notifications
    net.Receive(module_name, function()
        if net.ReadBool() then
            local ply = LocalPlayer()
            if IsValid( ply ) then
                if net.ReadBool() then
                    notification.AddLegacy('Now you\'re in build! Type !pvp for exit', NOTIFY_GENERIC, 5)
                    return
                end

                notification.AddLegacy('Now you\'re in pvp!', NOTIFY_GENERIC, 5)
            end

            return
        end

        notification.AddLegacy('Wait after changing mode!', NOTIFY_GENERIC, 5)
    end)

    -- icon in context menu
    do 

        list.Set( "DesktopWindows", "BuildMode", {
            title = "PVP/Build",
            icon = "icon16/heart.png",
            init = function( icon, window )
                
                if LocalPlayer():InBuildMode() then 
                    RunConsoleCommand( 'ulx', 'pvp' )
                else 
                    RunConsoleCommand( 'ulx', 'build' )
                end
                
            end
        } )
    
    end

end

do

    function ulx.buildmode( ply, disable )
        local isSuc = ply:SetBuildMode( not disable )

        if isSuc then 
            ulx.fancyLogAdmin( ply, '#A changed mode to ' .. (disable and 'pvp' or 'build') ) 
        end
    end

    local buildmode = ulx.command( category_name, 'ulx build', ulx.buildmode, '!build' )
    buildmode:addParam({ type=ULib.cmds.BoolArg, invisible=true })
    buildmode:setOpposite( 'ulx pvp', {_, true}, '!pvp' )
    buildmode:defaultAccess( ULib.ACCESS_ALL )
    buildmode:help( 'Enter in buildmode' )

end

-- Admin command
do

    function ulx.forceBuild( ply, plys, disable )
		for _, target in ipairs( plys ) do
            target:SetBuildMode( not disable, true )
            ulx.fancyLogAdmin( target, '#A changed mode to ' .. (disable and 'pvp' or 'build') )
        end
    end

    local forcebuild = ulx.command( category_name, 'ulx forcebuild', ulx.forceBuild, '!fbuild' )
    forcebuild:setOpposite( 'ulx forcepvp', {_, _, true}, '!fpvp' )
	forcebuild:addParam({ type=ULib.cmds.PlayersArg })
    forcebuild:addParam({ type=ULib.cmds.BoolArg, invisible=true })
    forcebuild:defaultAccess( ULib.ACCESS_ADMIN )
	forcebuild:help( 'Force build/pvp mode for selected players' )

end