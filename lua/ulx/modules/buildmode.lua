local moduleName = 'ULX.BuildMode'
util.AddNetworkString( moduleName )

local conVarFlags = bit.bor( FCVAR_ARCHIVE, FCVAR_NOTIFY )

-- Default limit - buildmode activation timeout
do

    local ulx_buildmode_timeout = CreateConVar( 'ulx_buildmode_timeout', '5', conVarFlags, 'Delay in seconds between switch buildmode or pvp.', 0, 86400 )
    local CurTime = CurTime

    hook.Add( 'CanPlayerBuildMode', 'DefaultLimits', function( ply, _, requestedState )
        if not requestedState then return end

        local lastBuildModeChange = ply.LastBuildModeChange
        if lastBuildModeChange and ( CurTime() - lastBuildModeChange ) > ulx_buildmode_timeout:GetFloat() then
            return false
        end
    end )

    hook.Add( 'PlayerToggledBuildMode', 'DefaultLimits', function( ply, _, requestedState )
        if not requestedState then return end
        ply.LastBuildModeChange = CurTime()
    end )

end

local IsValid = IsValid

-- Default feature - respawn on buildmode activation
do

    local ulx_buildmode_respawn = CreateConVar( 'ulx_buildmode_respawn', '1', conVarFlags, 'Respawns player if he leaves build mode.', 0, 1 )
    local timer_Simple = timer.Simple

    hook.Add( 'PlayerToggledBuildMode', 'DefaultFeatures', function( ply, _, requestedState )
        if requestedState or not ulx_buildmode_respawn:GetBool() then return end
        ply:KillSilent()

        timer_Simple( 0.25, function()
            if IsValid( ply ) and not ply:Alive() then
                ply:Spawn()
            end
        end )
    end )

end

-- Server-Side Meta-Functions
do

    local TEAM_SPECTATOR = TEAM_SPECTATOR

    local function canBuildMode( ply, requestedState )
        local currentState = ply:InBuildMode()
        if currentState == requestedState then
            return true
        end

        local hookResult = hook.Run( 'CanPlayerBuildMode', ply, currentState, requestedState )
        if hookResult ~= nil then
            return hookResult == true
        end

        return ply:IsFullyAuthenticated() and ply:Alive() and ply:Team() ~= TEAM_SPECTATOR
    end

    local PLAYER = FindMetaTable( 'Player' )
    local assert = assert
    local isbool = isbool

    function PLAYER:SetBuildMode( requestedState, hideNotification, force )
        assert( isbool( requestedState ), 'Argument #1 must be a boolean!' )

        if force or canBuildMode( self, requestedState ) then
            self:SetNW2Bool( moduleName, requestedState )

            if not hideNotification then
                net.Start( moduleName )
                    net.WriteBool( true )
                    net.WriteBool( requestedState )
                net.Send( self )
            end

            hook.Run( 'PlayerToggledBuildMode', self, currentState, requestedState )
            return true
        end

        if not hideNotification then
            net.Start( moduleName )
                net.WriteBool( false )
            net.Send( self )
        end

        return false
    end

end

-- Allow buildmode players noclip
hook.Add( 'PlayerNoClip', moduleName, function( ply, state )
    if ply:InBuildMode() then
        return true
    end
end )

-- Blocking damage from/to player in build mode
hook.Add( 'PlayerShouldTakeDamage', moduleName, function( ply, att )
    if ply:InBuildMode() or ( IsValid( att ) and att:IsPlayer() and att:InBuildMode() ) then
        return false
    end
end )
