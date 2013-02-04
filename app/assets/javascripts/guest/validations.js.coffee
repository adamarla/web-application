############################################################################
## Bootstrap 
############################################################################

jQuery ->

  $('#testform').validate {
    rules: {
      "a[login]": { required: true }
      "a[password]": { required: true }
    }
  }

  $('#studentform').validate {
    rules: {
      "studentform[name]": {required: true},
      "studentform[email]": {required: true},
      "studentform[gradelevel]": {required: true},
      "studentform[school]": {required: true},
      "studentform[country]": {required: true},
    },
    highlight: (element, errorClass, validClass) ->
      alert 'invalidity'
      $(element).parents('.control-group').addClass('error')
    ,
    unhighlight: (element, errorClass, validClass) ->
      $(element).parents('.control-group').removeClass('error')
    ,
    errorClass: "help-inline",
    errorElement: "span"
  }

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
