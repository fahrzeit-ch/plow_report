$(document).on('turbolinks:load', function() {
   const selected_sites = document.getElementById('selected_sites');
   const available_sites = document.getElementById('available_sites');

   const selected_sortable = Sortable.create(selected_sites, {
        group: "shared",
        ghostClass: 'drop-ghost',
        filter: '.no-drag',
        onAdd: (event) => {

        },
        onRemove: (event) => {

        }
    });
    const available_sortable = Sortable.create(available_sites, {
        group: { name: "shared"},
        sort: false
    })


});