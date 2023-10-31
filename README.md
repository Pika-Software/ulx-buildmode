# Garry's Mod Addon - ULX Buildmode
## Features
- Universal and easy Developer API.
- Multilanguage ( By default supports: en, uk, ru ).
- Lightweight, very little code, maximum code performance.

## Server-side ConVars
- `ulx_buildmode_timeout` <`5`> - Delay in seconds between switch buildmode or pvp.
- `ulx_buildmode_respawn` <`1`> - Respawns player if he leaves buildmode.

## Developer API
### A shared player meta function, returns true if the player is in build mode and false if not.
```lua
PLAYER:InBuildMode()
```

### A server-side hook, called when a player tries to change the buildmode state, return here true allows the player to change the buildmode state to requested state.
```lua
GM:CanPlayerBuildMode( ply, currentState, requestedState )
```

### A server-side hook called after a player changes build mode.
```lua
GM:PlayerToggledBuildMode( ply, oldState, newState )
```
