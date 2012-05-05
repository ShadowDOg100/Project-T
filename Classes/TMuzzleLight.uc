class TMuzzleLight extends UDKExplosionLight;

defaultproperties
{
	HighDetailFrameTime = 0.02f;
	Brightness = 10
	Radius = 256
	LightColor = (R=255, G=255, B=255)
	
	TimeShift(0) = (StartTime=0.0, Radius=160, Brightness=8, LightColor=(R=255, G=255, B=255, A=255)
	TimeShift(1) = (StartTime=0.2, Radius=96, Brightness=5, LightColor=(R=255, G=255, B=255, A=255)
	TimeShift(2) = (StartTime=0.25, Radius=96, Brightness=0, LightColor=(R=255, G=255, B=255, A=255)
}