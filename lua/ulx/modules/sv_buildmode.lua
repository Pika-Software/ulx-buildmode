local module_name = 'ULX.BuildMode'
util.AddNetworkString( module_name )

local change_delay = CreateConVar('ulx_buildmode_timeout', '5', FCVAR_ARCHIVE, ' - Delay in seconds for change bulid/pvp'):GetInt()
cvars.AddChangeCallback('ulx_buildmode_timeout', function( name, old, new )
    change_delay = tonumber( new ) or 0
end, module_name)

local kill_player = CreateConVar('ulx_buildmode_kill', '1', FCVAR_ARCHIVE, ' - Kill player on change bulid/pvp'):GetBool()
cvars.AddChangeCallback('ulx_buildmode_kill', function( name, old, new )
    kill_player = new == '1'
end, module_name)

do

    local PLAYER = FindMetaTable( 'Player' )

    function PLAYER:SetBuildMode( bool )
        assert( isbool( bool ), 'Argument #1 must be a boolean!' )
        if (self:InBuildMode() == bool) then return end
        if ((self[module_name] or 0) > CurTime()) then
            net.Start( module_name )
                net.WriteBool( false )
            net.Send( self )
            return
        end

        self[module_name] = CurTime() + change_delay
        self:SetNWBool( module_name, bool )

        if kill_player then
            self:KillSilent()
        end

        net.Start( module_name )
            net.WriteBool( true )
        net.Send( self )
    end

end

hook.Add('PlayerShouldTakeDamage', module_name, function( ply, att )
	if ply:InBuildMode() then return false end
end)

hook.Add('PlayerNoClip', module_name, function( ply, state )
    if ply:InBuildMode() then return true end
end)

hook.Add('EntityTakeDamage', module_name, function( ent, dmg )
    local att = dmg:GetAttacker()
    if IsValid( att ) and att:IsPlayer() and att:InBuildMode() then
        return true
    end
end)
