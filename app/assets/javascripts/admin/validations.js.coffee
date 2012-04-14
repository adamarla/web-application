
jQuery ->
  $('#new-teacher > form:first').isHappy {
    fields : {
      '#teacher_name': {
        required : true,
        message : 'need the full name here'
      }
    }
  }

  $('#new-school > form').isHappy {
    fields: {
      '#school_name': {
        required: true,
        message: 'required'
      }
      '#school_tag': {
        required: true,
        message: 'required'
      }
      '#school_zip_code': {
        required: true,
        message: 'required'
      }
      '#school_board_id': {
        required: true,
        message: 'required'
      }
      '#school_email': {
        required: true,
        test: happy.validate.email,
        message: 'invalid e-mail address'
      }
    }
  }

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
  
###
  $('#misc-traits > form').isHappy {
    fields: {
      '#misc_marks': {
        required: 'sometimes',
        test: happy.validate.notBlank,
        message: 'required'
      }

      '#misc_page_length': {
        required: 'sometimes',
        test: happy.validate.notBlank,
        message: 'required'
      }
    }
  }
###
  



