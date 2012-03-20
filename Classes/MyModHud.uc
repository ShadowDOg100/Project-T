// http://x9productions.com/blog/?p=269
// http://udkc.info/index.php?title=Tutorials:Basic_HUD

class MyModHud extends UDKHUD
	config(TGame);

var Vector WorldOrigin;
var Vector WorldDirection;

var FontRenderInfo TextRenderInfo;

var Texture2D    CursorTexture;

/** Various colors */
var const color GoldColor;

var Vector2D    MousePosition;	
	
function vector2D GetMouseCoordinates()
{
        local Vector2D mousePos;
        local UIInteraction UIController;
        local GameUISceneClient GameSceneClient;

        UIController  = PlayerOwner.GetUIController();

        if ( UIController != None)
        {
                GameSceneClient = UIController.SceneClient;
                if ( GameSceneClient != None )
                {
                        mousePos.X = GameSceneClient.MousePosition.X;
                        mousePos.Y = GameSceneClient.MousePosition.Y;
                }
        }

        return mousePos;
}

//Canvas is only valid during PostRender phase
event PostRender()
{
        MousePosition = GetMouseCoordinates();
        //Deproject the mouse from screen coordinate to world coordinate and store World Origin and Dir.
        Canvas.DeProject(MousePosition, WorldOrigin, WorldDirection);

        //now you have the world origin and direction vector of the mouse deprojection
        //so you can do with it whatever you'd like, such as do a Trace with it to see what the mouse is pointing at
        DrawHUD();
}

function DrawBar(String Title, float Value, float MaxValue, int X, int Y, int R, int G, int B) {
	local int PosX,NbCases,i;
 
	PosX = X; // Where we should draw the next rectangle
	NbCases = 10 * Value / MaxValue; // Number of active rectangles to draw

	i=0; // Number of rectangles already drawn

 

/* Displays active rectangles */
	while(i < NbCases && i < 10)
	{
Canvas.SetPos(PosX,Y);
Canvas.SetDrawColor(R,G,B,200);
Canvas.DrawRect(8,12);

PosX += 10;
i++;
}	

 

/* Displays desactived rectangles */
while(i < 10)
{

	Canvas.SetPos(PosX,Y);

	Canvas.SetDrawColor(255,255,255,80);
	Canvas.DrawRect(8,12);

	PosX += 10;
	i++;

}
/* Displays a title */
Canvas.SetPos(PosX + 5,Y);
Canvas.SetDrawColor(R,G,B,200);
Canvas.Font = class'Engine'.static.GetSmallFont();
Canvas.DrawText(Title);
}

/**
 * This is the main drawing pump.  It will determine which hud we need to draw (Game or PostGame).  Any drawing that should occur
 * regardless of the game state should go here.
 */
function DrawHUD()
{
	local PlayerController PC;
	local TPawn TP;
	local string StringMessage;
	local TWeapon Weapon;
	local int i, j;
	
	PC = PlayerOwner;
	TP = TPawn(PC.Pawn);
	Weapon = TWeapon(TP.Weapon);
	i = Weapon.GetAmmoCount();
	j = Weapon.GetClipCount();
	
	//StringMessage = "MouseX" @ MousePosition.X @ "MouseY" @ MousePosition.Y @ "World" @ WorldOrigin @ "WorldDir" @ WorldDirection;
	//StringMessage = "AmmoCount" @ i @ "ClipCount" @ j;
	
	// now draw string with GoldColor color
	
	Canvas.DrawColor = GoldColor;
	
	Canvas.SetPos( 10, 10 );
	Canvas.DrawText( StringMessage, false, , , TextRenderInfo );

	//Set position for mouse and plot the 2d texture.
	Canvas.SetPos(Canvas.ClipX/2 - 10, Canvas.ClipY/2 - 10);
	Canvas.DrawTile(CursorTexture, 26 , 26, 380, 320, 26,26);
	
	DrawBar("Health",PlayerOwner.Pawn.Health, PlayerOwner.Pawn.HealthMax,20,20,200,80,80);
	DrawBar("Clip" @ j,j,30,20,40,80,80,200);
	DrawBar("AmmoCount" @ i,i,120,20,60,80,200,80);
	
}

DefaultProperties
{
        CursorTexture=Texture2D'UI_HUD.HUD.UTCrossHairs'
        GoldColor=(R=255,G=183,B=11,A=255)
        TextRenderInfo=(bClipText=true)
}