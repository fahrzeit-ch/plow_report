$(document).on('turbolinks:load', function() {
    const editorSelector = '#editor';
    const containerSelector = '#siteInfo'
    const container = $(containerSelector);

    container.on('cocoon:after-insert', (e, insertedItem) => {
        applyEditor();
    });
    applyEditor();

    function applyEditor() {
        const contentInputField = $('#infoContent');
        const form = $(editorSelector).closest('form').on('submit', (e) => {
            setContent();
            return true;
        });
        const editor = new toastui.Editor({
            el: document.querySelector(editorSelector),
            height: '500px',
            initialValue: contentInputField.val(),
            initialEditType: 'wysiwyg',
            language: 'de',
            usageStatistics: false,
            hideModeSwitch: true
        });

        function setContent() {
            contentInputField.val(editor.getMarkdown());
        }
    }
});