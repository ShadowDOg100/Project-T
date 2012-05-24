class TPlayerInput extends PlayerInput within TPlayerController
	config(Input);

/** crouch */
simulated exec function Duck()
{
	if(bDuck == 0) bDuck = 1;
}

/** uncrouch */
simulated exec function UnDuck()
{
	if(bDuck == 1) bDuck = 0;
}

/** change stance */
simulated exec function ChangeStance()
{
	if(bDuck == 0)
	{
		Duck();
	}
	else
	{
		UnDuck();
	}
}

simulated exec function PickUp()
{

}

defaultproperties
{

}