--[[

        zZz
    \__/
    (--)
   //||\\

--]]

if SERVER then
    AddCSLuaFile( "player-buildmode/cl_init.lua" )
    include( "player-buildmode/init.lua" )
elseif CLIENT then
    include( "player-buildmode/cl_init.lua" )
end