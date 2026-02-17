with Text_IO, Kingdom_Logic;
use Text_IO, Kingdom_Logic;

procedure Kingdom is

   Game : Game_State;

begin
   Put_Line ("KINGDOM - THE GAME OF SUMERIA");
   Put_Line ("BASED ON THE CLASSIC HAMURABI");

   Initialize (Game);

   while not Is_Finished (Game) loop
      Show_Status (Game);
      Buy_Land (Game);
      if not Is_Finished (Game) then
         Sell_Land (Game);
         Feed_People (Game);
         Plant_Seeds (Game);
         Process_Year (Game);
      end if;
   end loop;

   Show_Final_Report (Game);

exception
   when Data_Error =>
      Put_Line ("HAMURABI: I DO NOT UNDERSTAND THAT NUMBER.");
   when Others =>
      Put_Line ("HAMURABI: AN UNEXPECTED ERROR OCCURRED. GOODBYE.");
end Kingdom;
