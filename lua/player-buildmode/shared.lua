local PLAYER = FindMetaTable( 'Player' )
local IsValid = IsValid

-- Shared Meta-Functions
function PLAYER:InBuildMode()
    return self:GetNW2Bool( 'buildmode-state', false )
end

-- Blocking blood particles and damage from/to player in build mode
hook.Add( 'ScalePlayerDamage', 'Player BuildMode::No Blood & Damage', function( ply, _, damageInfo )
    if ply:InBuildMode() then
        return true
    end

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

    return true
end )