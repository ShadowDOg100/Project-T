class GFxUI_PickUp extends UTGFxTweenableMoviePlayer;

var GFxObject RootMC;
var bool bInit;

function bool Start(optional bool UpdatedEquipped)
{	
	Super.Start();
	Advance(0);
    
    if(!bInit)
	{
        init();
	}
	
	return true;
}

function setText(String message)
{
	if(message == "pickup")
	{
		RootMC.GotoAndStopI(0);
	}
	else if(message == "swap")
	{
		RootMC.GotoAndStopI(1);
	}
}

function init(optional LocalPlayer LocPlay)
{
	RootMC = GetVariableObject("_root");
    bInit = true;
}

defaultproperties
{
    bInit = false;
	bIgnoreMouseInput=TRUE
    bEnableGammaCorrection = FALSE
    bDisplayWithHudOff = TRUE
	MovieInfo=SwfMovie'T.UI.PickUp'
}