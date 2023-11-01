AddCSLuaFile( 'player-buildmode/shared.lua' )
include( 'player-buildmode/shared.lua' )

local conVarFlags = bit.bor( FCVAR_ARCHIVE, FCVAR_NOTIFY )
local hook_Add = hook.Add
local IsValid = IsValid
local net = net

-- Default limit - buildmode activation timeout
do

    local mp_buildmode_timeout = CreateConVar( 'mp_buildmode_timeout', '5', conVarFlags, 'Delay in seconds between switch buildmode or pvp.', 0, 86400 )
    local CurTime = CurTime

    hook_Add( 'CanPlayerBuildMode', 'Player BuildMode::Default Limits', function( ply, _, requestedState )
        if not requestedState then return end

        local lastBuildModeChange = ply.LastBuildModeChange
        if not lastBuildModeChange then return end

        local curTime = CurTime()
        if ( curTime - lastBuildModeChange ) < mp_buildmode_timeout:GetFloat() then
            -- ply.LastBuildModeChange = curTime
            return false
        end
    end )

    hook_Add( 'PlayerToggledBuildMode', 'Player BuildMode::Default Limits', function( ply, _, requestedState )
        if not requestedState then return end
        ply.LastBuildModeChange = CurTime()
    end )

end

-- Default feature - respawn on buildmode activation
do

    local mp_buildmode_respawn = CreateConVar( 'mp_buildmode_respawn', '1', conVarFlags, 'Respawns player if he leaves build mode.', 0, 1 )
    local timer_Simple = timer.Simple

    hook_Add( 'PlayerToggledBuildMode', 'Player BuildMode::Default Features', function( ply, _, requestedState )
        if requestedState or not mp_buildmode_respawn:GetBool() then return end
        ply:KillSilent()

        timer_Simple( 0.025, function()
            if IsValid( ply ) and not ply:Alive() then
                ply:Spawn()
            end
        end )
    end )

end

-- Server-Side Meta-Functions
do

    local PLAYER = FindMetaTable( 'Player' )
    local hook_Run = hook.Run
    local assert = assert
    local isbool = isbool

    function PLAYER:SetBuildMode( requestedState, hideNotification, force )
        assert( isbool( requestedState ), 'Argument #1 must be a boolean!' )

        local currentState = self:InBuildMode()
        if currentState == requestedState then
            return false
        end

        if force or hook_Run( 'CanPlayerBuildMode', self, currentState, requestedState ) ~= false then
            self:SetNW2Bool( 'buildmode-state', requestedState )

            if not hideNotification then
                net.Start( 'player-buildmode-network' )
                    net.WriteBool( true )
                    net.WriteBool( requestedState )
                net.Send( self )
            end

            hook_Run( 'PlayerToggledBuildMode', self, currentState, requestedState )
            return true
        end

        if not hideNotification then
            net.Start( 'player-buildmode-network' )
                net.WriteBool( false )
            net.Send( self )
        end

        return false
    end

end

-- Networking
util.AddNetworkString( 'player-buildmode-network' )
net.Receive( 'player-buildmode-network', function( _, ply )
    ply:SetBuildMode( net.ReadBool(), false, false )
end )

-- Allow buildmode players noclip
hook_Add( 'PlayerNoClip', 'Player BuildMode::Noclip', function( ply, desiredState )
    if desiredState then
        if ply:InBuildMode() then
            return true
        end
    else
        return true
    end
end )

-- Blocking damage from/to player in build mode
hook_Add( 'PlayerShouldTakeDamage', 'Player BuildMode::No Player Damage', function( ply, attacker )
    if ply:InBuildMode() or ( IsValid( attacker ) and attacker:IsPlayer() and attacker:InBuildMode() ) then
        return false
    end
end )

-- Blocking damage from/to other entities in build mode
local isfunction = isfunction
local IsEntity = IsEntity

hook_Add( 'EntityTakeDamage', 'Player BuildMode::No Entity Damage', function( entity, damageInfo )
    local attacker = damageInfo:GetAttacker()
    if IsValid( attacker ) and attacker:IsPlayer() then
        if not attacker:InBuildMode() then return end
    else
        local inflictor = damageInfo:GetInflictor()
        if not IsValid( inflictor ) then return end

        if inflictor:IsWeapon() then
            attacker = inflictor:GetOwner()
            if not IsValid( attacker ) then
                attacker = inflictor:GetCreator()
                if not IsValid( attacker ) then return end
            end

            if not attacker:IsPlayer() then return end
        elseif inflictor:IsPlayer() then
            attacker = inflictor
        else
            return
        end

        if not attacker:InBuildMode() then return end
    end

    if entity:IsPlayer() then
        if entity == attacker then return end
        return true
    end

    local owner = nil

    -- FUCK CPPI - idiot came up with the idea of returning numbers in case of no implementation.
    if isfunction( entity.CPPIGetOwner ) then
        owner = entity:CPPIGetOwner()
    end

    -- https://wiki.facepunch.com/gmod/Entity:GetRagdollOwner
    if not owner or not IsEntity( owner ) or not IsValid( owner ) then
        owner = entity:GetRagdollOwner()
    end

    -- https://wiki.facepunch.com/gmod/Entity:GetCreator
    if not owner or not IsEntity( owner ) or not IsValid( owner ) then
        owner = entity:GetCreator()
    end

    -- https://wiki.facepunch.com/gmod/Entity:GetOwner
    if not owner or not IsEntity( owner ) or not IsValid( owner ) then
        owner = entity:GetOwner()
    end

    if owner ~= attacker then
        return true
    end
end )