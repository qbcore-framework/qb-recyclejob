local Translations = {
    success = {
        you_have_been_clocked_in = "تم تسجيل دخولك",
        sold = 'لقد بعت %{amount} %{item} مقابل $%{price}',
    },
    text = {
        point_enter_warehouse = "[E] دخول المستودع",
        enter_warehouse= "دخول المستودع",
        exit_warehouse= "مغادرة المستودع",
        point_exit_warehouse = "[E] مغادرة المستودع",
        toggle_duty = "تغيير الحالة",
        point_toggle_duty = "[E] تغيير الحالة",
        hand_in_package = "تسليم الطرد",
        point_hand_in_package = "[E] تسليم الطرد",
        get_package = "احصل على الطرد",
        point_get_package = "[E] احصل على الطرد",
        picking_up_the_package = "جاري التقاط الطرد",
        unpacking_the_package = "جاري فتح الطرد",
        clock_in = "تم تسجيل دخولك",
        clock_out = "تم تسجيل خروجك",
        sell_materials = "بيع المواد",
        point_sell_materials = "[E] بيع المواد",
        price = "السعر: $%{price}",
        amount = "الكمية",
        sell = "بيع",
    },
    error = {
        you_have_clocked_out = "تم تسجيل خروجك",
        nothing_to_sell = "ليس لديك شيء لتبيعه",
        out_of_stock = "%{item} غير متوفر",
        too_far_to_sell = "أنت بعيد جدًا لبيع المواد",
    },
}

if GetConvar('qb_locale', 'en') == 'ar' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end