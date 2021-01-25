App.cable.subscriptions.create("NotificationChannel", {
    received(data) {
        toastr.info(data["body"], data["title"]);
    }
})