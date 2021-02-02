App.cable.subscriptions.create("NotificationChannel", {
    received(data) {
        toastr.info(
            data["body"],
            data["title"],
            {
                "onclick": function() {
                    if(data["link_to"]) {
                        Turbolinks.visit(data["link_to"])
                    }
                },
                timeOut: 0,
                extendedTimeout: 0,
                closeButton: true,
                "onShown": function () {
                    $(this).on('click', 'a', function (e) {
                        e.stopPropagation();
                    });
                }
            });
    }
})