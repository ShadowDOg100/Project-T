class TPickup extends Actor
        abstract;

// Light Environment
var() const editconst DynamicLightEnvironmentComponent LightEnvironment;

// Player
var TPawn Player;

// Replenish Ammo, Health, Armor
var int amount; // Final amount to replenish
var int restore; // Amount to be restored

// Weapon
var class<TWeapon> weapClass;
var TWeapon Weapon;
var int WeapSlot;
var int WeapSubClass;
var array<TWeapon> WeaponList;

// Tell what item
var string item;

// Message
var string message;

// Ammunition
var int ammo;
var int clipAmmo;

// Boolean
var bool bTouch;

/** Weapons **/
// get weapon inventory slot
function int getWeapSlot()
{
	if (Weapon != none)
        {
                return Weapon.GetInventorySlot();
        }
}

// get weapon subclass
function int getWeapSubClass()
{
	if (Weapon != none)
	{
                return Weapon.GetWeaponSubClass();
        }
}

// get weapon ammo
function int getAmmo()
{
	if (Weapon != none)
	{
                return Weapon.GetAmmoCount();
        }
}

// get weapon clip
function int getClip()
{
	if (Weapon != none)
	{
                return Weapon.GetClipCount();
        }
}

/** Pawn **/
// get pawn health
function int getHealth()
{
        if (Player != none)
        {
                return Player.getHealth();
        }
}

// set pawn health
function setHealth(int value)
{
        if (Player != none)
        {
                if (value <= 100)
                {
                        Player.setHealth(value);
                }
                else
                {
                        Player.setHealth(100);
                }
        }
}

// get pawn armor
function int getArmor()
{
        if (Player != none)
        {
                return Player.getArmor();
        }
}

// set pawn armor
function setArmor(int value)
{
        if (Player != none)
        {
                if (value <= 100)
                {
                        Player.setArmor(value);
                }
                else
                {
                        Player.setArmor(100);
                }
        }
}

// Player touches pickup actor
event Touch (Actor Other, PrimitiveComponent OtherComp, Object.Vector HitLocation, Object.Vector HitNormal)
{
        local PlayerController PC;

        PC = PlayerController(Pawn(Other).Controller);

        if (PC != none)
        {
                bTouch = true;
                Player = TPawn(Other);
                Weapon = TWeapon(Player.Weapon);
                WeapSlot = getWeapSlot();
                WeapSubClass = getWeapSubClass();
                WorldInfo.Game.BroadCast(Player,"Item touched");
        }
}

// Player untouches pickup actor
event UnTouch(Actor Other)
{
        WorldInfo.Game.BroadCast(Player,"Item untouched");
        bTouch = false;
        Player = none;
        Weapon = none;
        WeapSlot = 0;
        WeapSubClass = 0;
}

// Pickup Weapon or Item
// Have exec Pickup in HUDWrapper and from there, display the pickup menu and call Pickup() at TPickup
simulated function Pickup(optional class<TWeapon> weap)
{
        if (btouch)
        {
                weapClass = weap;

                switch(item)
                {
                        case "":
                                return;
                        break;

                        case "HP":
                                WorldInfo.Game.BroadCast(Player,"You Gained: "@restore@" Health.");
                                // PlaySound()
                                amount = getHealth() + restore;
                                setHealth(amount);
                        break;
                
                        case "AP":
                                WorldInfo.Game.BroadCast(Player,"You Gained: "@restore@" Armor.");
                                // PlaySound()
                                amount = getArmor() + restore;
                                setArmor(amount);
                        break;

                        case "WP":
                                // PlaySound()
                                Player.GetWeaponList(WeaponList,true);
                                if(WeaponList[WeapSlot] != None)
		                {
			             if(WeaponList[WeapSlot].GetWeaponSubClass() == WeapSubClass)
			             {
				            WeaponList[WeapSlot].AddStorageAmmo(getAmmo() + getClip());
				            bTouch = false;
				            Destroy();
			             }
			             else
			             {
				            //swap weapon
			             }
		                }
		                else
		                {
                                        if (Weapon != none)
                                        {
				            Player.CreateInventory(weapClass);
				            Player.GetWeaponList(WeaponList, true);
				            WeaponList[WeapSlot].SetAmmo(getAmmo());
				            WeaponList[WeapSlot].SetClip(getClip());
				        }
		                }

                        break;
                }
                
                bTouch = false;
                Destroy();
        }
        /*
                        case "WP":
                                num1 = GetWeapSlot();
		                num2 = GetWeapSubClass();
		                TP.GetWeaponList(WeaponList,true);
		                if(WeaponList[num1] != None)
		                {
			             if(WeaponList[num1].GetWeaponSubClass() == num2)
			             {
				            WeaponList[num1].AddStorageAmmo(getAmmo() + getClip());
				            Destroy();
				            (TGFxHudWrapper(PC.myHUD)).ToggleWeaponPickup();
				            bTouch = false;
			             }
			             else
			             {
				            //swap weapon
			             }
		                }
		                else
		                {
			             PC.ClientMessage("PickUp");
			             Inv = spawn(touchWeap);
			             if ( Inv != None )
			             {
				            PC.ClientMessage("PickUp");
				            TP.CreateInventory( touchWeap );
				            TP.GetWeaponList(WeaponList, true);
				            WeaponList[num1].SetAmmo(getAmmo());
				            WeaponList[num1].SetClip(getClip());
				            Destroy();
				            (TGFxHudWrapper(PC.myHUD)).ToggleWeaponPickup();
				            bTouch = false;
			             }
		                }
        */
}

defaultproperties
{
}