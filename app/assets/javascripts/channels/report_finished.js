$(document).on('turbolinks:load', function() {
    $("[data-report-generating]").each(function() {
        const reportId = $(this).data("report-generating")
        App.cable.subscriptions.create({
            channel: "ReportFinishedChannel",
            id: reportId
        }, {
            received(data) {
                Rails.ajax({
                    type: 'get',
                    url: data["path"],
                    dataType: 'script'
                });
            }
        });
    });
});