include( 'player-buildmode/shared.lua' )

local notification_AddLegacy = notification.AddLegacy
local language_GetPhrase = language.GetPhrase
local NOTIFY_GENERIC = NOTIFY_GENERIC
local NOTIFY_ERROR = NOTIFY_ERROR
local net_ReadBool = net.ReadBool

-- Notifications
net.Receive( 'player-buildmode-network', function()
    if net_ReadBool() then
        if net_ReadBool() then
            notification_AddLegacy( language_GetPhrase( 'player.buildmode.activated' ), NOTIFY_GENERIC, 5 )
        else
            notification_AddLegacy( language_GetPhrase( 'player.buildmode.deactivated' ), NOTIFY_GENERIC, 5 )
        end
    else
        notification_AddLegacy( language_GetPhrase( 'player.buildmode.timeout' ), NOTIFY_ERROR, 5 )
    end
end )

-- Context menu button
local ply = nil
list.Set( 'DesktopWindows', 'Player BuildMode', {
    ['title'] = '#player.buildmode',
    ['icon'] = 'icon16/building.png',
    ['init'] = function( icon )
        if not ply then
            ply = LocalPlayer()
            if not IsValid( ply ) then
                return
            end

            ply:SetNW2VarProxy( 'buildmode-state', function( _, __, ___, newState )
                if not IsValid( icon ) then return end
                icon:SetIcon( newState and 'icon16/accept.png' or 'icon16/cancel.png' )
            end )
        end

        net.Start( 'player-buildmode-network' )
            net.WriteBool( not ply:InBuildMode() )
        net.SendToServer()
    end
} )