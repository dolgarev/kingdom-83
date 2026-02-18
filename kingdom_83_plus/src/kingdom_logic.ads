package Kingdom_Logic is

   type Bushels is private;
   type Acres   is private;
   type People  is private;

   type Game_State is limited private;

   procedure Initialize (State : in out Game_State);
   
   -- Game flow operations
   procedure Show_Status (State : in Game_State);
   procedure Buy_Land    (State : in out Game_State);
   procedure Sell_Land   (State : in out Game_State);
   procedure Feed_People (State : in out Game_State);
   procedure Plant_Seeds (State : in out Game_State);
   procedure Process_Year (State : in out Game_State);
   
   function Is_Finished (State : in Game_State) return Boolean;
   procedure Show_Final_Report (State : in Game_State);

private

   type Bushels is new Integer range -1000000 .. 1000000;
   type Acres   is new Integer range 0 .. 1000000;
   type People  is new Integer range 0 .. 1000000;

   type Game_State is record
      Year           : Integer;
      Population     : People;
      Grain          : Bushels;
      Land           : Acres;
      Yield          : Bushels;
      Rats_Ate       : Bushels;
      Land_Price     : Bushels;
      Starved        : People;
      Immigrants     : People;
      Plague_Deaths  : People;
      Total_Starved  : People;
   end record;

end Kingdom_Logic;
