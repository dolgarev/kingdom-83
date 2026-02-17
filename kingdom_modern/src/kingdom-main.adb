with Ada.Text_IO;
with Ada.Integer_Text_IO;
with Ada.Long_Integer_Text_IO;
with Kingdom.Logic;

procedure Kingdom.Main is

   use Kingdom.Logic;
   package TIO renames Ada.Text_IO;
   package IIO renames Ada.Integer_Text_IO;
   package LIIO renames Ada.Long_Integer_Text_IO;

   Game : Game_State;

   procedure Get_Amount (Prompt : String; Amount : out Integer) is
   begin
      TIO.Put (Prompt);
      IIO.Get (Amount);
   exception
      when others =>
         TIO.Skip_Line;
         raise Input_Error;
   end Get_Amount;

   procedure Purchase_Phase is
      Amount : Integer;
   begin
      loop
         begin
            Get_Amount ("HOW MANY ACRES DO YOU WISH TO BUY? ", Amount);
            if Amount < 0 then
               TIO.Put_Line ("HAMURABI: YOU CANNOT BUY NEGATIVE LAND!");
            elsif Can_Afford_Land (Game, Land_Area (Amount)) then
               Buy_Land (Game, Land_Area (Amount));
               exit;
            else
               TIO.Put_Line ("HAMURABI: THINK AGAIN. YOU DO NOT HAVE ENOUGH GRAIN.");
            end if;
         exception
            when Input_Error =>
               TIO.Put_Line ("HAMURABI: I DO NOT UNDERSTAND THAT NUMBER.");
         end;
      end loop;
   end Purchase_Phase;

   procedure Sale_Phase is
      Amount : Integer;
   begin
      loop
         begin
            Get_Amount ("HOW MANY ACRES DO YOU WISH TO SELL? ", Amount);
            if Amount < 0 then
               TIO.Put_Line ("HAMURABI: YOU CANNOT SELL NEGATIVE LAND!");
            elsif Has_Enough_Land (Game, Land_Area (Amount)) then
               Sell_Land (Game, Land_Area (Amount));
               exit;
            else
               TIO.Put_Line ("HAMURABI: THINK AGAIN. YOU DO NOT OWN THAT MUCH LAND.");
            end if;
         exception
            when Input_Error =>
               TIO.Put_Line ("HAMURABI: I DO NOT UNDERSTAND THAT NUMBER.");
         end;
      end loop;
   end Sale_Phase;

   procedure Feed_Phase is
      Amount : Long_Integer;
   begin
      loop
         begin
            TIO.Put ("HOW MANY BUSHELS DO YOU WISH TO FEED YOUR PEOPLE? ");
            LIIO.Get (Amount);
            if Amount < 0 then
               TIO.Put_Line ("HAMURABI: YOU CANNOT FEED THEM NEGATIVE GRAIN!");
            elsif Has_Enough_Grain (Game, Bushel_Count (Amount)) then
               Feed_People (Game, Bushel_Count (Amount));
               exit;
            else
               TIO.Put_Line ("HAMURABI: THINK AGAIN. YOU DO NOT HAVE THAT MUCH GRAIN.");
            end if;
         exception
            when others =>
               TIO.Skip_Line;
               TIO.Put_Line ("HAMURABI: I DO NOT UNDERSTAND THAT NUMBER.");
         end;
      end loop;
   end Feed_Phase;

   procedure Plant_Phase is
      Amount : Integer;
   begin
      loop
         begin
            Get_Amount ("HOW MANY ACRES DO YOU WISH TO PLANT WITH SEED? ", Amount);
            if Amount < 0 then
               TIO.Put_Line ("HAMURABI: YOU CANNOT PLANT NEGATIVE ACRES!");
            elsif not Has_Enough_Land (Game, Land_Area (Amount)) then
               TIO.Put_Line ("HAMURABI: THINK AGAIN. YOU OWN ONLY WHAT YOU OWN.");
            elsif not Has_Enough_Grain (Game, Bushel_Count (Amount / 2)) then
               TIO.Put_Line ("HAMURABI: THINK AGAIN. YOU HAVE NOT ENOUGH GRAIN.");
            elsif not Has_Enough_People (Game, Land_Area (Amount)) then
               TIO.Put_Line ("HAMURABI: BUT YOU HAVE NOT ENOUGH PEOPLE TO TEND THE FIELDS.");
            else
               Plant_Seeds (Game, Land_Area (Amount));
               exit;
            end if;
         exception
            when Input_Error =>
               TIO.Put_Line ("HAMURABI: I DO NOT UNDERSTAND THAT NUMBER.");
         end;
      end loop;
   end Plant_Phase;

begin
   TIO.Put_Line ("KINGDOM - THE MODERN SUMERIAN ADVENTURE");
   TIO.Put_Line ("BASED ON THE CLASSIC HAMURABI - ADA 2022 EDITION");

   Initialize (Game);

   while not Is_Finished (Game) loop
      Display_Status (Game);
      
      Purchase_Phase;
      
      if not Is_Finished (Game) then
         Sale_Phase;
         Feed_Phase;
         Plant_Phase;
         Process_Yearly_Events (Game);
      end if;
   end loop;

   Display_Final_Report (Game);

exception
   when others =>
      TIO.Put_Line ("HAMURABI: AN UNEXPECTED ERROR OCCURRED. THE KINGDOM FALLS.");
end Kingdom.Main;
