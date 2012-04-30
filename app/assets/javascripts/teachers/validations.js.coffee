
jQuery ->
  $('#edit-login-email > form').isHappy {
    fields: {
      '#account_email': {
        required: 'sometimes',
        test: happy.validate.email,
        message: 'invalid e-mail address'
      }
    }
  }

  $('#edit-password > form').isHappy {
    fields: {
      '#account_password': {
        required: 'sometimes',
        test: happy.validate.password,
        message: 'should be at least 6 characters long'
      }

      '#account_password_confirmation': {
        required: 'sometimes',
        test: happy.validate.sameToSame,
        arg: '#account_password',
        message: 'must match password above'
      }
    }
  }

  $('#question-options > form').isHappy {
    fields: {
      '#quiz_name': {
        required: true,
        message: 'mandatory'
      }
    }
  }
