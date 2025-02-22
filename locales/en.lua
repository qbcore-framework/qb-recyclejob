local Translations = {
    success = {
        you_have_been_clocked_in = "You Have Been Clocked In",
        sold = 'You Have Sold %{amount} %{item} For $%{price}',
    },
    text = {
        point_enter_warehouse = "[E] Enter Warehouse",
        enter_warehouse= "Enter Warehouse",
        exit_warehouse= "Exit Warehouse",
        point_exit_warehouse = "[E] Exit Warehouse",
        toggle_duty = "Toggle Duty",
        point_toggle_duty = "[E] Toggle Duty",
        hand_in_package = "Hand In Package",
        point_hand_in_package = "[E] Hand In Package",
        get_package = "Get Package",
        point_get_package = "[E] Get Package",
        picking_up_the_package = "Picking up the package",
        unpacking_the_package = "Unpacking the package",
        clock_in = "You Have Clocked In",
        clock_out = "You Have Clocked Out",
        sell_materials = "Sell Materials",
        point_sell_materials = "[E] Sell Materials",
        price = "Price: $%{price}",
        amount = "Amount",
        sell = "Sell",
    },
    error = {
        you_have_clocked_out = "You Have Clocked Out",
        nothing_to_sell = "You Have Nothing To Sell",
        out_of_stock = "%{item} Is Out Of Stock",
        too_far_to_sell = "You Are Too Far Away To Sell",
    },
}

Lang = Lang or Locale:new({
    phrases = Translations,
    warnOnMissing = true
})