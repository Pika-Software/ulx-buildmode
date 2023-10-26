local moduleName = 'ULX.BuildMode'
local categoryName = 'Utility'

-- Shared Meta-Functions
do

    local PLAYER = FindMetaTable( 'Player' )

    function PLAYER:InBuildMode()
        return self:GetNW2Bool( moduleName, false )
    end

end

local IsValid = IsValid

-- Blocking blood particles and damage from/to player in build mode
hook.Add( 'ScalePlayerDamage', moduleName, function( ply, _, damageInfo )
    if ply:InBuildMode() then
        return true
    end

    local att = damageInfo:GetAttacker()
    if IsValid( att ) and att:IsPlayer() and att:InBuildMode() then
        return true
    end

    local infl = damageInfo:GetInflictor()
    if IsValid( infl ) then
        if infl:IsPlayer() and infl:InBuildMode() then
            return true
        end

        local owner = infl:GetOwner()
        if IsValid( owner ) and owner:IsPlayer() and owner:InBuildMode() then
            return true
        end
    end
end )

if CLIENT then

    local notification_AddLegacy = notification.AddLegacy
    local language_GetPhrase = language.GetPhrase
    local NOTIFY_GENERIC = NOTIFY_GENERIC
    local NOTIFY_ERROR = NOTIFY_ERROR

    -- Notifications
    net.Receive( moduleName, function()
        if net.ReadBool() then
            if net.ReadBool() then
                notification_AddLegacy( language_GetPhrase( 'ulx.buildmode.activated' ), NOTIFY_GENERIC, 5 )
            else
                notification_AddLegacy( language_GetPhrase( 'ulx.buildmode.deactivated' ), NOTIFY_GENERIC, 5 )
            end
        else
            notification_AddLegacy( language_GetPhrase( 'ulx.buildmode.timeout' ), NOTIFY_ERROR, 5 )
        end
    end )

    -- Context menu button
    list.Set( 'DesktopWindows', moduleName, {
        ['title'] = '#ulx.buildmode',
        ['icon'] = 'icon16/building.png',
        ['init'] = function( icon )
            local ply = LocalPlayer()
            ply:SetNW2VarProxy( moduleName, function( _, __, ___, newState )
                if not IsValid( icon ) then return end
                icon:SetIcon( newState and 'icon16/accept.png' or 'icon16/cancel.png' )
            end )

            if ply:InBuildMode() then
                RunConsoleCommand( 'ulx', 'pvp' )
            else
                RunConsoleCommand( 'ulx', 'build' )
            end
        end
    } )

end

-- Player Command
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

-- Admin Command
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