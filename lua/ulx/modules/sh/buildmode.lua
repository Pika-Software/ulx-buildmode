-- Player Command
do

    function ulx.buildmode( ply, disable )
        if not ply:SetBuildMode( not disable, false, false ) then return end
        ulx.fancyLogAdmin( ply, '#A changed mode to ' .. ( disable and 'pvp' or 'build' ) )
    end

    local buildmode = ulx.command( 'Utility', 'ulx build', ulx.buildmode, '!build' )
    buildmode:addParam( { ['type'] = ULib.cmds.BoolArg, ['invisible'] = true } )
    buildmode:setOpposite( 'ulx pvp', { _, true }, '!pvp' )
    buildmode:defaultAccess( ULib.ACCESS_ALL )
    buildmode:help( 'Changing your game mode.' )

end

-- Admin Command
do

    function ulx.forceBuild( ply, players, disable )
        for _, target in ipairs( players ) do
            if not target:SetBuildMode( not disable, false, true ) then continue end
            ulx.fancyLogAdmin( target, '#A changed mode to ' .. ( disable and 'pvp' or 'build' ) )
        end
    end

    local forcebuild = ulx.command( 'Utility', 'ulx forcebuild', ulx.forceBuild, '!fbuild' )
    forcebuild:setOpposite( 'ulx forcepvp', { _, _, true }, '!fpvp' )
    forcebuild:addParam( { ['type'] = ULib.cmds.PlayersArg } )
    forcebuild:addParam( { ['type'] = ULib.cmds.BoolArg, ['invisible'] = true } )
    forcebuild:defaultAccess( ULib.ACCESS_ADMIN )
    forcebuild:help( 'Force build/pvp mode for selected players.' )

end