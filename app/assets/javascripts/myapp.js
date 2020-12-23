var ICQ = (function() {

    var status_update = function(data, tstatus, jqxhr) {
        if (ICQ.questionstatus === undefined) {
           ICQ.questionstatus = data.status; 
        }

        if (ICQ.questionstatus != data.status) {
            console.log("Modifying location");
            window.location = window.location.href;
        }
    };

    var monitor_question_status = function(ids) {
        var url = "/courses/" + ids[0] + "/questions/" + ids[1] + "/polls/" + ids[2] + "/status";

        // if no question is active, question/poll ids are both 0
        if (ids[1] == "0") {
            url = "/courses/" + ids[0] + "/status";
        }

        jQuery.ajax({
            'url': url,
            'dataType': 'json',
            'success': status_update,
        });

        setTimeout(monitor_question_status, 1000, ids);
    };

    return {
        init: function() {
            jQuery("#question_type").on('change', function() {
                if (jQuery("#question_type").val() == "MultiChoiceQuestion") {
                    jQuery("#question_qcontent").show();
                } else {
                    jQuery("#question_qcontent").hide();
                }
            });
            jQuery("#notify").on('ajax:success', function() {
                jQuery("#notify").removeClass("btn-warning");
                jQuery("#notify").addClass("btn-primary");
            });
            jQuery("#notify").on('ajax:failure', function() {
                jQuery("#notify").removeClass("btn-warning");
                jQuery("#notify").addClass("border-danger");
            });
            jQuery("#notify").on('click', function() {
                jQuery("#notify").removeClass("btn-primary");
                jQuery("#notify").addClass("btn-warning");
            });

            jQuery("#responseunfold").on('click', function() {
                jQuery("#responses").toggle();
            });
            jQuery("#showanswer").on('click', function() {
                jQuery(".answer").toggle();
            });
            if (document.getElementById("squestion") !== null) {
                var ids = jQuery("#squestion").attr('data-ids').split(/ /);
                if (ids.length == 3) {
                    monitor_question_status(ids);
                }
            }
        },
    }

}());
ICQ.questionstatus = undefined;

// window.addEventListener('DOMContentLoaded', ICQ.init);

jQuery(ICQ.init);
