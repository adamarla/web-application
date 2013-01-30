############################################################################
## Bootstrap 
############################################################################

jQuery ->

  $('#studentform').validate
    rules: {
      inputName: {required: true},
      inputEmail: {required:true, email: true},
      inputGradeLevel: {required:true, maxlength: 2},
      inputSchool: {required:true, minlength: 2},
      inputCountry: {required:true, minlength: 1}
    },
    messages: {
      inputName: "Please provide a name",
      inputEmail: "Email is mandatory",
      inputGradeLevel: "Please choose a Grade Level",
      inputSchool: "Please provide your School's name",
      inputCountry: "Please specify your country of residence",
    }
    highlight: (label) ->
      $(label).closest('.control-group').addClass('error')
    ,
    unhighlight: (label) ->
      $(label).closest('.control-group').removeClass('error')
    ,
    errorClass: "help-inline",
    errorElement: "span"

  $('#try-us form').isHappy {
    fields: {
      '#trial_name': {
        required: true,
        message: 'mandatory'
      }

      '#trial_school': {
        required: true,
        message: 'mandatory'
      }

      '#trial_zip_code': {
        required: true,
        message: 'mandatory'
      }

      '#trial_country_input > input': {
        required: true,
        message: 'mandatory'
      }

      '#trial_email': {
        required: true,
        test: happy.validate.email,
        message: 'invalid e-mail'
      }

      '#trial_email_confirm': {
        required: true,
        test: happy.validate.sameToSame,
        arg: '#trial_email',
        message: 'must match e-mail above'
      }
    }
  }
