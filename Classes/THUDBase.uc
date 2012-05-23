class THUDBase extends UDKHUD
	dependson(TWeapon)
	config(Game);

/** GFx movie used for displaying pause menu */
var GFxUI_PauseMenu		PauseMenuMovie;

/** class of dynamic music manager used with this hud/gametype */

/** Cached a typed Player controller.  Unlike PawnOwner we only set this once in PostBeginPlay */
var TPlayerController TPlayerOwner;

/** Whether to let actor overlays get drawn this tick */
var bool	bEnableActorOverlays;

var TextureCoordinates ToolTipSepCoords;
var float LastTimeTooltipDrawn;

var const Texture2D IconHudTexture;

/** Holds a reference to the font to use for a given console */
var config string ConsoleIconFontClassName;

/** If true, we will allow Weapons to show their crosshairs */
var bool bCrosshairShow;

/** If true, we will alter the crosshair when it's over a friendly */
var bool bCrosshairOnFriendly;

/** Make the crosshair green (found valid friendly */
var bool bGreenCrosshair;

/** Configurable crosshair scaling */
var float ConfiguredCrosshairScaling;

/** Used to pulse crosshair size */
var float LastPickupTime;

/** Various colors */
var const color BlackColor, GoldColor;

var const color LightGoldColor, LightGreenColor;

/** Holds the scaling factor given the current resolution.  This is calculated in PostRender() */
var float ResolutionScale, ResolutionScaleX;

/** Cache viewport size to determine if it has changed */
var int ViewX, ViewY;

var bool bHudMessageRendered;

simulated function PostBeginPlay()
{
	local Pawn P;

	super.PostBeginPlay();

	TPlayerOwner = TPlayerController(PlayerOwner);

	SetTimer(1.0, true);

	// add actors to the PostRenderedActors array
	ForEach DynamicActors(class'Pawn', P)
	{
		if ( (TPawn(P) != None) || (UTVehicle(P) != None) )
			AddPostRenderedActor(P);
	}

	// find the controller icons font
	ConsoleIconFont=Font(DynamicLoadObject(ConsoleIconFontClassName, class'font', true));
}

simulated event Timer()
{
	Super.Timer();
}


exec function ShowMenu()
{
	// if using GFx HUD, use GFx pause menu
	TogglePauseMenu();
}

/** 
  * Reset movies since resolution changed
  */
function ResolutionChanged()
{
	local bool bNeedPauseMenuMovie;

	bNeedPauseMenuMovie = PauseMenuMovie != none && PauseMenuMovie.bMovieIsOpen;

	RemoveMovies();
	if ( bNeedPauseMenuMovie )
	{
		TogglePauseMenu();
	}
}

/**
 * PostRender is the main draw loop.
 */
event PostRender()
{
	// Clear the flag
	bHudMessageRendered = false;

	RenderDelta = WorldInfo.TimeSeconds - LastHUDRenderTime;
	LastHUDRenderTime = WorldInfo.TimeSeconds;

	ResolutionScaleX = Canvas.ClipX/1024;
	ResolutionScale = Canvas.ClipY/768;

	if ( (ViewX != Canvas.ClipX) || (ViewY != Canvas.ClipY) )
	{
		ResolutionChanged();
		ViewX = Canvas.ClipX;
		ViewY = Canvas.ClipY;
	}
}

/*
 * Complete close of Scoreboard.  Fired from Flash
 * when the "close" animation is finished.
 */
function OnCloseAnimComplete()
{
}

/*
 * Complete open of Scoreboard.  Fired from Flash
 * when the "open" animation is finished.
 */
function OnOpenAnimComplete()
{
}

/** 
  * Destroy existing Movies
  */
function RemoveMovies()
{
	if (PauseMenuMovie != None)
	{
		PauseMenuMovie.Close(true);
		PauseMenuMovie = None;
	}
}

/** 
 *  Toggles visibility of normal in-game HUD
 */
function SetVisible(bool bNewVisible)
{
	bEnableActorOverlays = bNewVisible;
	bShowHUD = bNewVisible;
}

/** 
  * Called when pause menu is opened
  */
function CloseOtherMenus();

/*
 * Toggle the Pause Menu on or off.
 * 
 */
