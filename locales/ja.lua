local Translations = {
    success = {
        you_have_been_clocked_in = '出勤しました',
        sold = '%{amount}個の%{item}を$%{price}で売却しました',
    },
    text = {
        point_enter_warehouse = '[E] 倉庫に入る',
        enter_warehouse = '倉庫に入る',
        exit_warehouse = '倉庫から出る',
        point_exit_warehouse = '[E] 倉庫から出る',
        toggle_duty = '出勤/退勤',
        point_toggle_duty = '[E] 出勤/退勤',
        hand_in_package = 'パッケージを渡す',
        point_hand_in_package = '[E] パッケージを渡す',
        get_package = 'パッケージを入手',
        point_get_package = '[E] パッケージを入手',
        picking_up_the_package = 'パッケージを取る',
        unpacking_the_package = 'パッケージを開封する',
        clock_in = '出勤しました',
        clock_out = '退勤しました',
        sell_materials = '素材を売却',
        point_sell_materials = '[E] 素材を売却',
        price = '価格: $%{price}',
        amount = '数量',
        sell = '売却',
    },
    error = {
        you_have_clocked_out = '退勤しました',
        nothing_to_sell = '売却できるものがありません',
        out_of_stock = '%{item} は在庫切れです',
        too_far_to_sell = '売却場所から離れすぎています',
    },
}

Lang = Lang or Locale:new({
    phrases = Translations,
    warnOnMissing = true
})
