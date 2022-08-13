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
    language.Add( 'buildmode.enter', 'Enter in buildmode' )
    language.Add( 'buildmode.notifyEnter', 'Now you in build! Type !pvp for exit' )
    language.Add( 'buildmode.notifyExit', 'Now you in pvp!' )
    language.Add( 'buildmode.errorChange', 'Wait after changing mode!' )
    language.Add( 'buildmode.fancyNotify', '#A changed mode to #T' )

    -- Notifications
    net.Receive(module_name, function()
        if net.ReadBool() then
            local ply = LocalPlayer()
            if IsValid( ply ) then
                if ply:InBuildMode() then
                    notification.AddLegacy('#buildmode.notifyEnter', NOTIFY_GENERIC, 5)
                    return
                end

                notification.AddLegacy('#buildmode.notifyExit', NOTIFY_GENERIC, 5)
            end

            return
        end

        notification.AddLegacy('#buildmode.errorChange', NOTIFY_GENERIC, 5)
    end)

end

do

    function ulx.buildmode( ply, disable )
        ply:SetBuildMode( not disable )
        ulx.fancyLogAdmin( ply, '#buildmode.fancyNotify', disable and 'pvp' or 'build' )
    end

    local buildmode = ulx.command( category_name, 'ulx build', ulx.buildmode, '!build' )
    buildmode:help( '#buildmode.enter' )
    buildmode:defaultAccess( ULib.ACCESS_ALL )

    buildmode:setOpposite( 'ulx pvp', {_, true}, '!pvp' )
    buildmode:setOpposite( 'ulx unbuild', {_, true}, '!unbuild' )

end

-- Admin command
do

    function ulx.forceBuild( calling_ply, target_plys, disable )
		for _, ply in ipairs( target_plys ) do
            ply:SetForceBuildMode( not disable )
            ulx.fancyLogAdmin( target, '#buildmode.fancyNotify', disable and 'pvp' or 'build' )
        end
    end

    local forcebuild = ulx.command( category_name, 'ulx forcebuild', ulx.forceBuild, '!fbuild' )
	forcebuild:addParam({ type=ULib.cmds.PlayersArg })
	forcebuild:help( '#buildmode.force' )
    forcebuild:defaultAccess( ULib.ACCESS_ADMIN )

    forcebuild:setOpposite( 'ulx forcepvp', {_, true}, '!fpvp' )
    buildmode:setOpposite( 'ulx forceunbuild', {_, true}, '!funbuild' )

end