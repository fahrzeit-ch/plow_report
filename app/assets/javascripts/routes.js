const positionSelector = 'input.position-attr';
const containerSelector = '#site-list-container';

$(document).on('turbolinks:load', function() {
    const container = $(containerSelector);

    container.on('cocoon:after-insert', (e, insertedItem) => {
        const positions = $('#site-list-container').find(positionSelector).toArray().map( (el) => el.value);
        const validPositions = positions.filter(pos => !isNaN(pos));
        const highest = Math.max(...validPositions);
        $(insertedItem).find(positionSelector).val(highest + 1);
    })

    const selected_sites = document.getElementById('selected_sites');
    Sortable.create(selected_sites, {
        ghostClass: 'drop-ghost',
        filter: '.no-drag',
        onEnd: (/**Event*/evt) => {
            updatePositions();
        },
    });

    function updatePositions() {
        let position = 1;
        container.find(positionSelector).each((index, el) => {
            $(el).val(position);
            position++;
        });
    }
});