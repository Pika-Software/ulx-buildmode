local moduleName = 'ULX.BuildMode'
local categoryName = 'Utility'

-- Shared Meta-Functions
do

    local PLAYER = FindMetaTable( 'Player' )

    function PLAYER:InBuildMode()
        return self:GetNW2Bool( moduleName, false )
    end

end

-- Blocking blood particles and damage from/to player in build mode
do

    local IsValid = IsValid

    hook.Add( 'ScalePlayerDamage', moduleName, function( ply, _, damageInfo )
        if ply:InBuildMode() then
            return true
        end

        local att = damageInfo:GetAttacker()
        if IsValid( att ) and att:IsPlayer() and att:InBuildMode() then
            return true
        end
    end )

end

if CLIENT then

    -- Notifications
    net.Receive( moduleName, function()
        if net.ReadBool() then
            if net.ReadBool() then
                notification.AddLegacy( '#ulx.buildmode.activated', NOTIFY_GENERIC, 5 )
            else
                notification.AddLegacy( '#ulx.buildmode.deactivated', NOTIFY_GENERIC, 5 )
            end
        else
            notification.AddLegacy( '#ulx.buildmode.timeout', NOTIFY_ERROR, 5 )
        end
    end )

    -- icon in context menu
    list.Set( 'DesktopWindows', 'BuildMode', {
        ['title'] = 'PVP/Build',
        ['icon'] = 'icon16/heart.png',
        ['init'] = function()
            if LocalPlayer():InBuildMode() then
                RunConsoleCommand( 'ulx', 'pvp' )
            else
                RunConsoleCommand( 'ulx', 'build' )
            end
        end
    } )

end

do

    function ulx.buildmode( ply, disable )
        if not ply:SetBuildMode( not disable, false, false ) then return end
        ulx.fancyLogAdmin( ply, '#A changed mode to ' .. ( disable and 'pvp' or 'build' ) )
    end

    local buildmode = ulx.command( categoryName, 'ulx build', ulx.buildmode, '!build' )
    buildmode:addParam( { ['type'] = ULib.cmds.BoolArg, ['invisible'] = true } )
    buildmode:setOpposite( 'ulx pvp', { _, true }, '!pvp' )
    buildmode:defaultAccess( ULib.ACCESS_ALL )
    buildmode:help( 'Enter in buildmode' )

end

-- Admin command
do

    function ulx.forceBuild( ply, players, disable )
        for _, target in ipairs( players ) do
            if not target:SetBuildMode( not disable, false, true ) then continue end
            ulx.fancyLogAdmin( target, '#A changed mode to ' .. ( disable and 'pvp' or 'build' ) )
        end
    end

    local forcebuild = ulx.command( categoryName, 'ulx forcebuild', ulx.forceBuild, '!fbuild' )
    forcebuild:setOpposite( 'ulx forcepvp', { _, _, true }, '!fpvp' )
    forcebuild:addParam( { ['type'] = ULib.cmds.BoolArg, ['invisible'] = true } )
    forcebuild:addParam( { ['type'] = ULib.cmds.PlayersArg } )
    forcebuild:defaultAccess( ULib.ACCESS_ADMIN )
    forcebuild:help( 'Force build/pvp mode for selected players' )

end