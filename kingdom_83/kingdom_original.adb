with Text_IO;
use Text_IO;

procedure Kingdom is

   -- Ada 83 compatible basic types
   type Bushels is new Integer range -1000000 .. 1000000;
   type Acres is new Integer range 0 .. 1000000;
   type People is new Integer range 0 .. 1000000;

   package Int_IO is new Text_IO.Integer_IO (Integer);
   package Bush_IO is new Text_IO.Integer_IO (Bushels);
   package Acre_IO is new Text_IO.Integer_IO (Acres);
   package Peep_IO is new Text_IO.Integer_IO (People);

   -- Game State
   Year           : Integer := 1;
   Population     : People  := 100;
   Grain          : Bushels := 2800;
   Land           : Acres   := 1000;
   Yield          : Bushels := 3;
   Rats_Ate       : Bushels := 200;
   Land_Price     : Bushels := 19;
   Starved        : People  := 0;
   Immigrants     : People  := 5;
   Plague_Deaths  : People  := 0;
   Total_Starved  : People  := 0;

   -- Random Number Generator (Simple LCG for Ada 83)
   Seed : Integer := 12345;
   function Random return Float is
      M : constant Integer := 32768;
      A : constant Integer := 11035;
      C : constant Integer := 12345;
   begin
      Seed := (A * Seed + C) rem M;
      if Seed < 0 then
         Seed := Seed + M;
      end if;
      return Float (Seed) / Float (M);
   end Random;

   function Random_Range (Low, High : Integer) return Integer is
   begin
      return Low + Integer (Random * Float (High - Low + 1) - 0.5);
   end Random_Range;

   function Random_Range_Bush (Low, High : Integer) return Bushels is
   begin
      return Bushels (Random_Range (Low, High));
   end Random_Range_Bush;

   procedure Print_Status is
   begin
      New_Line;
      Put ("HAMURABI: I BEG TO REPORT TO YOU,"); New_Line;
      Put ("IN YEAR "); Int_IO.Put (Year, 0);
      Put (", "); Peep_IO.Put (Starved, 0);
      Put (" PEOPLE STARVED, "); Peep_IO.Put (Immigrants, 0);
      Put (" CAME TO THE CITY."); New_Line;

      if Plague_Deaths > 0 then
         Put ("A HORRIBLE PLAGUE STRUCK! ");
         Peep_IO.Put (Plague_Deaths, 0);
         Put (" PEOPLE DIED."); New_Line;
      end if;

      Put ("POPULATION IS NOW "); Peep_IO.Put (Population, 0); New_Line;
      Put ("THE CITY NOW OWNS "); Acre_IO.Put (Land, 0);
      Put (" ACRES."); New_Line;
      Put ("YOU HARVESTED "); Bush_IO.Put (Yield, 0);
      Put (" BUSHELS PER ACRE."); New_Line;
      Put ("RATS ATE "); Bush_IO.Put (Rats_Ate, 0);
      Put (" BUSHELS."); New_Line;
      Put ("YOU NOW HAVE "); Bush_IO.Put (Grain, 0);
      Put (" BUSHELS IN STORE."); New_Line; New_Line;
   end Print_Status;

   procedure Buy_Land is
      Amount : Acres;
      Price  : Bushels;
   begin
      Land_Price := Random_Range_Bush (17, 26);
      Put ("LAND IS SELLING AT "); Bush_IO.Put (Land_Price, 0);
      Put (" BUSHELS PER ACRE."); New_Line;
      loop
         Put ("HOW MANY ACRES DO YOU WISH TO BUY? ");
         Acre_IO.Get (Amount);
         Price := Bushels (Integer (Amount)) * Land_Price;
         if Price <= Grain then
            Land := Land + Amount;
            Grain := Grain - Price;
            exit;
         else
            Put ("HAMURABI: THINK AGAIN. YOU HAVE ONLY ");
            Bush_IO.Put (Grain, 0);
            Put (" BUSHELS OF GRAIN."); New_Line;
         end if;
      end loop;
   end Buy_Land;

   procedure Sell_Land is
      Amount : Acres;
   begin
      if Land = 0 then return; end if;
      loop
         Put ("HOW MANY ACRES DO YOU WISH TO SELL? ");
         Acre_IO.Get (Amount);
         if Amount <= Land then
            Land := Land - Amount;
            Grain := Grain + Bushels (Integer (Amount)) * Land_Price;
            exit;
         else
            Put ("HAMURABI: THINK AGAIN. YOU OWN ONLY ");
            Acre_IO.Put (Land, 0);
            Put (" ACRES."); New_Line;
         end if;
      end loop;
   end Sell_Land;

   procedure Feed_People is
      Amount : Bushels;
   begin
      loop
         Put ("HOW MANY BUSHELS DO YOU WISH TO FEED YOUR PEOPLE? ");
         Bush_IO.Get (Amount);
         if Amount <= Grain then
            Grain := Grain - Amount;
            -- Each person needs 20 bushels to not starve
            Starved := Population - People (Integer (Amount) / 20);
            if Starved < 0 then Starved := 0; end if;
            exit;
         else
            Put ("HAMURABI: THINK AGAIN. YOU HAVE ONLY ");
            Bush_IO.Put (Grain, 0);
            Put (" BUSHELS OF GRAIN."); New_Line;
         end if;
      end loop;
   end Feed_People;

   procedure Plant_Seeds is
      Amount : Acres;
      Needs  : Bushels;
   begin
      loop
         Put ("HOW MANY ACRES DO YOU WISH TO PLANT WITH SEED? ");
         Acre_IO.Get (Amount);
         Needs := Bushels (Integer (Amount) / 2); -- 1 bushel plants 2 acres
         if Amount > Land then
            Put ("HAMURABI: THINK AGAIN. YOU OWN ONLY ");
            Acre_IO.Put (Land, 0);
            Put (" ACRES."); New_Line;
         elsif Needs > Grain then
            Put ("HAMURABI: THINK AGAIN. YOU HAVE ONLY ");
            Bush_IO.Put (Grain, 0);
            Put (" BUSHELS OF GRAIN."); New_Line;
         elsif People (Integer (Amount) / 10) > Population then
            Put ("HAMURABI: BUT YOU HAVE ONLY ");
            Peep_IO.Put (Population, 0);
            Put (" PEOPLE TO TEND THE FIELDS."); New_Line;
         else
            Grain := Grain - Needs;
            Yield := Random_Range_Bush (1, 5);
            Rats_Ate := 0;
            if Random < 0.2 then
               Rats_Ate := Grain / Bushels (Random_Range (2, 5));
            end if;
            Grain := Grain + Bushels (Integer (Amount)) * Yield - Rats_Ate;
            exit;
         end if;
      end loop;
   end Plant_Seeds;

   procedure Process_Events is
   begin
      -- Plague
      Plague_Deaths := 0;
      if Random < 0.15 then
         Plague_Deaths := Population / 2;
         Population := Population - Plague_Deaths;
      end if;

      -- Starvation check
      if Starved > People (Float (Integer (Population)) * 0.45) then
         Put ("YOU STARVED "); Peep_IO.Put (Starved, 0);
         Put (" PEOPLE IN ONE YEAR!!!"); New_Line;
         Put ("DUE TO THIS EXTREME MISMANAGEMENT, YOU HAVE NOT ONLY"); New_Line;
         Put ("BEEN IMPEACHED AND THROWN OUT OF OFFICE BUT YOU HAVE"); New_Line;
         Put ("ALSO BEEN DECLARED PERSONA NON GRATA!!"); New_Line;
         Year := 11; -- End game
         return;
      end if;

      Total_Starved := Total_Starved + Starved;
      Population := Population - Starved;

      -- Immigration
      Immigrants := People (Random_Range (1, 5) * (20 * Integer (Land) + Integer (Grain)) / (Integer (Population) * 100 + 1));
      if Immigrants < 0 then Immigrants := 0; end if;
      Population := Population + Immigrants;

   end Process_Events;

begin
   Put_Line ("KINGDOM - THE GAME OF SUMERIA");
   Put_Line ("BASED ON THE CLASSIC HAMURABI");

   while Year <= 10 loop
      Print_Status;
      Buy_Land;
      if Year <= 10 then -- Check if still in game
         Sell_Land;
         Feed_People;
         Plant_Seeds;
         Process_Events;
         Year := Year + 1;
      end if;
   end loop;

   if Year = 11 then
      New_Line;
      Put ("IN YOUR 10-YEAR TERM OF OFFICE, ");
      Peep_IO.Put (Total_Starved, 0);
      Put (" PEOPLE STARVED."); New_Line;
      Put ("YOU ENDED WITH "); Acre_IO.Put (Land, 0);
      Put (" ACRES PER PERSON."); New_Line;
      Put_Line ("SO LONG FOR NOW.");
   end if;

exception
   when Data_Error =>
      Put_Line ("HAMURABI: I DO NOT UNDERSTAND THAT NUMBER.");
   when Others =>
      Put_Line ("HAMURABI: AN UNEXPECTED ERROR OCCURRED. GOODBYE.");
end Kingdom;
