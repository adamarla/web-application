
jQuery ->
  $('#try-us form').isHappy {
    fields: {
      '#trial_name': {
        required: true,
        message: 'mandatory'
      }

      '#trial_email': {
        required: true,
        message: 'mandatory'
      }

      '#trial_email_confirm': {
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
        required: 'sometimes',
        test: happy.validate.email,
        message: 'invalid e-mail'
      }

      '#trial_email_confirm': {
        required: 'sometimes',
        test: happy.validate.sameToSame,
        arg: '#trial_email',
        message: 'must match e-mail above'
      }

    }
  }
