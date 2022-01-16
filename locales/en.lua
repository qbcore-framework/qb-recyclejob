local Translations = {
    info = {
        recycle_center = 'Recycle Center',
        enter_recycle = '~g~E~w~ - To Enter',
        exit_recycle = '~g~E~w~ - To Go Outside',
        clock_out = '~g~E~w~ - Clock Out',
        clock_in = '~g~E~w~ -  Clock In',
        pack_package = '~g~E~w~ - Pack Package',
        package = 'Package',
        hand_in_package_3d = '~g~E~w~ - Hand In The Package',
        hand_in = 'Hand In'
    },
    success = {
        clocked_in = 'You Have Been Clocked In',
    },
    error = {
        clocked_out = 'You Have Clocked Out',
    },
    progress = {
        picking_package = 'Picking Up Package...',
        unpack_package = 'Unpacking Package...'
    }
}

Lang = Locale:new({
    phrases = Translations,
    warnOnMissing = true
})