class TGame extends UDKGame;

static event class<GameInfo> SetGameType(string MapName, string Options, string Portal)
{
    return class'TGame';
}
 
function PrintScreenDebug(string debugText)
{
    local PlayerController PC;
    PC = PlayerController(Pawn(Owner).Controller);
    if (PC != None)
       PC.ClientMessage("TGame: " $ debugText);
} 
 
function PostBeginPlay()
{
	Super.PostBeginPlay();
}
 
DefaultProperties
{
	HUDType=class'TGame.TGFxHUDWrapper'
	PlayerControllerClass=class'TGame.TPlayerController'
	DefaultPawnClass=class'TGame.TPawn'
}