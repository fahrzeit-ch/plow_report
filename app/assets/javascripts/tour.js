//= require enjoyhint/enjoyhint.min

//run Enjoyhint script
$(document).on('turbolinks:load', function () {

    //initialize instance
    var enjoyhint_instance = new EnjoyHint({});

    //simple config.
    //Only one step - highlighting(with description) "New" button
    //hide EnjoyHint after a click on the button.
    var enjoyhint_script_steps = [
        {
            'next #drive_start' : 'Set start date of your drive'
        },
        {
            'click #drive_end' : 'Enter end date of your drive'
        }
    ];

    //set script config
    enjoyhint_instance.set(enjoyhint_script_steps);


    enjoyhint_instance.run();

});
