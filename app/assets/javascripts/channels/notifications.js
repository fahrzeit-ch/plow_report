App.cable.subscriptions.create("NotificationChannel", {
    received(data) {
        if(data["update_element"]) {
            $(data["update_element"]["selector"]).replaceWith(data["update_element"]["replace_with"])
        }
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