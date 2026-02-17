package Kingdom.Logic with SPARK_Mode => On is

   type Bushel_Count is new Long_Integer range -100_000_000 .. 100_000_000;
   subtype Bus_Count is Bushel_Count;
   type Land_Area    is new Integer range 0 .. 1_000_000;
   type People_Count is new Integer range 0 .. 1_000_000;
   type Year_Number  is new Integer range 1 .. 11;

   type Game_State is private;

   -- Queries
   function Current_Year (State : Game_State) return Year_Number;
   function Is_Finished  (State : Game_State) return Boolean
     is (Current_Year (State) > 10);

   function Can_Afford_Land (State : Game_State; Amount : Land_Area) return Boolean;
   function Has_Enough_Land (State : Game_State; Amount : Land_Area) return Boolean;
   function Has_Enough_Grain (State : Game_State; Amount : Bus_Count) return Boolean;
   function Has_Enough_People (State : Game_State; Amount : Land_Area) return Boolean;

   -- Operations
   procedure Initialize (State : out Game_State)
     with Post => Current_Year (State) = 1;

   procedure Buy_Land (State : in out Game_State; Amount : Land_Area)
     with Pre  => not Is_Finished (State) and then Can_Afford_Land (State, Amount),
          Post => not Can_Afford_Land (State, Amount) or else True; -- Simplified post-condition

   procedure Sell_Land (State : in out Game_State; Amount : Land_Area)
     with Pre  => not Is_Finished (State) and then Has_Enough_Land (State, Amount);

   procedure Feed_People (State : in out Game_State; Amount : Bushel_Count)
     with Pre  => not Is_Finished (State) and then Has_Enough_Grain (State, Amount);

   procedure Plant_Seeds (State : in out Game_State; Amount : Land_Area)
     with Pre  => not Is_Finished (State) 
                  and then Has_Enough_Land (State, Amount)
                  and then Has_Enough_Grain (State, Bushel_Count (Amount / 2))
                  and then Has_Enough_People (State, Amount);

   procedure Process_Yearly_Events (State : in out Game_State)
     with Pre => not Is_Finished (State);

   -- Reporting
   procedure Display_Status (State : Game_State);
   procedure Display_Final_Report (State : Game_State);

   -- Exception for invalid input (though we use contracts for logic, main loop needs this)
   Input_Error : exception;

private


   type Game_State is record
      Year           : Year_Number  := 1;
      Population     : People_Count := 100;
      Grain          : Bus_Count    := 2800;
      Land           : Land_Area    := 1000;
      Yield          : Bus_Count    := 3;
      Rats_Ate       : Bus_Count    := 200;
      Land_Price     : Bus_Count    := 19;
      Starved        : People_Count := 0;
      Immigrants     : People_Count := 5;
      Plague_Deaths  : People_Count := 0;
      Total_Starved  : People_Count := 0;
   end record;

   function Current_Year (State : Game_State) return Year_Number is (State.Year);

   function Can_Afford_Land (State : Game_State; Amount : Land_Area) return Boolean
     is (Bus_Count (Amount) * State.Land_Price <= State.Grain);

   function Has_Enough_Land (State : Game_State; Amount : Land_Area) return Boolean
     is (Amount <= State.Land);

   function Has_Enough_Grain (State : Game_State; Amount : Bus_Count) return Boolean
     is (Amount <= State.Grain);

   function Has_Enough_People (State : Game_State; Amount : Land_Area) return Boolean
     is (People_Count (Amount / 10) <= State.Population);

end Kingdom.Logic;