function TogglePauseMenu()
{
    if ( PauseMenuMovie != none && PauseMenuMovie.bMovieIsOpen )
	{
		
		if( !WorldInfo.IsPlayInMobilePreview() )
		{
			PauseMenuMovie.PlayCloseAnimation();
		}
		else
		{
			// On mobile previewer, close right away
			CompletePauseMenuClose();
		}
	}
	else
    {
		CloseOtherMenus();

        PlayerOwner.SetPause(True);

        if (PauseMenuMovie == None)
        {
	        PauseMenuMovie = new class'GFxUI_PauseMenu';
            PauseMenuMovie.MovieInfo = SwfMovie'UDKHud.udk_pausemenu'; //movie for pause menu
            PauseMenuMovie.bEnableGammaCorrection = FALSE;
			PauseMenuMovie.LocalPlayerOwnerIndex = class'Engine'.static.GetEngine().GamePlayers.Find(LocalPlayer(PlayerOwner.Player));
            PauseMenuMovie.SetTimingMode(TM_Real);
        }

		SetVisible(false);
        PauseMenuMovie.Start();
        PauseMenuMovie.PlayOpenAnimation();

		// Do not prevent 'escape' to unpause if running in mobile previewer
		if( !WorldInfo.IsPlayInMobilePreview() )
		{
			PauseMenuMovie.AddFocusIgnoreKey('Escape');
		}
    }
}

/*
 * Complete necessary actions for OnPauseMenuClose.
 * Fired from Flash.
 */
function CompletePauseMenuClose()
{
    PlayerOwner.SetPause(False);
    PauseMenuMovie.Close(false);  // Keep the Pause Menu loaded in memory for reuse.
    SetVisible(true);
}

/** 
  * Returns the index of the local player that owns this HUD
  */
function int GetLocalPlayerOwnerIndex()
{
	return class'Engine'.static.GetEngine().GamePlayers.Find(LocalPlayer(PlayerOwner.Player));
}

