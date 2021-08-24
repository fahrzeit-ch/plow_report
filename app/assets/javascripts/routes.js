$(document).on('turbolinks:load', function() {
    const selected_sites = document.getElementById('selected_sites');
    const available_sites = document.getElementById('available_sites');

    const selected_sortable = Sortable.create(selected_sites, {
        group: "shared",
        ghostClass: 'drop-ghost',
        filter: '.no-drag',
        dataIdAttr: 'data-id',
        onAdd: (event) => {
            hideInfoTargetList();
            createFormElement(event);
        },
        onRemove: (event) => {
            updateInfoStateTargetList();
        }
    });


    const available_sortable = Sortable.create(available_sites, {
        group: { name: "shared"},
        sort: false
    })

    function updateInfoStateTargetList() {
        if(selected_sortable.toArray().length === 0) {
            $('.drag-target-info').show();
        }
    }

    function hideInfoTargetList() {
        $('.drag-target-info').hide();
    }
});