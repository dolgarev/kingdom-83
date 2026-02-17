with Ada.Text_IO;
with Ada.Numerics.Discrete_Random;
with Ada.Numerics.Float_Random;

package body Kingdom.Logic is

   package TIO renames Ada.Text_IO;

   -- Random Number Generation for different types
   package Random_Land is new Ada.Numerics.Discrete_Random (Land_Area);
   package Random_Bushel is new Ada.Numerics.Discrete_Random (Bus_Count);
   package Random_Integer is new Ada.Numerics.Discrete_Random (Integer);

   Land_Gen   : Random_Land.Generator;
   Bush_Gen   : Random_Bushel.Generator;
   Int_Gen    : Random_Integer.Generator;
   Float_Gen  : Ada.Numerics.Float_Random.Generator;

   procedure Initialize (State : out Game_State) is
   begin
      State := (Year           => 1,
                Population     => 100,
                Grain          => 2800,
                Land           => 1000,
                Yield          => 3,
                Rats_Ate       => 200,
                Land_Price     => 19,
                Starved        => 0,
                Immigrants     => 5,
                Total_Starved  => 0,
                others         => 0);
      
      -- Reset generators
      Random_Land.Reset (Land_Gen);
      Random_Bushel.Reset (Bush_Gen);
      Random_Integer.Reset (Int_Gen);
      Ada.Numerics.Float_Random.Reset (Float_Gen);
   end Initialize;

   procedure Display_Status (State : Game_State) is
   begin
      TIO.New_Line;
      TIO.Put_Line ("HAMURABI: I BEG TO REPORT TO YOU,");
      TIO.Put ("IN YEAR " & Year_Number'Image (State.Year) & ", ");
      TIO.Put (People_Count'Image (State.Starved) & " PEOPLE STARVED, ");
      TIO.Put_Line (People_Count'Image (State.Immigrants) & " CAME TO THE CITY.");

      if State.Plague_Deaths > 0 then
         TIO.Put_Line ("A HORRIBLE PLAGUE STRUCK! " & People_Count'Image (State.Plague_Deaths) & " PEOPLE DIED.");
      end if;

      TIO.Put_Line ("POPULATION IS NOW " & People_Count'Image (State.Population));
      TIO.Put_Line ("THE CITY NOW OWNS " & Land_Area'Image (State.Land) & " ACRES.");
      TIO.Put_Line ("YOU HARVESTED " & Bus_Count'Image (State.Yield) & " BUSHELS PER ACRE.");
      TIO.Put_Line ("RATS ATE " & Bus_Count'Image (State.Rats_Ate) & " BUSHELS.");
      TIO.Put_Line ("YOU NOW HAVE " & Bus_Count'Image (State.Grain) & " BUSHELS IN STORE.");
      TIO.New_Line;
   end Display_Status;

   procedure Buy_Land (State : in out Game_State; Amount : Land_Area) is
      Price : constant Bus_Count := Bus_Count (Amount) * State.Land_Price;
   begin
      State.Land  := State.Land + Amount;
      State.Grain := State.Grain - Price;
   end Buy_Land;

   procedure Sell_Land (State : in out Game_State; Amount : Land_Area) is
      Gain : constant Bus_Count := Bus_Count (Amount) * State.Land_Price;
   begin
      State.Land  := State.Land - Amount;
      State.Grain := State.Grain + Gain;
   end Sell_Land;

   procedure Feed_People (State : in out Game_State; Amount : Bushel_Count) is
      Num_Fed : constant People_Count := People_Count (Amount / 20);
   begin
      State.Grain   := State.Grain - Bus_Count (Amount);
      State.Starved := (if State.Population > Num_Fed then State.Population - Num_Fed else 0);
   end Feed_People;

   procedure Plant_Seeds (State : in out Game_State; Amount : Land_Area) is
      use Ada.Numerics.Float_Random;
      Needs : constant Bus_Count := Bus_Count (Amount / 2);
   begin
      State.Grain := State.Grain - Needs;
      
      -- Calculation of yield and rats for the next report
      State.Yield := Bus_Count (Random_Integer.Random (Int_Gen) mod 5 + 1);
      
      State.Rats_Ate := 0;
      if Random (Float_Gen) < 0.2 then
         declare
            Factor : constant Bus_Count := Bus_Count (Random_Integer.Random (Int_Gen) mod 4 + 2);
         begin
            State.Rats_Ate := State.Grain / Factor;
         end;
      end if;
      
      State.Grain := State.Grain + Bus_Count (Amount) * State.Yield - State.Rats_Ate;
   end Plant_Seeds;

   procedure Process_Yearly_Events (State : in out Game_State) is
      use Ada.Numerics.Float_Random;
   begin
      -- Plague
      State.Plague_Deaths := 0;
      if Random (Float_Gen) < 0.15 then
         State.Plague_Deaths := State.Population / 2;
         State.Population    := State.Population - State.Plague_Deaths;
      end if;

      -- Starvation check
      if Float (State.Starved) > Float (State.Population) * 0.45 then
         TIO.Put_Line ("YOU STARVED " & People_Count'Image (State.Starved) & " PEOPLE IN ONE YEAR!!!");
         TIO.Put_Line ("DUE TO THIS EXTREME MISMANAGEMENT, YOU HAVE BEEN IMPEACHED!");
         State.Year := 11;
         return;
      end if;

      State.Total_Starved := State.Total_Starved + State.Starved;
      State.Population    := State.Population - State.Starved;

      -- Immigration
      declare
         Imm : constant Integer := (Random_Integer.Random (Int_Gen) mod 5 + 1) * 
                                   (20 * Integer (State.Land) + Integer (State.Grain)) / 
                                   (Integer (State.Population) * 100 + 1);
      begin
         State.Immigrants := (if Imm > 0 then People_Count (Imm) else 0);
      end;
      State.Population := State.Population + State.Immigrants;

      -- Update land price for next year
      State.Land_Price := Bus_Count (Random_Integer.Random (Int_Gen) mod 10 + 17);
      
      State.Year := State.Year + 1;
   end Process_Yearly_Events;

   procedure Display_Final_Report (State : Game_State) is
   begin
      if State.Year = 11 then
         TIO.New_Line;
         TIO.Put_Line ("IN YOUR 10-YEAR TERM OF OFFICE, " & People_Count'Image (State.Total_Starved) & " PEOPLE STARVED.");
         TIO.Put_Line ("YOU ENDED WITH " & Land_Area'Image (State.Land) & " ACRES PER PERSON.");
         TIO.Put_Line ("SO LONG FOR NOW.");
      end if;
   end Display_Final_Report;

end Kingdom.Logic;