//Given a input command of the form GBA_ and its mapping store that in a lookup for future use
function DrawToolTip(Canvas Cvs, PlayerController PC, string Command, float X, float Y, float U, float V, float UL, float VL, float ResScale, optional Texture2D IconTexture = default.IconHudTexture, optional float Alpha=1.0)
{
	local float Left,xl,yl;
	local float ScaleX, ScaleY;
	local float WholeWidth;
	local string MappingStr; //String of key mapping
	local font OrgFont, BindFont;
	local string Key;

	//Catchall for spectators who don't need tooltips
	if (PC.PlayerReplicationInfo.bOnlySpectator || LastTimeTooltipDrawn == WorldInfo.TimeSeconds)
	{
		return;
	}

	//Only draw one tooltip per frame
	LastTimeTooltipDrawn = WorldInfo.TimeSeconds;

	OrgFont = Cvs.Font;

	//Get the fully localized version of the key binding
	TPlayerController(PC).BoundEventsStringDataStore.GetStringWithFieldName(Command, MappingStr);
	if (MappingStr == "")
	{
		`warn("No mapping for command"@Command);
		return;
	}

	TranslateBindToFont(MappingStr, BindFont, Key);

	if ( BindFont != none )
	{
		//These values might be negative (for flipping textures)
		ScaleX = abs(UL);
		ScaleY = abs(VL);
		Cvs.DrawColor = default.WhiteColor;
		Cvs.DrawColor.A = Alpha * 255;

		//Find the size of the string to be draw
		Cvs.Font = BindFont;
		Cvs.StrLen(Key, XL,YL);

		//Figure the offset from center for the left side
		WholeWidth = XL + (ScaleX * ResScale) + (default.ToolTipSepCoords.UL * ResScale);
		Left = X - (WholeWidth * 0.5);

		//Center and draw the key binding string
		Cvs.SetPos(Left, Y - (YL * 0.5));
		Cvs.DrawText(Key, true, , , TextRenderInfo);

		//Position to the end of the keybinding string
		Left += XL;
		Cvs.SetPos(Left, Y - (default.ToolTipSepCoords.VL * ResScale * 0.5));
		//Draw the separation icon (arrow)
		Cvs.DrawTile(default.IconHudTexture,default.ToolTipSepCoords.UL * ResScale, default.ToolTipSepCoords.VL * ResScale,
			default.ToolTipSepCoords.U,default.ToolTipSepCoords.V,default.ToolTipSepCoords.UL,default.ToolTipSepCoords.VL);

		//Position to the end of the separation icon
		Left += (default.ToolTipSepCoords.UL * ResScale);
		Cvs.SetPos(Left, Y - (ScaleY * ResScale * 0.5) );
		//Draw the tooltip icon
		Cvs.DrawTile(IconTexture, ScaleX * ResScale, ScaleY * ResScale, U, V, UL, VL);
	}

	Cvs.Font = OrgFont;
}

simulated function DrawShadowedTile(texture2D Tex, float X, float Y, float XL, float YL, float U, float V, float UL, float VL, Color TileColor, Optional bool bScaleToRes)
{
	local Color B;

	B = BlackColor;
	B.A = TileColor.A;

	XL *= (bScaleToRes) ? ResolutionScale : 1.0;
	YL *= (bScaleToRes) ? ResolutionScale : 1.0;

	Canvas.SetPos(X+1,Y+1);
	Canvas.DrawColor = B;
	Canvas.DrawTile(Tex,XL,YL,U,V,UL,VL);
	Canvas.SetPos(X,Y);
	Canvas.DrawColor = TileColor;
	Canvas.DrawTile(Tex,XL,YL,U,V,UL,VL);
}

simulated function DrawShadowedStretchedTile(texture2D Tex, float X, float Y, float XL, float YL, float U, float V, float UL, float VL, Color TileColor, Optional bool bScaleToRes)
{
	local LinearColor C,B;

	C = ColorToLinearColor(TileColor);
	B = ColorToLinearColor(BlackColor);
	B.A = C.A;

	XL *= (bScaleToRes) ? ResolutionScale : 1.0;
	YL *= (bScaleToRes) ? ResolutionScale : 1.0;

	Canvas.SetPos(X+1,Y+1);
	Canvas.DrawTileStretched(Tex,XL,YL,U,V,UL,VL,B);
	Canvas.SetPos(X,Y);
	Canvas.DrawColor = TileColor;
	Canvas.DrawTileStretched(Tex,XL,YL,U,V,UL,VL,C);
}

simulated function DrawShadowedRotatedTile(texture2D Tex, Rotator Rot, float X, float Y, float XL, float YL, float U, float V, float UL, float VL, Color TileColor, Optional bool bScaleToRes)
{
	local Color B;

	B = BlackColor;
	B.A = TileColor.A;

	XL *= (bScaleToRes) ? ResolutionScale : 1.0;
	YL *= (bScaleToRes) ? ResolutionScale : 1.0;

	Canvas.SetPos(X+1,Y+1);
	Canvas.DrawColor = B;
	Canvas.DrawRotatedTile(Tex,Rot,XL,YL,U,V,UL,VL);
	Canvas.SetPos(X,Y);
	Canvas.DrawColor = TileColor;
	Canvas.DrawRotatedTile(Tex,Rot,XL,YL,U,V,UL,VL);
}

function DisplayHUDMessage(string Message, optional float XOffsetPct = 0.05, optional float YOffsetPct = 0.05)
{
	local float XL,YL;
	local float BarHeight, Height, YBuffer, XBuffer, YCenter;

	if (!bHudMessageRendered)
	{
		// Preset the Canvas
		Canvas.SetDrawColor(255,255,255,255);
		Canvas.Font = GetFontSizeIndex(2);
		Canvas.StrLen(Message,XL,YL);

		// Figure out sizes/positions
		BarHeight = YL * 1.1;
		YBuffer = Canvas.ClipY * YOffsetPct;
		XBuffer = Canvas.ClipX * XOffsetPct;
		Height = YL * 2.0;

		YCenter = Canvas.ClipY - YBuffer - (Height * 0.5);

		// Draw the Bar
		Canvas.SetPos(0,YCenter - (BarHeight * 0.5) );
		Canvas.DrawTile(AltHudTexture, Canvas.ClipX, BarHeight, 382, 441, 127, 16);

		// Draw the Symbol
		Canvas.SetPos(XBuffer, YCenter - (Height * 0.5));
		Canvas.DrawTile(AltHudTexture, Height * 1.33333, Height, 734,190, 82, 70);

		// Draw the Text
		Canvas.SetPos(XBuffer + Height * 1.5, YCenter - (YL * 0.5));
		Canvas.DrawText(Message);

		bHudMessageRendered = true;
	}
}

defaultproperties
{
	ToolTipSepCoords=(U=260,V=379,UL=29,VL=27)
	IconHudTexture=Texture2D'UI_HUD.HUD.UI_HUD_BaseB'
	BindTextFont=MultiFont'UI_Fonts_Final.HUD.MF_Large'
	ConfiguredCrosshairScaling=1.0

	BlackColor=(R=0,G=0,B=0,A=255)
	GoldColor=(R=255,G=183,B=11,A=255)
	LightGoldColor=(R=255,G=255,B=128,A=255)
	LightGreenColor=(R=128,G=255,B=128,A=255)
}


