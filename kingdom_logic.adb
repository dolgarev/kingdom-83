with Text_IO;

package body Kingdom_Logic is

   package Int_IO is new Text_IO.Integer_IO (Integer);
   package Bush_IO is new Text_IO.Integer_IO (Bushels);
   package Acre_IO is new Text_IO.Integer_IO (Acres);
   package Peep_IO is new Text_IO.Integer_IO (People);

   -- Internal Random Number Generator (LCG)
   function Random (Seed : in out Integer) return Float is
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

   function Random_Range (Seed : in out Integer; Low, High : Integer) return Integer is
   begin
      return Low + Integer (Random (Seed) * Float (High - Low + 1) - 0.5);
   end Random_Range;

   function Random_Range_Bush (Seed : in out Integer; Low, High : Integer) return Bushels is
   begin
      return Bushels (Random_Range (Seed, Low, High));
   end Random_Range_Bush;

   procedure Initialize (State : in out Game_State) is
   begin
      State.Year           := 1;
      State.Population     := 100;
      State.Grain          := 2800;
      State.Land           := 1000;
      State.Yield          := 3;
      State.Rats_Ate       := 200;
      State.Land_Price     := 19;
      State.Starved        := 0;
      State.Immigrants     := 5;
      State.Plague_Deaths  := 0;
      State.Total_Starved  := 0;
      State.Seed           := 12345;
   end Initialize;

   procedure Show_Status (State : in Game_State) is
      use Text_IO;
   begin
      New_Line;
      Put ("HAMURABI: I BEG TO REPORT TO YOU,"); New_Line;
      Put ("IN YEAR "); Int_IO.Put (State.Year, 0);
      Put (", "); Peep_IO.Put (State.Starved, 0);
      Put (" PEOPLE STARVED, "); Peep_IO.Put (State.Immigrants, 0);
      Put (" CAME TO THE CITY."); New_Line;

      if State.Plague_Deaths > 0 then
         Put ("A HORRIBLE PLAGUE STRUCK! ");
         Peep_IO.Put (State.Plague_Deaths, 0);
         Put (" PEOPLE DIED."); New_Line;
      end if;

      Put ("POPULATION IS NOW "); Peep_IO.Put (State.Population, 0); New_Line;
      Put ("THE CITY NOW OWNS "); Acre_IO.Put (State.Land, 0);
      Put (" ACRES."); New_Line;
      Put ("YOU HARVESTED "); Bush_IO.Put (State.Yield, 0);
      Put (" BUSHELS PER ACRE."); New_Line;
      Put ("RATS ATE "); Bush_IO.Put (State.Rats_Ate, 0);
      Put (" BUSHELS."); New_Line;
      Put ("YOU NOW HAVE "); Bush_IO.Put (State.Grain, 0);
      Put (" BUSHELS IN STORE."); New_Line; New_Line;
   end Show_Status;

   procedure Buy_Land (State : in out Game_State) is
      use Text_IO;
      Amount : Acres;
      Price  : Bushels;
   begin
      State.Land_Price := Random_Range_Bush (State.Seed, 17, 26);
      Put ("LAND IS SELLING AT "); Bush_IO.Put (State.Land_Price, 0);
      Put (" BUSHELS PER ACRE."); New_Line;
      loop
         Put ("HOW MANY ACRES DO YOU WISH TO BUY? ");
         Acre_IO.Get (Amount);
         Price := Bushels (Integer (Amount)) * State.Land_Price;
         if Price <= State.Grain then
            State.Land := State.Land + Amount;
            State.Grain := State.Grain - Price;
            exit;
         else
            Put ("HAMURABI: THINK AGAIN. YOU HAVE ONLY ");
            Bush_IO.Put (State.Grain, 0);
            Put (" BUSHELS OF GRAIN."); New_Line;
         end if;
      end loop;
   end Buy_Land;

   procedure Sell_Land (State : in out Game_State) is
      use Text_IO;
      Amount : Acres;
   begin
      if State.Land = 0 then return; end if;
      loop
         Put ("HOW MANY ACRES DO YOU WISH TO SELL? ");
         Acre_IO.Get (Amount);
         if Amount <= State.Land then
            State.Land := State.Land - Amount;
            State.Grain := State.Grain + Bushels (Integer (Amount)) * State.Land_Price;
            exit;
         else
            Put ("HAMURABI: THINK AGAIN. YOU OWN ONLY ");
            Acre_IO.Put (State.Land, 0);
            Put (" ACRES."); New_Line;
         end if;
      end loop;
   end Sell_Land;

   procedure Feed_People (State : in out Game_State) is
      use Text_IO;
      Amount : Bushels;
   begin
      loop
         Put ("HOW MANY BUSHELS DO YOU WISH TO FEED YOUR PEOPLE? ");
         Bush_IO.Get (Amount);
         if Amount <= State.Grain then
            State.Grain := State.Grain - Amount;
            State.Starved := State.Population - People (Integer (Amount) / 20);
            if State.Starved < 0 then State.Starved := 0; end if;
            exit;
         else
            Put ("HAMURABI: THINK AGAIN. YOU HAVE ONLY ");
            Bush_IO.Put (State.Grain, 0);
            Put (" BUSHELS OF GRAIN."); New_Line;
         end if;
      end loop;
   end Feed_People;

   procedure Plant_Seeds (State : in out Game_State) is
      use Text_IO;
      Amount : Acres;
      Needs  : Bushels;
   begin
      loop
         Put ("HOW MANY ACRES DO YOU WISH TO PLANT WITH SEED? ");
         Acre_IO.Get (Amount);
         Needs := Bushels (Integer (Amount) / 2);
         if Amount > State.Land then
            Put ("HAMURABI: THINK AGAIN. YOU OWN ONLY ");
            Acre_IO.Put (State.Land, 0);
            Put (" ACRES."); New_Line;
         elsif Needs > State.Grain then
            Put ("HAMURABI: THINK AGAIN. YOU HAVE ONLY ");
            Bush_IO.Put (State.Grain, 0);
            Put (" BUSHELS OF GRAIN."); New_Line;
         elsif People (Integer (Amount) / 10) > State.Population then
            Put ("HAMURABI: BUT YOU HAVE ONLY ");
            Peep_IO.Put (State.Population, 0);
            Put (" PEOPLE TO TEND THE FIELDS."); New_Line;
         else
            State.Grain := State.Grain - Needs;
            State.Yield := Random_Range_Bush (State.Seed, 1, 5);
            State.Rats_Ate := 0;
            if Random (State.Seed) < 0.2 then
               State.Rats_Ate := State.Grain / Bushels (Random_Range (State.Seed, 2, 5));
            end if;
            State.Grain := State.Grain + Bushels (Integer (Amount)) * State.Yield - State.Rats_Ate;
            exit;
         end if;
      end loop;
   end Plant_Seeds;

   procedure Process_Year (State : in out Game_State) is
      use Text_IO;
   begin
      -- Plague
      State.Plague_Deaths := 0;
      if Random (State.Seed) < 0.15 then
         State.Plague_Deaths := State.Population / 2;
         State.Population := State.Population - State.Plague_Deaths;
      end if;

      -- Starvation check
      if State.Starved > People (Float (Integer (State.Population)) * 0.45) then
         Put ("YOU STARVED "); Peep_IO.Put (State.Starved, 0);
         Put (" PEOPLE IN ONE YEAR!!!"); New_Line;
         Put ("DUE TO THIS EXTREME MISMANAGEMENT, YOU HAVE NOT ONLY"); New_Line;
         Put ("BEEN IMPEACHED AND THROWN OUT OF OFFICE BUT YOU HAVE"); New_Line;
         Put ("ALSO BEEN DECLARED PERSONA NON GRATA!!"); New_Line;
         State.Year := 11; -- End game
         return;
      end if;

      State.Total_Starved := State.Total_Starved + State.Starved;
      State.Population := State.Population - State.Starved;

      -- Immigration
      State.Immigrants := People (Random_Range (State.Seed, 1, 5) * 
                          (20 * Integer (State.Land) + Integer (State.Grain)) / 
                          (Integer (State.Population) * 100 + 1));
      if State.Immigrants < 0 then State.Immigrants := 0; end if;
      State.Population := State.Population + State.Immigrants;
      
      State.Year := State.Year + 1;
   end Process_Year;

   function Is_Finished (State : in Game_State) return Boolean is
   begin
      return State.Year > 10;
   end Is_Finished;

   procedure Show_Final_Report (State : in Game_State) is
      use Text_IO;
   begin
      if State.Year = 11 then
         New_Line;
         Put ("IN YOUR 10-YEAR TERM OF OFFICE, ");
         Peep_IO.Put (State.Total_Starved, 0);
         Put (" PEOPLE STARVED."); New_Line;
         Put ("YOU ENDED WITH "); Acre_IO.Put (State.Land, 0);
         Put (" ACRES PER PERSON."); New_Line;
         Put_Line ("SO LONG FOR NOW.");
      end if;
   end Show_Final_Report;

end Kingdom_Logic;
