class TGame extends UDKGame
	config(Game);

static event class<GameInfo> SetGameType(string MapName, string Options, string Portal)
{
    return class'TGame';
}

DefaultProperties
{
	bRestartLevel = false
	bDelayedStart = false
	bWaitingToStartMatch = true
	
	PlayerControllerClass = class'TGame.TPlayerController'
	DefaultPawnClass = class'TGame.TPawn'
	HUDType=class'TGame.TGFxHUDWrapper'
}
